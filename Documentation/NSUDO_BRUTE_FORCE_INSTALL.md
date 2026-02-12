# NSUDO INSTALLATION - BRUTE FORCE METHOD

## BRUTE FORCE APPROACH - DISABLE DEFENDER COMPLETELY

Since we can't add exclusions due to UAC restrictions, we'll temporarily disable Defender entirely, install NSudo, then re-enable.

---

## STEP 1: DISABLE WINDOWS DEFENDER (GUI METHOD)

**This must be done manually in Windows Security:**

1. Press **Windows key**
2. Type: **Windows Security**
3. Click: **Windows Security** app
4. Click: **Virus & threat protection**
5. Under "Virus & threat protection settings", click: **Manage settings**
6. Turn **OFF** these toggles:
   - ✓ Real-time protection
   - ✓ Cloud-delivered protection
   - ✓ Automatic sample submission
   - ✓ Tamper Protection (turn this off FIRST)

**Important order:** Disable Tamper Protection FIRST, then the others will allow disabling.

---

## STEP 2: DOWNLOAD & EXTRACT NSUDO

After Defender is off:

**Method A: Browser Download**
```
URL: https://github.com/M2TeamArchived/NSudo/releases/download/8.2/NSudo_8.2_All_Components.zip
Save to: C:\Temp\
```

**Method B: PowerShell (if you prefer)**
```powershell
Invoke-WebRequest -Uri "https://github.com/M2TeamArchived/NSudo/releases/download/8.2/NSudo_8.2_All_Components.zip" -OutFile "C:\Temp\NSudo.zip" -UseBasicParsing
Expand-Archive -Path "C:\Temp\NSudo.zip" -DestinationPath "C:\Tools\NSudo" -Force
```

**Expected files in C:\Tools\NSudo\:**
- NSudoLG.exe (GUI - Launcher with GUI)
- NSudoLC.exe (Command line)
- NSudoG.exe (Core)

---

## STEP 3: VERIFY NSUDO FILES

**Check digital signature:**
```powershell
Get-AuthenticodeSignature "C:\Tools\NSudo\NSudoLG.exe" | Select-Object Status, SignerCertificate
```

**Should show:**
- Status: Valid (or NotSigned - older versions weren't signed)
- If signed, Signer: Mouri_Naruto

**Check file hashes (optional verification):**
```powershell
Get-FileHash "C:\Tools\NSudo\NSudoLG.exe" -Algorithm SHA256
```

---

## STEP 4: ADD PERMANENT DEFENDER EXCLUSION

**After NSudo is extracted, add exclusion so Defender doesn't delete it when re-enabled:**

```powershell
# This should work now with Tamper Protection off
Add-MpPreference -ExclusionPath "C:\Tools\NSudo"
```

**Or via GUI:**
1. Windows Security → Virus & threat protection
2. Manage settings
3. Scroll to "Exclusions"
4. Add or remove exclusions → Add an exclusion
5. Folder → Browse to C:\Tools\NSudo

---

## STEP 5: TEST NSUDO

**Test GUI version:**
```powershell
C:\Tools\NSudo\NSudoLG.exe
```

**NSudo window should open with:**
- User dropdown: TrustedInstaller, SYSTEM, Current User, etc.
- Privilege: Enable All Privileges
- Command line input box

**Test command line version:**
```powershell
# Launch CMD as TrustedInstaller
C:\Tools\NSudo\NSudoLC.exe -U:T -P:E cmd

# In the new CMD window, verify:
whoami /user
# Should show: NT SERVICE\TrustedInstaller
```

---

## STEP 6: RE-ENABLE WINDOWS DEFENDER

After NSudo is working and exclusion is added:

1. Windows Security → Virus & threat protection
2. Manage settings
3. Turn **ON**:
   - ✓ Real-time protection
   - ✓ Cloud-delivered protection  
   - ✓ Automatic sample submission
   - ✓ Tamper Protection

**NSudo should remain in C:\Tools\NSudo\ (exclusion protects it)**

---

## STEP 7: CREATE SHORTCUTS

**TrustedInstaller CMD Shortcut:**
```powershell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\TrustedInstaller Shell.lnk")
$Shortcut.TargetPath = "C:\Tools\NSudo\NSudoLC.exe"
$Shortcut.Arguments = "-U:T -P:E cmd"
$Shortcut.WorkingDirectory = "C:\Tools\NSudo"
$Shortcut.Description = "Command Prompt as TrustedInstaller"
$Shortcut.Save()
```

**TrustedInstaller PowerShell Shortcut:**
```powershell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\TrustedInstaller PS.lnk")
$Shortcut.TargetPath = "C:\Tools\NSudo\NSudoLC.exe"
$Shortcut.Arguments = "-U:T -P:E powershell"
$Shortcut.WorkingDirectory = "C:\Tools\NSudo"
$Shortcut.Description = "PowerShell as TrustedInstaller"
$Shortcut.Save()
```

**SYSTEM Shell Shortcut (using PSExec):**
```powershell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\SYSTEM Shell.lnk")
$Shortcut.TargetPath = "C:\Temp\PsExec64.exe"
$Shortcut.Arguments = "-accepteula -s -i cmd"
$Shortcut.WorkingDirectory = "C:\Temp"
$Shortcut.Description = "Command Prompt as NT AUTHORITY\SYSTEM"
$Shortcut.Save()
```

---

## STEP 8: VERIFY ACCESS LEVELS

**Test each shortcut:**

**1. Normal PowerShell:**
```powershell
whoami
# Should show: YourComputerName\matt
```

**2. SYSTEM Shell (PSExec shortcut):**
```cmd
whoami
# Should show: nt authority\system
```

**3. TrustedInstaller Shell (NSudo shortcut):**
```cmd
whoami /user
# Should show: NT SERVICE\TrustedInstaller
```

---

## NSUDO USAGE GUIDE

**Command Line Syntax:**
```
NSudoLC.exe -U:<User> -P:<Privilege> <Command>
```

**User options (-U):**
- `T` = TrustedInstaller
- `S` = SYSTEM
- `C` = Current User (elevated)
- `P` = Current Process (inherit)

**Privilege options (-P):**
- `E` = Enable All Privileges
- `D` = Disable All Privileges

**Examples:**
```powershell
# Run regedit as TrustedInstaller
NSudoLC.exe -U:T -P:E regedit

# Run DevManView as SYSTEM
NSudoLC.exe -U:S -P:E "C:\Temp\DevManView\DevManView.exe"

# Delete protected file as TrustedInstaller
NSudoLC.exe -U:T -P:E cmd /c "del C:\Windows\System32\protected_file.dll"
```

---

## REMOVING GHOST DEVICES WITH TRUSTEDINSTALLER

**Method 1: DevManView in TI shell**
```cmd
# Double-click "TrustedInstaller Shell" desktop shortcut
cd C:\Temp\DevManView
DevManView.exe /remove_all_disconnected
```

**Method 2: Registry direct deletion**
```cmd
# Open TrustedInstaller Shell
NSudoLC.exe -U:T -P:E regedit

# Navigate to and DELETE ghost entries:
# HKLM\SYSTEM\CurrentControlSet\Enum\USB\[VID_xxxx entries with no FriendlyName]
# HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR\[Disk entries]
# HKLM\SYSTEM\CurrentControlSet\Enum\HID\[HID entries]
```

**Method 3: PowerShell script in TI**
```powershell
# Run PowerShell as TrustedInstaller
NSudoLC.exe -U:T -P:E powershell

# Then in PowerShell:
$paths = @(
    "HKLM:\SYSTEM\CurrentControlSet\Enum\USB",
    "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR"
)

foreach ($path in $paths) {
    Get-ChildItem $path -Recurse | Where-Object {
        -not (Get-ItemProperty -Path $_.PSPath -Name "FriendlyName" -ErrorAction SilentlyContinue)
    } | Remove-Item -Recurse -Force
}
```

---

## TROUBLESHOOTING

**NSudo doesn't launch:**
- Make sure you extracted the ZIP (don't run from inside ZIP)
- Check that all three files exist: NSudoLG.exe, NSudoLC.exe, NSudoG.exe
- Try running from C:\Tools\NSudo\ directory

**"Access Denied" in TrustedInstaller shell:**
- Verify you're actually TrustedInstaller: `whoami /user`
- Some files require taking ownership first even with TI

**Defender keeps deleting NSudo:**
- Verify exclusion was added: `Get-MpPreference | Select-Object -ExpandProperty ExclusionPath`
- Tamper Protection must be OFF to add exclusions

---

## CURRENT STATUS

**What you have:**
- ✓ PSExec downloaded (C:\Temp\PsExec64.exe)
- ✓ DevManView downloaded (C:\Temp\DevManView\)
- ✗ NSudo needs manual installation (Defender blocking)
- ✗ UAC still enabled (needs manual disable + restart)

**Your checklist:**
1. [ ] Disable Tamper Protection in Windows Security
2. [ ] Disable Real-time Protection
3. [ ] Download NSudo to C:\Tools\NSudo\
4. [ ] Extract NSudo
5. [ ] Add exclusion for C:\Tools\NSudo
6. [ ] Re-enable Defender
7. [ ] Test NSudo: `NSudoLC.exe -U:T -P:E cmd`
8. [ ] Create desktop shortcuts
9. [ ] Disable UAC (separate task)
10. [ ] Restart computer
11. [ ] Remove ghost devices

---

**Ready to start? Begin with disabling Tamper Protection in Windows Security.**

