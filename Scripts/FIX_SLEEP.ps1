# ============================================================================
# Alienware P51E Sleep/Wake Fix Script
# Run this in PowerShell (Admin)
# ============================================================================

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Alienware P51E Sleep/Wake Repair" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "[1/6] Disabling Hybrid Sleep..." -ForegroundColor Yellow
powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP HYBRIDSLEEP 0
powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP HYBRIDSLEEP 0
Write-Host "      Done." -ForegroundColor Green

Write-Host "[2/6] Disabling USB Selective Suspend..." -ForegroundColor Yellow  
powercfg /setacvalueindex SCHEME_CURRENT SUB_USB USBSELECTIVESUSPEND 0
powercfg /setdcvalueindex SCHEME_CURRENT SUB_USB USBSELECTIVESUSPEND 0
Write-Host "      Done." -ForegroundColor Green

Write-Host "[3/6] Reducing PCI Express Power Management..." -ForegroundColor Yellow
powercfg /setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 1
Write-Host "      Done." -ForegroundColor Green

Write-Host "[4/6] Disabling wake timers (keep important ones)..." -ForegroundColor Yellow
powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP RTCWAKE 2
powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP RTCWAKE 0  
Write-Host "      Done." -ForegroundColor Green

Write-Host "[5/6] Applying changes..." -ForegroundColor Yellow
powercfg /setactive SCHEME_CURRENT
Write-Host "      Done." -ForegroundColor Green

Write-Host "[6/6] Disabling USB device wake capability..." -ForegroundColor Yellow
$usbDevices = Get-PnpDevice | Where-Object {$_.Class -eq 'USB' -and $_.Status -eq 'OK'}
foreach ($device in $usbDevices) {
    try {
        $power = Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName '{A45C254E-DF1C-4EFD-8020-67D146A850E0} 3' -ErrorAction SilentlyContinue
        if ($power.Data -eq 1) {
            Write-Host "      Disabling wake for: $($device.FriendlyName)" -ForegroundColor Gray
            Set-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName '{A45C254E-DF1C-4EFD-8020-67D146A850E0} 3' -Value 0 -ErrorAction SilentlyContinue
        }
    } catch {
        # Skip devices that don't support wake
    }
}
Write-Host "      Done." -ForegroundColor Green

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Phase 1 Complete - Power Settings Fixed" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Review C:\Temp\Sleep_Diagnostics\USB_CLEANUP.ps1" -ForegroundColor White
Write-Host "2. Disconnect ALL external USB devices" -ForegroundColor White  
Write-Host "3. Run USB_CLEANUP.ps1 to fix driver issues" -ForegroundColor White
Write-Host "4. Restart the laptop" -ForegroundColor White
Write-Host "5. Test sleep/wake functionality" -ForegroundColor White
Write-Host ""
pause
