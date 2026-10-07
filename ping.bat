@echo off
setlocal
title Live Ping Monitor

set "PING_TARGET="
set /p "PING_TARGET=Enter IP address to monitor: "

if not defined PING_TARGET (
    echo.
    echo No IP address entered.
    pause
    exit /b 1
)

powershell.exe -NoLogo -NoProfile -Command ^
 "$target = ($env:PING_TARGET).Trim();" ^
 "$ping = New-Object System.Net.NetworkInformation.Ping;" ^
 "$results = @(); $count = 0;" ^
 "$border = '+--------+----------+-------------+----------+';" ^
 "try {" ^
 "  while ($true) {" ^
 "    $watch = [System.Diagnostics.Stopwatch]::StartNew();" ^
 "    $count++;" ^
 "    try {" ^
 "      $reply = $ping.Send($target, 1000);" ^
 "      if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {" ^
 "        $status = 'ONLINE'; $rtt = ('{0} ms' -f $reply.RoundtripTime); $color = 'Green';" ^
 "      } elseif ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::TimedOut) {" ^
 "        $status = 'TIMEOUT'; $rtt = '-'; $color = 'Red';" ^
 "      } else {" ^
 "        $status = 'FAILED'; $rtt = '-'; $color = 'Yellow';" ^
 "      }" ^
 "    } catch {" ^
 "      $status = 'ERROR'; $rtt = '-'; $color = 'Red';" ^
 "    }" ^
 "    $results += [PSCustomObject]@{Count=$count; Time=(Get-Date -Format 'HH:mm:ss'); Status=$status; RTT=$rtt; Color=$color};" ^
 "    $results = @($results | Select-Object -Last 5);" ^
 "    Clear-Host;" ^
 "    Write-Host '';" ^
 "    Write-Host '  LIVE PING MONITOR - LAST 5 RESULTS' -ForegroundColor Cyan;" ^
 "    Write-Host ('  Target: {0}  |  Ctrl+C to stop' -f $target) -ForegroundColor Gray;" ^
 "    Write-Host '';" ^
 "    Write-Host $border -ForegroundColor DarkGray;" ^
 "    Write-Host ('| {0,-6} | {1,-8} | {2,-11} | {3,-8} |' -f 'Count','Time','Status','RTT') -ForegroundColor Cyan;" ^
 "    Write-Host $border -ForegroundColor DarkGray;" ^
 "    foreach ($row in $results) {" ^
 "      Write-Host ('| {0,6} | {1,-8} | {2,-11} | {3,8} |' -f $row.Count,$row.Time,$row.Status,$row.RTT) -ForegroundColor $row.Color;" ^
 "    }" ^
 "    Write-Host $border -ForegroundColor DarkGray;" ^
 "    $watch.Stop();" ^
 "    $delay = 1000 - $watch.ElapsedMilliseconds;" ^
 "    if ($delay -gt 0) { Start-Sleep -Milliseconds $delay; }" ^
 "  }" ^
 "} finally { $ping.Dispose(); }"

endlocal