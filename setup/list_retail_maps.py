"""UCU Map Kit, "Extract Retail Maps…": the list of maps in a retail BATTLETECH install, from the game's own data.

    py -3 list_retail_maps.py <retail install> <out folder>

Reads (read-only): the metadata database (StreamingAssets/MDD/MetadataDatabase.db: map id, display name, biome, content pack,
whether the build includes the map), globalgamemanagers' scene list (a map's scene index is its levelN file), each map's level
file closure (the same files setup/closure-list.py names, so the size is what setup/stage-ar-input.ps1 stages), and
StreamingAssets/data/VersionManifest.csv (the <map>_icon sprites the game's own map screen loads).

Writes to <out folder>: retail-maps.tsv and previews/<map id>.png for each map that has a retail icon (the .dds converted;
the pictures stay on this machine). Progress goes to stdout, one `scan n/total` line per map; the last line is `scanned <n> maps`.
"""
import csv
import os
import re
import sqlite3
import sys

from PIL import Image, ImageOps
from UnityPy.files import SerializedFile
from UnityPy.streams import EndianBinaryReader
import UnityPy

def lp(p):  # extended-length path: a plain path past 259 characters fails to open on Windows with LongPathsEnabled = 0 (its default)
    p = os.path.normpath(os.path.abspath(p))
    if os.name != 'nt' or p.startswith('\\\\?\\'): return p
    return '\\\\?\\UNC\\' + p[2:] if p.startswith('\\\\') else '\\\\?\\' + p


COLUMNS = ['map_id', 'level', 'display_name', 'biome', 'pack', 'scene', 'icon', 'level_bytes', 'input_files', 'input_bytes']
_externals = {}


def externals(data_dir, name):
    """The file names a serialized file refers to (builtin resources left out); read once per file."""
    if name not in _externals:
        found = []
        with open(os.path.join(data_dir, name), 'rb') as handle:
            for e in SerializedFile(EndianBinaryReader(handle)).externals:
                base = e.path.replace('library/', '').split('/')[-1]
                if not (base.startswith('unity default') or base.startswith('unity_builtin')):
                    found.append(base)
        _externals[name] = found
    return _externals[name]


def closure(data_dir, start):
    seen, todo = [], [start]
    while todo:
        n = todo.pop()
        if n in seen or not os.path.exists(os.path.join(data_dir, n)):
            continue
        seen.append(n)
        todo.extend(externals(data_dir, n))
    return seen


def size_of(data_dir, name):
    total, count = 0, 0
    # stage-ar-input.ps1's set: a .assets file's streamed media is <base>.resource, without the .assets (KFIX5)
    stem = name[:-len('.assets')] if name.endswith('.assets') else name
    for f in dict.fromkeys((name, name + '.resS', name + '.resource', stem + '.resource')):
        p = os.path.join(data_dir, f)
        if os.path.exists(p):
            total += os.path.getsize(p)
            count += 1
    return total, count


def dir_size(path):
    total = count = 0
    for d, _, fs in os.walk(path):
        for f in fs:
            total += os.path.getsize(os.path.join(d, f))
            count += 1
    return total, count


def pretty(biome):
    """tundraFrozen -> Tundra frozen (the game's own biome skin name)."""
    words = re.sub(r'([a-z])([A-Z])', r'\1 \2', biome).lower()
    return words[:1].upper() + words[1:]


def main(install, out):
    plain_db = os.path.join(os.path.abspath(install), 'BattleTech_Data', 'StreamingAssets', 'MDD', 'MetadataDatabase.db')
    data_dir = lp(os.path.join(install, 'BattleTech_Data'))
    sa = os.path.join(data_dir, 'StreamingAssets')
    out = lp(out)
    os.makedirs(os.path.join(out, 'previews'), exist_ok=True)
    # sqlite takes a URI, which has no extended-length form: this one file keeps its plain path (the install's own path plus 51 characters)
    db = sqlite3.connect('file:' + plain_db.replace('\\', '/') + '?mode=ro', uri=True)
    biomes = dict(db.execute('select BiomeSkinID, Name from BiomeSkin'))
    pack = {m: p for m, p, t in db.execute('select ContentPackItemID, ContentPackID, ItemType from ContentPackItem') if t == 'Map'}
    rows = db.execute('select MapID, FriendlyName, BiomeSkinID, MapPath from Map where IncludeInBuild = 1 order by MapID').fetchall()
    scenes = [s for o in UnityPy.load(os.path.join(data_dir, 'globalgamemanagers')).objects if o.type.name == 'BuildSettings' for s in o.read_typetree()['scenes']]
    level_of = {s: f'level{i}' for i, s in enumerate(scenes)}
    icons = {}
    with open(os.path.join(sa, 'data', 'VersionManifest.csv'), newline='', encoding='utf-8') as handle:
        for r in csv.DictReader(handle):
            if r['type'] == 'Sprite' and r['id'].endswith('_icon'):
                icons[r['id'][:-5]] = r['path']
    fixed = sum(dir_size(os.path.join(data_dir, d))[0] for d in ('Managed', 'Resources'))
    fixed_files = sum(dir_size(os.path.join(data_dir, d))[1] for d in ('Managed', 'Resources'))
    gm_bytes, gm_files = size_of(data_dir, 'globalgamemanagers')
    kept = []
    for n, (map_id, name, biome, path) in enumerate(rows, 1):
        level = level_of.get(path)
        if level is None or not os.path.exists(os.path.join(data_dir, level)):
            print(f'skip {map_id}: no {level or "scene entry"} in this install', flush=True)
            continue
        files = [f for f in closure(data_dir, level) if f != 'globalgamemanagers']
        sized = [size_of(data_dir, f) for f in files]
        icon = ''
        if map_id in icons and os.path.exists(lp(os.path.join(sa, icons[map_id]))):
            # Unity's DDS rows run bottom-up; the game's own sprite load shows the icon upright, so the PNG is flipped to match.
            ImageOps.flip(Image.open(lp(os.path.join(sa, icons[map_id]))).convert('RGBA')).save(os.path.join(out, 'previews', map_id + '.png'))
            icon = map_id + '.png'
        kept.append([map_id, level, name, pretty(biomes.get(biome, 'UNDEFINED')), pack.get(map_id, ''), path, icon, size_of(data_dir, level)[0],
                     sum(c for _, c in sized) + gm_files + fixed_files, sum(b for b, _ in sized) + gm_bytes + fixed])
        print(f'scan {n}/{len(rows)} {map_id}', flush=True)
    tmp = os.path.join(out, 'retail-maps.tsv.tmp')
    with open(tmp, 'w', encoding='utf-8', newline='\n') as handle:
        handle.write('\t'.join(COLUMNS) + '\n')
        for r in kept:
            handle.write('\t'.join(str(c) for c in r) + '\n')
    os.replace(tmp, os.path.join(out, 'retail-maps.tsv'))
    print(f'scanned {len(kept)} maps')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
