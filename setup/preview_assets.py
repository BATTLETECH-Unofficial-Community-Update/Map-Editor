"""UCU Map Kit: bring the Game-view preview's assets into a kit project.

Copies the GUID closure of the given roots (the player's camera prefab, the biome's moods) from an AssetRipper export
into the project, keeping the export's GUIDs. Files already in the project (same path or same GUID) are not
touched, so earlier setup steps (shader switch, texture payloads) stay as they are. ShaderAssets (`--- !u!48`) are not
copied: references to them are pointed at the recovered shader of the same name in Assets/Resources/hbs-shaders or the kit's own
Shaders/Resources/hbs-shaders (with `type: 3`, see tools/shader-recovery/rewrite_type3.py; `rewrite_shader_refs` below, also used by
import_closure.py), and names with no recovered shader are listed as gaps. The
player's compute shaders, which the camera needs and AssetRipper does not export, are copied from UCU's
Project/Assets/Shaders/bundle with their metas. Code GUIDs (Scripts/, Plugins/, .dll) are left to the script binding.

usage (Editor closed):
  py -3 preview_assets.py <export Assets> <project root> <ucu repo> <report dir> [--apply] <root> [<root> ...]
<root> is relative to <export Assets>, e.g. Resources/internal/GameCamera.prefab. Without --apply nothing is written
except the report.
"""
import os, re, shutil, sys, collections

GUID = re.compile(rb'guid: ([0-9a-f]{32})')
CODE = ('Scripts/', 'Plugins/')
COMPUTE = ('ClusteredLighting', 'MaterialIDTile', 'VolumetricIntegration')


def meta_guid(meta):
    with open(meta, encoding='utf-8', errors='replace') as h:
        for l in h:
            if l.startswith('guid:'):
                return l.split()[1]


def index(assets):
    out = {}
    for d, _, fs in os.walk(assets):
        for f in fs:
            if f.endswith('.meta'):
                g = meta_guid(os.path.join(d, f))
                if g:
                    out[g] = os.path.relpath(os.path.join(d, f[:-5]), assets).replace(os.sep, '/')
    return out


def is_shader_asset(path):
    with open(path, 'rb') as h:
        return b'--- !u!48 ' in h.read(200)


def shader_asset_name(path):
    with open(path, encoding='utf-8', errors='replace') as h:
        for l in h:
            m = re.match(r'^  m_Name: (.+)$', l.rstrip('\r\n'))
            if m:
                return m.group(1).strip()


def recovered(project_assets):
    """Shader name -> GUIDs of the recovered .shader files: the project's own Resources/hbs-shaders and the kit package's
    Shaders/Resources/hbs-shaders (SHD1)."""
    roots = [os.path.join(project_assets, 'Resources', 'hbs-shaders'),
             os.path.join(os.path.dirname(project_assets), 'Packages', 'com.ucu.mapkit', 'Shaders', 'Resources', 'hbs-shaders')]
    out = collections.defaultdict(list)
    for root in roots:
        for d, _, fs in os.walk(root):
            for f in fs:
                if f.endswith('.shader'):
                    p = os.path.join(d, f)
                    m = re.search(r'^\s*Shader\s+"([^"]+)"', open(p, encoding='utf-8', errors='replace').read(), re.M)
                    if m:
                        out[m.group(1)].append(meta_guid(p + '.meta'))
    return out


def rewrite_shader_refs(data, remap):
    """Bytes of a YAML asset with every reference to a GUID in `remap` (old -> new) pointed at the new GUID with `type: 3`
    (a .shader behind `type: 2` resolves to the error shader). Returns (bytes, references rewritten)."""
    if not remap or data[:5] != b'%YAML':
        return data, 0
    pat = re.compile(rb'guid: (' + b'|'.join(g.encode() for g in remap) + rb'), type: \d\}')
    return pat.subn(lambda m: b'guid: ' + remap[m.group(1).decode()].encode() + b', type: 3}', data)


def closure(src, idx, roots):
    seen, files, shaders, missing = set(), [], {}, collections.Counter()
    todo = list(roots)
    while todo:
        rel = todo.pop()
        if rel in seen:
            continue
        seen.add(rel)
        p = os.path.normpath(os.path.join(src, rel))  # normpath: an extended-length root (\?\) does not take forward slashes
        if os.path.isdir(p):
            continue
        if is_shader_asset(p):
            shaders[rel] = shader_asset_name(p)
            continue
        files.append(rel)
        with open(p, 'rb') as h:
            if h.read(5) != b'%YAML':
                continue
        for g in GUID.findall(open(p, 'rb').read()):
            g = g.decode()
            if g.startswith('0000000000000000'):
                continue
            t = idx.get(g)
            if t is None:
                missing[g] += 1
            elif not (t.startswith(CODE) or t.endswith('.dll')):
                todo.append(t)
    return files, shaders, missing


def main(argv):
    apply = '--apply' in argv
    argv = [a for a in argv if a != '--apply']
    src, proj, ucu, report = argv[:4]
    roots = argv[4:]
    dst = os.path.join(proj, 'Assets')
    os.makedirs(report, exist_ok=True)
    idx = index(src)
    have = index(dst)
    have_paths = set(have.values())
    files, shaders, missing = closure(src, idx, roots)

    # ShaderAsset GUID -> recovered shader GUID by name; a stand-in already in the project keeps its GUID.
    rec = recovered(dst)
    guid_of = {rel: g for g, rel in idx.items()}
    remap, gaps = {}, []
    with open(os.path.join(report, 'preview-shaders.tsv'), 'w', encoding='utf-8', newline='\n') as w:
        w.write('export_guid\tname\tstate\tproject_guid\n')
        for rel, name in sorted(shaders.items(), key=lambda x: x[1] or ''):
            g = guid_of[rel]
            r = rec.get(name, [])
            if len(r) == 1:
                remap[g] = r[0]; state = 'recovered'
            elif g in have:
                remap[g] = g; state = 'project-standin'
            else:
                gaps.append(name); state = 'GAP-no-recovered-shader' if not r else f'GAP-{len(r)}-same-name'
            w.write(f"{g}\t{name}\t{state}\t{remap.get(g, '-')}\n")

    copy, skip = [], collections.Counter()
    for rel in files:
        g = guid_of.get(rel)
        if rel in have_paths:
            skip['same-path'] += 1
        elif g in have:
            skip['same-guid-other-path'] += 1
        else:
            copy.append(rel)
    size = sum(os.path.getsize(os.path.join(src, r)) + os.path.getsize(os.path.join(src, r + '.meta')) for r in copy)
    with open(os.path.join(report, 'preview-closure.tsv'), 'w', encoding='utf-8', newline='\n') as w:
        w.write('rel\tbytes\taction\n')
        for rel in files:
            w.write(f"{rel}\t{os.path.getsize(os.path.join(src, rel))}\t{'copy' if rel in copy else 'skip'}\n")
    with open(os.path.join(report, 'preview-missing.tsv'), 'w', encoding='utf-8', newline='\n') as w:
        for g, n in missing.most_common():
            w.write(f"{g}\t{n}\n")

    comp_src = os.path.join(ucu, 'Project', 'Assets', 'Shaders', 'bundle')
    comp_dst = os.path.join(dst, 'MapKitCompute')
    comp = [c for c in COMPUTE if not os.path.exists(os.path.join(comp_dst, c + '.compute'))]

    rewrites = 0
    if apply:
        for rel in copy:
            s, d = os.path.join(src, rel), os.path.join(dst, rel)
            os.makedirs(os.path.dirname(d), exist_ok=True)
            shutil.copyfile(s + '.meta', d + '.meta')
            b = open(s, 'rb').read()
            b, k = rewrite_shader_refs(b, remap)
            rewrites += k
            open(d, 'wb').write(b)
            folder = os.path.dirname(rel)
            while folder:  # folder metas, so Unity keeps the export's folder GUIDs
                m, t = os.path.join(src, folder + '.meta'), os.path.join(dst, folder + '.meta')
                if os.path.exists(m) and not os.path.exists(t):
                    shutil.copyfile(m, t)
                folder = os.path.dirname(folder)
        os.makedirs(comp_dst, exist_ok=True)
        for c in comp:
            for ext in ('.compute', '.compute.meta'):
                shutil.copyfile(os.path.join(comp_src, c + ext), os.path.join(comp_dst, c + ext))

    print(f"{'applied' if apply else 'dry run'}: roots={len(roots)} closure={len(files)} copy={len(copy)} bytes={size} "
          f"skip={dict(skip)} unresolved-guids={len(missing)}")
    print(f"shader assets={len(shaders)} remapped={len(remap)} gaps={len(gaps)} {sorted(set(n for n in gaps if n))}")
    print(f"compute to copy={comp} refs rewritten={rewrites}")


if __name__ == '__main__':
    main(sys.argv[1:])
