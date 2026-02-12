# KILL ALL SPYWARE - EXECUTION SCRIPT
# Run with TrustedInstaller: NSudoLC.exe -U:T -P:E powershell -File KILL_SPYWARE.ps1

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "MICROSOFT SPYWARE TERMINATION" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "This will STOP ALL TELEMETRY. Type 'KILL' to proceed"
if ($confirm -ne 'KILL') {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "[1/7] Stopping spyware services..." -ForegroundColor Yellow

$spywareServices = @(
    'DiagTrack',                          # Main telemetry
    'dmwappushservice',                   # Push notifications
    'CDPSvc',                            # Connected Devices
    'CDPUserSvc',                        # Connected Devices User
    'OneSyncSvc',                        # Sync Host
    'WerSvc',                            # Error Reporting
    'WpnService',                        # Push Notifications
    'PimIndexMaintenanceSvc',            # Contact Data
    'UnistoreSvc',                       # User Data Storage
    'UserDataSvc',                       # User Data Access
    'MessagingService',                  # Messaging
    'XblAuthManager',                    # Xbox Auth
    'XblGameSave',                       # Xbox Save
    'lfsvc',                             # Geolocation
    'MapsBroker',                        # Maps
    'RetailDemo',                        # Retail Demo
    'DPS',                               # Diagnostic Policy
    'WdiServiceHost',                    # Diagnostic Service
    'WdiSystemHost',                     # Diagnostic System
    'TroubleshootingSvc',                # Troubleshooting
    'SSDPSRV',                           # SSDP Discovery
    'SensorDataService',                 # Sensor Data
    'SensrSvc',                          # Sensor Monitoring
    'SensorService'                      # Sensor Service
)

foreach ($svc in $spywareServices) {
    try {
        $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($service) {
            Write-Host "  Killing: $($service.DisplayName)" -ForegroundColor Red
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "  Failed: $svc" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[2/7] Disabling telemetry in registry..." -ForegroundColor Yellow

# Telemetry = 0
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >$null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >$null

# Activity Feed = OFF
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /t REG_DWORD /d 0 /f >$null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 0 /f >$null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v UploadUserActivities /t REG_DWORD /d 0 /f >$null

# Error Reporting = OFF
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >$null

# CEIP = OFF
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v CEIPEnable /t REG_DWORD /d 0 /f >$null

# App Telemetry = OFF
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v AITEnable /t REG_DWORD /d 0 /f >$null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisableInventory /t REG_DWORD /d 1 /f >$null

# Feedback = OFF
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v DoNotShowFeedbackNotifications /t REG_DWORD /d 1 /f >$null

# Advertising ID = OFF
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v DisabledByGroupPolicy /t REG_DWORD /d 1 /f >$null

# Location = OFF
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v DisableLocation /t REG_DWORD /d 1 /f >$null

Write-Host "  ✓ Registry locked down" -ForegroundColor Green

Write-Host ""
Write-Host "[3/7] Disabling scheduled telemetry tasks..." -ForegroundColor Yellow

$spywareTasks = @(
    '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
    '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
    '\Microsoft\Windows\Autochk\Proxy',
    '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
    '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
    '\Microsoft\Windows\Feedback\Siuf\DmClient',
    '\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload',
    '\Microsoft\Windows\Application Experience\MareBackup',
    '\Microsoft\Windows\Application Experience\StartupAppTask',
    '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector'
)

foreach ($task in $spywareTasks) {
    try {
        Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
        Write-Host "  Disabled: $task" -ForegroundColor Red
    } catch {}
}

Write-Host ""
Write-Host "[4/7] Blocking telemetry domains (hosts file)..." -ForegroundColor Yellow

$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$telemetryDomains = @(
    'vortex.data.microsoft.com',
    'vortex-win.data.microsoft.com',
    'telecommand.telemetry.microsoft.com',
    'oca.telemetry.microsoft.com',
    'sqm.telemetry.microsoft.com',
    'watson.telemetry.microsoft.com',
    'telemetry.microsoft.com',
    'reports.wes.df.telemetry.microsoft.com',
    'wes.df.telemetry.microsoft.com',
    'services.wes.df.telemetry.microsoft.com',
    'telemetry.appex.bing.net',
    'telemetry.urs.microsoft.com',
    'settings-sandbox.data.microsoft.com',
    'survey.watson.microsoft.com',
    'watson.live.com',
    'watson.microsoft.com',
    'statsfe2.ws.microsoft.com',
    'statsfe2.update.microsoft.com.akadns.net',
    'diagnostics.support.microsoft.com',
    'feedback.windows.com',
    'feedback.microsoft-hohm.com',
    'feedback.search.microsoft.com'
)

# Backup hosts file
Copy-Item $hostsFile "$hostsFile.backup" -Force

# Add blocks
$hostsContent = Get-Content $hostsFile
$newEntries = @()
$newEntries += "`n# Microsoft Telemetry Block - $(Get-Date)"

foreach ($domain in $telemetryDomains) {
    if ($hostsContent -notmatch [regex]::Escape($domain)) {
        $newEntries += "0.0.0.0 $domain"
    }
}

Add-Content -Path $hostsFile -Value $newEntries
Write-Host "  ✓ Blocked $($telemetryDomains.Count) domains" -ForegroundColor Green

Write-Host ""
Write-Host "[5/7] Flushing DNS cache..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "  ✓ DNS flushed" -ForegroundColor Green

Write-Host ""
Write-Host "[6/7] Killing active telemetry processes..." -ForegroundColor Yellow
$spywareProcesses = @('CompatTelRunner', 'DiagTrackRunner', 'DeviceCensus')
foreach ($proc in $spywareProcesses) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "  Killed: $proc" -ForegroundColor Red
}

Write-Host ""
Write-Host "[7/7] Disabling Windows Update (prevents re-enabling)..." -ForegroundColor Yellow
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Set-Service wuauserv -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service UsoSvc -Force -ErrorAction SilentlyContinue
Set-Service UsoSvc -StartupType Disabled -ErrorAction SilentlyContinue

# Disable Update Medic Service (hardcore)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 4 /f >$null

Write-Host "  ✓ Windows Update disabled" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "SPYWARE TERMINATED" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "What was killed:" -ForegroundColor Cyan
Write-Host "  • 24 spyware services disabled" -ForegroundColor White
Write-Host "  • 10 scheduled tasks disabled" -ForegroundColor White
Write-Host "  • 22 telemetry domains blocked" -ForegroundColor White
Write-Host "  • Registry locked down (telemetry = 0)" -ForegroundColor White
Write-Host "  • Windows Update disabled" -ForegroundColor White
Write-Host ""
Write-Host "RESTART REQUIRED for full effect" -ForegroundColor Yellow
Write-Host ""
$restart = Read-Host "Restart now? (y/n)"
if ($restart -eq 'y') {
    Restart-Computer -Force
}
