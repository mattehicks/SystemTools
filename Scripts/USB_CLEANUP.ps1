# ============================================================================
# USB Device Cleanup Script - UPDATED FOR DUAL WIFI SETUP
# IMPORTANT: Keep BOTH WiFi dongles plugged in during cleanup!
# This will remove ghost/unknown USB devices while protecting your network
# ============================================================================

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "USB Device Cleanup - Dual WiFi Setup" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    pause
    exit
}

Write-Host "DUAL WIFI SETUP DETECTED" -ForegroundColor Cyan
Write-Host "This script will protect your WiFi dongles:" -ForegroundColor Green
Write-Host "- NETGEAR A6100 (Server network)" -ForegroundColor White
Write-Host "- TP-Link Wireless Nano USB Adapter (wifi network)" -ForegroundColor White
Write-Host ""
Write-Host "WARNING: This will remove Unknown/Error USB devices" -ForegroundColor Yellow
Write-Host "Make sure other external USB devices are disconnected!" -ForegroundColor Red
Write-Host "(mice, keyboards, drives, hubs - except WiFi dongles)" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Type YES to continue"
if ($confirm -ne "YES") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Scanning for problematic USB devices..." -ForegroundColor Yellow

# Get WiFi dongles to protect them (by VID/PID - more reliable)
$netgear = Get-PnpDevice | Where-Object {$_.InstanceId -match 'VID_0846&PID_9052'}
$tplink = Get-PnpDevice | Where-Object {$_.InstanceId -match 'VID_2357&PID_011E'}

Write-Host "Protected devices (will NOT remove):" -ForegroundColor Green
if ($netgear) { Write-Host "  ✓ $($netgear.FriendlyName)" -ForegroundColor Gray }
if ($tplink) { Write-Host "  ✓ $($tplink.FriendlyName)" -ForegroundColor Gray }
Write-Host ""

# Find problem devices EXCLUDING the WiFi dongles
$problemDevices = Get-PnpDevice | Where-Object {
    ($_.Class -match 'USB|HIDClass|USBDevice') -and 
    ($_.Status -eq 'Unknown' -or $_.Status -eq 'Error') -and
    ($_.InstanceId -ne $netgear.InstanceId) -and
    ($_.InstanceId -ne $tplink.InstanceId)
}
