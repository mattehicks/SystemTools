# NSUDO + UAC DISABLE - QUICK CHECKLIST

## COMPLETE SYSTEM ACCESS - BRUTE FORCE METHOD

---

## PHASE 1: INSTALL NSUDO (Do this first)

### ☐ 1. Disable Windows Defender
- [ ] Windows Security → Virus & threat protection
- [ ] Manage settings
- [ ] Turn OFF "Tamper Protection" (FIRST!)
- [ ] Turn OFF "Real-time protection"
- [ ] Turn OFF "Cloud-delivered protection"
- [ ] Turn OFF "Automatic sample submission"

### ☐ 2. Download NSudo
- [ ] URL: https://github.com/M2TeamArchived/NSudo/releases/download/8.2/NSudo_8.2_All_Components.zip
- [ ] Save to: C:\Temp\NSudo.zip
- [ ] OR use browser to download

### ☐ 3. Extract NSudo
- [ ] Right-click NSudo.zip → Extract All
- [ ] Extract to: C:\Tools\NSudo\
- [ ] Verify files exist:
  - [ ] C:\Tools\NSudo\NSudoLG.exe
  - [ ] C:\Tools\NSudo\NSudoLC.exe
  - [ ] C:\Tools\NSudo\NSudoG.exe

### ☐ 4. Add Defender Exclusion
- [ ] Windows Security → Virus & threat protection
- [ ] Manage settings → Exclusions
- [ ] Add exclusion → Folder → C:\Tools\NSudo

### ☐ 5. Re-enable Defender
- [ ] Turn ON "Real-time protection"
- [ ] Turn ON "Cloud-delivered protection"
- [ ] Turn ON "Automatic sample submission"
- [ ] Turn ON "Tamper Protection"

### ☐ 6. Test NSudo
```cmd
C:\Tools\NSudo\NSudoLC.exe -U:T -P:E cmd
```
- [ ] New CMD window opens
- [ ] Run: `whoami /user`
- [ ] Should show: NT SERVICE\TrustedInstaller

---

## PHASE 2: DISABLE UAC (Do this after NSudo works)

### ☐ 7. Disable UAC via GUI
- [ ] Press Windows key
- [ ] Type: "UAC"
- [ ] Click: "Change User Account Control settings"
- [ ] Drag slider to: "Never notify" (bottom)
- [ ] Click: OK
- [ ] May prompt for admin - click Yes

### ☐ 8. Restart Computer
- [ ] Save all work
- [ ] Restart computer
- [ ] UAC is now disabled permanently

---

## PHASE 3: CREATE SHORTCUTS (After restart)

### ☐ 9. TrustedInstaller Shortcut
```powershell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\TrustedInstaller.lnk")
$Shortcut.TargetPath = "C:\Tools\NSudo\NSudoLC.exe"
$Shortcut.Arguments = "-U:T -P:E cmd"
$Shortcut.Save()
```

### ☐ 10. SYSTEM Shortcut
```powershell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\SYSTEM.lnk")
$Shortcut.TargetPath = "C:\Temp\PsExec64.exe"
$Shortcut.Arguments = "-accepteula -s -i cmd"
$Shortcut.Save()
```

---

## PHASE 4: REMOVE GHOST DEVICES (Final step)

### ☐ 11. Use TrustedInstaller to Remove Ghosts
```cmd
# Double-click "TrustedInstaller" desktop shortcut
cd C:\Temp\DevManView
DevManView.exe /remove_all_disconnected
```

### ☐ 12. Verify Removal
```powershell
Get-PnpDevice | Where-Object {$_.Status -eq 'Unknown' -or $_.Status -eq 'Error'} | Measure-Object
```
- [ ] Count should be 0 or very low

---

## VERIFICATION CHECKLIST

After everything is complete:

### Access Levels:
- [ ] Normal PowerShell: `whoami` → YourComputerName\matt
- [ ] SYSTEM shortcut: `whoami` → nt authority\system
- [ ] TrustedInstaller shortcut: `whoami /user` → NT SERVICE\TrustedInstaller

### UAC Status:
- [ ] No UAC prompts when running admin tasks
- [ ] Registry edits work without permission errors

### Ghost Devices:
- [ ] Device Manager shows no Unknown/Error USB devices
- [ ] Sleep/wake cycles work correctly

---

## QUICK COMMANDS REFERENCE

**Launch TrustedInstaller CMD:**
```cmd
C:\Tools\NSudo\NSudoLC.exe -U:T -P:E cmd
```

**Launch SYSTEM CMD:**
```cmd
C:\Temp\PsExec64.exe -accepteula -s -i cmd
```

**Check access level:**
```cmd
whoami
whoami /user
whoami /priv
```

**Remove ghost devices:**
```cmd
cd C:\Temp\DevManView
DevManView.exe /remove_all_disconnected
```

---

## ESTIMATED TIME: 15-20 MINUTES

- Phase 1 (NSudo): 10 minutes
- Phase 2 (UAC): 2 minutes + restart
- Phase 3 (Shortcuts): 2 minutes
- Phase 4 (Ghosts): 2 minutes

**Start with Phase 1, Step 1: Disable Tamper Protection**

