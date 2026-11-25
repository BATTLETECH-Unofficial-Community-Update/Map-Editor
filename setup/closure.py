# GUID closure of one exported scene: every asset it references, recursively, by GUID (read-only).
import os, re, sys, json, collections
def lp(p):  # extended-length path: a plain path past 259 characters fails to open on Windows with LongPathsEnabled = 0 (its default)
    p = os.path.normpath(os.path.abspath(p))
    if os.name != 'nt' or p.startswith('\\\\?\\'): return p
    return '\\\\?\\UNC\\' + p[2:] if p.startswith('\\\\') else '\\\\?\\' + p
assets = lp(sys.argv[1]); scene = sys.argv[2]; out = lp(sys.argv[3])
idx = {}
for d, _, fs in os.walk(assets):
    for f in fs:
        if f.endswith('.meta'):
            p = os.path.join(d, f)
            with open(p, encoding='utf-8', errors='replace') as h:
                for l in h:
                    if l.startswith('guid:'): idx[l.split()[1]] = p[:-5]; break
G = re.compile(rb'guid: ([0-9a-f]{32})')
# Unity 2018's UnityEngine.UI.dll: engine code, not exported (no meta). Retail levels can carry uGUI components saved in them
# (rawCliffsides: a dialog panel, 40); import_closure.py rewrites those references to com.unity.ugui's scripts (KFIX3/KFIX4).
UGUI_2018 = 'f5f67c52d1564df4a8936ccd202a3bd8'
refs = collections.Counter(); seen = set(); order = []; missing = collections.Counter()
todo = [os.path.normpath(os.path.join(assets, scene))]  # normpath: a forward-slash scene path listed the scene twice on Windows (KR0)
while todo:
    p = todo.pop()
    if p in seen: continue
    seen.add(p); order.append(p)
    if os.path.isdir(p): continue
    with open(p, 'rb') as h: head = h.read(5)
    if head != b'%YAML': continue
    data = open(p, 'rb').read()
    for g in G.findall(data):
        g = g.decode(); refs[g] += 1
        if g.startswith('0000000000000000') or g == UGUI_2018: continue
        t = idx.get(g)
        if t is None: missing[g] += 1; continue
        rel = os.path.relpath(t, assets).replace(os.sep, '/')
        if rel.startswith('Scripts/') or rel.startswith('Plugins/') or rel.endswith('.dll'): continue  # code: bound to the decompiled code, not copied
        if t not in seen: todo.append(t)
code = collections.Counter(); shaders = []
for g, n in refs.items():
    if g == UGUI_2018: code[(g, 'UnityEngine.UI (Unity 2018 DLL)')] = n; continue
    t = idx.get(g)
    if t is None: continue
    rel = os.path.relpath(t, assets).replace(os.sep, '/')
    if rel.startswith('Scripts/') or rel.startswith('Plugins/') or rel.endswith('.dll'): code[(g, rel)] = n
rows = []; tot = 0; bytype = collections.Counter(); bycnt = collections.Counter()
for p in order:
    if os.path.isdir(p): continue
    rel = os.path.relpath(p, assets).replace(os.sep, '/'); s = os.path.getsize(p); tot += s
    top = rel.split('/')[0]; bytype[top] += s; bycnt[top] += 1; rows.append((rel, s))
with open(out, 'w', encoding='utf-8', newline='\n') as w:
    for rel, s in rows: w.write(f"{rel}\t{s}\n")
with open(out.replace('.tsv', '-code.tsv'), 'w', encoding='utf-8', newline='\n') as w:
    for (g, rel), n in sorted(code.items(), key=lambda x: -x[1]): w.write(f"{g}\t{rel}\t{n}\n")
with open(out.replace('.tsv', '-missing.tsv'), 'w', encoding='utf-8', newline='\n') as w:
    for g, n in missing.most_common(): w.write(f"{g}\t{n}\n")
print(f"closure files={len(rows)} bytes={tot} (with metas add ~{len(rows)*250})")
for k, v in bytype.most_common(): print(f"  {k}\t{bycnt[k]}\t{v}")
print(f"code refs: {len(code)} distinct script/dll guids; by root:", collections.Counter(r.split('/')[1] if r.startswith(('Scripts/','Plugins/')) else r for (g, r) in code))
print(f"unresolved non-builtin guids: {len(missing)} distinct, {sum(missing.values())} refs")
