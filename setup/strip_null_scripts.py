"""UCU Map Kit: remove the null-script MonoBehaviours from an exported map scene by text edit, before its closure is cut.

Retail ships some scene components whose script was stripped before release: `m_Script` is {fileID: 0} in the level file
itself, so the export has nothing to bind them to. On 9 retail maps `HorizonMountains` and
`HorizonMountains/Horizon[ON]_Transition_Terrain` carry one each (KFIX2, read from retail level13 and level26). Unity counts
each as a missing script and logs "The referenced script ... is missing!" on load. UCU removes the same components from
its own map scenes as a retail bug fix (tools/transplant/strip_null_scripts.py in the UCU repository,
whose strip() this copies unchanged). It deletes only the dead `--- !u!114` documents and their `- component:` lines;
nothing else in the scene changes.

A component is removed only if its fileID appears nowhere else in the scene except its own GameObject's component list.
Otherwise the run stops before writing anything. The export is a working copy the chain deletes, so no backup is kept.

Usage (a dry run unless --apply):
    py -3 strip_null_scripts.py --project <ExportedProject> --scene <Assets/...unity>... [--apply] [--manifest FILE]
"""
import argparse
import hashlib
import os
import re
import sys

HEADER = re.compile(rb"^--- !u!(\d+) &(-?\d+)( stripped)?\r?$", re.M)
NULL_SCRIPT = re.compile(rb"^  m_Script: \{fileID: 0\}\r?$", re.M)
OWNER = re.compile(rb"^  m_GameObject: \{fileID: (-?\d+)\}\r?$", re.M)
NAME = re.compile(rb"^  m_Name: (.*?)\r?$", re.M)


def lp(p):  # extended-length path: a plain path past 259 characters fails to open on Windows with LongPathsEnabled = 0 (its default)
    p = os.path.normpath(os.path.abspath(p))
    if os.name != 'nt' or p.startswith('\\\\?\\'): return p
    return '\\\\?\\UNC\\' + p[2:] if p.startswith('\\\\') else '\\\\?\\' + p


def fail(message):
    sys.exit(f"strip_null_scripts: {message}")


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def documents(data):
    marks = list(HEADER.finditer(data))
    for i, m in enumerate(marks):
        end = marks[i + 1].start() if i + 1 < len(marks) else len(data)
        yield m.group(1), m.group(2), bool(m.group(3)), m.start(), end


def strip(data, rel):
    docs = list(documents(data))
    by_id = {fid: (cls, start, end) for cls, fid, _, start, end in docs}
    cuts, removed = [], []
    for cls, fid, stripped, start, end in docs:
        body = data[start:end]
        if cls != b"114" or stripped or not NULL_SCRIPT.search(body):
            continue
        owner = OWNER.search(body)
        if not owner or owner.group(1) not in by_id:
            fail(f"{rel}: &{fid.decode()} has no GameObject in the scene")
        go_cls, go_start, go_end = by_id[owner.group(1)]
        line = re.compile(rb"^  - component: \{fileID: " + re.escape(fid) + rb"\}\r?\n", re.M)
        go_body = data[go_start:go_end]
        lines = list(line.finditer(go_body))
        refs = [m.start() for m in re.finditer(rb"fileID: " + re.escape(fid) + rb"\b", data)]
        if go_cls != b"1" or len(lines) != 1 or len(refs) != 1:
            fail(f"{rel}: &{fid.decode()} is referenced {len(refs)} times / {len(lines)} component lines; not removed")
        name = NAME.search(go_body)
        removed.append((fid.decode(), owner.group(1).decode(), name.group(1).decode("utf-8", "replace") if name else "?"))
        cuts.append((start, end))
        cuts.append((go_start + lines[0].start(), go_start + lines[0].end()))
    out, pos = [], 0
    for start, end in sorted(cuts):
        if start < pos:
            fail(f"{rel}: overlapping cuts")
        out.append(data[pos:start])
        pos = end
    out.append(data[pos:])
    return b"".join(out), removed


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--project", required=True)
    parser.add_argument("--scene", action="append", required=True, help="Assets/... path of a scene to edit")
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--manifest", help="TSV of every removal and the before/after sha256")
    args = parser.parse_args()
    rows, results = [], {}
    for rel in args.scene:
        with open(lp(os.path.join(args.project, *rel.split("/"))), "rb") as handle:
            data = handle.read()
        new, removed = strip(data, rel)
        results[rel] = (data, new)
        for fid, go, name in removed:
            rows.append(f"{rel}\t{fid}\t{go}\t{name}\t{sha256(data)}\t{sha256(new)}\t{len(data)}\t{len(new)}")
        print(f"{rel}: remove {len(removed)} ({', '.join(n for _, _, n in removed)}), {len(data)} -> {len(new)} bytes")
    if args.manifest:
        with open(args.manifest, "w", encoding="utf-8", newline="\n") as handle:
            handle.write("scene\tcomponent\tgameObject\tname\tbeforeSha256\tafterSha256\tbeforeBytes\tafterBytes\n")
            handle.writelines(r + "\n" for r in rows)
    if not args.apply:
        print("dry run: nothing written")
        return
    for rel, (data, new) in results.items():
        if new != data:
            with open(lp(os.path.join(args.project, *rel.split("/"))), "wb") as handle:
                handle.write(new)
    print(f"applied to {sum(1 for d, n in results.values() if n != d)} scenes")


if __name__ == "__main__":
    main()
