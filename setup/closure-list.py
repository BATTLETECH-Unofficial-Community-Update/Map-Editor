# File-level closure names of a level (level itself plus recursive externals within BattleTech_Data), one per line, read-only.
import sys, os
from UnityPy.files import SerializedFile
from UnityPy.streams import EndianBinaryReader
root, start = sys.argv[1], sys.argv[2]
seen = []; todo = [start]
while todo:
    n = todo.pop()
    if n in seen: continue
    p = os.path.join(root, n)
    if not os.path.exists(p): print('MISSING', n, file=sys.stderr); continue
    seen.append(n)
    sf = SerializedFile(EndianBinaryReader(open(p, 'rb').read()))
    for e in sf.externals:
        b = e.path.replace('library/', '').split('/')[-1]
        if b.startswith('unity default') or b.startswith('unity_builtin'): continue
        todo.append(b)
print('\n'.join(seen))
