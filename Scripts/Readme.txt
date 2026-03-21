SystemTools Synopsis

Three logical groups:
1. Hardware/Sleep Fixes (laptop-specific, post Win11→Win10 downgrade)

RUN_ALL_FIXES.ps1 — Master orchestrator: WiFi check → disable broken HW → fix sleep → USB cleanup
CHECK_WIFI_ADAPTERS.ps1 — Validates NETGEAR A6100 + TP-Link Nano USB dongles
DISABLE_BROKEN_HARDWARE.ps1 — Disables Killer WiFi + Realtek 2.5GbE (dead from downgrade)
FIX_SLEEP.ps1 — Power plan fixes: hybrid sleep off, USB suspend off, PCIe ASPM, wake timers
USB_CLEANUP.ps1 — Removes ghost/unknown USB devices, protects WiFi dongles
REMOVE_AS_SYSTEM.ps1 — Brute-force removes 3 specific ghost HID/USB devices via pnputil

2. Privacy/Debloat Pipeline (6-phase sequential)

DEBLOAT_1_INVENTORY.ps1 — Scans & exports AppX packages + telemetry services to CSV
DEBLOAT_2_REMOVE_APPS.ps1 — Removes all AppX except Store, Calculator, Photos, ScreenSketch, Paint
DEBLOAT_3_DISABLE_TELEMETRY.bat — 15 registry tweaks (telemetry, Cortana, ads, Bing, OneDrive, etc.)
DEBLOAT_4_DISABLE_SERVICES.ps1 — Disables 25 services (DiagTrack, Xbox, sensors, maps, etc.)
DEBLOAT_5_BLOCK_DOMAINS.ps1 — Blocks ~60 MS telemetry domains via hosts file
DEBLOAT_6_DISABLE_UPDATES.ps1 — 5-method WU kill (services, GPO, delivery opt, metered, tasks)
PRIVACY_LOCKDOWN_MASTER.ps1 — Orchestrates phases 3-6, creates restore point first
KILL_SPYWARE.ps1 — All-in-one: services + registry + tasks + hosts + DNS flush + process kill + WU disable
AUTOMATED_SPYWARE_CHECK.ps1 — Silent re-check/re-kill for scheduled task use
CREATE_SPYWARE_TASK.ps1 — Creates weekly Sunday 2AM scheduled task for the above

3. System Utilities

CLEAR_EVENT_LOGS.ps1 — Wipes all event logs (clean baseline for testing)
CREATE_SHORTCUTS.ps1 — Desktop shortcuts for NSudo (TrustedInstaller) + PsExec (SYSTEM)
DISABLE_UAC.bat / FORCE_DISABLE_UAC.bat — UAC disable (simple + brute force all 8 reg values)


Observations before running:

DEBLOAT_1_INVENTORY.ps1 exports CSVs to .\ (relative path) — will dump wherever PS working dir is, not necessarily into the Scripts folder
DEBLOAT_5_BLOCK_DOMAINS.ps1 includes www.bing.com — this will break Bing entirely (maybe intentional?)
KILL_SPYWARE.ps1 overlaps heavily with PRIVACY_LOCKDOWN_MASTER.ps1 — running both is redundant but harmless (idempotent)
USB_CLEANUP.ps1 is truncated — the file cuts off after the $problemDevices query, missing the actual removal logic
CREATE_SHORTCUTS.ps1 hardcodes paths (C:\Tools\NSudo\..., C:\Temp\PsExec64.exe) — will need those present

Which scripts do you want to run/test first? The privacy pipeline and the hardware fixes are separate tracks. I'd suggest:

Safe to dry-run now: DEBLOAT_1_INVENTORY (read-only scan), CHECK_WIFI_ADAPTERS (read-only), AUTOMATED_SPYWARE_CHECK (reports + auto-fixes)
Needs review first: USB_CLEANUP.ps1 appears truncated/incomplete