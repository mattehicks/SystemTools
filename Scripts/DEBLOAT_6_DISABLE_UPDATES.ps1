# DISABLE WINDOWS UPDATE COMPLETELY
# Phase 6: Stop forced updates permanently
# Run with TrustedInstaller

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "PHASE 6: DISABLE WINDOWS UPDATE" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host ""
Write-Host "⚠️  WARNING: This disables automatic security updates!" -ForegroundColor Yellow
Write-Host "⚠️  You will need to manually update Windows periodically" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Type 'DISABLE' to confirm"

if ($confirm -ne 'DISABLE') {
    Write-Host "Aborted." -ForegroundColor Green
    exit
}

Write-Host ""

# Method 1: Disable Windows Update Services
Write-Host "[1/5] Disabling Windows Update services..." -ForegroundColor Yellow

$updateServices = @(
    'wuauserv',        # Windows Update
    'UsoSvc',          # Update Orchestrator Service
    'WaaSMedicSvc'     # Windows Update Medic Service (hardened)
)

foreach ($service in $updateServices) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc) {
        Write-Host "  Stopping: $($svc.DisplayName)" -ForegroundColor Red
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        
        Write-Host "  Disabling: $($svc.DisplayName)" -ForegroundColor Red
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

# WaaSMedicSvc requires registry (it's a protected service)
Write-Host "  Disabling WaaSMedicSvc via registry..." -ForegroundColor Red
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 4 /f | Out-Null

Write-Host "✓ Update services disabled" -ForegroundColor Green
Write-Host ""

# Method 2: Group Policy Registry Keys
Write-Host "[2/5] Configuring group policy (registry)..." -ForegroundColor Yellow

# Disable automatic updates
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f | Out-Null

# Disable automatic driver updates
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v SearchOrderConfig /t REG_DWORD /d 0 /f | Out-Null

# Disable Windows Update access
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DoNotConnectToWindowsUpdateInternetLocations /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableWindowsUpdateAccess /t REG_DWORD /d 1 /f | Out-Null

# Disable automatic restart after updates
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUPowerManagement /t REG_DWORD /d 0 /f | Out-Null

Write-Host "✓ Group policy configured" -ForegroundColor Green
Write-Host ""

# Method 3: Disable Update Delivery Optimization
Write-Host "[3/5] Disabling delivery optimization..." -ForegroundColor Yellow
Stop-Service DoSvc -Force -ErrorAction SilentlyContinue
Set-Service DoSvc -StartupType Disabled -ErrorAction SilentlyContinue
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f | Out-Null
Write-Host "✓ Delivery optimization disabled" -ForegroundColor Green
Write-Host ""

# Method 4: Set network as metered (prevents downloads over it)
Write-Host "[4/5] Setting network connections as metered..." -ForegroundColor Yellow
$adapters = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}
foreach ($adapter in $adapters) {
    try {
        Set-NetConnectionProfile -InterfaceAlias $adapter.Name -NetworkCategory Private -ErrorAction SilentlyContinue
        
        # Mark as metered via registry
        $guid = (Get-NetAdapter -Name $adapter.Name).InterfaceGuid
        $regPath = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost"
        
        # Wi-Fi, Ethernet cost = 2 (metered)
        reg add $regPath /v WiFi /t REG_DWORD /d 2 /f | Out-Null
        reg add $regPath /v Ethernet /t REG_DWORD /d 2 /f | Out-Null
        
        Write-Host "  ✓ $($adapter.Name) set as metered" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Could not set $($adapter.Name) as metered" -ForegroundColor Yellow
    }
}
Write-Host ""

# Method 5: Disable scheduled update tasks
Write-Host "[5/5] Disabling Windows Update scheduled tasks..." -ForegroundColor Yellow

$updateTasks = @(
    '\Microsoft\Windows\WindowsUpdate\Scheduled Start',
    '\Microsoft\Windows\WindowsUpdate\sih',
    '\Microsoft\Windows\WindowsUpdate\sihboot',
    '\Microsoft\Windows\UpdateOrchestrator\Schedule Scan',
    '\Microsoft\Windows\UpdateOrchestrator\Schedule Scan Static Task',
    '\Microsoft\Windows\UpdateOrchestrator\UpdateModelTask',
    '\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker',
    '\Microsoft\Windows\WaaSMedic\PerformRemediation'
)

foreach ($task in $updateTasks) {
    Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
    Write-Host "  DISABLED: $task" -ForegroundColor Red
}

Write-Host "✓ Update tasks disabled" -ForegroundColor Green
Write-Host ""

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "WINDOWS UPDATE COMPLETELY DISABLED" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Methods applied:" -ForegroundColor Cyan
Write-Host "  ✓ Update services disabled" -ForegroundColor White
Write-Host "  ✓ Group policy configured" -ForegroundColor White
Write-Host "  ✓ Delivery optimization disabled" -ForegroundColor White
Write-Host "  ✓ Networks marked as metered" -ForegroundColor White
Write-Host "  ✓ Scheduled tasks disabled" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANT:" -ForegroundColor Yellow
Write-Host "  - Windows will NOT auto-update" -ForegroundColor Red
Write-Host "  - Security patches will NOT install automatically" -ForegroundColor Red
Write-Host "  - You MUST manually update when needed" -ForegroundColor Red
Write-Host ""
Write-Host "To manually update (when you want):" -ForegroundColor Cyan
Write-Host "  1. Re-enable: Set-Service wuauserv -StartupType Manual" -ForegroundColor White
Write-Host "  2. Check updates in Settings" -ForegroundColor White
Write-Host "  3. Re-disable after updates complete" -ForegroundColor White
Write-Host ""
Write-Host "Restart required for full effect" -ForegroundColor Yellow
Write-Host ""
pause
