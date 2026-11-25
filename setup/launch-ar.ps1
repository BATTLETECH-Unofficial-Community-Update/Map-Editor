# Detached AssetRipper export: -In (staged BATTLETECH folder) -Out (export folder) -Log. Same launcher as D2-b's, parametrized (KR0).
# -Ar: the AssetRipper.CLI.dll to run (assetripper-patches/build.ps1 makes the map kit's; the stock 1.3.14 build also runs).
param([Parameter(Mandatory)][string]$In, [Parameter(Mandatory)][string]$Out, [Parameter(Mandatory)][string]$Log, [Parameter(Mandatory)][string]$Ar)
$cmd = "cmd.exe /c dotnet `"$ar`" `"$In`" `"$Out`" > `"$Log`" 2>&1"
$si = New-CimInstance -ClassName Win32_ProcessStartup -ClientOnly -Property @{ ShowWindow = [uint16]0 }
$r = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = $cmd; ProcessStartupInformation = $si }
"cmd: $cmd"; "pid=$($r.ProcessId) rv=$($r.ReturnValue) at $(Get-Date -Format o)"
