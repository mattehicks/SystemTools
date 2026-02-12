# AUTOMATED SPYWARE CHECK & RE-KILL
# For scheduled task execution (no user input required)

$logPath = Join-Path $env:TEMP "SpywareCheck_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$log = @()
$log += "Automated Spyware Check - $(Get-Date)"
$log += "=" * 60

Write-Host "Automated Spyware Check - $(Get-Date)" -ForegroundColor Cyan
Write-Host ""

# Check telemetry registry
$telemetry = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name AllowTelemetry -ErrorAction SilentlyContinue

if ($telemetry.AllowTelemetry -eq 0) {
    Write-Host "[OK] Telemetry: DISABLED" -ForegroundColor Green
    $log += "[OK] Telemetry: DISABLED"
} else {
    Write-Host "[X] Telemetry: ENABLED - FIXING" -ForegroundColor Red
    $log += "[X] Telemetry: ENABLED - FIXING"
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
}

# Spyware services
$services = @('DiagTrack','dmwappushservice','CDPSvc','OneSyncSvc','WerSvc','WpnService','XblAuthManager','XblGameSave','lfsvc','MapsBroker','DPS')
$fixed = 0

foreach ($svc in $services) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service -and ($service.Status -eq 'Running' -or $service.StartType -ne 'Disabled')) {
        Write-Host "[X] $($service.Name): Re-enabled - FIXING" -ForegroundColor Red
        $log += "[X] $($service.Name): Re-enabled"
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        $fixed++
    }
}

# Check Windows Update
$wu = Get-Service wuauserv -ErrorAction SilentlyContinue
if ($wu.Status -eq 'Running') {
    Write-Host "[!] Windows Update running - STOPPING" -ForegroundColor Yellow
    $log += "[!] Windows Update: Stopped"
    Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
    $fixed++
}

Write-Host ""
if ($fixed -eq 0) {
    Write-Host "Status: ALL SECURE" -ForegroundColor Green
    $log += "RESULT: All secure"
    $exitCode = 0
} else {
    Write-Host "Status: FIXED $fixed issues" -ForegroundColor Yellow
    $log += "RESULT: Fixed $fixed issues"
    $exitCode = 1
}

Write-Host "Log: $logPath" -ForegroundColor Gray
$log | Out-File -FilePath $logPath -Force
exit $exitCode
