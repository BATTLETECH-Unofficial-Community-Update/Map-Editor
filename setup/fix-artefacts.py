# UCU Map Kit setup: decompiler-artefact fixes, each one recorded with file:line. Run with the Editor closed. Idempotent.
#   py -3 fix-artefacts.py <project>/Assets/HBS-Decompiled      (setup-project.ps1 runs it after decompile.ps1)
import os, re, shutil, sys
if len(sys.argv) != 2 or not os.path.isdir(sys.argv[1]):
    sys.exit("usage: fix-artefacts.py <project>/Assets/HBS-Decompiled (an existing folder)")
root = sys.argv[1]  # Assets/HBS-Decompiled
# 1. Layout: Unity treats a folder named *.Framework as a native plugin bundle and skips its scripts.
src = os.path.join(root, 'BattleTech.Framework'); dst = os.path.join(root, 'BattleTech', 'Framework')
if os.path.isdir(src):
    os.makedirs(os.path.dirname(dst), exist_ok=True); shutil.move(src, dst)
    if os.path.exists(src + '.meta'): os.remove(src + '.meta')
    print(f"moved {src} -> {dst}")
def edit(rel, pat, rep, why):
    f = os.path.join(root, rel); t = open(f, encoding='utf-8').read()
    for m in list(re.finditer(pat, t))[::-1]:
        line = t[:m.start()].count('\n') + 1
        t = t[:m.start()] + m.expand(rep) + t[m.end():]
        print(f"edit {rel}:{line} {why}")
    open(f, 'w', encoding='utf-8', newline='').write(t)
# 2. Explicit interface accessor emitted as a method (CS0683); retail decompile has it too, UCU's source drops it.
edit(os.path.join('BattleTech.UI.TMProWrapper', 'HBS_InputField.cs'),
     r'\n(\t\[SpecialName\]\n)?\tTransform ICanvasElement\.get_transform\(\)\n\t\{\n\t\treturn base\.transform;\n\t\}\n', '\n',
     'removed explicit ICanvasElement.get_transform (CS0683)')
# 3. Nested type printed without its outer type (Dapper SqlMapper.GridReader, CS0246); baseline decompile prints SqlMapper.GridReader.
for rel in (os.path.join('HBS.Data', 'FileBackedSQLiteDB.cs'), os.path.join('BattleTech.Data', 'MetadataDatabase.cs')):
    edit(rel, r'(?<![\w.])GridReader(?= QueryMultiple)', 'SqlMapper.GridReader', 'GridReader -> SqlMapper.GridReader (CS0246)')
# 4. Constrained call on a generic receiver printed as a ref-local copy dance (CS8374); baseline decompile prints the plain assignment.
edit(os.path.join('UIWidgets', 'ListViewCustomHeight.cs'),
     r'ref TItem reference = ref (\w+);\n(\t+)TItem val = default\(TItem\);\n\t+if \(val == null\)\n\t+\{\n\t+val = reference;\n\t+reference = ref val;\n\t+\}\n\t+reference\.Height = CalculateItemHeight\(\1\);',
     r'\1.Height = CalculateItemHeight(\1);', 'ref-local copy dance -> plain assignment (CS8374)')
# 5. Query syntax assigning its range variable (CS1947); UCU's source and the baseline use method syntax.
edit(os.path.join('UIWidgets', 'ListViewBase.cs'),
     r'\(from x in selectedIndicies\n\t+where x != index\n\t+select \(x > index\) \? x-- : x\)\.ToList\(\)',
     'selectedIndicies.Where(x => x != index).Select(x => (x <= index) ? x : x--).ToList()', 'query syntax -> method syntax (CS1947)')
