# QUICK EXECUTION GUIDE

## YOU'RE IN THE WRONG PLACE

You opened a TrustedInstaller PowerShell, but didn't run the script.

---

## CORRECT EXECUTION:

### Method 1: From TrustedInstaller CMD (Easier)

1. **Close current PowerShell window**

2. **Double-click: "TrustedInstaller CMD"** (not PS)

3. **Run these commands:**
```cmd
cd .\Scripts
powershell -ExecutionPolicy Bypass -File "Scripts\KILL_SPYWARE.ps1"
```

4. **Type `KILL` when prompted**

---

### Method 2: From Current TrustedInstaller PS (You're here now)

**Since you're already in TrustedInstaller PowerShell:**

```powershell
# Press Ctrl+C to cancel current command

# Then run:
cd .\Scripts
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Scripts\KILL_SPYWARE.ps1
```

**Type `KILL` when the script prompts you**

---

### Method 3: Direct NSudo Launch (From normal CMD/PS)

```cmd
cd .\Scripts
Tools\NSudo\NSudoLC.exe -U:T -P:E powershell -ExecutionPolicy Bypass -File "Scripts\KILL_SPYWARE.ps1"
```

---

## WHAT YOU DID WRONG

You typed `KILL` directly in PowerShell.

PowerShell interpreted it as: `Stop-Process -Name KILL`

**You need to RUN THE SCRIPT FIRST, then type KILL when the script asks.**

---

## TRY AGAIN:

**Press Ctrl+C to exit the current command**

**Then:**
```powershell
cd .\Scripts
.\Scripts\KILL_SPYWARE.ps1
```

**Wait for script to load and ask for confirmation**

**THEN type `KILL`**

