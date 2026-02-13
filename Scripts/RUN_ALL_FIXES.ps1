# ============================================================================
# MASTER REPAIR SCRIPT - System Sleep/Wake Fix
# Runs all repairs in correct order with safety checks
# ============================================================================

$ErrorActionPreference = "Stop"

Write-Host "â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—" -ForegroundColor Cyan
Write-Host "â•‘   System - COMPLETE SLEEP/WAKE REPAIR SUITE      â•‘" -ForegroundColor Cyan
Write-Host "â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host ""

# Admin check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell â†’ Run as Administrator" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "WHAT THIS WILL DO:" -ForegroundColor Yellow
Write-Host "0. Check WiFi adapters (NETGEAR + TP-Link)" -ForegroundColor White
Write-Host "1. Disable broken Killer WiFi + Realtek Ethernet (Win11â†’Win10 casualties)" -ForegroundColor White
Write-Host "2. Fix power plan settings (disable hybrid sleep, USB suspend, etc.)" -ForegroundColor White
Write-Host "3. Remove 119 'Unknown' USB devices (protecting your WiFi dongles)" -ForegroundColor White
Write-Host "4. Disable USB wake capability" -ForegroundColor White
Write-Host ""
Write-Host "ESTIMATED TIME: 10 minutes" -ForegroundColor Cyan
Write-Host ""

$continue = Read-Host "Ready to begin? (Y/N)"
if ($continue -ne "Y" -and $continue -ne "y") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host "PHASE 0: Check WiFi Adapters" -ForegroundColor Cyan
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host ""

& "$PSScriptRoot\CHECK_WIFI_ADAPTERS.ps1"

# Check if both adapters are working before continuing
$netgear = Get-PnpDevice | Where-Object {$_.InstanceId -match 'VID_0846&PID_9052'}
$tplink = Get-PnpDevice | Where-Object {$_.InstanceId -match 'VID_2357&PID_011E'}

if ($tplink.Status -ne 'OK') {
    Write-Host ""
    Write-Host "âš  WARNING: TP-Link adapter not fully working" -ForegroundColor Yellow
    Write-Host "You can continue, but you may need to fix the driver later." -ForegroundColor White
    Write-Host ""
    $continueAnyway = Read-Host "Continue anyway? (Y/N)"
    if ($continueAnyway -ne "Y" -and $continueAnyway -ne "y") {
        Write-Host "Cancelled. Fix WiFi adapter first, then re-run this script." -ForegroundColor Yellow
        exit
    }
}

Write-Host ""
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host "PHASE 1: Disable Broken Hardware" -ForegroundColor Cyan
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host ""

& "$PSScriptRoot\DISABLE_BROKEN_HARDWARE.ps1"

Write-Host ""
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host "PHASE 2: Fix Power Configuration" -ForegroundColor Cyan  
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host ""

& "$PSScriptRoot\FIX_SLEEP.ps1"

Write-Host ""
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host "PHASE 3: USB Device Cleanup" -ForegroundColor Cyan
Write-Host "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: About to clean USB devices" -ForegroundColor Yellow
Write-Host "You should unplug ALL external USB except your WiFi dongles:" -ForegroundColor Red
Write-Host "- External mice" -ForegroundColor White
Write-Host "- External keyboards" -ForegroundColor White  
Write-Host "- USB drives" -ForegroundColor White
Write-Host "- USB hubs (if not using for dongles)" -ForegroundColor White
Write-Host ""
Write-Host "KEEP PLUGGED IN:" -ForegroundColor Green
Write-Host "- NETGEAR A6100 (Server connection)" -ForegroundColor White
Write-Host "- Any other WiFi dongles you're actively using" -ForegroundColor White
Write-Host ""

$usbReady = Read-Host "Have you unplugged external USB devices? (Y/N)"
if ($usbReady -ne "Y" -and $usbReady -ne "y") {
    Write-Host ""
    Write-Host "Please unplug external USB devices, then run this script again." -ForegroundColor Yellow
    Write-Host "Or run manually: .\USB_CLEANUP.ps1" -ForegroundColor Gray
    pause
    exit
}

& "$PSScriptRoot\USB_CLEANUP.ps1"

Write-Host ""
Write-Host "â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—" -ForegroundColor Green
Write-Host "â•‘              ALL REPAIRS COMPLETED!                        â•‘" -ForegroundColor Green
Write-Host "â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEP: Restart your laptop" -ForegroundColor Yellow
Write-Host ""
Write-Host "After restart:" -ForegroundColor Cyan
Write-Host "- Test sleep by closing lid" -ForegroundColor White
Write-Host "- Test wake by opening lid" -ForegroundColor White
Write-Host "- Should be stable and responsive" -ForegroundColor White
Write-Host ""
Write-Host "If still having issues, check:" -ForegroundColor Yellow
Write-Host "- HARDWARE_ISSUES.md (long-term solutions)" -ForegroundColor White
Write-Host "- REPAIR_PLAN.md (advanced troubleshooting)" -ForegroundColor White
Write-Host ""

$restart = Read-Host "Restart now? (Y/N)"
if ($restart -eq "Y" -or $restart -eq "y") {
    Write-Host "Restarting in 5 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    Restart-Computer
} else {
    Write-Host "Remember to restart before testing!" -ForegroundColor Yellow
    pause
}

