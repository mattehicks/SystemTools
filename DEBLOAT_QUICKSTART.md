# WINDOWS DEBLOAT - QUICK START

**Goal:** Maximum privacy, minimum Microsoft interference

**Approach:** Step-by-step, reversible, nuclear option available

---

## OPTION 1: SAFE DEBLOAT (Recommended Start)

Run these in order, test after each:

### Step 1: Inventory (See what you have)
```powershell
.\Scripts\DEBLOAT_1_INVENTORY.ps1
```
Review: `bloatware_inventory.csv`

### Step 2: Remove Bloatware Apps
```cmd
# Double-click "TrustedInstaller CMD" desktop shortcut, then:
cd .\Scripts
Tools\NSudo\NSudoLC.exe -U:T -P:E powershell -File "Scripts\DEBLOAT_2_REMOVE_APPS.ps1"
```

### Step 3: Disable Telemetry
```cmd
# In TrustedInstaller CMD:
Scripts\DEBLOAT_3_DISABLE_TELEMETRY.bat
```

### Step 4: Restart & Test
```powershell
Restart-Computer
```

---

## OPTION 2: NUCLEAR DEBLOAT (All at once)

**Full guide:** `WINDOWS_DEBLOAT_NUCLEAR.md` (550 lines)

**Includes:**
- Remove ALL Microsoft Store apps
- Disable ALL telemetry
- Block Microsoft domains via hosts file
- Disable Windows Update
- Remove Edge browser
- Disable 20+ spyware services
- Disable telemetry scheduled tasks
- Firewall rules to block Microsoft

---

## WHAT GETS REMOVED

### Apps (Phase 2):
```
✗ Xbox (all components)
✗ Cortana
✗ Teams (consumer)
✗ OneDrive
✗ Get Help, Tips, Feedback
✗ Mixed Reality
✗ 3D Viewer, Paint 3D
✗ Skype
✗ Games (Solitaire, Candy Crush)
✗ News, Weather, Mail, Calendar
✗ Maps, Voice Recorder, Alarms
✗ Your Phone
✗ Office Hub
✗ People app

✓ KEEPS: Store, Calculator, Photos, Snipping Tool, Paint
```

### Services Disabled (Phase 4):
```
✗ DiagTrack (Telemetry)
✗ dmwappushservice
✗ WerSvc (Error Reporting)
✗ OneSyncSvc
✗ XblAuthManager (Xbox)
✗ XblGameSave (Xbox)
✗ lfsvc (Geolocation)
✗ WSearch (Windows Search - optional)
... and 12 more
```

### Telemetry Blocked (Phase 3):
```
✗ Data collection
✗ Activity feed
✗ Cortana
✗ Error reporting
✗ CEIP
✗ Feedback
✗ Advertising ID
✗ Location tracking
✗ OneDrive sync
✗ Windows tips
✗ Timeline
✗ Windows Spotlight
✗ Bing in Start Menu
```

---

## EXECUTION METHODS

### Method A: Step-by-Step (Safer)
```cmd
1. Run: DEBLOAT_1_INVENTORY.ps1 (review what you have)
2. Run: DEBLOAT_2_REMOVE_APPS.ps1 (remove bloatware)
3. Run: DEBLOAT_3_DISABLE_TELEMETRY.bat (disable spyware)
4. Restart
5. Test system
6. Continue with more phases if desired
```

### Method B: Nuclear (All phases)
```
See: WINDOWS_DEBLOAT_NUCLEAR.md
Contains complete 10-phase guide with all code
```

---

## REVERSAL

If something breaks:

### Restore Point
```cmd
rstrui.exe
# Select: "Before Nuclear Debloat"
```

### Re-enable Windows Update
```powershell
Set-Service wuauserv -StartupType Automatic
Start-Service wuauserv
```

### Restore Hosts File
```powershell
Copy-Item "C:\Windows\System32\drivers\etc\hosts.backup" "C:\Windows\System32\drivers\etc\hosts" -Force
ipconfig /flushdns
```

### Re-enable Services
```powershell
# Example:
Set-Service DiagTrack -StartupType Automatic
Start-Service DiagTrack
```

---

## WARNINGS

🔴 **TRADE-OFFS:**
- Windows Update disabled = Security risk
- Store removed = Can't install UWP apps
- Telemetry blocked = Some apps may break
- Cortana/Search broken = No web results
- OneDrive disabled = No sync
- Xbox disabled = No Game Bar

**This is for PRIVACY, not convenience.**

---

## FILES CREATED

All in: `.\Scripts\`

### Documentation:
- `WINDOWS_DEBLOAT_NUCLEAR.md` - Complete 10-phase guide
- `DEBLOAT_QUICKSTART.md` - This file

### Scripts:
- `Scripts\DEBLOAT_1_INVENTORY.ps1` - Scan current bloat
- `Scripts\DEBLOAT_2_REMOVE_APPS.ps1` - Remove Microsoft Store apps
- `Scripts\DEBLOAT_3_DISABLE_TELEMETRY.bat` - Registry privacy tweaks

### More scripts in full guide:
- DEBLOAT_4_DISABLE_SERVICES.ps1
- DEBLOAT_5_BLOCK_DOMAINS.ps1
- DEBLOAT_6_DISABLE_UPDATES.ps1
- DEBLOAT_7_REMOVE_EDGE.ps1
- DEBLOAT_8_FIREWALL_RULES.ps1
- DEBLOAT_9_DISABLE_TASKS.ps1

---

## RECOMMENDED APPROACH

**For you (power user, max privacy):**

1. **Today:** Run Phase 1-3 (Inventory, Remove Apps, Disable Telemetry)
2. **Test:** Use system for 1 day, see what breaks
3. **Tomorrow:** Continue with Phase 4-5 (Services, Hosts file)
4. **Decide:** Whether to go nuclear with Windows Update disable

**Start here:**
```cmd
# Double-click "TrustedInstaller CMD"
cd .\Scripts
powershell -File Scripts\DEBLOAT_1_INVENTORY.ps1
```

---

**Ready to begin?**

