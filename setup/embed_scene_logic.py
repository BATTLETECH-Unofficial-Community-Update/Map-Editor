"""Move encounter logic out of Assets/MonoBehaviour and into the map scene that owns it.

Retail keeps every result, conditional and AI order inside the level file, next to the
objects they point at. The extraction split them into standalone assets, and an asset
cannot point into a scene: importing one with its scene on disk, or building a player from
one, loops on `Do not use ReadObjectThreaded on scene objects!` until the Editor dies.

This restores retail's shape. For each scene it follows the `myCargoVTwo` slots through
the logic assets, appends each one to the scene as a document of its own, turns the pointers
between them into local ones, then deletes the asset and its meta. Nothing else in the scene
changes. A logic asset two scenes reach goes into both. A run over a project that has
already been converted finds nothing to do.

Usage (a dry run unless --apply):
    python -I tools/transplant/embed_scene_logic.py --project Project [--scene <rel>]...
        [--apply] [--backup DIR] [--manifest FILE] [--update-lock]
"""
import argparse
import collections
import hashlib
import os
import re
import shutil
import subprocess
import sys

def lp(p):  # extended-length path: a plain path past 259 characters fails to open on Windows with LongPathsEnabled = 0 (its default)
    p = os.path.normpath(os.path.abspath(p))
    if os.name != 'nt' or p.startswith('\\\\?\\'): return p
    return '\\\\?\\UNC\\' + p[2:] if p.startswith('\\\\') else '\\\\?\\' + p


HERE = os.path.dirname(os.path.abspath(__file__))
PAYLOAD_LOCK = os.path.join(HERE, "payloads.lock.tsv")
LOGIC_DIR = "Assets/MonoBehaviour"
SCENE_ROOTS = ("Assets/Level Design", "Assets/Scenes")
ASSET_ID = b"11400000"
SLOT = re.compile(rb"myCargoVTwo: \{fileID: 11400000, guid: ([0-9a-f]{32}), type: 2\}")
ASSET_REF = re.compile(rb"\{fileID: 11400000, guid: ([0-9a-f]{32}), type: 2\}")
OBJECT_REF = re.compile(rb"\{fileID: (-?\d+), guid: ([0-9a-f]{32}), type: 2\}")
SCENE_ROOT_ID = 102900000
HEADER = re.compile(rb"^--- !u!\d+ &(-?\d+)", re.M)
ASSET_HEADER = re.compile(rb"^--- !u!114 &11400000\r?\n", re.M)
GUID = re.compile(r"^guid: ([0-9a-f]{32})", re.M)


def fail(message):
    raise ValueError(message)


def read(path):
    with open(path, "rb") as handle:
        return handle.read()


def meta_guid(path):
    with open(path, encoding="utf-8", errors="replace") as handle:
        found = GUID.search(handle.read())
    if not found:
        fail(f"no guid in {path}")
    return found.group(1)


def logic_assets(project):
    """guid -> project-relative path for every asset in the logic folder."""
    found = {}
    root = os.path.join(project, *LOGIC_DIR.split("/"))
    for name in os.listdir(root):
        if name.endswith(".asset.meta"):
            found[meta_guid(os.path.join(root, name))] = f"{LOGIC_DIR}/{name[:-5]}"
    return found


def scene_files(project):
    """guid -> project-relative path for every scene under the scene roots."""
    found = {}
    for top in SCENE_ROOTS:
        for folder, _, names in os.walk(os.path.join(project, *top.split("/"))):
            for name in names:
                if name.endswith(".unity"):
                    full = os.path.join(folder, name)
                    rel = os.path.relpath(full, project).replace("\\", "/")
                    found[meta_guid(full + ".meta")] = rel
    return found


def local_id(guid, taken):
    """A stable local id for this asset, clear of every id already in the scene."""
    value = int.from_bytes(hashlib.md5(guid.encode() + b"/logic").digest()[:8], "big") & ((1 << 62) - 1)
    while value in taken or value == 0:
        value += 1
    taken.add(value)
    return value


def closure(start, bodies, assets, project):
    """Every logic asset reached from these guids through cargo slots."""
    seen = set()
    stack = list(start)
    while stack:
        guid = stack.pop()
        if guid in seen or guid not in assets:
            continue
        seen.add(guid)
        if guid not in bodies:
            bodies[guid] = read(os.path.join(project, *assets[guid].split("/")))
        stack.extend(m.group(1).decode() for m in SLOT.finditer(bodies[guid]))
    return seen


def embed(scene_bytes, scene_guid, moved, bodies, assets, scenes):
    """Scene bytes with these assets appended and every reference to them made local."""
    ids = {int(m.group(1)) for m in HEADER.finditer(scene_bytes)}
    existing = set(ids)
    local = {guid: local_id(guid, ids) for guid in sorted(moved)}

    def to_local(match):
        guid = match.group(1).decode()
        if guid in local:
            return b"{fileID: %d}" % local[guid]
        return match.group(0)

    def to_scene(match):
        guid = match.group(2).decode()
        object_id = int(match.group(1))
        if guid not in scenes or object_id == SCENE_ROOT_ID:
            return match.group(0)
        if guid != scene_guid:
            fail(f"pointer into another scene: {scenes[guid]}")
        if object_id not in existing:
            fail(f"pointer to a missing object {object_id} in {scenes[guid]}")
        return b"{fileID: %d}" % object_id

    out = [ASSET_REF.sub(to_local, scene_bytes)]
    if not out[0].endswith(b"\n"):
        out.append(b"\n")
    for guid in sorted(moved):
        body = bodies[guid]
        headers = ASSET_HEADER.findall(body)
        if len(headers) != 1 or len(HEADER.findall(body)) != 1:
            fail(f"expected one object in {assets[guid]}")
        doc = body[ASSET_HEADER.search(body).start():]
        doc = doc.replace(b"&" + ASSET_ID, b"&%d" % local[guid], 1)
        doc = OBJECT_REF.sub(to_scene, ASSET_REF.sub(to_local, doc))
        out.append(doc if doc.endswith(b"\n") else doc + b"\n")
    return b"".join(out), local


def plan(project, only):
    assets = logic_assets(project)
    scenes = scene_files(project)
    bodies = {}
    per_scene = {}
    for guid, rel in sorted(scenes.items(), key=lambda item: item[1]):
        if only and rel not in only:
            continue
        data = read(os.path.join(project, *rel.split("/")))
        start = {m.group(1).decode() for m in SLOT.finditer(data)} & set(assets)
        if start:
            per_scene[guid] = closure(start, bodies, assets, project)
    return assets, scenes, bodies, per_scene


def check_left_behind(project, assets, scenes, moved_all):
    """Nothing that stays may point into a scene or at an asset that moved."""
    bad = []
    for guid, rel in assets.items():
        if guid in moved_all:
            continue
        data = read(os.path.join(project, *rel.split("/")))
        for match in OBJECT_REF.finditer(data):
            target = match.group(2).decode()
            pointer = target in scenes and int(match.group(1)) != SCENE_ROOT_ID
            if pointer or target in moved_all:
                bad.append(rel)
                break
    return bad


def update_lock(project, removed, rewritten):
    """Drop the moved assets' rows and re-pin the scenes; every other row stays as it is."""
    with open(PAYLOAD_LOCK, encoding="utf-8", newline="") as handle:
        rows = handle.read().split("\n")
    pins = {}
    for rel in rewritten:
        full = os.path.join(project, *rel.split("/"))
        digest = hashlib.sha256()
        with open(full, "rb") as handle:
            for block in iter(lambda: handle.read(1 << 22), b""):
                digest.update(block)
        pins[rel] = f"{rel}\t{os.path.getsize(full)}\t{digest.hexdigest()}"
    kept = []
    seen = set()
    for row in rows:
        rel = row.split("\t", 1)[0]
        if rel in removed:
            continue
        if rel in pins:
            row = pins[rel]
            seen.add(rel)
        kept.append(row)
    # A scene git tracks has no lock row: the commit carries its bytes.
    missing = set(pins) - seen
    for rel in sorted(missing):
        listed = subprocess.run(["git", "ls-files", "--", rel], cwd=project[4:] if project.startswith("\\\\?\\") else project, capture_output=True).stdout
        if listed.strip():
            missing.discard(rel)
    if missing:
        fail(f"scenes with no lock row: {sorted(missing)[:3]}")
    with open(PAYLOAD_LOCK, "w", encoding="utf-8", newline="") as handle:
        handle.write("\n".join(kept))


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--project", required=True)
    parser.add_argument("--scene", action="append", default=[], help="project-relative scene; repeatable")
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--backup", help="copy every file this run changes or deletes here first")
    parser.add_argument("--manifest", help="write scene, asset and local id rows here")
    parser.add_argument("--update-lock", action="store_true")
    args = parser.parse_args()
    project = lp(args.project)

    assets, scenes, bodies, per_scene = plan(project, set(args.scene))
    owners = collections.Counter(guid for moved in per_scene.values() for guid in moved)
    moved_all = set(owners)
    print(f"scenes {len(per_scene)}, logic assets {len(moved_all)}, in more than one scene "
          f"{sum(1 for n in owners.values() if n > 1)}")
    if not moved_all:
        print("nothing to do")
        return 0
    results = {}
    manifest = []
    for scene_guid, moved in per_scene.items():
        rel = scenes[scene_guid]
        before = read(os.path.join(project, *rel.split("/")))
        results[rel], local = embed(before, scene_guid, moved, bodies, assets, scenes)
        del before
        manifest.extend(f"{rel}\t{assets[g]}\t{g}\t{local[g]}" for g in sorted(moved))
        if args.apply:
            full = os.path.join(project, *rel.split("/"))
            if args.backup:
                target = os.path.join(args.backup, *rel.split("/"))
                os.makedirs(os.path.dirname(target), exist_ok=True)
                shutil.copy2(full, target)
            with open(full + ".embed-tmp", "wb") as handle:
                handle.write(results[rel])
            results[rel] = None
    left = [] if args.scene else check_left_behind(project, assets, scenes, moved_all)
    if left:
        for path in [os.path.join(project, *r.split("/")) + ".embed-tmp" for r in results]:
            if os.path.exists(path):
                os.remove(path)
        fail(f"{len(left)} assets stay behind with a pointer into a scene or a moved asset: {left[:5]}")
    if args.manifest:
        with open(args.manifest, "w", encoding="utf-8", newline="\n") as handle:
            handle.write("scene\tasset\tguid\tlocal_id\n" + "\n".join(manifest) + "\n")
    if not args.apply:
        print(f"dry run: would rewrite {len(results)} scenes and delete {len(moved_all)} assets")
        return 0
    for rel in results:
        full = os.path.join(project, *rel.split("/"))
        os.replace(full + ".embed-tmp", full)
    removed = set()
    for guid in moved_all:
        rel = assets[guid]
        full = os.path.join(project, *rel.split("/"))
        if args.backup:
            target = os.path.join(args.backup, *rel.split("/"))
            os.makedirs(os.path.dirname(target), exist_ok=True)
            shutil.copy2(full, target)
            shutil.copy2(full + ".meta", target + ".meta")
        os.remove(full)
        os.remove(full + ".meta")
        removed.add(rel)
    if args.update_lock:
        update_lock(project, removed, list(results))
    print(f"rewrote {len(results)} scenes, deleted {len(removed)} assets")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except ValueError as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
