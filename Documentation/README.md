# SLEEP/WAKE REPAIR PACKAGE - FILE GUIDE

## START HERE

### Option 1: Run Everything Automatically (RECOMMENDED)
**File:** `RUN_ALL_FIXES.ps1`  
**What it does:** Runs all three repair phases in order with safety prompts  
**Time:** 10 minutes + restart  
**Run:** Right-click PowerShell → Run as Admin → `.\RUN_ALL_FIXES.ps1`

### Option 2: Read First, Then Decide  
**File:** `QUICKSTART_UPDATED.md`  
**What it does:** Quick explanation + step-by-step manual instructions  
**Best for:** Want to understand what's happening before running scripts

---

## DOCUMENTATION FILES

### HARDWARE_ISSUES.md ⚠️ IMPORTANT - READ THIS
**Why your sleep is broken:**
- Win11 → Win10 downgrade broke Killer WiFi + Ethernet
- Forced you into USB dongles + hub
- 119 Unknown USB devices accumulated  
- These broken devices prevent stable sleep

**Long-term solutions:**
- Replace WiFi card with Intel AX200 (~$25)
- BIOS settings to check
- USB hub optimization

### FINDINGS.md
**Original diagnostic report:**
- All 119 Unknown USB devices listed
- Power plan analysis
- Event log showing rapid sleep/wake cycles
- Why hybrid sleep is the problem

### REPAIR_PLAN.md
**Complete repair guide:**
- All three phases explained in detail
- Advanced troubleshooting if issues persist
- Monitoring commands to verify fixes
- Driver update priorities

---

## SCRIPT FILES (PowerShell - Run as Admin)

### 1. DISABLE_BROKEN_HARDWARE.ps1
**Phase 0 - Run First!**
- Disables Killer WiFi (Error state)
- Disables Realtek 2.5GbE Ethernet (Unknown state)
- Prevents failed hardware from interfering with sleep

### 2. FIX_SLEEP.ps1  
**Phase 1 - Power Configuration**
- Disables hybrid sleep (stops instant wake)
- Disables USB selective suspend
- Reduces PCI Express power management
- Limits wake timers
- Disables USB device wake capability

### 3. USB_CLEANUP.ps1
**Phase 2 - Device Cleanup**
- Removes all 119 "Unknown" USB devices
- Clears ghost devices from registry
- Forces clean re-detection after restart
- **IMPORTANT:** Unplug external USB first (keep WiFi dongles)

### 4. RUN_ALL_FIXES.ps1 ⭐ RECOMMENDED
**Master script - runs 1, 2, 3 in order**
- Safety prompts at each phase
- Automatic restart option
- Complete solution in one run

---

## QUICK REFERENCE

### Simplest Path (Do This):
```powershell
# Open PowerShell as Admin
cd C:\Temp\Sleep_Diagnostics
.\RUN_ALL_FIXES.ps1
# Follow prompts → Restart when done
```

### Manual Path (If You Prefer):
```powershell
# Phase 0
.\DISABLE_BROKEN_HARDWARE.ps1

# Phase 1  
.\FIX_SLEEP.ps1

# Phase 2 (unplug external USB first!)
.\USB_CLEANUP.ps1

# Restart
Restart-Computer
```

---

## WHAT'S WRONG & WHY

### Root Cause:
Your Dell gaming laptop shipped with Windows 11. Downgrading to Win10 broke:
- Qualcomm Killer WiFi 6E (no Win10 drivers) → **ERROR state**
- Realtek 2.5GbE Ethernet (no proper Win10 support) → **UNKNOWN state**

### Cascade Effect:
1. No working network → USB WiFi dongles needed
2. Multiple dongles → USB hub needed
3. Hub + dongles → 119 "Unknown" USB devices over time
4. Unknown devices → power management chaos
5. Power chaos + broken hardware → **sleep/wake failure**

### Our Fix:
1. Disable broken hardware (stops interference)
2. Fix power plan (hybrid sleep OFF, USB optimization)
3. Remove Unknown devices (clean slate)
4. Result: Stable sleep/wake

---

## AFTER FIXES - TEST CHECKLIST

✅ Close lid → wait 10 sec → open lid (should wake cleanly)  
✅ Press power button → wait 10 sec → press again (should wake)  
✅ Leave idle 5 min → move mouse (should wake)  
✅ NETGEAR A6100 still connected after wake
✅ Device Manager shows minimal/zero "Unknown" devices

---

## IF STILL HAVING ISSUES

### Check BIOS Settings:
- Restart → F2 repeatedly during boot
- Disable: USB Wake Support, Wake on LAN
- Try toggle: Legacy USB Support

### Verify Power Settings:
```powershell
powercfg /query SCHEME_CURRENT
# Check: Hybrid Sleep = 0, USB Suspend = 0
```

### Monitor Sleep Events:
```powershell
powercfg /sleepstudy /output sleepstudy.html
powercfg /lastwake
powercfg /devicequery wake_armed
```

### Long-Term Solution:
Replace Killer WiFi card with Intel AX200 (~$25):
- Full Win10 support
- Eliminates USB dongle dependency
- Native power management
- See HARDWARE_ISSUES.md for details

---

## SUPPORT

**Issues persist?** Provide:
1. Screenshot of Device Manager (remaining Unknown devices)
2. Output of `powercfg /lastwake`
3. Sleepstudy.html results
4. Event Viewer errors (IDs: 42, 131, 506, 507)

---

## FILES SUMMARY

| File | Type | Purpose |
|------|------|---------|
| **README.md** | Guide | This file - navigation & overview |
| **QUICKSTART_UPDATED.md** | Guide | Fast manual instructions |
| **HARDWARE_ISSUES.md** | Analysis | Why problem exists, long-term fixes |
| **FINDINGS.md** | Report | Original diagnostic data |
| **REPAIR_PLAN.md** | Guide | Detailed repair documentation |
| **RUN_ALL_FIXES.ps1** | Script | ⭐ Master repair script (RECOMMENDED) |
| **CHECK_WIFI_ADAPTERS.ps1** | Script | Verify both WiFi dongles working |
| **DISABLE_BROKEN_HARDWARE.ps1** | Script | Phase 0 - Disable failed devices |
| **FIX_SLEEP.ps1** | Script | Phase 1 - Power configuration |
| **USB_CLEANUP.ps1** | Script | Phase 2 - Remove Unknown devices |
| **CLEAR_EVENT_LOGS.ps1** | Script | Clear all logs for clean tracking |
| **DUAL_WIFI_SETUP.md** | Guide | Dual WiFi adapter configuration |

---

**Good luck! Your Dell laptop should sleep properly after these fixes.**

*Created: 2026-02-07*  
*Target: Dell gaming laptop (Win11→Win10 downgrade)*

