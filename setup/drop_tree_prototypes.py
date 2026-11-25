"""UCU Map Kit: drop the tree prototypes that have no prefab, and the tree instances that use them, from an exported map's
TerrainData by text edit, before its closure is cut.

Retail ships some TerrainData with tree prototypes whose prefab is null (MapStory_StoryEncounter2_aDes, retail level44:
prototypes 4 and 5, used by 63 + 51 instances). Unity logs "Tree prefab at index N is missing." for each on every load,
and nothing draws them: RenderTrees and TreeContainer skip an instance whose prototype prefab is null. UCU removes them
from its own copy of that map as a retail bug fix (register E09; tools/transplant/drop_tree_prototypes.py, whose fail(),
block(), items() and edit() this copies unchanged). Here the dropped indices are the prototypes whose entry is
`- prefab: {fileID: 0}`, in every TerrainData of the export (Assets/TerrainData); a TerrainData with none is left alone.
edit() refuses if a dropped prototype has a prefab or if the per-prototype counts of the kept instances change. The
export is a working copy the chain deletes, so no backup is kept.

Usage (a dry run unless --apply):
    py -3 drop_tree_prototypes.py --project <ExportedProject> [--apply] [--manifest FILE]
"""
import argparse
import hashlib
import os
import re
import sys
from collections import Counter


def lp(p):  # extended-length path: a plain path past 259 characters fails to open on Windows with LongPathsEnabled = 0 (its default)
    p = os.path.normpath(os.path.abspath(p))
    if os.name != 'nt' or p.startswith('\\\\?\\'): return p
    return '\\\\?\\UNC\\' + p[2:] if p.startswith('\\\\') else '\\\\?\\' + p


def fail(message):
    sys.exit(f"drop_tree_prototypes: {message}")


def block(lines, header):
    """Index range [start, end) of the list items under `header` (the header line itself excluded)."""
    hits = [i for i, l in enumerate(lines) if l.rstrip("\r") == header]
    if len(hits) != 1:
        fail(f"{header.strip()} found {len(hits)} times")
    start = hits[0] + 1
    indent = len(header) - len(header.lstrip())
    end = start
    item, cont = " " * indent + "- ", " " * (indent + 2)
    while end < len(lines) and (lines[end].startswith(item) or lines[end].startswith(cont)):
        end += 1
    return start, end


def items(lines, start, end, indent):
    out, cur = [], None
    for i in range(start, end):
        if lines[i].startswith(" " * indent + "- "):
            if cur is not None:
                out.append(cur)
            cur = [i]
        else:
            cur.append(i)
    if cur is not None:
        out.append(cur)
    return out


def edit(data, drop):
    nl = "\r\n" if "\r\n" in data else "\n"
    lines = data.split(nl)
    p0, p1 = block(lines, "    m_TreePrototypes:")
    protos = items(lines, p0, p1, 4)
    for d in drop:
        if d >= len(protos):
            fail(f"prototype {d} does not exist ({len(protos)} prototypes)")
        if lines[protos[d][0]].strip() != "- prefab: {fileID: 0}":
            fail(f"prototype {d} has a prefab: {lines[protos[d][0]].strip()}")
    i0, i1 = block(lines, "    m_TreeInstances:")
    insts = items(lines, i0, i1, 4)
    index_re = re.compile(r"^      index: (\d+)\r?$")
    before, after = Counter(), Counter()
    keep_inst = []
    for entry in insts:
        idx_lines = [k for k in entry if index_re.match(lines[k])]
        if len(idx_lines) != 1:
            fail(f"tree instance at line {entry[0] + 1} has {len(idx_lines)} index lines")
        k = idx_lines[0]
        old = int(index_re.match(lines[k]).group(1))
        before[old] += 1
        if old in drop:
            continue
        new = old - sum(1 for d in drop if d < old)
        lines[k] = f"      index: {new}"
        after[new] += 1
        keep_inst.append(entry)
    remap = {old: old - sum(1 for d in drop if d < old) for old in range(len(protos)) if old not in drop}
    expected = Counter({remap[o]: n for o, n in before.items() if o not in drop})
    if after != expected:
        fail(f"per-prototype counts changed: expected {sorted(expected.items())}, got {sorted(after.items())}")
    dropped_lines = {k for d in drop for k in protos[d]}
    kept_inst_lines = {k for e in keep_inst for k in e}
    out = []
    for i, l in enumerate(lines):
        if i in dropped_lines:
            continue
        if i0 <= i < i1 and i not in kept_inst_lines:
            continue
        out.append(l)
    return nl.join(out), before, after, len(protos)


def null_prototypes(lines):
    """Indices of the m_TreePrototypes entries whose prefab is {fileID: 0}; None when the file has no tree prototype list."""
    if sum(1 for l in lines if l.rstrip("\r") == "    m_TreePrototypes:") != 1:
        return None
    p0, p1 = block(lines, "    m_TreePrototypes:")
    return [i for i, it in enumerate(items(lines, p0, p1, 4)) if lines[it[0]].strip() == "- prefab: {fileID: 0}"]


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--project", required=True)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--manifest", help="TSV of every edited TerrainData and the before/after counts and sha256")
    args = parser.parse_args()
    folder = lp(os.path.join(args.project, "Assets", "TerrainData"))
    sha = lambda b: hashlib.sha256(b).hexdigest()
    rows, writes, binary = [], [], 0
    names = sorted(f for f in os.listdir(folder) if f.endswith(".asset")) if os.path.isdir(folder) else []
    for name in names:
        full = os.path.join(folder, name)
        with open(full, "rb") as handle:
            raw = handle.read()
        if not raw.startswith(b"%YAML"):
            binary += 1; continue
        text = raw.decode("utf-8")
        drop = null_prototypes(text.split("\r\n" if "\r\n" in text else "\n"))
        if not drop:
            continue
        new_text, before, after, nprotos = edit(text, drop)
        new = new_text.encode("utf-8")
        print(f"Assets/TerrainData/{name}: {nprotos} prototypes, drop {drop}; instances {sum(before.values())} -> {sum(after.values())}; "
              f"bytes {len(raw)} -> {len(new)}")
        rows.append(f"Assets/TerrainData/{name}\t{','.join(map(str, drop))}\t{sorted(before.items())}\t{sorted(after.items())}\t{sha(raw)}\t{sha(new)}")
        writes.append((full, new))
    print(f"TerrainData files={len(names)}, not YAML (not read)={binary}, with null-prefab tree prototypes={len(writes)}")
    if args.manifest:
        with open(args.manifest, "w", encoding="utf-8", newline="\n") as handle:
            handle.write("path\tdropped\tbefore_counts\tafter_counts\tsha256_before\tsha256_after\n")
            handle.writelines(r + "\n" for r in rows)
    if not args.apply:
        print("dry run: nothing written")
        return
    for full, new in writes:
        with open(full, "wb") as handle:
            handle.write(new)
    print(f"applied to {len(writes)} TerrainData files")


if __name__ == "__main__":
    main()
