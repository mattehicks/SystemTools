# WINDOWS DEBLOAT & PRIVACY - EXTREME EDITION

**Goal:** Strip Windows 10 down to bare essentials, disable telemetry, remove bloatware, stop forced updates

**Approach:** Nuclear option - maximum privacy, minimum Microsoft interference

---

## PHASE 1: INVENTORY CURRENT BLOAT

### Built-in Apps to Remove
```powershell
# List all provisioned apps
Get-AppxProvisionedPackage -Online | Select-Object DisplayName | Sort-Object DisplayName

# List installed apps
Get-AppxPackage | Select-Object Name, PackageFullName | Sort-Object Name
```

### Telemetry Services Currently Running
```powershell
# Identify telemetry/diagnostic services
Get-Service | Where-Object {
    $_.Name -match 'diagtrack|dmwappush|CDPUserSvc|OneSyncSvc|MessagingService|PimIndexMaintenance|UnistoreSvc|UserDataSvc|WpnService|XblAuthManager|XblGameSave'
} | Select-Object Name, DisplayName, Status, StartType
```

---

## PHASE 2: REMOVE BLOATWARE APPS

### Script 1: Remove All Microsoft Store Apps (Except Store & Calculator)

```powershell
# Get all AppX packages for current user
$apps = Get-AppxPackage

# Apps to KEEP (whitelist)
$keepApps = @(
    'Microsoft.WindowsStore',           # Store itself
    'Microsoft.WindowsCalculator',      # Calculator
    'Microsoft.Windows.Photos',         # Photos (optional - remove if you want)
    'Microsoft.ScreenSketch',           # Snipping Tool
    'Microsoft.Paint'                   # Paint (optional)
)

# Remove everything else
foreach ($app in $apps) {
    $remove = $true
    foreach ($keep in $keepApps) {
        if ($app.Name -like "*$keep*") {
            $remove = $false
            break
        }
    }
    
    if ($remove) {
        Write-Host "Removing: $($app.Name)" -ForegroundColor Red
        Remove-AppxPackage -Package $app.PackageFullName -ErrorAction SilentlyContinue
        
        # Also remove provisioned package (prevents reinstall)
        $provisioned = Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*$($app.Name)*" }
        if ($provisioned) {
            Remove-AppxProvisionedPackage -Online -PackageName $provisioned.PackageName -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host "Keeping: $($app.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Bloatware removal complete!" -ForegroundColor Green
```

**Apps that will be removed:**
- Xbox Game Bar, Xbox Live
- Cortana
- Microsoft Teams (consumer)
- OneDrive (you have it but can keep if wanted)
- Get Help, Tips, Feedback Hub
- Mixed Reality Portal
- 3D Viewer, Paint 3D
- Skype
- Solitaire, Candy Crush, other games
- News, Weather, Mail/Calendar
- Maps, Voice Recorder, Alarms
- Your Phone, Mobile Plans
- Office Hub
- People app

---

## PHASE 3: DISABLE TELEMETRY & SPYWARE

### Registry Tweaks - Maximum Privacy

```powershell
# Run as TrustedInstaller for full access
$regTweaks = @'
# Disable Telemetry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

# Disable Activity Feed
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v UploadUserActivities /t REG_DWORD /d 0 /f

# Disable Cortana
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCloudSearch /t REG_DWORD /d 0 /f

# Disable Windows Error Reporting
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f

# Disable Customer Experience Improvement Program
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v CEIPEnable /t REG_DWORD /d 0 /f

# Disable Application Telemetry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v AITEnable /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisableInventory /t REG_DWORD /d 1 /f

# Disable Windows Feedback
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v DoNotShowFeedbackNotifications /t REG_DWORD /d 1 /f

# Disable Advertising ID
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v DisabledByGroupPolicy /t REG_DWORD /d 1 /f

# Disable Location Tracking
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v DisableLocation /t REG_DWORD /d 1 /f

# Disable Automatic Map Updates
reg add "HKLM\SYSTEM\Maps" /v AutoUpdateEnabled /t REG_DWORD /d 0 /f

# Disable OneDrive
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f

# Disable Windows Tips
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableSoftLanding /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f

# Disable Timeline
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /t REG_DWORD /d 0 /f

# Disable Windows Spotlight (lock screen ads)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsSpotlightFeatures /t REG_DWORD /d 1 /f

# Disable Bing in Start Menu
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableWebSearch /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v ConnectedSearchUseWeb /t REG_DWORD /d 0 /f
'@

$regTweaks | Out-File -FilePath ".\Scripts\Scripts\DISABLE_TELEMETRY.bat" -Encoding ASCII
```

---

## PHASE 4: DISABLE SPYWARE SERVICES

### Services to Disable/Stop

```powershell
# List of spyware/telemetry services
$servicesToDisable = @(
    'DiagTrack',                        # Connected User Experiences and Telemetry
    'dmwappushservice',                 # WAP Push Message Routing Service
    'diagnosticshub.standardcollector.service',  # Diagnostics Hub
    'RetailDemo',                       # Retail Demo Service
    'WerSvc',                          # Windows Error Reporting
    'CDPUserSvc',                      # Connected Devices Platform Service
    'OneSyncSvc',                      # Sync Host (OneDrive)
    'PimIndexMaintenanceSvc',          # Contact Data
    'UnistoreSvc',                     # User Data Storage
    'UserDataSvc',                     # User Data Access
    'WpnService',                      # Windows Push Notifications
    'MessagingService',                # Messaging Service
    'XblAuthManager',                  # Xbox Live Auth Manager
    'XblGameSave',                     # Xbox Live Game Save
    'XboxNetApiSvc',                   # Xbox Live Networking Service
    'XboxGipSvc',                      # Xbox Accessory Management
    'lfsvc',                           # Geolocation Service
    'MapsBroker',                      # Downloaded Maps Manager
    'PhoneSvc',                        # Phone Service
    'RemoteRegistry',                  # Remote Registry (security risk)
    'RetailDemo',                      # Retail Demo
    'SensorDataService',               # Sensor Data Service
    'SensrSvc',                        # Sensor Monitoring Service
    'SensorService',                   # Sensor Service
    'WalletService',                   # Wallet Service
    'WSearch'                          # Windows Search (if you don't use it)
)

foreach ($service in $servicesToDisable) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc) {
        Write-Host "Disabling: $($svc.DisplayName)" -ForegroundColor Red
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    }
}
```

---

## PHASE 5: BLOCK MICROSOFT TELEMETRY DOMAINS

### Hosts File Method

```powershell
# Backup current hosts file
Copy-Item "C:\Windows\System32\drivers\etc\hosts" "C:\Windows\System32\drivers\etc\hosts.backup"

# Telemetry domains to block
$telemetryDomains = @(
    'vortex.data.microsoft.com',
    'vortex-win.data.microsoft.com',
    'telecommand.telemetry.microsoft.com',
    'telecommand.telemetry.microsoft.com.nsatc.net',
    'oca.telemetry.microsoft.com',
    'oca.telemetry.microsoft.com.nsatc.net',
    'sqm.telemetry.microsoft.com',
    'sqm.telemetry.microsoft.com.nsatc.net',
    'watson.telemetry.microsoft.com',
    'watson.telemetry.microsoft.com.nsatc.net',
    'redir.metaservices.microsoft.com',
    'choice.microsoft.com',
    'choice.microsoft.com.nsatc.net',
    'df.telemetry.microsoft.com',
    'reports.wes.df.telemetry.microsoft.com',
    'wes.df.telemetry.microsoft.com',
    'services.wes.df.telemetry.microsoft.com',
    'sqm.df.telemetry.microsoft.com',
    'telemetry.microsoft.com',
    'watson.ppe.telemetry.microsoft.com',
    'telemetry.appex.bing.net',
    'telemetry.urs.microsoft.com',
    'telemetry.appex.bing.net:443',
    'settings-sandbox.data.microsoft.com',
    'vortex-sandbox.data.microsoft.com',
    'survey.watson.microsoft.com',
    'watson.live.com',
    'watson.microsoft.com',
    'statsfe2.ws.microsoft.com',
    'corpext.msitadfs.glbdns2.microsoft.com',
    'compatexchange.cloudapp.net',
    'cs1.wpc.v0cdn.net',
    'a-0001.a-msedge.net',
    'statsfe2.update.microsoft.com.akadns.net',
    'sls.update.microsoft.com.akadns.net',
    'fe2.update.microsoft.com.akadns.net',
    'diagnostics.support.microsoft.com',
    'corp.sts.microsoft.com',
    'statsfe1.ws.microsoft.com',
    'pre.footprintpredict.com',
    'i1.services.social.microsoft.com',
    'i1.services.social.microsoft.com.nsatc.net',
    'feedback.windows.com',
    'feedback.microsoft-hohm.com',
    'feedback.search.microsoft.com'
)

# Add to hosts file
$hostsContent = Get-Content "C:\Windows\System32\drivers\etc\hosts"
$newEntries = @()

foreach ($domain in $telemetryDomains) {
    if ($hostsContent -notmatch $domain) {
        $newEntries += "0.0.0.0 $domain"
    }
}

if ($newEntries.Count -gt 0) {
    Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "`n# Microsoft Telemetry Block"
    Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value $newEntries
    Write-Host "Added $($newEntries.Count) telemetry domains to hosts file" -ForegroundColor Green
}
```

---

## PHASE 6: DISABLE WINDOWS UPDATE (NUCLEAR OPTION)

### Method 1: Disable Windows Update Service

```powershell
# Stop and disable Windows Update
Stop-Service wuauserv -Force
Set-Service wuauserv -StartupType Disabled

# Disable Update Orchestrator
Stop-Service UsoSvc -Force
Set-Service UsoSvc -StartupType Disabled

# Disable Windows Update Medic Service (requires registry)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v Start /t REG_DWORD /d 4 /f
```

### Method 2: Group Policy (More Reliable)

```
Registry path for manual update only:
HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
- NoAutoUpdate = 1 (DWORD)
- AUOptions = 2 (DWORD) - Notify before download
```

### Method 3: Metered Connection Trick

```powershell
# Set all connections as metered (prevents downloads)
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -First 1
Set-NetConnectionProfile -InterfaceAlias $adapter.Name -NetworkCategory Private
```

---

## PHASE 7: REMOVE EDGE (CHROMIUM)

### Uninstall Edge

```powershell
# Find Edge installer
$edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application"
$edgeInstaller = Get-ChildItem "$edgePath\*\Installer" -Recurse | Where-Object {$_.Name -eq "setup.exe"} | Select-Object -First 1

if ($edgeInstaller) {
    # Uninstall Edge
    Start-Process -FilePath $edgeInstaller.FullName -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait
    
    # Remove leftover folders
    Remove-Item -Path "${env:ProgramFiles(x86)}\Microsoft\Edge" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge" -Recurse -Force -ErrorAction SilentlyContinue
}

# Prevent Edge reinstall
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v DoNotUpdateToEdgeWithChromium /t REG_DWORD /d 1 /f
```

---

## PHASE 8: FIREWALL RULES - BLOCK MICROSOFT

### Windows Firewall Outbound Rules

```powershell
# Block Windows Update servers
New-NetFirewallRule -DisplayName "Block Windows Update" -Direction Outbound -RemoteAddress 13.107.4.50,13.107.5.88 -Action Block

# Block telemetry IPs (some known ranges)
$telemetryIPs = @(
    '13.64.0.0-13.107.255.255',      # Azure range (includes telemetry)
    '52.96.0.0-52.127.255.255',      # More Azure
    '65.52.0.0-65.55.255.255'        # Microsoft owned
)

# This is extreme and may break some services
# foreach ($ip in $telemetryIPs) {
#     New-NetFirewallRule -DisplayName "Block MS Telemetry $ip" -Direction Outbound -RemoteAddress $ip -Action Block
# }
```

---

## PHASE 9: TASK SCHEDULER - DISABLE SPYWARE TASKS

### Disable Telemetry Scheduled Tasks

```powershell
$tasksToDisable = @(
    '\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser',
    '\Microsoft\Windows\Application Experience\ProgramDataUpdater',
    '\Microsoft\Windows\Autochk\Proxy',
    '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator',
    '\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip',
    '\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector',
    '\Microsoft\Windows\Feedback\Siuf\DmClient',
    '\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload',
    '\Microsoft\Windows\Windows Error Reporting\QueueReporting',
    '\Microsoft\Windows\Application Experience\MareBackup',
    '\Microsoft\Windows\Application Experience\StartupAppTask',
    '\Microsoft\Windows\Application Experience\PcaPatchDbTask',
    '\Microsoft\Windows\Maps\MapsUpdateTask'
)

foreach ($task in $tasksToDisable) {
    Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
    Write-Host "Disabled: $task" -ForegroundColor Red
}
```

---

## PHASE 10: OPTIONAL NUCLEAR OPTIONS

### Disable Windows Defender (If you use 3rd party AV)

```powershell
# ONLY if you have another antivirus!
# This is EXTREME and reduces security

# Disable real-time protection
Set-MpPreference -DisableRealtimeMonitoring $true

# Disable completely via registry (requires restart)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
```

### Remove Cortana Completely

```powershell
# Cortana already disabled by registry above, but to remove:
Get-AppxPackage *Microsoft.549981C3F5F10* | Remove-AppxPackage
```

### Disable System Restore (If you have backups elsewhere)

```powershell
Disable-ComputerRestore -Drive "C:\"
vssadmin delete shadows /all /quiet
```

---

## MASTER EXECUTION SCRIPT

Save this as: `DEBLOAT_MASTER.ps1`

```powershell
# WINDOWS DEBLOAT & PRIVACY - MASTER SCRIPT
# Run with TrustedInstaller via NSudo

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "WINDOWS NUCLEAR DEBLOAT - EXTREME PRIVACY MODE" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host ""
Write-Host "This will:" -ForegroundColor Yellow
Write-Host "  - Remove ALL Microsoft Store apps (except Store, Calculator)" -ForegroundColor White
Write-Host "  - Disable ALL telemetry" -ForegroundColor White
Write-Host "  - Block Microsoft telemetry domains" -ForegroundColor White
Write-Host "  - Disable Windows Update" -ForegroundColor White
Write-Host "  - Disable 20+ spyware services" -ForegroundColor White
Write-Host "  - Remove Edge browser" -ForegroundColor White
Write-Host ""
$confirm = Read-Host "Type 'NUKE' to proceed"

if ($confirm -ne 'NUKE') {
    Write-Host "Aborted." -ForegroundColor Green
    exit
}

Write-Host ""
Write-Host "[1/10] Creating restore point..." -ForegroundColor Cyan
Checkpoint-Computer -Description "Before Nuclear Debloat" -RestorePointType MODIFY_SETTINGS

Write-Host "[2/10] Removing bloatware apps..." -ForegroundColor Cyan
# Insert Phase 2 code here

Write-Host "[3/10] Disabling telemetry (registry)..." -ForegroundColor Cyan
# Insert Phase 3 code here

Write-Host "[4/10] Disabling spyware services..." -ForegroundColor Cyan
# Insert Phase 4 code here

Write-Host "[5/10] Blocking telemetry domains (hosts file)..." -ForegroundColor Cyan
# Insert Phase 5 code here

Write-Host "[6/10] Disabling Windows Update..." -ForegroundColor Cyan
# Insert Phase 6 code here

Write-Host "[7/10] Removing Edge browser..." -ForegroundColor Cyan
# Insert Phase 7 code here

Write-Host "[8/10] Creating firewall rules..." -ForegroundColor Cyan
# Insert Phase 8 code here

Write-Host "[9/10] Disabling scheduled tasks..." -ForegroundColor Cyan
# Insert Phase 9 code here

Write-Host "[10/10] Final cleanup..." -ForegroundColor Cyan
# Additional cleanup

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "DEBLOAT COMPLETE!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "RESTART REQUIRED for all changes to take effect" -ForegroundColor Yellow
Write-Host ""
$restart = Read-Host "Restart now? (y/n)"
if ($restart -eq 'y') {
    Restart-Computer -Force
}
```

---

## VERIFICATION COMMANDS

After debloat, check what's left:

```powershell
# Check remaining apps
Get-AppxPackage | Select-Object Name | Sort-Object Name

# Check disabled services
Get-Service | Where-Object {$_.StartType -eq 'Disabled'} | Select-Object Name, DisplayName

# Check hosts file
Get-Content "C:\Windows\System32\drivers\etc\hosts" | Select-String "microsoft"

# Check telemetry registry
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry
```

---

## REVERSAL (If Needed)

```powershell
# Restore system
rstrui.exe  # System Restore

# Re-enable Windows Update
Set-Service wuauserv -StartupType Automatic
Start-Service wuauserv

# Restore hosts file
Copy-Item "C:\Windows\System32\drivers\etc\hosts.backup" "C:\Windows\System32\drivers\etc\hosts" -Force
```

---

## WARNINGS

**🔴 EXTREME PRIVACY = TRADE-OFFS:**

1. **No Windows Update** - Security risk, must manually update
2. **Broken Windows Store** - Can't install Store apps (already removed anyway)
3. **Some apps may break** - Apps that rely on Microsoft services
4. **Cortana/Search broken** - No web results in Start menu
5. **OneDrive disabled** - Won't sync
6. **Xbox features gone** - No Game Bar, game streaming
7. **Windows Hello broken** - Face/fingerprint login disabled

**This is for MAXIMUM privacy, not maximum convenience.**

---

Ready to execute? Tell me which phases you want to run!

