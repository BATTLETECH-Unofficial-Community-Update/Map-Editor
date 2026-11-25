# Export bytes against the retail bytes behind them (derived). AssetRipper's path_id_map.json gives (retail file, path id, name, type);
# an export asset is matched to its retail object only when (name, type) is unique (1:1), then the object's serialized size plus its streamed
# payload (.resS) is the retail side. Read-only on the retail data dir. Merges D2-b's, KR0's and KR1a's variants.
#   closure mode: retail-closure-size.py <data_dir> <path_id_map.json> <closure.tsv> <export_assets> <LEVEL> [max_ratio]   (one map's closure; LEVEL = e.g. level86)
#     with max_ratio (the map kit's picker passes 2.0) it ends with a GATE line and exits 3 when the total ratio is over, naming the categories behind it
#   whole mode:   retail-closure-size.py --whole <data_dir> <path_id_map.json> <export_assets> [<out_prefix>]       (every file under Assets)
# Whole mode prints (1) the export split by category and by top folder, (2) matched 1:1 ratios for Mesh, Texture2D, Texture2DArray, AudioClip,
# (3) the scenes against every levelN(+.resS) in data_dir. Categories: meshes (Mesh), textures (Texture2D, Texture2DArray, Cubemap, Texture3D,
# RenderTexture), audio (AudioClip), scenes (*.unity), scripts (Scripts/, Plugins/), other (the rest).
import os, re, sys, json, collections
import UnityPy
def lp(p):  # extended-length path: a plain path past 259 characters fails to open on Windows with LongPathsEnabled = 0 (its default)
    p = os.path.normpath(os.path.abspath(p))
    if os.name != 'nt' or p.startswith('\\\\?\\'): return p
    return '\\\\?\\UNC\\' + p[2:] if p.startswith('\\\\') else '\\\\?\\' + p
whole = sys.argv[1] == '--whole'
if whole:
    data_dir, pid_map, export_assets = sys.argv[2:5]; prefix = sys.argv[5] if len(sys.argv) > 5 else None
else:
    data_dir, pid_map, closure, export_assets, LEVEL = sys.argv[1:6]
    max_ratio = float(sys.argv[6]) if len(sys.argv) > 6 else None
    closure = lp(closure)
data_dir = lp(data_dir); pid_map = lp(pid_map); export_assets = lp(export_assets)
if whole and prefix: prefix = lp(prefix)
TYPED = ('Texture2D', 'Mesh', 'Texture2DArray', 'AudioClip')
STREAMED = ('Texture2D', 'Texture2DArray', 'Mesh', 'AudioClip')
CATS = {'Mesh': 'meshes', 'Texture2D': 'textures', 'Texture2DArray': 'textures', 'Cubemap': 'textures', 'Texture3D': 'textures',
        'RenderTexture': 'textures', 'CubemapArray': 'textures', 'AudioClip': 'audio', 'Scripts': 'scripts', 'Plugins': 'scripts'}
def category(rel):
    if rel.endswith('.unity'): return 'scenes'
    return CATS.get(rel.split('/')[0], 'other')
pm = json.load(open(pid_map, encoding='utf-8'))
by_nt = collections.defaultdict(list)
for f in pm['Files']:
    for a in f['Assets']: by_nt[(a['Name'], a['Type'])].append((f['Name'], a['PathID']))
if whole:
    rows = []; metas = collections.Counter(); metan = collections.Counter()
    for d, _, fs in os.walk(export_assets):
        for f in fs:
            p = os.path.join(d, f); rel = os.path.relpath(p, export_assets).replace(os.sep, '/')
            if f.endswith('.meta'): metas[rel.split('/')[0]] += os.path.getsize(p); metan[rel.split('/')[0]] += 1; continue
            rows.append((rel, os.path.getsize(p)))
else:
    rows = list(dict(l.split('\t') for l in open(closure, encoding='utf-8').read().splitlines()).items())  # deduplicated
want = {}; unmatched = collections.Counter(); ambiguous = collections.Counter(); cat_export = collections.Counter(); cat_n = collections.Counter()
for rel, size in rows:
    top = rel.split('/')[0]
    if top not in TYPED: continue
    stem = os.path.splitext(os.path.basename(rel))[0]
    c = by_nt.get((stem, top)) or by_nt.get((re.sub(r'_\d+$', '', stem), top))
    if not c: unmatched[top] += 1; continue
    if len(c) > 1: ambiguous[top] += 1; continue
    want[c[0]] = (top, rel); cat_export[top] += int(size); cat_n[top] += 1
files = collections.defaultdict(set)
for (fn, pid) in want: files[fn].add(pid)
cat_retail = collections.Counter(); k = 0
for fn, pids in sorted(files.items()):
    env = UnityPy.load(os.path.join(data_dir, fn)); k += 1
    for obj in env.objects:
        if obj.path_id not in pids: continue
        n = obj.byte_size
        if obj.type.name in STREAMED:
            try:
                d = obj.read(); sd = getattr(d, 'm_StreamData', None)
                if sd is not None: n += int(getattr(sd, 'size', 0) or 0)
            except Exception as e: print('read-fail', fn, obj.path_id, obj.type.name, e, flush=True)
        cat_retail[want[(fn, obj.path_id)][0]] += n
    if k % 20 == 0: print('retail files read', k, '/', len(files), flush=True)
if whole:
    byfolder = collections.Counter(); byfolder_n = collections.Counter(); bycat = collections.Counter(); bycat_n = collections.Counter()
    for rel, s in rows:
        top = rel.split('/')[0] if '/' in rel else '(root)'; byfolder[top] += s; byfolder_n[top] += 1; c = category(rel); bycat[c] += s; bycat_n[c] += 1
    tot = sum(byfolder.values()); mt = sum(metas.values())
    print('## export by category (asset files, .meta excluded)'); print('category\tfiles\tbytes\tshare')
    for c in ('meshes', 'textures', 'audio', 'scenes', 'scripts', 'other'): print(f"{c}\t{bycat_n[c]}\t{bycat[c]}\t{bycat[c] / tot:.3f}")
    print(f"TOTAL\t{len(rows)}\t{tot}\t1.000\n.meta files\t{sum(metan.values())}\t{mt}")
    print('## export by top folder'); print('folder\tcategory\tfiles\tbytes\tmeta_bytes')
    for t, v in byfolder.most_common(): print(f"{t}\t{category(t + '/x')}\t{byfolder_n[t]}\t{v}\t{metas[t]}")
    print('## matched 1:1 against retail objects'); print('type\tmatched_1to1\texport_bytes\tretail_bytes\tratio\tambiguous_left_out\tunmatched')
    te = tr = 0
    for t in TYPED:
        e, r = cat_export[t], cat_retail[t]; te += e; tr += r
        print(f"{t}\t{cat_n[t]}\t{e}\t{r}\t{(e / r if r else 0):.2f}\t{ambiguous[t]}\t{unmatched[t]}")
    print(f"TOTAL matched\t{sum(cat_n.values())}\t{te}\t{tr}\t{(te / tr if tr else 0):.2f}")
    lv = [f for f in os.listdir(data_dir) if re.fullmatch(r'level\d+(\.resS)?', f)]
    lvb = sum(os.path.getsize(os.path.join(data_dir, f)) for f in lv); sc = sum(s for rel, s in rows if rel.endswith('.unity'))
    scn = sum(1 for rel, s in rows if rel.endswith('.unity'))
    print(f"## scenes: {scn} exported .unity files {sc} B against {len(lv)} level files (levelN + .resS) {lvb} B (ratio {(sc / lvb if lvb else 0):.2f}; retail's sharedassets are not in the denominator)")
    if prefix:
        with open(prefix + '-folders.tsv', 'w', encoding='utf-8', newline='\n') as w:
            for t, v in byfolder.most_common(): w.write(f"{t}\t{byfolder_n[t]}\t{v}\n")
else:
    print('category\tmatched_1to1\texport_bytes\tretail_bytes\tratio')
    te = tr = 0
    for t in sorted(cat_export):
        e, r = cat_export[t], cat_retail[t]; te += e; tr += r
        print(f"{t}\t{cat_n[t]}\t{e}\t{r}\t{(e / r if r else 0):.2f}")
    lv = sum(os.path.getsize(os.path.join(data_dir, f)) for f in (LEVEL, LEVEL + '.resS') if os.path.exists(os.path.join(data_dir, f)))
    sc = sum(int(s) for rel, s in rows if rel.startswith('Level Design/'))
    print(f"scene ({LEVEL}+resS vs exported Level Design files, deduplicated)\t-\t{sc}\t{lv}\t{sc / lv:.2f}")
    print(f"TOTAL 1:1-matched typed + scene\t-\t{te + sc}\t{tr + lv}\t{(te + sc) / (tr + lv):.2f}")
    print('ambiguous (left out)', dict(ambiguous), 'unmatched', dict(unmatched), 'rows', len(rows))
    if max_ratio is not None:
        by = {t: (cat_export[t], cat_retail[t]) for t in cat_export}; by['scene'] = (sc, lv)
        ranked = sorted(((e / r if r else 0.0), t, e, r) for t, (e, r) in by.items() if r)
        total = (te + sc) / (tr + lv) if tr + lv else 0.0
        # The gate is on the total. A category over the limit alone is recorded either way: Mesh, Texture2DArray and the
        # scene are explained (text YAML against retail's binary serialization, KR1a); any other is marked unexplained.
        explained = {'Mesh', 'Texture2DArray', 'scene'}
        def tag(t):
            return 'explained: YAML' if t in explained else 'UNEXPLAINED'
        named = ', '.join(f"{t} {x:.2f}x ({e:,} B against {r:,} B; {tag(t)})" for x, t, e, r in reversed(ranked) if x > max_ratio) or ('none over the limit alone; largest ' + (f"{ranked[-1][1]} {ranked[-1][0]:.2f}x" if ranked else 'n/a'))
        print(f"GATE total {total:.2f}x limit {max_ratio}x: " + ("OVER" if total > max_ratio else 'ok') + f"; categories over the limit: {named}")
        sys.exit(3 if total > max_ratio else 0)
