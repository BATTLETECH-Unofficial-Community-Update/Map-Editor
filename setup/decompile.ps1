# UCU Map Kit setup, game code: decompile the UCU install's Assembly-CSharp and firstpass into the kit project, and copy the third-party
# DLLs, sqlite3.dll and the game database (MetadataDatabase.db) from the UCU install. Newtonsoft.Json.dll is left out (the package
# com.unity.nuget.newtonsoft-json, which add_packages.py pins); Mono.Data.Sqlite.dll is added (needed by the decompiled code, d2b round d). Run with Unity closed; setup-project.ps1 runs it.
#   decompile.ps1 -Ucu <UCU install> -Project <Unity project> -Work <work folder, emptied of its decompile\ subfolder>
# Needs ilspycmd 9.0.0.7889 as a dotnet tool (fix-artefacts.py matches that version's output).
# Stops on a failed input check, decompile or copy.
param([Parameter(Mandatory)][string]$Ucu, [Parameter(Mandatory)][string]$Project, [Parameter(Mandatory)][string]$Work)
$ErrorActionPreference = 'Continue' # ilspycmd's stderr (its update notice) must not stop the run; every failure below throws
$m ="$Ucu\BattleTech_Data\Managed"; $p = "$Project\Assets"
if (-not (Test-Path "$m\Assembly-CSharp.dll")) { throw "Not a UCU install: $m\Assembly-CSharp.dll is missing." }
if (-not (Test-Path $p)) { throw "Not a Unity project: $p is missing." }
$il = "$env:USERPROFILE\.dotnet\tools\ilspycmd.exe"
if (-not (Test-Path $il)) { $il = (Get-Command ilspycmd -ErrorAction SilentlyContinue).Source }
if (-not $il) { throw "ilspycmd is not installed: dotnet tool install -g ilspycmd --version 9.0.0.7889" }
Remove-Item Env:DOTNET_ROLL_FORWARD -ErrorAction SilentlyContinue
$ver = (& $il --version) -join "`n"
$ver
if ($LASTEXITCODE -ne 0) { throw "ilspycmd did not start (exit $LASTEXITCODE). ilspycmd 9.0.0.7889 runs only on the .NET 8 runtime: install it (the runtimes found: $((& dotnet --list-runtimes 2>$null | Select-String '^Microsoft.NETCore.App ' | ForEach-Object { ($_.Line -split ' ')[1] }) -join ', ')), then run setup again." }
if ($ver -notmatch 'ilspycmd: 9\.0\.0\.7889') { throw "ilspycmd 9.0.0.7889 is needed (found: $(($ver -split "`n")[0])): dotnet tool update -g ilspycmd --version 9.0.0.7889" }
$tmp = "$Work\decompile"; Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
foreach ($a in 'Assembly-CSharp', 'Assembly-CSharp-firstpass') {
  $t0 = Get-Date
  & $il -p -o "$tmp\$a" "$m\$a.dll" 2>&1 | Select-Object -Last 3
  $rc = $LASTEXITCODE
  "$a exit=$rc secs=$([int]((Get-Date)-$t0).TotalSeconds) files=$((Get-ChildItem "$tmp\$a" -Recurse -Filter *.cs).Count)"
  if ($rc -ne 0) { throw "ilspycmd failed on $a.dll (exit $rc)." }
}
Get-ChildItem $tmp -Recurse -Include *.csproj | ForEach-Object { "drop $($_.FullName)"; Remove-Item $_.FullName }
Get-ChildItem $tmp -Recurse -Directory -Filter Properties | ForEach-Object { Get-ChildItem $_.FullName | ForEach-Object { "drop $($_.FullName)" }; Remove-Item -Recurse $_.FullName }
robocopy "$tmp\Assembly-CSharp" "$p\HBS-Decompiled" /E /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "Copying the decompiled Assembly-CSharp failed (robocopy $LASTEXITCODE)." }
New-Item -ItemType Directory -Force "$p\Plugins" | Out-Null
robocopy "$tmp\Assembly-CSharp-firstpass" "$p\Plugins\HBS-Decompiled-firstpass" /E /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "Copying the decompiled firstpass failed (robocopy $LASTEXITCODE)." }
$dlls = '0Harmony','BattleTech.Common','DOTween','DOTween43','DOTween46','DOTweenPro','Dapper.Unity','GalaxyCSharp','Google.Protobuf.Unity','HBSNet','HBSNetUdp','InControl','Ionic.Zip','LibTessDotNet','Lidgren.Network','NGettext','ServiceStack.Interfaces','ShadowrunDTO','ShadowrunSerializer','StringObfuscator','UnityUIExtensions','com.rlabrecque.steamworks.net','protobuf-net','Mono.Data.Sqlite'
New-Item -ItemType Directory -Force "$p\Plugins\Managed" | Out-Null
foreach ($d in $dlls) { Copy-Item "$m\$d.dll" "$p\Plugins\Managed\" -ErrorAction Stop }
"copied dlls=$((Get-ChildItem "$p\Plugins\Managed" -Filter *.dll).Count)"
New-Item -ItemType Directory -Force "$p\Plugins\x86_64", "$p\StreamingAssets\MDD" | Out-Null
Copy-Item "$Ucu\BattleTech_Data\Plugins\x86_64\sqlite3.dll" "$p\Plugins\x86_64\sqlite3.dll" -ErrorAction Stop
Copy-Item "$Ucu\BattleTech_Data\StreamingAssets\MDD\MetadataDatabase.db" "$p\StreamingAssets\MDD\MetadataDatabase.db" -ErrorAction Stop
"cs in HBS-Decompiled=$((Get-ChildItem "$p\HBS-Decompiled" -Recurse -Filter *.cs).Count) firstpass=$((Get-ChildItem "$p\Plugins\HBS-Decompiled-firstpass" -Recurse -Filter *.cs).Count)"
