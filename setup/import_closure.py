# Map-kit D2-b: copy one scene's GUID closure (assets with their metas) from an AssetRipper export into a project, and
# bind the export's script GUIDs to the decompiled UCU code. Run with the Editor closed. (Moved from the D2-b run folder in
# KR1g, which added a second map to a project with it.)
#   import_closure.py copy <export Assets> <closure.tsv> <project Assets>     (ShaderAssets are not copied: the materials it writes are pointed at UCU's shaders)
#   import_closure.py bind <export Assets> <project Assets> <report.tsv>
#   import_closure.py bind shaders <project Assets> [<closure.tsv> ...]       (the shader binding again over maps already imported; no closure = every material)
#   import_closure.py pin  <closure.tsv> <project Assets>                     (the texture pin again over a map already imported)
# Shader binding: retail materials name their shader by the GUID Mapkit Asset Manager gave it, which is the MD5 of
# the shader's file and path ID in the retail data (SHD0). The kit ships UCU's recovered shaders (Shaders/Resources/hbs-shaders,
# setup/install_shaders.py), whose GUIDs are UCU's own. setup/shader-map.tsv pairs the two by shader name, and every material the copy
# writes (or `bind shaders` finds) gets `m_Shader` pointed at UCU's GUID with `type: 3` (a .shader behind `type: 2` is the error shader).
# Shaders the kit does not ship stay as they were and are listed as gaps.
# Texture pin (KR2, TEX1): AssetRipper writes each texture's retail format as the top-level `textureFormat:` of the TextureImporter
# but no platform override, so Unity re-encodes the PNG with its default (BC7 at compression 2) and HBS code that tests
# `format == DXT5` (TerrainMaterialSetup.UpdateTerrainTextures) logs an Error. Every texture meta the copy writes, or `pin` finds,
# gets a Standalone platform override with overridden: 1 and that retail format, as UCU's tracked metas do. The pixels are still
# Unity's encode of the PNG, not retail's payload byte for byte.
import os, re, sys, shutil, collections, csv


def lp(p):  # extended-length path: a plain path past 259 characters fails to open on Windows with LongPathsEnabled = 0 (its default)
    p = os.path.normpath(os.path.abspath(p))
    if os.name != 'nt' or p.startswith('\\\\?\\'): return p
    return '\\\\?\\UNC\\' + p[2:] if p.startswith('\\\\') else '\\\\?\\' + p

sys.dont_write_bytecode = True  # no __pycache__ beside this script: it runs inside the package, which Unity imports
from preview_assets import is_shader_asset, shader_asset_name, rewrite_shader_refs

NS = re.compile(r'^\s*namespace\s+([\w.]+)', re.M)


def guid_of(meta):
    with open(meta, encoding='utf-8', errors='replace') as h:
        for l in h:
            if l.startswith('guid:'):
                return l.split()[1]


def project_guids(dst):
    out = {}
    for d, _, fs in os.walk(dst):
        for f in fs:
            if f.endswith('.meta'):
                g = guid_of(os.path.join(d, f))
                if g: out[g] = os.path.join(d, f[:-5])
    return out


# uGUI references (KFIX4): Unity 2018 kept every UnityEngine.UI component in one DLL, so a retail reference is
# {fileID: <per-class>, guid: f5f67c52..., type: 3}. The kit project has com.unity.ugui, whose scripts each have their own GUID
# and fileID 11500000. The copy rewrites each such reference by its fileID, so a scene binds in the kit project and in a mod
# bundle alike. Table: UCU's Project/Assets/Editor/AssetGuidFixupTool.cs ComponentRemap (every f5f67c52 row, lines 79-109),
# target GUIDs checked against the com.unity.ugui 2.6.0 metas.
UGUI_2018 = 'f5f67c52d1564df4a8936ccd202a3bd8'
UGUI_SCRIPTS = {
    -765806418: 'fe87c0e1cc204ed48ad3b37840f39efc',  # Image
    1367256648: '1aa08ab6e0800fa44ae55d278d1423e3',  # ScrollRect
    1679637790: '306cc8c2b49d7114eaa3623786fc2126',  # LayoutElement
    1297475563: '59f8146938fff824cb5fd77236b75775',  # VerticalLayoutGroup
    -405508275: '30649d3a9faa99c48a7b1166b86bf2a0',  # HorizontalLayoutGroup
    1741964061: '3245ec927659c4140ac4f8d17403cc18',  # ContentSizeFitter
    2109663825: '9085046f02f69544eb97fd06b6048fe2',  # Toggle
    -1200242548: '31a19414c41e5ae4aae2af33fee712f6',  # Mask
    -2061169968: '2a4db7a114972834c8e4117be1d82ba3',  # Scrollbar
    -2095666955: '8a8695521f0d02e499659fee002a26c2',  # GridLayoutGroup
    1392445389: '4e29b1a8efbd4b44bb3f3716e73f07ff',  # Button
    -146154839: '3312d7739989d2b4e91e6319e9a96d76',  # RectMask2D
    708705254: '5f7201a12d95ffc409449d95f23cf332',  # Text
    1573420865: 'cfabb0440166ab443bba8876756fdfa9',  # Shadow
    -900027084: 'e19747de3f5aca642ab2be37e372fb86',  # Outline
    -98529514: '1344c3c82d62a2a41a3576d8abb8e3ea',  # RawImage
    -234403039: '7a98125502f715b4b83cfb77b434e436',  # Selectable
    853051423: '0d0b652f32a2cc243917e4028fa0f046',  # Dropdown
    -113659843: '67db9e8f0e2ae9c40bc1e2b64352a6b4',  # Slider
    1301386320: 'dc42784cf147c0c48a680349fa168899',  # GraphicRaycaster
    575553740: 'd199490a83bb2b844b9695cbf13b01ef',  # InputField
    -619905303: '76c392e42b5098c458856cdf6ecaaaa1',  # EventSystem
    1980459831: '0cd44c1031e13a943bb63640046fad76',  # CanvasScaler
    -768656878: 'c49b4cc203aa6414fae5c798d1d0e7d6',  # PhysicsRaycaster
    1077351063: '4f231c4fb786f3946a6b90b886c48677',  # StandaloneInputModule
}
UGUI_REF = re.compile(rb'\{fileID: (-?\d+), guid: ' + UGUI_2018.encode() + rb', type: 3\}')


def rewrite_ugui(path):
    """Points each Unity 2018 uGUI script reference in one YAML file at com.unity.ugui. Returns (rewritten, fileIDs not in the table)."""
    with open(path, 'rb') as h:
        if h.read(5) != b'%YAML':
            return 0, collections.Counter()
        data = b'%YAML' + h.read()
    if UGUI_2018.encode() not in data:
        return 0, collections.Counter()
    left = collections.Counter(); n = 0
    def sub(m):
        nonlocal n
        g = UGUI_SCRIPTS.get(int(m.group(1)))
        if g is None:
            left[int(m.group(1))] += 1; return m.group(0)
        n += 1; return b'{fileID: 11500000, guid: ' + g.encode() + b', type: 3}'
    new = UGUI_REF.sub(sub, data)
    if n:
        with open(path, 'wb') as h:
            h.write(new)
    return n, left


SHADER_MAP = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'shader-map.tsv')
BUILTIN = '0000000000000000'


def shader_map():
    """(name -> UCU GUID, Mapkit Asset Manager GUID -> UCU GUID, MAM GUID -> name), from shader-map.tsv; only shaders the kit ships bind."""
    by_name, by_mam, names = {}, {}, {}
    with open(SHADER_MAP, encoding='utf-8', newline='') as h:
        for r in csv.DictReader(h, delimiter='\t'):
            names[r['mam_guid']] = r['name']
            if r['state'] == 'kit':
                by_name[r['name']] = r['ucu_guid']; by_mam[r['mam_guid']] = r['ucu_guid']
    return by_name, by_mam, names


def rewrite_materials(paths, remap):
    """Points the shader reference of each material at UCU's shader. Returns (materials changed, references rewritten, still-unbound shader GUIDs)."""
    changed = refs = 0; left = collections.Counter()
    for p in paths:
        with open(p, 'rb') as h:
            data = h.read()
        new, n = rewrite_shader_refs(data, remap)
        if n:
            with open(p, 'wb') as h:
                h.write(new)
            changed += 1; refs += n
        for m in re.finditer(rb'm_Shader: \{fileID: \d+, guid: ([0-9a-f]{32}), type: 2\}', new):
            if not m.group(1).decode().startswith(BUILTIN):
                left[m.group(1).decode()] += 1
    return changed, refs, left


def bind_shaders(assets, closures):
    """The shader binding over maps already imported (the export is gone, so the GUID pairs come from shader-map.tsv). Scope: the .mat rows
    of the given closure lists (plus the copies written beside a different GUID's file, `<name>_<guid8>.mat`), or every material under Assets
    outside the code folders when none is given."""
    _, by_mam, names = shader_map()
    mats = set()
    if closures:
        for c in closures:
            for line in open(c, encoding='utf-8').read().splitlines():
                rel = line.split('\t')[0]
                if not rel.endswith('.mat'):
                    continue
                p = lp(os.path.join(assets, rel))
                if os.path.exists(p):
                    mats.add(p)
                d, f = os.path.split(p); stem = os.path.splitext(f)[0]
                if os.path.isdir(d):
                    mats.update(os.path.join(d, x) for x in os.listdir(d) if x.endswith('.mat') and re.fullmatch(re.escape(stem) + r'_[0-9a-f]{8}\.mat', x))
    else:
        for d, ds, fs in os.walk(assets):
            if os.path.relpath(d, assets).split(os.sep)[0] in ('HBS-Decompiled', 'Plugins', 'Scripts'):
                ds[:] = []; continue
            mats.update(os.path.join(d, f) for f in fs if f.endswith('.mat'))
    changed, refs, left = rewrite_materials(sorted(mats), by_mam)
    print(f"materials scanned={len(mats)} changed={changed} shader references rewritten={refs}")
    print("still unbound (material references): " + ', '.join(f"{names.get(g, 'unknown ' + g)}={n}" for g, n in left.most_common()))


PIN_BLOCK = re.compile(r'^  platformSettings:\n(  - serializedVersion: \d+\n(?:    .*\n)+)', re.M)


def pin_texture_meta(meta):
    """Adds the Standalone override (retail's own format) to a TextureImporter meta that has none. True when it changed the file."""
    with open(meta, encoding='utf-8', newline='') as h:
        raw = h.read()
    nl = '\r\n' if '\r\n' in raw else '\n'
    t = raw.replace('\r\n', '\n')
    if 'TextureImporter:' not in t or re.search(r'^    buildTarget: Standalone$', t, re.M):
        return False
    fmt = re.search(r'^  textureFormat: (\d+)$', t, re.M)
    block = PIN_BLOCK.search(t)
    if not fmt or int(fmt.group(1)) <= 0 or not block:
        return False
    entry = block.group(1)
    for pat, rep in ((r'buildTarget: \w+', 'buildTarget: Standalone'), (r'textureFormat: -?\d+', 'textureFormat: ' + fmt.group(1)),
                     (r'textureCompression: \d+', 'textureCompression: 0'), (r'overridden: \d+', 'overridden: 1')):
        entry = re.sub('^    ' + pat + '$', '    ' + rep, entry, count=1, flags=re.M)
    t = t[:block.end()] + entry + t[block.end():]
    with open(meta, 'w', encoding='utf-8', newline='') as h:
        h.write(t.replace('\n', nl))
    return True


def pin(closure, dst):
    """Pins the texture metas of one map's closure in a project that already holds them (the export is not needed: the closure
    list names the project paths). An asset that was written beside a different GUID's file is not at its closure path and is
    counted, not pinned."""
    seen = done = elsewhere = 0
    for line in open(closure, encoding='utf-8').read().splitlines():
        m = lp(os.path.join(dst, line.split('\t')[0])) + '.meta'
        if not os.path.exists(m):
            elsewhere += 1; continue
        if 'TextureImporter:' not in open(m, encoding='utf-8', errors='replace').read():
            continue
        seen += 1
        if pin_texture_meta(m):
            done += 1
    print(f"texture metas in the closure={seen}, pinned now={done}, closure paths with no meta there (shaders, beside-GUID copies)={elsewhere}")


def copy(src, closure, dst):
    """Adds a map's closure to a project that may already hold other maps from exports with deterministic GUIDs
    (tools/map-kit/assetripper-patches): an asset whose GUID the project already has is the same asset and is not copied
    again; an asset whose path is taken by a different GUID (AssetRipper's numbered names, e.g. MonoBehaviour_3, name
    different objects in different exports) is written beside it with its GUID in the name. References are by GUID."""
    n = b = skipped = same = moved = pinned = ugui = 0; differ = []; mats = []; gaps = collections.Counter(); ugui_left = collections.Counter()
    have = project_guids(dst)
    by_name, remap, _ = shader_map()  # MAM GUID -> UCU GUID; the export's own ShaderAsset names add to it below
    for line in open(closure, encoding='utf-8').read().splitlines():
        cols = line.split('\t')
        rel = cols[0]
        to = cols[2] if len(cols) > 2 else rel  # a third column names another place in the project (retail_moods.py keeps Resources/ out)
        s = lp(os.path.join(src, rel))
        if is_shader_asset(s):
            skipped += 1; name = shader_asset_name(s); sg = guid_of(s + '.meta')
            if name in by_name:
                remap[sg] = by_name[name]
            elif sg not in remap:
                gaps[name] += 1
            continue
        g = guid_of(s + '.meta')
        if g in have:
            same += 1
            with open(s, 'rb') as x, open(have[g], 'rb') as y:
                if x.read() != y.read(): differ.append(rel)
            continue
        d = lp(os.path.join(dst, to))
        if os.path.exists(d + '.meta'):
            stem, ext = os.path.splitext(d); d = f"{stem}_{g[:8]}{ext}"; moved += 1
        os.makedirs(os.path.dirname(d), exist_ok=True)
        shutil.copyfile(s, d); shutil.copyfile(s + '.meta', d + '.meta'); have[g] = d
        r, l = rewrite_ugui(d); ugui += r; ugui_left.update(l)
        if pin_texture_meta(d + '.meta'): pinned += 1
        if d.endswith('.mat'): mats.append(d)
        n += 1; b += os.path.getsize(s) + os.path.getsize(s + '.meta')
    print(f"already in the project (same GUID)={same}, of which different bytes={len(differ)} {differ[:5]}; "
          f"written beside a different GUID's file={moved}")
    # folder metas, so Unity keeps the export's folder GUIDs
    for line in open(closure, encoding='utf-8').read().splitlines():
        cols = line.split('\t')
        if len(cols) > 2 and cols[2] != cols[0]:
            continue  # moved elsewhere: the export has no folder there
        rel = os.path.dirname(cols[0])
        while rel:
            m = lp(os.path.join(src, rel + '.meta')); t = lp(os.path.join(dst, rel + '.meta'))
            if os.path.exists(m) and not os.path.exists(t):
                shutil.copyfile(m, t)
            rel = os.path.dirname(rel)
    print(f"copied files={n} bytes={b} (with metas) shader-assets-skipped={skipped} texture-metas-pinned={pinned}")
    print(f"uGUI (Unity 2018 DLL) script references pointed at com.unity.ugui={ugui}; left, fileID not in the table={dict(ugui_left)}")
    changed, refs, left = rewrite_materials(mats, remap)
    print(f"materials written={len(mats)} pointed at UCU's shaders={changed} (references={refs}); shaders with no kit shader={dict(gaps)}; "
          f"material references still on a retail shader GUID={sum(left.values())}")


def key(path):
    t = open(path, encoding='utf-8', errors='replace').read()
    m = NS.search(t)
    return ((m.group(1) if m else ''), os.path.splitext(os.path.basename(path))[0])


def index(root):
    out = {}
    for d, _, fs in os.walk(root):
        for f in fs:
            if f.endswith('.cs'):
                p = os.path.join(d, f)
                out.setdefault(key(p), []).append(p)
    return out


def bind(src, dst, report):
    pairs = [(os.path.join(src, 'Scripts', 'Assembly-CSharp'), os.path.join(dst, 'HBS-Decompiled')),
             (os.path.join(src, 'Plugins', 'Assembly-CSharp-firstpass'), os.path.join(dst, 'Plugins', 'HBS-Decompiled-firstpass'))]
    c = collections.Counter()
    with open(report, 'w', encoding='utf-8', newline='\n') as w:
        w.write('state\tnamespace\tclass\tguid\tdecompiled\n')
        for ar, ours in pairs:
            a = index(ar); o = index(ours)
            for k, ps in sorted(a.items()):
                meta = ps[0] + '.meta'
                if not os.path.exists(meta):
                    c['ar-no-meta'] += 1; continue
                g = guid_of(meta)
                tgt = o.get(k)
                if not tgt:
                    c['retail-class-absent-from-ucu'] += 1; w.write(f"absent\t{k[0]}\t{k[1]}\t{g}\t\n"); continue
                if len(tgt) > 1 or len(ps) > 1:
                    c['ambiguous'] += 1; w.write(f"ambiguous\t{k[0]}\t{k[1]}\t{g}\t{';'.join(tgt)}\n"); continue
                m = tgt[0] + '.meta'
                if not os.path.exists(m):
                    c['ucu-no-meta'] += 1; continue
                t = open(m, encoding='utf-8').read()
                t2 = re.sub(r'^guid: [0-9a-f]{32}', 'guid: ' + g, t, count=1, flags=re.M)
                if t2 != t:
                    open(m, 'w', encoding='utf-8', newline='\n').write(t2); c['rebound'] += 1
                else:
                    c['already'] += 1
                w.write(f"bound\t{k[0]}\t{k[1]}\t{g}\t{os.path.relpath(tgt[0], dst)}\n")
            c['ucu-only'] += sum(1 for k in o if k not in a)
    print('bind:', dict(c))


if __name__ == '__main__':
    if sys.argv[1] == 'copy':
        copy(lp(sys.argv[2]), lp(sys.argv[3]), lp(sys.argv[4]))
    elif sys.argv[1] == 'pin':
        pin(lp(sys.argv[2]), lp(sys.argv[3]))
    elif sys.argv[1] == 'bind' and sys.argv[2] == 'shaders':
        bind_shaders(lp(sys.argv[3]), [lp(c) for c in sys.argv[4:]])
    elif sys.argv[1] == 'bind':
        bind(lp(sys.argv[2]), lp(sys.argv[3]), lp(sys.argv[4]))
