# kr-collect.py <retail-maps dir> [--open <open dir>] <id> [<id> ...]: one TSV row per map from the picker's own per-map logs.
# With --open, the map's open count (<open dir>/<id>.json, kr-chain.ps1's record) adds null_mesh, split into
# null_mesh_retail (rows of <map>/retail-null-meshes.tsv, which the picker writes at step 1/6) and null_mesh_lost = null_mesh - retail,
# which must be 0 (KFIX3: every null mesh of KR2 was retail's own); blank when either side is missing.
import json, os, re, sys
root = sys.argv[1]; args = sys.argv[2:]; opens = None
if args[:1] == ['--open']: opens, args = args[1], args[2:]
cols = ['map_id', 'chain', 'stage_s', 'export_s', 'embed_s', 'closure_s', 'import_s', 'delete_s', 'export_files', 'export_bytes', 'closure_files', 'closure_bytes', 'unresolved_guids', 'gate_total', 'gate_line', 'already_same_guid', 'diff_bytes', 'beside_diff_guid', 'copied_files', 'copied_bytes', 'shaders_skipped', 'cats_over_2x', 'null_mesh', 'null_mesh_retail', 'null_mesh_lost']
print('\t'.join(cols))
def rd(p):
    try: return open(p, encoding='utf-8', errors='replace').read()
    except OSError: return ''
for mid in args:
    d = os.path.join(root, mid); r = dict.fromkeys(cols, '')
    r['map_id'] = mid
    try: done = json.load(open(os.path.join(d, 'done.json')))
    except Exception: done = None
    r['chain'] = 'ok' if done else 'no done.json'
    if done:
        for s in done['steps']:
            m = re.search(r' (\d)/6 .*: (\d+) s$', s)
            if m: r[['', 'stage_s', 'export_s', 'embed_s', 'closure_s', 'import_s', 'delete_s'][int(m.group(1))]] = m.group(2)
        r['closure_files'], r['closure_bytes'] = done['closureFiles'], done['closureBytes']
    w = [l for l in rd(os.path.join(d, 'watch.log')).splitlines() if 'AR ended' in l]
    if w:
        m = re.search(r'out_files=(\d+) out_bytes=(\d+)', w[-1]); r['export_files'], r['export_bytes'] = m.groups() if m else ('', '')
    c = rd(os.path.join(d, 'closure.log')); m = re.search(r'unresolved non-builtin guids: (\d+) distinct', c); r['unresolved_guids'] = m.group(1) if m else ''
    if not done:
        m = re.search(r'closure files=(\d+) bytes=(\d+)', c)
        if m: r['closure_files'], r['closure_bytes'] = m.groups()
    g = rd(os.path.join(d, 'gate.log')); gl = [l for l in g.splitlines() if l.startswith('GATE')]
    if gl: r['gate_line'] = gl[-1]; m = re.search(r'GATE total ([\d.]+)x', gl[-1]); r['gate_total'] = m.group(1) if m else ''
    if gl:
        r['cats_over_2x'] = '; '.join(f'{t} {x}x ({tag})' for t, x, tag in re.findall(r'(\w+) ([\d.]+)x \([^)]*?; (explained: YAML|UNEXPLAINED)\)', gl[-1].split('categories over the limit:')[-1])) or 'none'
    i = rd(os.path.join(d, 'import.log'))
    m = re.search(r'already in the project \(same GUID\)=(\d+), of which different bytes=(\d+).*written beside a different GUID\'s file=(\d+)', i)
    if m: r['already_same_guid'], r['diff_bytes'], r['beside_diff_guid'] = m.groups()
    m = re.search(r'copied files=(\d+) bytes=(\d+).*shader-assets-skipped=(\d+)', i)
    if m: r['copied_files'], r['copied_bytes'], r['shaders_skipped'] = m.groups()
    rt = rd(os.path.join(d, 'retail-null-meshes.tsv')).splitlines()
    if rt: r['null_mesh_retail'] = len(rt) - 1
    o = rd(os.path.join(opens, mid + '.json')) if opens else ''
    if o:
        res = json.loads(o)['result']; x = json.loads(res[:res.rindex(']') + 1])[0]
        r['null_mesh'] = x.get('nullMesh', '')
    if r['null_mesh'] != '' and r['null_mesh_retail'] != '': r['null_mesh_lost'] = r['null_mesh'] - r['null_mesh_retail']
    print('\t'.join(str(r[c]) for c in cols))
