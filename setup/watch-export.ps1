# Size watch for a detached AssetRipper export (moved out of KR1a's kr1-run.ps1 and fixed). Ends when the launcher's cmd.exe (-CmdPid) ends or a stop rule trips.
#   -Out <export folder>  -CmdPid <pid launch-ar.ps1 printed>  -LimitBytes <hard cap, e.g. 2 x retail BattleTech_Data>  -Log <watch.log>
#   -DriveFreeMinGB (default 100)  -RamFreeMinGB (default 1.5)  -IntervalSec (default 5)
# Stop rules (kill the export's process tree; RAM trip SUSPENDS the dotnet child with NtSuspendProcess instead):
#   1. output bytes over the cap;
#   2. PROJECTED: bytes + rate x (IntervalSec + scan time) x 2 would pass the cap by the next sample (KR1a: samples 60 s apart, the export crossed 2x retail
#      between two of them and finished at 2.04x; the rate near the end was about 190 MB/s);
#   3. free space on the output drive below -DriveFreeMinGB;
#   4. free RAM below -RamFreeMinGB.
# Fixes against KR1a's loop: 5 s samples (was 60 s), the projection rule, and the dotnet child is picked by name (KR1a took the first child of cmd.exe, which
# can be conhost.exe: its working set read 0.0 GB and a RAM trip would have suspended the wrong process).
# A trip writes `TRIPPED <reason>` to the log and exits non-zero (2 bytes, 5 projected, 3 disk, 4 RAM). Normal end: `WATCH DONE`, exit 0.
param([Parameter(Mandatory)][string]$Out, [Parameter(Mandatory)][int]$CmdPid, [Parameter(Mandatory)][int64]$LimitBytes, [Parameter(Mandatory)][string]$Log,
      [int]$DriveFreeMinGB = 100, [double]$RamFreeMinGB = 1.5, [int]$IntervalSec = 5)
Add-Type -Namespace Nt -Name P -MemberDefinition '[DllImport("ntdll.dll")] public static extern int NtSuspendProcess(IntPtr h);'
$drive = (Split-Path -Qualifier (Resolve-Path -LiteralPath (Split-Path $Out -Parent)).Path).TrimEnd(':')
function L($m) { ("{0} {1}" -f (Get-Date -Format o), $m) | Out-File -Append -Encoding ascii $Log }
function Free { (Get-PSDrive $drive).Free }
function RamFree { (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory * 1KB }
function Kill { Get-CimInstance Win32_Process -Filter "ParentProcessId=$CmdPid" | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }; Stop-Process -Id $CmdPid -Force -ErrorAction SilentlyContinue }
# Extended-length form: an export file past 259 characters (a long project folder; Mapkit Asset Manager writes them) is skipped silently by a plain
# enumeration on Windows PowerShell 5.1 with LongPathsEnabled = 0, so the size rules would see fewer bytes than the disk holds.
function DirBytes($p) { $b = 0L; $n = 0; $q = '\\?\' + [IO.Path]::GetFullPath($p); if ([IO.Directory]::Exists($q)) { foreach ($f in ([IO.DirectoryInfo]$q).EnumerateFiles('*', 'AllDirectories')) { $b += $f.Length; $n++ } }; @($n, $b) }
$t0 = Get-Date; $prevB = 0L; $prevT = $t0
while (Get-Process -Id $CmdPid -ErrorAction SilentlyContinue) {
  $ts = Get-Date; $d = DirBytes $Out; $files = $d[0]; $bytes = $d[1]; $now = Get-Date
  $scan = ($now - $ts).TotalSeconds; $dt = ($now - $prevT).TotalSeconds
  $rate = if ($dt -gt 0 -and $prevB -gt 0) { [math]::Max(0, ($bytes - $prevB) / $dt) } else { 0 }
  $proj = $bytes + $rate * ($IntervalSec + $scan) * 2
  $ar = Get-CimInstance Win32_Process -Filter "ParentProcessId=$CmdPid AND Name='dotnet.exe'" | Select-Object -First 1
  $ws = if ($ar) { (Get-Process -Id $ar.ProcessId -ErrorAction SilentlyContinue).WorkingSet64 } else { 0 }
  L ("t={0:N0}s out_files={1} out_bytes={2} rate_MBps={3:N0} projected={4:N0} limit={5} free={6:N1}GB ram_free={7:N1}GB ar_ws={8:N1}GB scan_s={9:N1}" -f ($now - $t0).TotalSeconds, $files, $bytes, ($rate / 1e6), $proj, $LimitBytes, ((Free) / 1e9), ((RamFree) / 1e9), ($ws / 1e9), $scan)
  if ($bytes -gt $LimitBytes) { Kill; L "TRIPPED output $bytes over ${LimitBytes}: export stopped"; exit 2 }
  if ($proj -gt $LimitBytes) { Kill; L "TRIPPED projected $([int64]$proj) would pass ${LimitBytes} by the next sample (now $bytes, rate $([int64]$rate) B/s): export stopped"; exit 5 }
  if ((Free) -lt $DriveFreeMinGB * 1e9) { Kill; L "TRIPPED free space on ${drive}: below $DriveFreeMinGB GB: export stopped"; exit 3 }
  if ((RamFree) -lt $RamFreeMinGB * 1e9 -and $ar) { [Nt.P]::NtSuspendProcess((Get-Process -Id $ar.ProcessId).Handle) | Out-Null; L "TRIPPED free RAM below $RamFreeMinGB GB: AssetRipper pid $($ar.ProcessId) SUSPENDED (NtSuspendProcess), not killed"; exit 4 }
  $prevB = $bytes; $prevT = $now
  Start-Sleep -Seconds $IntervalSec
}
$d = DirBytes $Out
L ("AR ended span={0} out_files={1} out_bytes={2} limit={3} over_limit={4}" -f ((Get-Date) - $t0), $d[0], $d[1], $LimitBytes, ($d[1] -gt $LimitBytes))
L 'WATCH DONE'
exit 0
