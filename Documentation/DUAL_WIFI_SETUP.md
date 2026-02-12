# DUAL WIFI SETUP - UPDATED INFO

## YOUR CURRENT CONFIGURATION

**Network 1 (Server):**
- Adapter: NETGEAR A6100 WiFi Adapter
- Status: ✅ Working (OK)
- Connection: Direct to laptop USB port
- VID/PID: 0846:9052

**Network 2 (Second network):**
- Adapter: TP-Link Wireless Nano USB Adapter  
- Status: ❌ ERROR (Driver issue - Problem Code 28)
- Connection: Direct to laptop USB port
- VID/PID: 2357:011E
- Network Status: "Not Present" (no connection)

**USB Hub:**
- Status: Not currently being used
- Both dongles connected directly to laptop ✓

---

## TP-LINK ADAPTER NEEDS ATTENTION

Your TP-Link adapter shows **ERROR** status with Problem Code 28 = "Drivers not installed"

### To Fix:

**Option 1: Download Driver (RECOMMENDED)**
1. Visit: https://www.tp-link.com/support/download/
2. Search for model with VID/PID 2357:011E
   - Likely model: TL-WN823N or similar nano adapter
3. Download Windows 10 x64 driver
4. Install → Restart
5. Run `CHECK_WIFI_ADAPTERS.ps1` to verify

**Option 2: Windows Update**
```powershell
# Let Windows search for driver
pnputil /scan-devices
# Check Device Manager after a minute
```

**Option 3: Manual Driver Install**
1. Device Manager → TP-Link adapter
2. Right-click → Update driver
3. "Search automatically for drivers"
4. If fails, try "Browse my computer"
5. Point to any TP-Link driver folder you download

---

## UPDATED SCRIPTS - WHAT CHANGED

### NEW: CHECK_WIFI_ADAPTERS.ps1
- Checks both NETGEAR and TP-Link status
- Detects driver issues (Problem Code 28, 22, etc.)
- Provides specific fix instructions for each problem
- Verifies both adapters before proceeding with sleep fixes

**Run this:** `.\CHECK_WIFI_ADAPTERS.ps1`

### UPDATED: RUN_ALL_FIXES.ps1
- Now runs CHECK_WIFI_ADAPTERS.ps1 as Phase 0
- Warns if TP-Link isn't working  
- Asks if you want to continue anyway
- Safe to run even with TP-Link in error state

### UPDATED: USB_CLEANUP.ps1
- Now protects BOTH dongles by hardware ID (VID/PID)
- More reliable than name matching
- Will NOT remove either:
  - NETGEAR A6100 (VID_0846&PID_9052)
  - TP-Link (VID_2357&PID_011E)

---

## SHOULD YOU FIX TP-LINK FIRST?

**Two approaches:**

### Approach A: Fix TP-Link, then sleep (RECOMMENDED)
1. Download/install TP-Link Win10 driver
2. Restart
3. Run `CHECK_WIFI_ADAPTERS.ps1` to verify both working
4. Run `RUN_ALL_FIXES.ps1` for sleep fixes
5. Both networks + stable sleep ✓

**Time:** +30 minutes for driver hunt/install

### Approach B: Fix sleep now, TP-Link later
1. Run `RUN_ALL_FIXES.ps1` (will warn about TP-Link)
2. Continue anyway
3. Sleep/wake gets fixed
4. Fix TP-Link driver when convenient
5. One network works, sleep stable ✓

**Time:** Sleep fixed in 10 minutes, TP-Link whenever

---

## IMPORTANT: DIRECT CONNECTION IS BETTER

You moved both dongles from hub to direct laptop USB ports - **this is excellent!**

**Benefits:**
- More stable power delivery
- Fewer wake conflicts
- Better signal reliability
- Eliminates hub as potential problem source

**Keep it this way** even after fixes are applied.

---

## TESTING AFTER FIXES

With dual WiFi setup, test both:

**Test 1: Sleep/Wake with both connected**
- Close lid → 10 sec → open (should wake clean)
- Check: `Get-NetAdapter` - both still connected?
- Server network should stay active
- Second network maintains connection (if driver working)

**Test 2: Individual adapter stability**
- Disconnect TP-Link → test sleep → reconnect
- Both should survive sleep/wake cycles
- No "Unknown" device errors after wake

---

## QUICK ACTION GUIDE

**Right now, you can:**

**Option 1 - Fix everything at once:**
```powershell
cd C:\Temp\Sleep_Diagnostics
.\RUN_ALL_FIXES.ps1
# Will check WiFi, warn about TP-Link, ask to continue
# Choose Y to fix sleep anyway, worry about TP-Link later
```

**Option 2 - Check WiFi first:**
```powershell
.\CHECK_WIFI_ADAPTERS.ps1
# See detailed status of both adapters
# Get specific instructions for fixing TP-Link
```

**Option 3 - Just the essentials:**
```powershell
# Fix sleep only (TP-Link can wait)
.\DISABLE_BROKEN_HARDWARE.ps1
.\FIX_SLEEP.ps1
# Skip USB cleanup for now if concerned about dongles
```

---

## SCRIPTS PROTECTION SUMMARY

All scripts now recognize and protect both dongles:
- ✅ NETGEAR A6100 identified by VID_0846&PID_9052
- ✅ TP-Link identified by VID_2357&PID_011E
- ❌ Will NOT remove or disable these during cleanup
- ❌ Will NOT modify their power settings

Safe to run even with dongles connected!

---

**Bottom line:** Scripts updated for dual WiFi. TP-Link needs driver, but sleep fixes work regardless. Your choice whether to fix TP-Link first or later.
