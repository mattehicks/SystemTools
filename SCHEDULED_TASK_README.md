# AUTOMATED SPYWARE CHECK - SCHEDULED TASK

**Purpose:** Automatically check weekly if Microsoft spyware services have been re-enabled and disable them.

---

## OVERVIEW

**The problem:**
- Windows Update (if manually run) can re-enable spyware services
- System updates may reset telemetry settings
- Some services auto-restart after reboots

**The solution:**
- Automated weekly check
- Automatically disables re-enabled services
- Runs silently in background
- Creates logs for review

---

## FILES

**1. AUTOMATED_SPYWARE_CHECK.ps1**
- The actual check/fix script
- Runs automatically (no user input)
- Checks telemetry registry
- Checks 14 spyware services
- Re-disables anything that's been re-enabled

**2. CREATE_SPYWARE_TASK.ps1**
- Setup script to create the scheduled task
- Run once as Administrator
- Creates weekly task (Sunday 2 AM)
- Includes test run option

---

## QUICK START

### Create the Scheduled Task

**Run as Administrator:**
```powershell
cd C:\Path\To\SystemsWorks\Scripts
.\CREATE_SPYWARE_TASK.ps1
```

**Prompts:**
1. "Create this scheduled task? (y/n)" → Type `y`
2. "Test run the task now? (y/n)" → Type `y` to verify it works

**That's it!**

---

## WHAT IT CHECKS

### Registry:
- Telemetry setting (should be 0)
- DiagTrack status (should be 0)

### Services (should all be Disabled):
- DiagTrack (main telemetry)
- dmwappushservice
- CDPSvc
- OneSyncSvc
- WerSvc (error reporting)
- WpnService
- XblAuthManager
- XblGameSave
- lfsvc (location)
- MapsBroker
- DPS
- WdiServiceHost
- WdiSystemHost
- TroubleshootingSvc

### Windows Update:
- Checks if running
- Stops and disables if found

---

## SCHEDULE

**When it runs:**
- Every Sunday at 2:00 AM
- Runs even if computer is sleeping (will run when wakes)
- Runs on battery power

**Why Sunday 2 AM:**
- Low usage time
- After weekend (if you manually ran updates)
- Before work week starts

---

## LOGS

**Location:** `%TEMP%\SpywareCheck_YYYYMMDD_HHMMSS.log`

**Example:** `C:\Users\YourUsername\AppData\Local\Temp\SpywareCheck_20260212_140000.log`

**What's logged:**
- Date/time of check
- Telemetry status
- Each service status
- Any fixes applied
- Final result (all secure or fixed X issues)

**To view latest log:**
```powershell
Get-ChildItem $env:TEMP -Filter "SpywareCheck_*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content
```

---

## TASK DETAILS

**Task Name:** `SpywareCheck-Weekly`

**Runs as:** SYSTEM (highest privileges)

**Settings:**
- Runs whether user is logged on or not
- Runs with highest privileges
- Hidden window (silent)
- Allowed on battery
- Won't stop if going on battery

---

## VERIFY TASK IS WORKING

### Check task exists:
```powershell
Get-ScheduledTask -TaskName "SpywareCheck-Weekly"
```

### Check last run:
```powershell
Get-ScheduledTaskInfo -TaskName "SpywareCheck-Weekly"
```

### Run task manually:
```powershell
Start-ScheduledTask -TaskName "SpywareCheck-Weekly"
```

### Check task in GUI:
1. Press `Win + R`
2. Type: `taskschd.msc`
3. Navigate to: Task Scheduler Library
4. Find: SpywareCheck-Weekly
5. Right-click → Properties

---

## WHAT HAPPENS IF SERVICES ARE RE-ENABLED

**The script automatically:**
1. Detects which services are running or enabled
2. Stops each running service
3. Sets startup type to Disabled
4. Re-sets telemetry registry to 0
5. Stops Windows Update if running
6. Logs everything
7. Exit code 1 (indicating action was taken)

**You'll know from the log:**
```
✗ Connected User Experiences and Telemetry: Running / Automatic
  Fixed: Stopped and disabled

RESULT: Fixed 1 re-enabled services
```

---

## REMOVE THE TASK

**If you want to stop automatic checking:**

```powershell
Unregister-ScheduledTask -TaskName "SpywareCheck-Weekly" -Confirm:$false
```

**Or via GUI:**
1. Open Task Scheduler (taskschd.msc)
2. Find: SpywareCheck-Weekly
3. Right-click → Delete

---

## CHANGE SCHEDULE

**To run daily instead of weekly:**

```powershell
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
Set-ScheduledTask -TaskName "SpywareCheck-Weekly" -Trigger $trigger
```

**To change time:**

```powershell
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 10pm
Set-ScheduledTask -TaskName "SpywareCheck-Weekly" -Trigger $trigger
```

---

## MANUAL RUN

**Don't want to wait? Run it now:**

```powershell
cd C:\Path\To\SystemsWorks\Scripts
.\AUTOMATED_SPYWARE_CHECK.ps1
```

**Or:**
```powershell
Start-ScheduledTask -TaskName "SpywareCheck-Weekly"
```

---

## EXIT CODES

**0:** All secure, no action needed  
**1:** Found and fixed re-enabled services

---

## TROUBLESHOOTING

### Task not running?

**Check task status:**
```powershell
Get-ScheduledTask -TaskName "SpywareCheck-Weekly" | Select-Object State, LastRunTime
```

**If State = Disabled:**
```powershell
Enable-ScheduledTask -TaskName "SpywareCheck-Weekly"
```

### Task runs but doesn't fix anything?

**Check it's running as SYSTEM:**
```powershell
(Get-ScheduledTask -TaskName "SpywareCheck-Weekly").Principal.UserId
```

Should say: `SYSTEM`

### Can't find logs?

**List all logs:**
```powershell
Get-ChildItem $env:TEMP -Filter "SpywareCheck_*.log" | Sort-Object LastWriteTime -Descending
```

---

## SECURITY NOTES

**Why run as SYSTEM:**
- Required to modify registry (HKLM)
- Required to stop/disable services
- Required to modify Windows Update

**Is it safe:**
- Script only disables spyware services
- Doesn't delete anything
- Doesn't modify system files
- Only touches known spyware components
- Creates logs of all actions

---

## RECOMMENDED

**After creating the task:**
1. Test run immediately (to verify it works)
2. Check the log (to see what it does)
3. Let it run automatically going forward
4. Review logs monthly

**If you manually run Windows Update:**
- Run the task immediately after
- Check if any services were re-enabled

---

## SUMMARY

**Create once, runs forever:**
```powershell
.\CREATE_SPYWARE_TASK.ps1
```

**Task automatically:**
- Checks weekly
- Fixes re-enabled spyware
- Logs everything
- Runs silently

**Your privacy stays protected!** ✅
