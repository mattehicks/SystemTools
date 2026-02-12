# UPDATED QUICK START - Hardware Incompatibility Edition

## CRITICAL INFO: Your Dell gaming laptop was Win11, now Win10
- Built-in Killer WiFi: **BROKEN** (no Win10 drivers)
- Built-in Ethernet: **BROKEN** (no proper Win10 support)
- This is why you need USB dongles
- **These broken devices are causing your sleep/wake issues!**

---

## NEW STEP 0: Disable Broken Hardware (Do First!)

### Disable Failed Network Adapters:
```
1. Win+X → Device Manager
2. View → Show hidden devices
3. Find "Network Controller" (yellow warning icon)
   → Right-click → Disable device → Yes
4. Find "Realtek Gaming 2.5GbE Family Controller"  
   → Right-click → Disable device → Yes
5. Any other network devices showing Error/Unknown
   → Disable them too
```

**Why:** These broken devices send wake signals even when failed, preventing stable sleep.

---

## STEP 0.5: TP-Link Dongle Check

Your TP-Link USB adapter shows "Unknown" status. Fix or remove:

**Is it plugged in?**
- Yes, using it → Download Win10 driver from tp-link.com
- No, not using it → Leave unplugged

---

## STEP 1: Optimize USB Setup

**Move NETGEAR A6100 (Server) to direct USB port:**
- Currently on hub? Move to laptop USB port directly
- This is your working connection - keep it stable

**USB Hub (if using):**
- Device Manager → USB controllers → Your hub
- Properties → Power Management tab
- **Uncheck** "Allow this device to wake computer"

---

## STEP 2: Fix Power Settings (2 min)
```
Right-click PowerShell → Run as Administrator
cd C:\Temp\Sleep_Diagnostics  
.\FIX_SLEEP.ps1
```

---

## STEP 3: Clean USB Devices (5 min)
```
Unplug: mice, keyboards, drives, hubs (KEEP dongles plugged!)
.\USB_CLEANUP.ps1
Type: YES
```

---

## STEP 4: Restart
```
Restart-Computer
```

---

## STEP 5: Test Sleep
```
After restart:
- Close lid → 10 sec → open (should wake)
- Power button → 10 sec → press again (should wake)  
- Idle 5 min → move mouse (should wake)
```

---

## What We're Fixing:

### The Problem Chain:
1. ❌ Win11 → Win10 downgrade broke Killer WiFi + Ethernet
2. ❌ You added USB WiFi dongles as workaround
3. ❌ USB hub added for multiple dongles
4. ❌ 119 "Unknown" USB devices accumulated  
5. ❌ Broken hardware + USB chaos = sleep/wake failure

### Our Solution:
1. ✅ Disable broken built-in network hardware
2. ✅ Optimize USB dongle placement (direct vs hub)
3. ✅ Fix power plan (disable hybrid sleep, USB suspend)
4. ✅ Remove all Unknown USB devices
5. ✅ Disable USB wake capability

---

## If Still Broken After This:

**Check BIOS settings:**
- Restart → F2 repeatedly
- Disable: USB Wake Support, Wake on LAN
- Try toggling: Legacy USB Support

**Long-term fix:**
- Replace Killer WiFi card with Intel AX200 (Win10 compatible)
- Cost: ~$20-30, YouTube install guides available
- Gets rid of USB dongles entirely

---

**Total time:** ~15 minutes + restart

**Read HARDWARE_ISSUES.md for complete explanation of why this happened.**

