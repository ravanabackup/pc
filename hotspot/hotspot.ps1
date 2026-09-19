param([ValidateSet('on','off','toggle','status')][string]$Action = 'toggle')
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]

function Await($WinRtTask, $ResultType) {
    $asTask  = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    $netTask.Result
}

$conn = [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]::GetInternetConnectionProfile()
if ($null -eq $conn) { Write-Host 'No active Internet connection - hotspot cannot be started.'; exit 1 }

$tm = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]::CreateFromConnectionProfile($conn)
$rt = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult]

$state = $tm.TetheringOperationalState
Write-Host ('Current hotspot state: ' + $state)

$r = $null
switch ($Action) {
    'status' { }
    'on'     { if ($state -ne 'On') { $r = Await ($tm.StartTetheringAsync()) $rt } }
    'off'    { if ($state -eq 'On') { $r = Await ($tm.StopTetheringAsync())  $rt } }
    'toggle' { if ($state -eq 'On') { $r = Await ($tm.StopTetheringAsync())  $rt }
               else                { $r = Await ($tm.StartTetheringAsync()) $rt } }
}

if ($r) { Write-Host ('Result: ' + $r.Status + ' ' + $r.AdditionalErrorMessage) }
Write-Host ('New hotspot state: ' + $tm.TetheringOperationalState)