"""UCU Map Kit: the MoodSettings a retail map can draw come out of the extraction with it.

    py -3 retail_moods.py <export Assets> <retail install> <map id> <out closure.tsv> [<files list>]

Read-only on the export and the retail install; the only file written is <out closure.tsv> (and <out>.report.txt beside it).
1. The map's moods, by the rule the game uses (Contract.cs GetMood): the map's biome from the MDD (Map.BiomeSkinID), the biome's required
   mood tags (BiomeSkin.RequiredMoodTagSetID), every Mood row whose tag set holds all of them and not BLACKLISTED (the game always excludes it).
2. Their closure in the export: each mood's `Resources/moods/<name>.asset` and every asset it reaches by GUID (the star texture, the weather
   prefab with its materials and textures). Code is bound by import_closure.py bind and ShaderAssets by its shader map, as for a map.
3. The size gate (AGENTS.md, generated data against retail): the closure's export bytes against the retail bytes of the same objects (the
   mood objects from the game's own container, the other assets by name and class in the staged data, with the PPtr graph of a prefab
   walked through its type trees). Over GATE_RATIO, a texture whose size differs from retail's, an asset with no retail counterpart, or a
   closure that reaches a folder other than the ones a mood uses: exit 3 and nothing is written for the copy.
4. <out closure.tsv>: `source rel <TAB> bytes <TAB> destination rel`, for `import_closure.py copy`. `Resources/` is the one folder a project
   must not hold the copy in (a player build ships it; a mod must not carry it by accident), so its files go under MapKitRetailMoods/
   (Resources/moods/X.asset -> MapKitRetailMoods/Moods/X.asset). GUIDs are the export's, the same on every extraction.
Exit 0 also when the map's biome has no mood (an empty list is written).
"""
import os, re, sys, sqlite3, collections, struct

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from preview_assets import index, closure  # the same GUID closure the preview setup uses

GATE_RATIO = 2.0
# What a mood reaches: its own asset and star texture (Resources), the weather prefab (GameObject) with its materials and textures, a
# reflection cubemap. Anything else is another map's or the game's code, and stops the run.
ALLOWED = ('Resources/moods/', 'Resources/textures/', 'GameObject/', 'Material/', 'Texture2D/', 'Cubemap/')
DEST_ROOT = 'MapKitRetailMoods'


def lp(p):  # extended-length path (see closure.py)
    p = os.path.normpath(os.path.abspath(p))
    if os.name != 'nt' or p.startswith('\\\\?\\'): return p
    return '\\\\?\\UNC\\' + p[2:] if p.startswith('\\\\') else '\\\\?\\' + p


def destination(rel):
    if rel.startswith('Resources/moods/'): return DEST_ROOT + '/Moods/' + rel[len('Resources/moods/'):]
    if rel.startswith('Resources/'): return DEST_ROOT + '/' + rel[len('Resources/'):]
    return rel


def map_moods(install, map_id):
    """(biome name, required tags, [(mood name, friendly name)]) by the game's rule; ([], ...) when the map or its biome is unknown."""
    plain = os.path.join(os.path.abspath(install), 'BattleTech_Data', 'StreamingAssets', 'MDD', 'MetadataDatabase.db')
    db = sqlite3.connect('file:' + plain.replace('\\', '/') + '?mode=ro', uri=True)
    row = db.execute('select bs.Name, bs.RequiredMoodTagSetID from Map m join BiomeSkin bs on m.BiomeSkinID = bs.BiomeSkinID where m.MapID = ?', (map_id,)).fetchone()
    if row is None: return None, [], []
    biome, tagset = row
    tags = lambda ts: {r[0] for r in db.execute('select TagName from TagSetTag where TagSetID = ?', (ts,))}
    need = tags(tagset)
    # GetTagSetWithRequiredTags (Tags_MDDExtenstions.cs) always excludes BLACKLISTED: the story missions' moods (Mission1a to Mission9) are never drawn at random.
    moods = [(n, f) for n, f, ts in db.execute('select Name, FriendlyName, TagSetID from Mood order by FriendlyName') if need and need <= tags(ts) and 'BLACKLISTED' not in tags(ts)]
    return biome, sorted(need), moods


def png_size(path):
    with open(path, 'rb') as h: head = h.read(24)
    return struct.unpack('>II', head[16:24]) if head[:8] == b'\x89PNG\r\n\x1a\n' else None


class Retail:
    """Retail objects of the staged data by (name, class), with serialized sizes."""
    CLASSES = ('GameObject', 'Texture2D', 'Cubemap', 'Material')

    def __init__(self, data, names):
        import UnityPy
        self.UnityPy, self.data = UnityPy, data
        self.envs = {}
        self.names = names
        self.by = collections.defaultdict(list)  # (name, class) -> [(file, obj)]
        self.pending = list(dict.fromkeys(['resources.assets'] + [n for n in names if n.endswith('.assets') and n != 'resources.assets']))
        self.loaded = []

    def _load_next(self):
        while self.pending:
            f = self.pending.pop(0); p = os.path.join(self.data, f)
            if not os.path.exists(p): continue
            env = self.UnityPy.load(lp(p)); self.envs[f] = {o.path_id: o for o in env.objects}; self.loaded.append(f)
            for o in env.objects:
                if o.type.name in self.CLASSES:
                    try: self.by[(o.read().m_Name, o.type.name)].append((f, o))
                    except Exception: pass
            return True
        return False

    def find(self, name, cls):
        while True:
            c = self.by.get((name, cls))
            if c: return c
            if not self._load_next(): return []

    @staticmethod
    def size(o):
        n = o.byte_size
        if o.type.name in ('Texture2D', 'Cubemap'):
            try:
                sd = getattr(o.read(), 'm_StreamData', None)
                if sd is not None: n += int(getattr(sd, 'size', 0) or 0)
            except Exception: pass
        return n

    def graph(self, f, o):
        """{(file, path id): object} of the PPtr graph from o inside file f (no scripts, shaders or meshes: a material's shader is the kit's)."""
        seen, todo = {}, [(f, o)]
        while todo:
            f, o = todo.pop()
            if (f, o.path_id) in seen: continue
            seen[(f, o.path_id)] = o
            if o.type.name in ('MonoBehaviour', 'MonoScript', 'Shader', 'Mesh', 'AnimationClip'): continue
            try: tt = o.read_typetree()
            except Exception: continue
            stack = [tt]
            while stack:
                x = stack.pop()
                if isinstance(x, dict):
                    if set(x) == {'m_FileID', 'm_PathID'}:
                        t = self.envs[f].get(x['m_PathID']) if x['m_FileID'] == 0 else None
                        if t is not None: todo.append((f, t))
                    else: stack.extend(x.values())
                elif isinstance(x, list): stack.extend(x)
        return seen


def main(export_assets, install, map_id, out, files_list=None):
    export_assets = lp(export_assets); out = lp(out)
    report = []
    def say(s): print(s, flush=True); report.append(s)
    biome, need, moods = map_moods(install, map_id)
    if biome is None:
        say(f'MOODS {map_id}: not in the game\'s map table; 0 moods by the game\'s rule')
    else:
        say(f'MOODS {map_id}: biome {biome}, required tags {need}, {len(moods)} moods by the game\'s rule: {", ".join(n for n, _ in moods)}')
    ex = lambda rel: os.path.normpath(os.path.join(export_assets, rel))
    roots = [f'Resources/moods/{n}.asset' for n, _ in moods if os.path.exists(ex(f'Resources/moods/{n}.asset'))]
    noasset = [n for n, _ in moods if f'Resources/moods/{n}.asset' not in roots]
    if noasset: say(f'MOODS no asset in the export for: {", ".join(noasset)} (the game keeps the previous mood for these too)')
    rows = []
    if roots:
        files, shaders, missing = closure(export_assets, index(export_assets), roots)
        if missing: say(f'GATE STOP: the closure has {len(missing)} unresolved GUIDs: {list(missing)[:5]}'); return 3
        foreign = [f for f in files if not f.startswith(ALLOWED)]
        if foreign: say(f'GATE STOP: the closure reaches assets a mood does not use: {foreign[:8]} ({len(foreign)} files)'); return 3
        names = [l.strip() for l in open(files_list, encoding='utf-8')] if files_list else ['resources.assets']
        retail = Retail(os.path.join(os.path.abspath(install), 'BattleTech_Data'), names)
        import UnityPy
        data = os.path.join(os.path.abspath(install), 'BattleTech_Data')
        env = UnityPy.load(lp(os.path.join(data, 'globalgamemanagers')), lp(os.path.join(data, 'resources.assets')))
        container = next(o.read() for o in env.objects if o.type.name == 'ResourceManager').m_Container
        mood_bytes = {k.lower(): v.deref().byte_size for k, v in container if k.lower().startswith('moods/')}
        export_total = retail_total = 0; per = []; bad = []
        retail_seen = {}
        for rel in sorted(files):
            size = os.path.getsize(ex(rel)); export_total += size
            stem = os.path.splitext(os.path.basename(rel))[0]; top = rel.split('/')[0]
            if rel.startswith('Resources/moods/'):
                rb = mood_bytes.get('moods/' + stem.lower())
                if rb is None: bad.append(f'{rel}: no object in the game\'s container'); continue
                retail_total += rb; per.append((rel, size, rb, 'mood object (retail container)')); continue
            cls = {'GameObject': 'GameObject', 'Material': 'Material', 'Texture2D': 'Texture2D', 'Cubemap': 'Cubemap', 'Resources': 'Texture2D'}[top]
            c = retail.find(stem, cls)
            if len(c) != 1: bad.append(f'{rel}: {len(c)} retail objects named {stem} ({cls})'); continue
            f, o = c[0]
            if cls == 'Texture2D':
                rd = o.read(); png = png_size(ex(rel))
                if png is not None and (png[0], png[1]) != (rd.m_Width, rd.m_Height): bad.append(f'{rel}: {png[0]}x{png[1]} against retail {rd.m_Width}x{rd.m_Height}')
            if cls == 'GameObject':  # the prefab's own graph is the retail side of the prefab; its materials and textures are rows of their own
                g = {k: v for k, v in retail.graph(f, o).items() if v.type.name not in ('Material', 'Texture2D', 'Cubemap', 'Shader', 'MonoScript')}
                rb = sum(Retail.size(v) for v in g.values())
            else: rb = Retail.size(o)
            if (f, o.path_id) in retail_seen: bad.append(f'{rel}: same retail object as {retail_seen[(f, o.path_id)]}'); continue
            retail_seen[(f, o.path_id)] = rel
            retail_total += rb; per.append((rel, size, rb, f'{cls} in {f}'))
        say('GATE rows (export bytes against retail bytes of the same object):')
        yaml_classes = ('mood object', 'GameObject', 'Material')  # text YAML against retail's binary serialization (KR1a)
        for rel, e, r, what in per:
            note = 'explained: YAML' if what.startswith(yaml_classes) and e > r else ('explained: PNG against raw pixels, size checked equal' if what.startswith('Texture2D') and e < r else '')
            say(f'  {rel}\t{e}\t{r}\t{e / r:.2f}\t{what}\t{note}')
        ratio = export_total / retail_total if retail_total else 0.0
        say(f'GATE total {len(files)} files {export_total} B against retail {retail_total} B = {ratio:.2f}x, limit {GATE_RATIO}x; shader assets not copied: {len(shaders)}; moods {len(roots)}')
        if bad: say('GATE STOP: ' + '; '.join(bad)); return 3
        if ratio > GATE_RATIO: say(f'GATE STOP: {ratio:.2f}x is over {GATE_RATIO}x'); return 3
        say('GATE ok')
        rows = [(rel, os.path.getsize(ex(rel)), destination(rel)) for rel in sorted(files)]
        assert not any('resources' in d.lower().split('/') for _, _, d in rows), 'a destination is inside a Resources folder'
    with open(out, 'w', encoding='utf-8', newline='\n') as w:
        for rel, size, dest in rows: w.write(f'{rel}\t{size}\t{dest}\n')
    with open(out + '.report.txt', 'w', encoding='utf-8', newline='\n') as w:
        w.write('\n'.join(report) + '\n')
    return 0


if __name__ == '__main__':
    if len(sys.argv) < 5: sys.exit(__doc__)
    sys.exit(main(*sys.argv[1:6]))
