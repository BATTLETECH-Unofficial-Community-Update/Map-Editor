# UCU Map Kit setup, game code (last part): rewrite each file's `namespace X;` into `namespace X { ... }` (README "What setup does";
# the same transform as UCU's own block_namespace, reimplemented here because a modder has no UCU repo). Usage: block-ns.py <project>/Assets
# Exits 1 when a file is left.
import os, re, sys
if len(sys.argv) != 2 or not os.path.isdir(os.path.join(sys.argv[1], "HBS-Decompiled")):
    sys.exit("usage: block-ns.py <project>/Assets (it must hold HBS-Decompiled: run decompile.ps1 first)")
rx = re.compile(rb"(?m)^namespace ([^\r\n;]+);(?=\r?$)")
def block(path):
    raw = open(path, "rb").read(); m = rx.search(raw)
    if not m: return False
    eol = b"\r\n" if raw[m.end():].startswith(b"\r\n") else b"\n"
    out = raw[:m.start()] + b"namespace " + m.group(1) + eol + b"{" + raw[m.end():]
    open(path, "wb").write(out + (b"" if out.endswith(eol) else eol) + b"}" + eol)
    return True
n = conv = 0
for sub in ("HBS-Decompiled", "Plugins/HBS-Decompiled-firstpass"):
    for root, dirs, files in os.walk(os.path.join(sys.argv[1], sub)):
        for f in files:
            if f.endswith(".cs"):
                n += 1; conv += block(os.path.join(root, f))
left = sum(1 for sub in ("HBS-Decompiled", "Plugins/HBS-Decompiled-firstpass") for r, _, fs in os.walk(os.path.join(sys.argv[1], sub))
           for f in fs if f.endswith(".cs") and rx.search(open(os.path.join(r, f), "rb").read()))
print(f"cs files={n} converted={conv} file-scoped left={left}")
if left:
    sys.exit(1)
