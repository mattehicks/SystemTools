# LEVEL 3 SETUP - MANUAL EXECUTION REQUIRED

## WHAT I TRIED TO DO AUTOMATICALLY

**Attempted:**
1. ✗ Disable UAC → Registry access denied
2. ✓ Download PSExec → Success (C:\Temp\PsExec64.exe)
3. ✗ Download NSudo → GitHub link unavailable

**Why it failed:**
Even with Desktop Commander running as "admin", UAC Medium integrity blocks:
- Registry modifications (HKLM\SOFTWARE\...)
- Some system file access
- Task scheduler modifications

**This proves you need the elevated access we're trying to set up!**

---

## MANUAL SETUP STEPS (YOU MUST DO THESE)

### STEP 1: DISABLE UAC (Run as TRUE Admin)

**Option A: GUI Method (Easiest)**
1. Press Windows key
2. Type: `UAC`
3. Click: "Change User Account Control settings"
4. Drag slider to "Never notify"
5. Click: OK
6. Restart computer

**Option B: Registry Method**
1. Press Windows + R
2. Type: `regedit` and press Enter
3. Navigate to: `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System`
4. Find: `EnableLUA`
5. Double-click → Change value to `0`
6. Click: OK
7. Restart computer

**Option C: Command Prompt (Admin)**
1. Right-click Start → "Windows PowerShell (Admin)" or "Command Prompt (Admin)"
2. Run this command:
```cmd
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f
```
3. Restart computer

**After restart:**
- No more UAC prompts
- True administrator rights (High integrity)
- Can modify system files
- Registry edits work

---

### STEP 2: VERIFY PSEXEC (Already Downloaded)

PSExec is ready at: `C:\Temp\PsExec64.exe`

**Test it (after UAC is disabled and restart):**
```powershell
C:\Temp\PsExec64.exe -accepteula -s -i cmd.exe
```

This should open a command prompt running as **NT AUTHORITY\SYSTEM**

**Verify by running:**
```cmd
whoami
```
Should show: `nt authority\system`

---

### STEP 3: DOWNLOAD NSUDO MANUALLY

**Download from:**
https://github.com/M2TeamArchived/NSudo/releases

**Or direct link (try these in order):**
1. https://github.com/M2Team/NSudo/releases/latest
2. https://nsudo.m2team.org/en-us/

**Extract to:** `C:\Tools\NSudo\`

**Files you need:**
- NSudoLG.exe (GUI version)
- NSudoLC.exe (command line version)

**Test it:**
```cmd
C:\Tools\NSudo\NSudoLG.exe
```

In NSudo GUI:
- User: Select "TrustedInstaller"
- Privilege: "Enable All Privileges"
- Command: `cmd`
- Click: Run

This opens a command prompt as **TrustedInstaller**

---

### STEP 4: CREATE EASY SHORTCUTS

After UAC is disabled and NSudo is downloaded, run these commands:

**SYSTEM Shell Shortcut:**
```powershell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\SYSTEM Shell.lnk")
$Shortcut.TargetPath = "C:\Temp\PsExec64.exe"
$Shortcut.Arguments = "-accepteula -s -i cmd.exe"
$Shortcut.IconLocation = "cmd.exe"
$Shortcut.Description = "Command Prompt as NT AUTHORITY\SYSTEM"
$Shortcut.Save()
```

**TrustedInstaller Shell Shortcut:**
```powershell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\TrustedInstaller Shell.lnk")
$Shortcut.TargetPath = "C:\Tools\NSudo\NSudoLC.exe"
$Shortcut.Arguments = "-U:T -P:E cmd"
$Shortcut.IconLocation = "cmd.exe"
$Shortcut.Description = "Command Prompt as TrustedInstaller"
$Shortcut.Save()
```

---

## WHAT YOU'LL HAVE AFTER SETUP

**Desktop Shortcuts:**
1. **"SYSTEM Shell"** → Click to open NT AUTHORITY\SYSTEM command prompt
2. **"TrustedInstaller Shell"** → Click to open TrustedInstaller command prompt

**Capabilities:**
- No UAC prompts ever
- True admin rights by default
- SYSTEM access: Double-click "SYSTEM Shell" shortcut
- TrustedInstaller access: Double-click "TrustedInstaller Shell" shortcut
- Can modify ANY Windows file
- Can edit ANY registry key
- Can remove ghost devices (finally!)

---

## REMOVING GHOST DEVICES (After Setup)

Once you have TrustedInstaller access:

**Method 1: DevManView in TrustedInstaller Shell**
```cmd
# Open TrustedInstaller Shell from desktop
cd C:\Temp\DevManView
DevManView.exe /remove_all_disconnected
```

**Method 2: Registry Direct**
```cmd
# Open TrustedInstaller Shell
regedit

# Delete ghost entries from:
# HKLM\SYSTEM\CurrentControlSet\Enum\USB
# HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR
# HKLM\SYSTEM\CurrentControlSet\Enum\HID
```

---

## QUICK REFERENCE

**Current Status:**
- PSExec: ✓ Downloaded (C:\Temp\PsExec64.exe)
- NSudo: ✗ Needs manual download
- UAC: ✗ Still enabled (needs manual disable + restart)
- Shortcuts: ✗ Not created yet

**Your Action Items:**
1. Disable UAC (see STEP 1 above)
2. Restart computer
3. Download NSudo (see STEP 3 above)
4. Create shortcuts (see STEP 4 above)
5. Test: Double-click "SYSTEM Shell" → Run `whoami` → Should show "nt authority\system"

**After that, you'll have ultimate control of your system.**

---

## REVERSING THE CHANGES (If Needed)

**Re-enable UAC:**
```cmd
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f
```
Then restart.

**Remove tools:**
- Delete C:\Temp\PsExec64.exe
- Delete C:\Tools\NSudo folder
- Delete desktop shortcuts

**Everything is reversible.**
