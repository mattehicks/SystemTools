# ClaudeDesktop HQ - Quick Reference Card

## Location
```
.\Scripts
```

## One-Liners

### Navigate to HQ
```cmd
cd .\Scripts
```

### Launch TrustedInstaller Shell
```cmd
Tools\NSudo\NSudoLC.exe -U:T -P:E cmd
```

### Launch SYSTEM Shell
```cmd
Tools\PsExec64.exe -accepteula -s -i cmd
```

### Remove All Ghost Devices
```cmd
Tools\NSudo\NSudoLC.exe -U:T -P:E "Tools\DevManView\DevManView.exe /remove_all_disconnected"
```

### Check Ghost Device Count
```powershell
Get-PnpDevice | Where-Object {$_.Status -eq 'Unknown' -or $_.Status -eq 'Error'} | Measure-Object
```

### Verify WiFi Adapters
```powershell
Get-NetAdapter | Where-Object {$_.InterfaceDescription -match 'NETGEAR|TP-Link'}
```

### Clear All Event Logs
```powershell
.\Scripts\CLEAR_EVENT_LOGS.ps1
```

---

## Desktop Shortcuts (Already on Desktop)

- **TrustedInstaller CMD** - Highest privilege command prompt
- **TrustedInstaller PS** - Highest privilege PowerShell
- **SYSTEM CMD** - NT AUTHORITY\SYSTEM command prompt
- **SYSTEM PS** - NT AUTHORITY\SYSTEM PowerShell  
- **NSudo GUI** - Graphical launcher

---

## File Structure

```
ClaudeDesktop\
├── README.md              # Main overview
├── QUICK_REFERENCE.md     # This file
├── Documentation\         # 17 markdown guides
├── Scripts\              # 8 PowerShell scripts
└── Tools\                # Symlinks to NSudo, PSExec, DevManView
```

---

## Key Documentation

| File | Purpose |
|------|---------|
| `PHASE1_COMPLETE.md` | Current status, next steps |
| `ULTIMATE_ACCESS.md` | Complete privilege escalation guide |
| `GHOST_DEVICES_EXPLAINED.md` | What ghosts are, how to remove |
| `REPAIR_COMPLETED.md` | Sleep/wake fixes applied |

---

## Current Status

✅ NSudo installed  
✅ Tools ready  
✅ Shortcuts created  
✅ Sleep/wake fixed  
⏳ UAC needs disabling  
⏳ Restart required  
⏳ 120 ghost devices pending removal  

---

## Next Action

**Disable UAC → Restart → Remove ghosts**

1. Windows key → "UAC" → Slider to bottom → OK
2. Restart computer
3. Double-click "TrustedInstaller CMD" on desktop
4. Run: `cd .\Scripts`
5. Run: `Tools\DevManView\DevManView.exe /remove_all_disconnected`
6. Done!

---

**Keep this file handy for quick command reference!**

