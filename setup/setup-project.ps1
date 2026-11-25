# UCU Map Kit setup: turn a new, empty Unity 6000.6.9f1 project into a kit project (README "Setup"). Run it with Unity closed:
#   powershell -NoProfile -ExecutionPolicy Bypass -File <kit folder>\setup\setup-project.ps1 -Ucu <UCU install> -Retail <retail BATTLETECH install> -Project <Unity project>
#     [-Unity <Unity.exe>]   default: Unity Hub's 6000.6.9f1 under Program Files
#     [-Work <folder>]       default: <project>\..\mapkit-work (the decompiler's output and setup's logs; outside the project)
#     [-Name <name>]         the project's name in Unity Hub, and its productName; default: the project folder's name
#     [-Company <name>]      its companyName; default: UCU Map Kit
# Needs Python 3 (py -3 or python), the .NET SDK (dotnet) and ilspycmd 9.0.0.7889, and a UCU install with ModTek v4 in Mods\ModTek.
# Reads the UCU and retail installs, never writes to them.
# Steps, each one stops setup when it fails: 1 packages (add_packages.py), 2 the game's layer and tag table, 3 Assets/csc.rsp, 4 project
# settings in batch mode (MapKitSetup.cs: Linear, .NET Framework, unsafe code, deferred, Windows graphics APIs D3D12 then D3D11, the retail
# folder for Extract Retail Maps, the project's name and company), 5 game code (decompile.ps1, fix-artefacts.py, block-ns.py), 6 the kit itself into
# Packages/com.ucu.mapkit, 7 the deferred shader overrides (deferred-overrides.py), 8 the loader mod MapKitLoader built from Loader~ with
# dotnet into <project>\MapKitOutput\_loader\MapKitLoader (where Test Map in UCU builds it), 9 the first compile with the API updater on
# (gate: Unity exit 0 and no `error CS`). Ends with SETUP OK or exit 1.
param([Parameter(Mandatory)][string]$Ucu, [Parameter(Mandatory)][string]$Retail, [Parameter(Mandatory)][string]$Project,
      [string]$Unity = (Join-Path $env:ProgramFiles 'Unity\Hub\Editor\6000.6.9f1\Editor\Unity.exe'), [string]$Work = '',
      [string]$Name = '', [string]$Company = '')
$ErrorActionPreference = 'Stop'
$kit = Split-Path $PSScriptRoot -Parent
$Project = (Resolve-Path $Project).Path.TrimEnd('\')
if (-not $Work) { $Work = Join-Path (Split-Path $Project -Parent) 'mapkit-work' }
$logs = Join-Path $Work 'logs'
New-Item -ItemType Directory -Force $logs | Out-Null

# Checks first: nothing is written until all of them pass.
if (-not (Test-Path "$Ucu\BattleTech_Data\Managed\Assembly-CSharp.dll")) { throw "Not a UCU install: $Ucu\BattleTech_Data\Managed\Assembly-CSharp.dll is missing." }
if (-not (Test-Path "$Ucu\Mods\ModTek\lib\0Harmony.dll")) { throw "$Ucu has no Mods\ModTek ($Ucu\Mods\ModTek\lib\0Harmony.dll is missing; MapKitLoader is built against it). Install ModTek v4 into $Ucu\Mods\ModTek (the kit README, Prerequisites, says where to get it): the Mod support box in UCU's installer installs only Doorstop and UCU's bootstrap, not ModTek." }
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) { throw "The .NET SDK (dotnet) is not on PATH: setup builds MapKitLoader with it." }
if (-not (Test-Path "$Retail\BattleTech_Data")) { throw "Not a BATTLETECH install: $Retail\BattleTech_Data is missing." }
if (-not (Test-Path "$Project\Packages\manifest.json")) { throw "Not a Unity project: $Project\Packages\manifest.json is missing. Create the project with Unity 6000.6.9f1 first." }
if (-not (Select-String -Quiet -SimpleMatch 'm_EditorVersion: 6000.6.9f1' "$Project\ProjectSettings\ProjectVersion.txt")) { throw "The project is not a Unity 6000.6.9f1 project ($Project\ProjectSettings\ProjectVersion.txt)." }
if ((Test-Path "$Project\Packages\com.ucu.mapkit") -or (Test-Path "$Project\Assets\HBS-Decompiled")) { throw "Setup runs once, on a new project: $Project already has the kit or the game code." }
if ($kit.TrimEnd('\').StartsWith($Project + '\', [StringComparison]::OrdinalIgnoreCase)) { throw "Run setup from a kit folder outside the project, not from $kit." }
if ((Get-Content -Raw "$kit\package.json") -notmatch '"name":\s*"com\.ucu\.mapkit"') { throw "$kit is not the UCU Map Kit (package.json)." }
if (-not (Test-Path $Unity)) { throw "Unity 6000.6.9f1 is not at $Unity (pass -Unity <Unity.exe>)." }
$rx = [regex]::Escape($Project) + '(["\s\\]|$)'
function Test-ProjectOpen { @(Get-CimInstance Win32_Process -Filter "Name='Unity.exe'" | Where-Object { $_.CommandLine -and $_.CommandLine.Replace('/', '\') -match $rx }).Count -gt 0 }
if (Test-ProjectOpen) { throw "Unity has $Project open. Close it and run setup again." }
$py = if (Get-Command py -ErrorAction SilentlyContinue) { @('py', '-3') } else { @('python') }
function Invoke-Py { & $py[0] @($py | Select-Object -Skip 1) @args; if ($LASTEXITCODE) { throw "$($args[0]) failed (exit $LASTEXITCODE)." } }

# One blocking batch Unity run (the kit's batch-unity.ps1 without its repo lookup): waits until no Unity process holds the project.
function Invoke-Unity([string]$Log, [string]$Extra) {
    $a = "-batchmode -quit -projectPath `"$Project`" -logFile `"$Log`" $Extra"
    "start $(Get-Date -Format o): $Unity $a"
    $p = Start-Process -FilePath $Unity -ArgumentList $a -PassThru -WindowStyle Hidden
    $p.WaitForExit()
    while (Test-ProjectOpen) { Start-Sleep 5 }
    "end $(Get-Date -Format o) unityExit=$($p.ExitCode) logBytes=$((Get-Item $Log).Length)"
    $p.ExitCode
}

"== 1/9 packages"
Invoke-Py (Join-Path $PSScriptRoot 'add_packages.py') $Project
"== 2/9 layer and tag table (UCU's ProjectSettings/TagManager.asset: bundle prefabs and the template use retail's layers)"
Copy-Item (Join-Path $PSScriptRoot 'ProjectSettings~\TagManager.asset') "$Project\ProjectSettings\TagManager.asset" -Force
"== 3/9 Assets/csc.rsp"
[IO.File]::WriteAllText("$Project\Assets\csc.rsp", "-warnaserror-:0619`n-langversion:12.0`n")
"== 4/9 project settings"
$stage = "$Project\Assets\MapKitSetup"
New-Item -ItemType Directory -Force "$stage\Editor" | Out-Null
[IO.File]::WriteAllText("$stage\Editor\MapKitSetup.cs", "#define MAPKIT_SETUP`n" + [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'MapKitSetup.cs')))
$log = Join-Path $logs 'setup-4-settings.log'
$named = $(if ($Name) { " -mapkitName `"$Name`"" }) + $(if ($Company) { " -mapkitCompany `"$Company`"" })
try { $out = Invoke-Unity $log "-accept-apiupdate -executeMethod MapKitSetup.ApplySettings -mapkitRetail `"$Retail`"$named" }
finally { Remove-Item -Recurse -Force $stage, "$stage.meta" -ErrorAction SilentlyContinue }
$out | Select-Object -SkipLast 1
$line = Select-String -Path $log -Pattern '^MAPKIT_SETUP ' | Select-Object -Last 1
if ($out[-1] -ne 0 -or -not $line -or $line.Line -notmatch 'apis=Direct3D12,Direct3D11 .* hubName=\S') { throw "Project settings failed (Unity exit $($out[-1])); see $log." }
$line.Line
"== 5/9 game code"
& (Join-Path $PSScriptRoot 'decompile.ps1') -Ucu $Ucu -Project $Project -Work $Work
Invoke-Py (Join-Path $PSScriptRoot 'fix-artefacts.py') "$Project\Assets\HBS-Decompiled"
Invoke-Py (Join-Path $PSScriptRoot 'block-ns.py') "$Project\Assets"
"== 6/9 the kit into Packages/com.ucu.mapkit"
robocopy $kit "$Project\Packages\com.ucu.mapkit" /E /XD __pycache__ obj .git /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "Copying the kit failed (robocopy $LASTEXITCODE)." }
"kit files=$((Get-ChildItem "$Project\Packages\com.ucu.mapkit" -Recurse -File).Count)"
"== 7/9 deferred shader overrides (UCU's GraphicsSettings values: the kit's recovered deferred, reflections and screen-space shadow shaders)"
Invoke-Py (Join-Path $PSScriptRoot 'deferred-overrides.py') $Project
"== 8/9 MapKitLoader (the loader mod every kit map needs; built from Loader~ against this UCU install)"
$lw = "$Project\MapKitOutput\_loader"
if (Test-Path $lw) { Remove-Item -Recurse -Force $lw }
New-Item -ItemType Directory -Force "$lw\src" | Out-Null
Copy-Item (Join-Path $kit 'Loader~\*') "$lw\src" -Include *.cs, *.csproj, mod.json
$log = Join-Path $logs 'setup-8-loader.log'
& { $ErrorActionPreference = 'Continue'   # a native stderr line under Stop would end setup before the exit code is read
    dotnet build "$lw\src\MapKitLoader.csproj" -c Release -nologo "-p:ManagedDir=$Ucu\BattleTech_Data\Managed" "-p:HarmonyDll=$Ucu\Mods\ModTek\lib\0Harmony.dll" -o "$lw\MapKitLoader" *> $log }
if ($LASTEXITCODE -or -not (Test-Path "$lw\MapKitLoader\MapKitLoader.dll")) { throw "Building MapKitLoader failed (dotnet exit $LASTEXITCODE); see $log." }
"MapKitLoader: $lw\MapKitLoader (MapKitLoader.dll sha256 $((Get-FileHash "$lw\MapKitLoader\MapKitLoader.dll").Hash))"
"== 9/9 first compile (API updater on: Addressables 3.1.0 calls two renamed functions)"
$log = Join-Path $logs 'setup-9-compile.log'
$out = Invoke-Unity $log '-accept-apiupdate'
$out | Select-Object -SkipLast 1
$errors = @(Select-String -Path $log -Pattern 'error CS\d+')
"errorCS=$($errors.Count)"
$errors | Select-Object -First 10 | ForEach-Object { $_.Line }
if ($out[-1] -ne 0 -or $errors.Count) { "SETUP FAILED at the first compile; see $log."; exit 1 }
"SETUP OK: $Project (log $log)"
