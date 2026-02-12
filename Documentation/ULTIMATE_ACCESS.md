# ULTIMATE ACCESS - COMPLETE GUIDE TO OWNING YOUR SYSTEM

## YOUR CURRENT LIMITATIONS

**What you have:**
- Administrator account (BUILTIN\Administrators)
- Medium Mandatory Level (UAC filtered)
- Limited privileges (no SeDebugPrivilege, no SeTakeOwnershipPrivilege)

**What's blocking you:**
1. **UAC (User Account Control)** - Filters admin token to Medium integrity
2. **TrustedInstaller** - Owns critical system files (NT SERVICE\TrustedInstaller)
3. **SYSTEM account** - Higher than admin (NT AUTHORITY\SYSTEM)
4. **Secure Boot** - Prevents unauthorized kernel modifications
5. **Driver Signature Enforcement** - Blocks unsigned drivers
6. **Windows Defender** - Active protection against "suspicious" modifications

---

## ESCALATION LEVELS - FROM LEAST TO MOST INVASIVE

### LEVEL 1: DISABLE UAC (PARTIAL ACCESS)

**What it does:** Stops token filtering, gives true admin rights  
**What you gain:** High integrity instead of Medium  
**What you DON'T gain:** SYSTEM access, TrustedInstaller ownership  
**Reversible:** Yes

**Execution:**
```powershell
# Disable UAC completely
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

# Restart required
Restart-Computer
```

**After restart:**
- No more UAC prompts
- True administrator rights
- Can modify most system files
- Still can't touch TrustedInstaller-owned files
- Device Manager modifications may work

**Risk:** LOW - Easy to reverse, doesn't break anything

---

### LEVEL 2: ENABLE ALL PRIVILEGES (MORE ACCESS)

**What it does:** Grants SeTakeOwnershipPrivilege, SeDebugPrivilege, etc.  
**What you gain:** Can take ownership of files/registry, debug processes  
**What you DON'T gain:** Automatic SYSTEM access  
**Reversible:** Yes

**Execution:**
```powershell
# Add to local security policy
secedit /export /cfg C:\Temp\secpol.cfg
$content = Get-Content C:\Temp\secpol.cfg
$content = $content -replace "SeTakeOwnershipPrivilege = .*", "SeTakeOwnershipPrivilege = *S-1-5-32-544"
$content = $content -replace "SeDebugPrivilege = .*", "SeDebugPrivilege = *S-1-5-32-544"
$content | Set-Content C:\Temp\secpol_new.cfg
secedit /configure /db secedit.sdb /cfg C:\Temp\secpol_new.cfg

# Or use Local Security Policy GUI:
# secpol.msc → Local Policies → User Rights Assignment
# Add "Administrators" to:
# - Take ownership of files or other objects
# - Debug programs
# - Back up files and directories
# - Restore files and directories
```

**After applying:**
- Can take ownership of any file
- Can debug any process
- Can backup/restore system files
- Still need to manually claim ownership

**Risk:** LOW - Standard for power users

---

### LEVEL 3: PERMANANT SYSTEM SHELL (HEAVY ACCESS)

**What it does:** Create always-available SYSTEM command prompt  
**What you gain:** NT AUTHORITY\SYSTEM privileges on demand  
**What you DON'T gain:** TrustedInstaller (SYSTEM < TrustedInstaller)  
**Reversible:** Yes

**Method A: Task Scheduler (Persistent)**
```powershell
# Create SYSTEM-level PowerShell that auto-starts
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoExit -Command "Write-Host ''SYSTEM Shell'' -ForegroundColor Red"'
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "SystemShell" -Action $action -Trigger $trigger -Principal $principal

# Access via:
# Start-ScheduledTask -TaskName "SystemShell"
# Then attach to the process
```

**Method B: Service (More Permanent)**
```powershell
# Create a Windows service that runs as SYSTEM
sc.exe create SystemShell binPath= "cmd.exe /k" type= own type= interact
sc.exe start SystemShell
```

**Method C: PSExec (Quick)**
```powershell
# Download PSExec
Invoke-WebRequest -Uri "https://live.sysinternals.com/PsExec64.exe" -OutFile "C:\Temp\PsExec64.exe"

# Launch SYSTEM shell
C:\Temp\PsExec64.exe -s -i -d cmd.exe
# OR
C:\Temp\PsExec64.exe -s -i -d powershell.exe
```

**After setup:**
- Run anything as SYSTEM
- Can modify almost all files
- Can manipulate running services
- Still can't edit TrustedInstaller files without taking ownership first

**Risk:** LOW-MEDIUM - SYSTEM is powerful but documented/expected

---

### LEVEL 4: TRUSTEDINSTALLER ACCESS (ULTIMATE WINDOWS ACCESS)

**What it does:** Become TrustedInstaller (highest Windows privilege)  
**What you gain:** Can modify ANY Windows file/registry key  
**What you DON'T gain:** Kernel-level access (still userland)  
**Reversible:** Yes

**Method A: Token Manipulation (Advanced)**
```powershell
# Requires SYSTEM first, then impersonate TrustedInstaller
# Run from SYSTEM shell:

$TI = Get-Process -Name "TrustedInstaller" -ErrorAction SilentlyContinue
if (-not $TI) {
    # Start TrustedInstaller service
    sc.exe start TrustedInstaller
    Start-Sleep -Seconds 2
    $TI = Get-Process -Name "TrustedInstaller"
}

# Use C++ or PowerShell Empire to steal TI token
# This requires advanced scripting
```

**Method B: Manual Ownership + Full Control**
```powershell
# Take ownership of any file/registry key
takeown /F "C:\Windows\System32\drivers\etc\hosts" /A
icacls "C:\Windows\System32\drivers\etc\hosts" /grant Administrators:F

# For registry:
# Right-click key → Permissions → Advanced → Change Owner → Administrators → Apply
# Then grant Full Control to Administrators
```

**Method C: NSudo Tool (Automated TrustedInstaller)**
Download NSudo: https://github.com/M2Team/NSudo/releases
```powershell
# Run anything as TrustedInstaller
NSudo.exe -U:T -P:E cmd.exe
# -U:T = TrustedInstaller
# -P:E = Elevated
```

**After TrustedInstaller access:**
- Can delete/modify ANY Windows file
- Can edit ANY registry key
- Can remove Windows components
- Can break Windows easily

**Risk:** MEDIUM-HIGH - Easy to brick Windows if you delete wrong files

---

### LEVEL 5: DISABLE SECURE BOOT + DRIVER SIGNING (KERNEL ACCESS)

**What it does:** Allows unsigned drivers, kernel modifications  
**What you gain:** Can load custom drivers, modify kernel  
**What you DON'T gain:** Protection against malware  
**Reversible:** Yes (but requires reboot)

**Execution:**
```powershell
# Disable driver signature enforcement
bcdedit /set nointegritychecks on
bcdedit /set testsigning on
bcdedit /set loadoptions DDISABLE_INTEGRITY_CHECKS

# Disable Secure Boot (BIOS setting)
# Restart → F2 → Security → Secure Boot → Disabled
```

**After disabling:**
- Can load unsigned drivers
- Can inject into kernel
- Can run rootkits (yours or malicious)
- Windows shows "Test Mode" watermark

**Risk:** HIGH - Disables security, allows malware

---

### LEVEL 6: KERNEL DEBUGGER ACCESS (DEEPEST WINDOWS ACCESS)

**What it does:** Enables kernel debugging, full hardware control  
**What you gain:** Can modify kernel memory, debug drivers  
**What you DON'T gain:** Physical security bypass  
**Reversible:** Yes

**Execution:**
```powershell
# Enable kernel debugging
bcdedit /debug on
bcdedit /dbgsettings serial debugport:1 baudrate:115200

# Or network debugging:
bcdedit /dbgsettings NET HOSTIP:192.168.1.10 PORT:50000

# Requires debugger attached (WinDbg)
```

**After enabling:**
- Full kernel memory access
- Can modify any process
- Can bypass Windows protection
- Requires external debugger tool

**Risk:** HIGH - Kernel-level access, can crash system easily

---

### LEVEL 7: CUSTOM BOOTLOADER (BEYOND WINDOWS)

**What it does:** Replace Windows Boot Manager  
**What you gain:** Pre-Windows execution, unsigned OS loading  
**What you DON'T gain:** Easier system management  
**Reversible:** Yes (if you back up)

**Options:**
- **GRUB2** - Linux bootloader, can chainload Windows
- **rEFInd** - UEFI boot manager
- **Clover** - Hackintosh bootloader (works on regular PCs)

**Risk:** EXTREME - Can make system unbootable if misconfigured

---

## PRACTICAL RECOMMENDED SETUP

**For daily "ultimate access" without breaking things:**

**1. Disable UAC (Level 1)**
```powershell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0
Restart-Computer
```

**2. Enable ownership privileges (Level 2)**
```powershell
# Run secpol.msc
# Grant Administrators group: Take ownership, Debug, Backup, Restore
```

**3. Keep PSExec handy (Level 3)**
```powershell
# Download once:
Invoke-WebRequest -Uri "https://live.sysinternals.com/PsExec64.exe" -OutFile "C:\Windows\System32\PsExec64.exe"

# Use when needed:
PsExec64.exe -s -i cmd.exe  # SYSTEM shell
```

**4. Download NSudo for TrustedInstaller (Level 4)**
```powershell
# Keep in C:\Tools\NSudo.exe
# Use when you need TI access:
NSudo.exe -U:T -P:E regedit.exe
```

This gives you on-demand SYSTEM and TrustedInstaller access without permanently disabling security.

---

## WHAT I CAN DO RIGHT NOW

### Option A: Disable UAC + Enable Privileges
```powershell
# I'll execute:
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

# Then you restart and have true admin rights
```

### Option B: Download + Setup PSExec
```powershell
# I'll download PSExec and create easy shortcuts
# You'll have SYSTEM shell on demand
```

### Option C: Full Ultimate Setup
```powershell
# I'll do all of:
# 1. Disable UAC
# 2. Download PSExec, NSudo
# 3. Enable all admin privileges
# 4. Create shortcuts for SYSTEM/TI shells
# 5. Document everything
```

### Option D: Show Me Everything, I'll Decide
```powershell
# I'll create detailed docs for all 7 levels
# You choose which to implement
```

---

## WHICH LEVEL OF ACCESS DO YOU WANT?

Type:
- **LEVEL1** = Disable UAC only (safest, still powerful)
- **LEVEL3** = UAC + PSExec SYSTEM shell (recommended)
- **LEVEL4** = UAC + PSExec + NSudo (TrustedInstaller access)
- **LEVEL5** = Everything + disable driver signing (kernel access)
- **NUCLEAR** = Full documentation for all 7 levels, you decide

**My recommendation: LEVEL3 (UAC + PSExec)**
- True admin rights immediately
- SYSTEM access on demand
- Safe, reversible, standard for power users
- Gives you control without breaking security
