# PRIVACY LOCKDOWN - EXECUTION GUIDE

**Goal:** Stop all Microsoft telemetry, tracking, and forced updates

---

## WHAT THIS DOES

### ✅ Phase 3: Disable Telemetry (Registry)
- Telemetry collection disabled
- Activity feed disabled
- Cortana disabled
- Error reporting disabled
- CEIP disabled
- Feedback disabled
- Advertising ID disabled
- Location tracking disabled
- OneDrive sync disabled
- Windows tips disabled
- Timeline disabled
- Windows Spotlight disabled
- Bing in Start Menu disabled

### ✅ Phase 4: Disable 20+ Spyware Services
Services that will be STOPPED and DISABLED:
```
✗ DiagTrack                   - Telemetry
✗ dmwappushservice            - WAP Push
✗ diagnosticshub              - Diagnostics Hub
✗ WerSvc                      - Error Reporting
✗ CDPUserSvc                  - Connected Devices
✗ OneSyncSvc                  - Sync (OneDrive/Mail)
✗ PimIndexMaintenanceSvc      - Contact Data
✗ UnistoreSvc                 - User Data Storage
✗ UserDataSvc                 - User Data Access
✗ WpnService                  - Push Notifications
✗ MessagingService            - Messaging
✗ XblAuthManager              - Xbox Live Auth
✗ XblGameSave                 - Xbox Game Save
✗ XboxNetApiSvc               - Xbox Networking
✗ XboxGipSvc                  - Xbox Accessories
✗ lfsvc                       - Geolocation
✗ MapsBroker                  - Downloaded Maps
✗ PhoneSvc                    - Phone Service
✗ RemoteRegistry              - Remote Registry
✗ SensorDataService           - Sensor Data
✗ SensrSvc                    - Sensor Monitoring
✗ SensorService               - Sensor Service
✗ WalletService               - Wallet
✗ WSearch                     - Windows Search (optional)
```

### ✅ Phase 5: Block ~60 Microsoft Domains (Hosts File)
Domains blocked (redirect to 0.0.0.0):
```
✗ vortex.data.microsoft.com
✗ telecommand.telemetry.microsoft.com
✗ watson.telemetry.microsoft.com
✗ telemetry.microsoft.com
✗ feedback.windows.com
✗ diagnostics.support.microsoft.com
... and 54 more telemetry domains
```

### ✅ Phase 6: Disable Windows Update Completely
```
✗ Windows Update service disabled
✗ Update Orchestrator disabled
✗ Update Medic Service disabled
✗ Delivery Optimization disabled
✗ Auto-update scheduled tasks disabled
✗ Networks marked as metered
```

---

## EXECUTION (2 OPTIONS)

### OPTION 1: ONE-CLICK MASTER SCRIPT (Recommended)

Runs all 4 phases automatically:

```cmd
# 1. Double-click "TrustedInstaller CMD" on desktop

# 2. Navigate to HQ
cd .\Scripts

# 3. Run master script
Tools\NSudo\NSudoLC.exe -U:T -P:E powershell -File "Scripts\PRIVACY_LOCKDOWN_MASTER.ps1"

# 4. Type 'LOCKDOWN' when prompted

# 5. Wait for completion (2-3 minutes)

# 6. Restart when prompted
```

### OPTION 2: Manual (Run Each Phase)

If you want to see each step:

```cmd
# In TrustedInstaller CMD:
cd .\Scripts\Scripts

# Phase 3: Registry
DEBLOAT_3_DISABLE_TELEMETRY.bat

# Phase 4: Services  
powershell -File DEBLOAT_4_DISABLE_SERVICES.ps1

# Phase 5: Hosts File
powershell -File DEBLOAT_5_BLOCK_DOMAINS.ps1

# Phase 6: Windows Update
powershell -File DEBLOAT_6_DISABLE_UPDATES.ps1

# Restart
shutdown /r /t 0
```

---

## VERIFICATION (After Restart)

### Check Services Disabled:
```powershell
Get-Service DiagTrack,dmwappushservice,WerSvc,OneSyncSvc | Select Name,Status,StartType
# All should show: Status=Stopped, StartType=Disabled
```

### Check Hosts File:
```powershell
Get-Content C:\Windows\System32\drivers\etc\hosts | Select-String "microsoft"
# Should show ~60 blocked domains
```

### Check Windows Update:
```powershell
Get-Service wuauserv,UsoSvc | Select Name,Status,StartType
# Both should show: Status=Stopped, StartType=Disabled
```

### Check Registry:
```powershell
Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowTelemetry
# Should show: AllowTelemetry : 0
```

---

## WHAT YOU'LL NOTICE

### Immediately After:
- No more Windows Update notifications
- No more "Get Office" or other ads
- No Cortana web search in Start Menu
- Cleaner, faster system

### Over Time:
- **Zero telemetry sent to Microsoft**
- **Zero forced updates**
- **No tracking**
- **No data collection**

### Trade-offs:
- ⚠️ **No automatic security updates** (must update manually)
- Some Microsoft features won't work (OneDrive sync, Timeline, etc.)
- Store may not work properly (you kept apps, but Store service affected)

---

## MANUAL WINDOWS UPDATE (When Needed)

Since auto-update is disabled, update manually every month:

```powershell
# 1. Temporarily re-enable Windows Update
Set-Service wuauserv -StartupType Manual
Start-Service wuauserv

# 2. Check for updates
Start ms-settings:windowsupdate

# 3. Install updates

# 4. Re-disable Windows Update
Stop-Service wuauserv
Set-Service wuauserv -StartupType Disabled
```

**Recommendation:** Update once per month for security patches

---

## REVERSAL (If Needed)

### Full System Restore:
```cmd
rstrui.exe
# Select: "Before Privacy Lockdown"
```

### Re-enable Windows Update Only:
```powershell
Set-Service wuauserv -StartupType Automatic
Set-Service UsoSvc -StartupType Automatic
Start-Service wuauserv
Start-Service UsoSvc
```

### Restore Hosts File:
```powershell
Copy-Item C:\Windows\System32\drivers\etc\hosts.backup C:\Windows\System32\drivers\etc\hosts -Force
ipconfig /flushdns
```

### Re-enable All Services:
```powershell
$services = @('DiagTrack','dmwappushservice','WerSvc','OneSyncSvc')
foreach ($svc in $services) {
    Set-Service $svc -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service $svc -ErrorAction SilentlyContinue
}
```

---

## BACKUP LOCATIONS

Backups created automatically:
```
C:\Windows\System32\drivers\etc\hosts.backup
System Restore Point: "Before Privacy Lockdown"
```

---

## SECURITY NOTE

**You are now responsible for updates!**

Microsoft can't force updates anymore, which means:
- ✅ No unwanted reboots
- ✅ No feature updates you don't want
- ⚠️ Security patches won't auto-install

**Best practice:**
- Check for updates monthly
- Install critical security patches
- Skip feature updates if you want

---

## FILES CREATED

All in: `.\Scripts\Scripts\`

```
PRIVACY_LOCKDOWN_MASTER.ps1      - One-click execution
DEBLOAT_3_DISABLE_TELEMETRY.bat  - Registry tweaks
DEBLOAT_4_DISABLE_SERVICES.ps1   - Service disabling
DEBLOAT_5_BLOCK_DOMAINS.ps1      - Hosts file blocking
DEBLOAT_6_DISABLE_UPDATES.ps1    - Windows Update disable
```

---

## READY TO EXECUTE?

**Recommended command:**

```cmd
cd .\Scripts
Tools\NSudo\NSudoLC.exe -U:T -P:E powershell -File "Scripts\PRIVACY_LOCKDOWN_MASTER.ps1"
```

**Type 'LOCKDOWN' when prompted, then restart after completion.**

**Your system will be LOCKED DOWN - no telemetry, no tracking, no forced updates.**

