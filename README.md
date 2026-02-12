# ClaudeDesktop HQ - Command Center

## Directory Structure

```
.\Scripts\
├── Documentation\     # All guides, explanations, and documentation
├── Scripts\          # PowerShell scripts for automation
├── Tools\            # Symlinks to installed tools
└── README.md         # This file
```

---

## Tools Available

### NSudo (TrustedInstaller Access)
**Location:** `Tools\NSudo\` → `C:\Tools\NSudo\...\x64\`
**Usage:**
```cmd
Tools\NSudo\NSudoLC.exe -U:T -P:E cmd
Tools\NSudo\NSudoLG.exe (GUI)
```

### PSExec (SYSTEM Access)
**Location:** `Tools\PsExec64.exe` → `C:\Temp\PsExec64.exe`
**Usage:**
```cmd
Tools\PsExec64.exe -accepteula -s -i cmd
```

### DevManView (Device Manager)
**Location:** `Tools\DevManView\` → `C:\Temp\DevManView\`
**Usage:**
```cmd
Tools\DevManView\DevManView.exe /remove_all_disconnected
```

---

## Scripts Available

All in `Scripts\` folder:

### Power User Setup
- `RUN_ALL_FIXES.ps1` - Master sleep/wake repair script
- `CREATE_SHORTCUTS.ps1` - Create desktop shortcuts for privilege escalation
- `CLEAR_EVENT_LOGS.ps1` - Clear all Windows event logs

### System Fixes
- `FIX_SLEEP.ps1` - Configure power settings for stable sleep/wake
- `USB_CLEANUP.ps1` - Remove ghost USB devices
- `DISABLE_BROKEN_HARDWARE.ps1` - Disable failed hardware
- `CHECK_WIFI_ADAPTERS.ps1` - Verify WiFi dongles status

### Advanced
- `REMOVE_AS_SYSTEM.ps1` - Device removal with SYSTEM privileges

---

## Documentation Available

All in `Documentation\` folder:

### Quick Reference
- `README.md` - Original sleep/wake project overview
- `PHASE1_COMPLETE.md` - Current status and next steps
- `QUICK_CHECKLIST.md` - Step-by-step checklist

### System Access
- `ULTIMATE_ACCESS.md` - Complete guide to Windows privilege escalation (7 levels)
- `LEVEL3_MANUAL_SETUP.md` - NSudo + PSExec setup guide
- `NSUDO_BRUTE_FORCE_INSTALL.md` - NSudo installation with Defender workaround
- `NSUDO_FALSE_POSITIVE.md` - Why Defender flags NSudo

### Sleep/Wake Issue
- `HARDWARE_ISSUES.md` - Root cause analysis (Win11→Win10 downgrade)
- `FINDINGS.md` - Original diagnostic data
- `REPAIR_PLAN.md` - Detailed repair strategy
- `REPAIR_COMPLETED.md` - What was fixed
- `DUAL_WIFI_SETUP.md` - Dual WiFi adapter configuration

### Ghost Devices
- `GHOST_DEVICES_EXPLAINED.md` - What they are and why they exist
- `BRUTE_FORCE_PLAN.md` - All attempted removal methods
- `REMOVAL_RESULTS.md` - DevManView attempt results

### Original Guides
- `QUICKSTART.md` - Original quick start
- `QUICKSTART_UPDATED.md` - Updated for dual WiFi

---

## Desktop Shortcuts (Already Created)

- 🔴 **TrustedInstaller CMD** - Highest privilege
- 🔴 **TrustedInstaller PS** - Highest privilege PowerShell
- 🟡 **SYSTEM CMD** - NT AUTHORITY\SYSTEM
- 🟡 **SYSTEM PS** - NT AUTHORITY\SYSTEM PowerShell
- 🔵 **NSudo GUI** - Graphical launcher

---

## Quick Commands

### From HQ Root Directory

**Launch TrustedInstaller shell:**
```cmd
Tools\NSudo\NSudoLC.exe -U:T -P:E cmd
```

**Launch SYSTEM shell:**
```cmd
Tools\PsExec64.exe -accepteula -s -i cmd
```

**Remove ghost devices:**
```cmd
Tools\NSudo\NSudoLC.exe -U:T -P:E "Tools\DevManView\DevManView.exe /remove_all_disconnected"
```

**Fix sleep/wake:**
```powershell
.\Scripts\FIX_SLEEP.ps1
```

**Clear event logs:**
```powershell
.\Scripts\CLEAR_EVENT_LOGS.ps1
```

---

## Current Status

### Completed
- ✅ NSudo installed and working
- ✅ PSExec downloaded
- ✅ DevManView ready
- ✅ Desktop shortcuts created
- ✅ Sleep/wake power settings fixed
- ✅ Event logs cleared
- ✅ WiFi adapters analyzed
- ✅ All documentation organized

---

## Next Steps

1. **Disable UAC:**
   - Windows key → Type "UAC"
   - Drag slider to bottom
   - Click OK
   - **Restart computer**

2. **After restart - Remove ghosts:**
   ```cmd
   # Double-click "TrustedInstaller CMD" desktop shortcut
   cd .\Scripts
   Tools\DevManView\DevManView.exe /remove_all_disconnected
   ```

3. **Verify:**
   ```powershell
   Get-PnpDevice | Where-Object {$_.Status -eq 'Unknown'} | Measure-Object
   # Should show 0 or very low count
   ```

4. **Test sleep/wake:**
   - Close lid → wait 10 sec → open
   - Should wake cleanly and quickly
   - Both WiFi adapters should remain connected

---

## Notes

- All tools are symlinked, not copied (saves space)
- Original locations maintained for compatibility
- HQ is version control ready (GitHub folder)
- Scripts use relative paths from HQ root
- Documentation is Markdown for easy viewing

---

**Established: 2026-02-07**    


