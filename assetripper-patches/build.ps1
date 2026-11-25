# Build the map kit's AssetRipper: upstream AssetRipper at the pinned commit, plus the patches beside this script, published as
# AssetRipper.CLI. The kit runs the result as an external program and never links it (AssetRipper is GPL-3.0).
#   powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1 -Src <work folder for the source> -Out <publish folder>
# Downloads the source and the NuGet packages the build needs; the built tool sends nothing anywhere.
param([Parameter(Mandatory)][string]$Src, [Parameter(Mandatory)][string]$Out)
$ErrorActionPreference = 'Stop'
$commit = '189ccb660ddaf6e1abdd1422113ea60fde8470b4' # AssetRipper 1.3.14, the version of UCU's AssetRipper-CLI_v2 exports
function Run { & $args[0] @($args | Select-Object -Skip 1); if ($LASTEXITCODE -ne 0) { throw "$($args -join ' ') failed ($LASTEXITCODE)" } }
if (-not (Test-Path (Join-Path $Src '.git'))) {
  Run git init -q $Src
  Run git -C $Src remote add origin https://github.com/AssetRipper/AssetRipper.git
  Run git -C $Src config core.autocrlf false # the patches carry the repository's LF line ends
}
Run git -C $Src fetch -q --depth 1 origin $commit
Run git -C $Src checkout -q -f $commit
Run git -C $Src clean -fdqx Source
foreach ($p in Get-ChildItem $PSScriptRoot -Filter '*.patch' | Sort-Object Name) { Run git -C $Src apply --whitespace=nowarn $p.FullName; "applied $($p.Name)" }
Run dotnet publish (Join-Path $Src 'Source\AssetRipper.CLI\AssetRipper.CLI.csproj') -c Release -o $Out --nologo -v q
"built $Out\AssetRipper.CLI.dll from $commit + patches"
