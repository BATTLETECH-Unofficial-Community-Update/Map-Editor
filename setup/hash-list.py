import sys, os, hashlib
root = sys.argv[1]
for rel in open(sys.argv[2], encoding='utf-8').read().splitlines():
    p = os.path.join(root, rel)
    print(f"{rel}\t{hashlib.sha256(open(p,'rb').read()).hexdigest() if os.path.exists(p) else '-'}")
