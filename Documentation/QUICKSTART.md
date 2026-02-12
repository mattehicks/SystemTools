# QUICK START - Dell gaming laptop Sleep Fix

## RIGHT NOW - DO THIS:

### Step 1: Fix Power Settings (2 minutes)
```
1. Right-click PowerShell → Run as Administrator
2. cd C:\Temp\Sleep_Diagnostics  
3. .\FIX_SLEEP.ps1
4. Press any key when done
```

### Step 2: Clean USB Devices (5 minutes)
```
1. Unplug ALL external USB devices (mice, keyboards, drives, hubs, phones)
2. In same PowerShell window:
3. .\USB_CLEANUP.ps1
4. Type: YES
5. Wait for completion
```

### Step 3: Restart
```
Restart-Computer
```

### Step 4: Test Sleep
```
After restart:
- Close lid → wait 10 sec → open lid (should wake cleanly)
- Press power button → wait 10 sec → press again (should wake)
- Success? Done! 
- Still broken? Read REPAIR_PLAN.md for advanced fixes
```

---

## What Was Wrong:

1. ❌ Hybrid sleep causing instant wake
2. ❌ 119 Unknown USB devices preventing power management
3. ❌ Aggressive USB/PCIe power saving conflicting with hardware
4. ❌ Wake timers causing unexpected wakes

## What We Fixed:

1. ✅ Disabled hybrid sleep  
2. ✅ Disabled USB selective suspend
3. ✅ Reduced PCI Express power management
4. ✅ Limited wake timers
5. ✅ Removed all Unknown USB devices
6. ✅ Disabled USB wake capability

---

**Total time:** ~10 minutes + restart

