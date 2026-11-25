# Stage AssetRipper input from the GOG install (read-only on the install; delete-then-copy, never through a hard link).
#   closure mode (D2-b, KR0):  -List <file of base names>  -> each name plus .resS/.resource (a .assets file's .resource drops the
#                                                             .assets), globalgamemanagers, Managed, Resources
#   all-levels mode (KR1a):    -All                        -> every top-level file of BattleTech_Data (levels, sharedassets, resources,
#                                                             globalgamemanagers, .resS/.resource, boot.config, app.info), Managed, Resources
#   -StreamingAssets           also stage BattleTech_Data\StreamingAssets (robocopy /E)
# GI and Plugins are never staged (D2-b's input did not carry them). Output: a summary line, then name<TAB>bytes per top-level file.
param([Parameter(Mandatory)][string]$Install, [Parameter(Mandatory)][string]$Out, [string]$List = '',
      [switch]$All, [switch]$StreamingAssets)
if (-not $All -and -not $List) { throw 'give -List <file> or -All' }
# Extended-length paths for every PowerShell and .NET call on the staged tree: Windows PowerShell 5.1 does not open a path past 259
# characters (LongPathsEnabled = 0, the Windows default), and the project folder this lands in can be as long as the modder likes.
# robocopy takes the plain paths: it handles long paths itself.
function Get-LongPath([string]$p) { $p = [IO.Path]::GetFullPath($p); if ($p.StartsWith('\\?\')) { $p } elseif ($p.StartsWith('\\')) { '\\?\UNC\' + $p.Substring(2) } else { '\\?\' + $p } }
$srcP = Join-Path $Install 'BattleTech_Data'; $dstP = Join-Path $Out 'BattleTech_Data'
$src = Get-LongPath $srcP; $dst = Get-LongPath $dstP; $Out = Get-LongPath $Out
if (Test-Path -LiteralPath $dst) { throw "staging folder exists, delete it first: $dstP" }
[void][IO.Directory]::CreateDirectory($dst)
$n = 0; $bytes = 0
if ($All) { $files = @(Get-ChildItem -LiteralPath $src -File | ForEach-Object { $_.Name }) }
else {
  $names = @(Get-Content $List | Where-Object { $_ }) + @('globalgamemanagers')
  # Unity names a .assets file's streamed media <base>.resource, without the .assets (sharedassets84.assets -> sharedassets84.resource):
  # the VideoClips' bytes. Without it Mapkit Asset Manager writes each VideoClip as YAML that points at the missing file, and every
  # Build Mod logged "Failed to pack resource file" (KFIX5).
  $files = foreach ($b in $names) { foreach ($f in (@($b, "$b.resS", "$b.resource", (($b -replace '\.assets$', '') + '.resource')) | Select-Object -Unique)) { if (Test-Path -LiteralPath ([IO.Path]::Combine($src, $f))) { $f } } }
}
foreach ($f in $files) { $p = [IO.Path]::Combine($src, $f); Copy-Item -LiteralPath $p -Destination ([IO.Path]::Combine($dst, $f)); $n++; $bytes += (Get-Item -LiteralPath $p).Length }
$dirs = @('Managed', 'Resources'); if ($StreamingAssets) { $dirs += 'StreamingAssets' }
foreach ($d in $dirs) { robocopy (Join-Path $srcP $d) (Join-Path $dstP $d) /E /NFL /NDL /NJH /NJS /NP | Out-Null; $s = (Get-ChildItem -LiteralPath ([IO.Path]::Combine($dst, $d)) -Recurse -File | Measure-Object Length -Sum); $n += $s.Count; $bytes += $s.Sum; "dir $d files=$($s.Count) bytes=$($s.Sum)" }
Copy-Item -LiteralPath (Join-Path $Install 'BattleTech.exe') -Destination $Out -ErrorAction SilentlyContinue
"staged files=$n bytes=$bytes"
Get-ChildItem -LiteralPath $dst -File | Sort-Object Name | ForEach-Object { "{0}`t{1}" -f $_.Name, $_.Length }
