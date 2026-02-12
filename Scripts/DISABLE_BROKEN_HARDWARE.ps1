# ============================================================================
# Disable Broken Network Hardware (Win11 → Win10 downgrade casualties)
# Run this BEFORE the sleep fix scripts
# ============================================================================

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Disable Broken Network Hardware" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    pause
    exit
}

Write-Host "Scanning for broken network devices..." -ForegroundColor Yellow
Write-Host ""

# Find the broken devices
$killerWifi = Get-PnpDevice | Where-Object {$_.InstanceId -match 'PCI\\VEN_17CB' -and $_.Status -eq 'Error'}
$realtekEth = Get-PnpDevice | Where-Object {$_.InstanceId -match 'PCI\\VEN_10EC&DEV_8125' -and $_.Status -eq 'Unknown'}

$disabled = 0

if ($killerWifi) {
    Write-Host "[1/2] Found: Killer WiFi (Error state)" -ForegroundColor Red
    Write-Host "      Disabling: $($killerWifi.FriendlyName)" -ForegroundColor Yellow
    try {
        Disable-PnpDevice -InstanceId $killerWifi.InstanceId -Confirm:$false
        Write-Host "      ✓ Disabled" -ForegroundColor Green
        $disabled++
    } catch {
        Write-Host "      ✗ Failed to disable" -ForegroundColor Red
    }
} else {
    Write-Host "[1/2] Killer WiFi not found (may already be disabled)" -ForegroundColor Gray
}

Write-Host ""

if ($realtekEth) {
    Write-Host "[2/2] Found: Realtek 2.5GbE Ethernet (Unknown state)" -ForegroundColor Red
    Write-Host "      Disabling: $($realtekEth.FriendlyName)" -ForegroundColor Yellow
    try {
        Disable-PnpDevice -InstanceId $realtekEth.InstanceId -Confirm:$false
        Write-Host "      ✓ Disabled" -ForegroundColor Green
        $disabled++
    } catch {
        Write-Host "      ✗ Failed to disable" -ForegroundColor Red
    }
} else {
    Write-Host "[2/2] Realtek Ethernet not found (may already be disabled)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Disabled $disabled broken device(s)" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "WHY THIS HELPS:" -ForegroundColor Yellow
Write-Host "- These devices were sending wake signals while in Error state" -ForegroundColor White
Write-Host "- Windows was constantly trying to initialize them during sleep" -ForegroundColor White
Write-Host "- Disabling them prevents interference with sleep/wake" -ForegroundColor White
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Run: .\FIX_SLEEP.ps1" -ForegroundColor White
Write-Host "2. Run: .\USB_CLEANUP.ps1 (after unplugging external USB)" -ForegroundColor White
Write-Host "3. Restart laptop" -ForegroundColor White
Write-Host ""
pause
