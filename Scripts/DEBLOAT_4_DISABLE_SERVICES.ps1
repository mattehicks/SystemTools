# DISABLE SPYWARE SERVICES
# Phase 4: Stop all Microsoft telemetry/tracking services
# Run with TrustedInstaller

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "PHASE 4: DISABLE SPYWARE SERVICES" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host ""

# Complete list of spyware/telemetry services
$servicesToDisable = @(
    'DiagTrack',                        # Connected User Experiences and Telemetry
    'dmwappushservice',                 # WAP Push Message Routing Service
    'diagnosticshub.standardcollector.service',  # Diagnostics Hub Standard Collector
    'RetailDemo',                       # Retail Demo Service
    'WerSvc',                          # Windows Error Reporting
    'CDPUserSvc',                      # Connected Devices Platform User Service
    'OneSyncSvc',                      # Sync Host (OneDrive/Mail sync)
    'PimIndexMaintenanceSvc',          # Contact Data
    'UnistoreSvc',                     # User Data Storage
    'UserDataSvc',                     # User Data Access
    'WpnService',                      # Windows Push Notifications
    'MessagingService',                # Messaging Service
    'XblAuthManager',                  # Xbox Live Auth Manager
    'XblGameSave',                     # Xbox Live Game Save
    'XboxNetApiSvc',                   # Xbox Live Networking
    'XboxGipSvc',                      # Xbox Accessory Management
    'lfsvc',                           # Geolocation Service
    'MapsBroker',                      # Downloaded Maps Manager
    'PhoneSvc',                        # Phone Service (links phone to PC)
    'RemoteRegistry',                  # Remote Registry (security risk)
    'SensorDataService',               # Sensor Data Service
    'SensrSvc',                        # Sensor Monitoring Service
    'SensorService',                   # Sensor Service
    'WalletService',                   # Wallet Service
    'WSearch'                          # Windows Search (optional - disable if you don't use)
)

Write-Host "Services to disable: $($servicesToDisable.Count)" -ForegroundColor Yellow
Write-Host ""

$disabled = 0
$notFound = 0
$alreadyDisabled = 0

foreach ($serviceName in $servicesToDisable) {
    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    
    if ($svc) {
        if ($svc.StartType -eq 'Disabled') {
            Write-Host "ALREADY DISABLED: $($svc.DisplayName)" -ForegroundColor Gray
            $alreadyDisabled++
        } else {
            Write-Host "DISABLING: $($svc.DisplayName)" -ForegroundColor Red
            
            try {
                # Stop service
                Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                
                # Disable service
                Set-Service -Name $serviceName -StartupType Disabled -ErrorAction Stop
                
                $disabled++
            } catch {
                Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "NOT FOUND: $serviceName" -ForegroundColor Gray
        $notFound++
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "SERVICE DISABLING COMPLETE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Newly disabled:      $disabled" -ForegroundColor Red
Write-Host "Already disabled:    $alreadyDisabled" -ForegroundColor Gray
Write-Host "Not found:           $notFound" -ForegroundColor Gray
Write-Host ""
Write-Host "Restart recommended for full effect" -ForegroundColor Yellow
Write-Host ""
pause
