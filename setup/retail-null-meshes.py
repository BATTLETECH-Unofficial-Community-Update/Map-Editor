# retail-null-meshes.py <BattleTech_Data> <levelN> <out.tsv>: the renderers retail itself ships with no mesh (read-only on the install).
# Every GameObject in the level file with a MeshFilter and a renderer whose MeshFilter m_Mesh has path ID 0 (LOD slots, decals,
# destruction cells, distant terrain): one row per object, hierarchy path and GameObject path ID. The picker writes it at stage time
# (step 1/6) so the open counts can tell retail's null meshes from lost ones (kr-open-counts.cs, kr-collect.py: lost = nullMesh - retail).
# From KFIX3's scan_retail.py (.hermes/reports/map-kit-kfix3-20261123/), which matched all 4,945 kit null meshes of KR2 to retail ones.
import os, sys, collections
import UnityPy

data, lvl, out = sys.argv[1], sys.argv[2], sys.argv[3]
RENDER = {'MeshRenderer', 'SkinnedMeshRenderer', 'LineRenderer', 'TrailRenderer', 'ParticleSystemRenderer', 'SpriteRenderer'}
env = UnityPy.load(os.path.join(data, lvl))
sf = next(iter(env.files.values()))
objs = {o.path_id: o for o in sf.objects.values()}
tr = {}; gos = {}; gocomp = collections.defaultdict(list)
for pid, o in objs.items():
    t = o.type.name
    if t in ('Transform', 'RectTransform'):
        d = o.read_typetree(); tr[pid] = (d['m_GameObject']['m_PathID'], d['m_Father']['m_PathID'])
    elif t == 'GameObject':
        d = o.read_typetree(); gos[pid] = d['m_Name']
        for c in d['m_Component']:
            gocomp[pid].append(c['component']['m_PathID'])
gotr = {g: t for t, (g, f) in tr.items()}
def path(g):
    parts = []; t = gotr.get(g)
    while t:
        gg, fa = tr[t]; parts.append(gos.get(gg, '?')); t = fa
    return '/'.join(reversed(parts))
rows = []; meshFilters = 0
for g, comps in gocomp.items():
    kinds = {objs[c].type.name: c for c in reversed(comps) if c in objs}   # first component of each type
    if 'MeshFilter' not in kinds or not (set(kinds) & RENDER): continue
    meshFilters += 1
    if objs[kinds['MeshFilter']].read_typetree()['m_Mesh']['m_PathID'] == 0: rows.append((path(g), g))
with open(out, 'w', encoding='utf-8', newline='\n') as w:
    w.write('path\tgoPathID\n')
    for p, g in sorted(rows): w.write(f'{p}\t{g}\n')
print(f'{lvl}: renderers with a MeshFilter={meshFilters}, retail null meshes={len(rows)} -> {out}')
