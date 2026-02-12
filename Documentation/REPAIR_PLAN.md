# Dell gaming laptop - SLEEP/WAKE REPAIR PLAN

## ROOT CAUSES IDENTIFIED

1. **Hybrid Sleep Enabled** - Causes immediate wake after sleep attempt
2. **119 Unknown USB Devices** - Windows can't manage power for unrecognized devices  
3. **Aggressive Power Management** - USB and PCI-E settings conflict with hardware
4. **Wake Timer Chaos** - Apps/services waking system unexpectedly

## REPAIR SEQUENCE (Do in order)

### PHASE 1: Fix Power Configuration (5 minutes)
**Location:** `C:\Temp\Sleep_Diagnostics\FIX_SLEEP.ps1`

**What it does:**
- Disables hybrid sleep (stops rapid enter/exit cycles)
- Disables USB selective suspend (prevents USB device conflicts)
- Reduces PCI Express power management (stops PCIe wake events)
- Limits wake timers to important only
- Disables USB device wake capability

**How to run:**
1. Right-click PowerShell → Run as Administrator
2. Navigate: `cd C:\Temp\Sleep_Diagnostics`
3. Run: `.\FIX_SLEEP.ps1`
4. Press any key when complete

**Expected result:** Power settings optimized for reliable sleep

---

### PHASE 2: Clean USB Device Registry (10 minutes)
**Location:** `C:\Temp\Sleep_Diagnostics\USB_CLEANUP.ps1`

**CRITICAL:** Disconnect ALL external USB devices first!
- Unplug mice, keyboards (except built-in), USB drives, hubs, phones
- Leave only: Internal keyboard, trackpad, built-in camera

**What it does:**
- Removes 119 "Unknown" USB device entries
- Clears ghost devices preventing proper power management
- Forces Windows to re-detect devices cleanly on next boot

**How to run:**
1. **Disconnect ALL external USB devices!**
2. Right-click PowerShell → Run as Administrator  
3. Navigate: `cd C:\Temp\Sleep_Diagnostics`
4. Run: `.\USB_CLEANUP.ps1`
5. Type: `YES` to confirm
6. Wait for completion

**Expected result:** All Unknown USB devices removed

---

### PHASE 3: Restart and Test (15 minutes)

1. **Restart the laptop**
2. **After restart, reconnect USB devices ONE AT A TIME:**
   - Connect device
   - Wait 30 seconds for driver installation
   - Check Device Manager: `devmgmt.msc`
   - Verify device shows "OK" status (not Unknown/Error)
   - If device shows Unknown → remove it, find proper driver
3. **Test sleep/wake:**
   - Close lid → wait 10 seconds → open lid (should wake)
   - Press power button briefly → wait 10 seconds → press again (should wake)
   - Leave idle for configured time → move mouse (should wake)

**Success criteria:** Laptop sleeps reliably and wakes responsive

---

## ADDITIONAL FIXES IF STILL HAVING ISSUES

### Check for BIOS Updates
Dell gaming laptop may have BIOS updates addressing sleep/wake:
1. Visit Dell Support (support.dell.com)
2. Enter service tag (check bottom of laptop)
3. Download/install latest BIOS
4. Update BIOS following Dell instructions

### Install Dell laptop Command Center (AWCC)
Missing thermal/performance management tools:
1. Visit Dell.com/support/drivers
2. Search: "Dell laptop Command Center"
3. Download latest version
4. Install → restart
5. Configure performance profiles properly

### Driver Updates Priority Order
1. **Chipset drivers** (AMD or Intel - check Device Manager)
2. **Graphics drivers** (AMD - already have AMD FUEL Service)
3. **Realtek Audio/WiFi drivers** (version check)
4. **USB 3.0 controller drivers**
5. **Touchpad drivers** (if Synaptics/Alps/Elan)

### Problematic Devices Detected
Based on scan, these may need attention:
- **Logitech devices** (VID_046D): Multiple in Unknown state
- **Samsung mobile** (VID_04E8:PID_6860): ADB interface conflicts
- **Wacom pen tablet** (VID_256C:PID_006E): Driver may be outdated
- **Generic USB hubs** (VID_05E3): May need updated drivers
- **Realtek card reader** (VID_0BDA): Often causes wake issues

### Windows Settings to Verify
After fixes applied, check these:

**Power Options:**
- Control Panel → Power Options → Change plan settings
- Verify sleep timers match your preferences
- Check "Choose what closing the lid does"

**Device Manager Review:**
1. Press Win+X → Device Manager
2. View → Show hidden devices
3. Expand: USB controllers, Human Interface Devices
4. Remove any with yellow warning icons
5. Right-click working USB Root Hubs → Power Management
6. **Uncheck** "Allow this device to wake the computer"

**Fast Startup (may cause issues):**
- Control Panel → Power Options → Choose what power buttons do
- Click "Change settings that are currently unavailable"
- Consider **unchecking** "Turn on fast startup" if problems persist

---

## MONITORING AND VERIFICATION

### After Fixes Applied, Run These Checks:

**1. Sleep Study Report (requires admin):**
```powershell
powercfg /sleepstudy /output C:\Temp\Sleep_Diagnostics\sleepstudy.html
```
Open in browser to see sleep session analysis

**2. What Woke The System:**
```powershell
powercfg /lastwake
```

**3. Devices That Can Wake System:**
```powershell
powercfg /devicequery wake_armed
```
Review output - you may want to disable wake for some devices

**4. Active Wake Requests:**
```powershell  
powercfg /requests
```
Shows apps preventing sleep

**5. Event Viewer - Sleep Events:**
- Win+R → eventvwr.msc
- Windows Logs → System
- Filter Current Log → Event IDs: 1, 42, 506, 507
- Look for patterns in sleep/wake times

---

## EXPECTED OUTCOMES

### Before Fixes:
- ❌ Sleep entered → immediately exits (< 1 second)
- ❌ Laptop appears asleep but keyboard lit, unresponsive
- ❌ Wake requires hard power cycle
- ❌ 119 Unknown USB devices in Device Manager

### After Fixes:
- ✅ Sleep entered → stays asleep until user action
- ✅ Clean wake with keyboard/mouse/lid
- ✅ Display turns on, system responsive
- ✅ Minimal or zero Unknown devices

---

## IF PROBLEMS PERSIST

Contact me with:
1. Screenshot of Device Manager showing remaining Unknown devices
2. Output of: `powercfg /lastwake`
3. Output of: `powercfg /requests`  
4. C:\Temp\Sleep_Diagnostics\sleepstudy.html results
5. Any error messages from Event Viewer (Event IDs 42, 131)

---

## SUMMARY OF FILES CREATED

- **FINDINGS.md** - Diagnostic report with all issues found
- **REPAIR_PLAN.md** - This document (complete repair guide)
- **FIX_SLEEP.ps1** - Phase 1 script (power configuration)
- **USB_CLEANUP.ps1** - Phase 2 script (remove Unknown devices)

All scripts are safe and reversible. They modify Windows power settings and remove only Unknown/Error devices.

---

**Good luck! Your Dell laptop should sleep properly after these fixes.**

