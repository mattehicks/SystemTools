# UAC DISABLE - INSTRUCTIONS

## YOU SAID UAC IS DISABLED BUT...

Registry shows: **EnableLUA = 1** (ENABLED)

**This means:**
- Either the setting wasn't changed, OR
- You changed it but haven't restarted yet

**UAC changes require restart to take effect!**

---

## OPTION 1: DISABLE VIA GUI (Easiest)

1. Press **Windows key**
2. Type: **UAC**
3. Click: **"Change User Account Control settings"**
4. **Drag slider all the way to bottom**: "Never notify"
5. Click: **OK**
6. **RESTART COMPUTER** (required!)

---

## OPTION 2: DISABLE VIA SCRIPT (With NSudo)

**Run this as TrustedInstaller:**

1. **Double-click** the desktop shortcut: **"TrustedInstaller CMD"**
2. In the TrustedInstaller window, run:
   ```cmd
   cd .\Scripts\Scripts
   DISABLE_UAC.bat
   ```
3. Should show: "EnableLUA REG_DWORD 0x0"
4. **RESTART COMPUTER**

---

## OPTION 3: MANUAL REGISTRY EDIT

1. Press **Windows + R**
2. Type: **regedit** → Enter
3. Navigate to:
   ```
   HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
   ```
4. Find: **EnableLUA**
5. Double-click it
6. Change value to: **0**
7. Click: **OK**
8. **RESTART COMPUTER**

---

## VERIFICATION AFTER RESTART

After reboot, open PowerShell and run:
```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA
```

Should show: **EnableLUA : 0**

Or check integrity level:
```cmd
whoami /groups | findstr /i "mandatory"
```

Should show: **Mandatory Label\High Mandatory Level**

---

## THEN: REMOVE GHOST DEVICES

After UAC is disabled AND you've restarted:

1. **Double-click**: "TrustedInstaller CMD" on desktop
2. Run:
   ```cmd
   cd .\Scripts
   Tools\DevManView\DevManView.exe /remove_all_disconnected
   ```
3. All 120 ghost devices = GONE

---

## CURRENT STATUS

❌ UAC: Still ENABLED (EnableLUA = 1)  
⏳ Need to: Use one of the 3 options above  
⏳ Then: **RESTART COMPUTER**  
⏳ After restart: Remove ghost devices  

---

**Bottom line: Choose Option 1, 2, or 3 above, then RESTART!**

