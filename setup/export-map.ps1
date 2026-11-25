# One map's AssetRipper export under the size watch (the picker's step 2): launch-ar.ps1 starts Mapkit Asset Manager detached,
# watch-export.ps1 samples the output every 5 s and stops it on a size, disk or RAM rule. Exit 0 only when the watch ended normally
# and the tool's log ends "Export complete."; a stop rule exits with the watcher's code (2 bytes, 5 projected, 3 disk, 4 RAM) and
# writes `TRIPPED <reason>` to -WatchLog. Prints `watch-exit <n>` and the last lines of the tool's log.
#   -In <staged input>  -Out <export folder>  -Ar <AssetRipper.CLI.dll of Mapkit Asset Manager>  -ArLog <tool log>  -WatchLog <watch log>
#   -LimitBytes <hard cap on the export's bytes>  [-DriveFreeMinGB 10]
param([Parameter(Mandatory)][string]$In, [Parameter(Mandatory)][string]$Out, [Parameter(Mandatory)][string]$Ar,
      [Parameter(Mandatory)][string]$ArLog, [Parameter(Mandatory)][string]$WatchLog, [Parameter(Mandatory)][int64]$LimitBytes, [int]$DriveFreeMinGB = 10)
$ErrorActionPreference = 'Stop'
$started = & (Join-Path $PSScriptRoot 'launch-ar.ps1') -In $In -Out $Out -Log $ArLog -Ar $Ar
$started
$m = [regex]::Match((@($started) -join "`n"), '(?m)^pid=(\d+) rv=(\d+)')
if (-not $m.Success -or $m.Groups[2].Value -ne '0') { Write-Output "launch failed: $($started -join ' ')"; exit 6 }
$arPid = [int]$m.Groups[1].Value
& (Join-Path $PSScriptRoot 'watch-export.ps1') -Out $Out -CmdPid $arPid -LimitBytes $LimitBytes -Log $WatchLog -DriveFreeMinGB $DriveFreeMinGB
$code = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE } # the watcher exits 0 on a normal end and 2..5 on a stop rule
Write-Output "watch-exit $code"
if (Test-Path $ArLog) { Get-Content $ArLog -Tail 3 }
if ($code -ne 0) { exit $code }
if (-not (Test-Path $ArLog) -or -not (Select-String -Path $ArLog -Pattern 'Export complete' -Quiet)) { Write-Output 'the tool ended without "Export complete."'; exit 7 }
exit 0
