# BRUTE FORCE GHOST DEVICE REMOVAL - SYSTEM LEVEL
# This script runs removal commands as NT AUTHORITY\SYSTEM

$devices = @(
    'HID\VID_260D&PID_1027&MI_03\8&3817A7B3&0&0000',
    'USB\VID_046D&PID_C52B&MI_02\7&13960C0D&0&0002',
    'HID\VID_256C&PID_006E&MI_01\9&E7D30F8&0&0000'
)

Write-Host "Removing devices as SYSTEM..." -ForegroundColor Yellow

foreach ($deviceId in $devices) {
    try {
        pnputil /remove-device "$deviceId" /force 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Removed: $deviceId" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed: $deviceId" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Error: $deviceId" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Remaining Unknown devices:" -ForegroundColor Cyan
(Get-PnpDevice | Where-Object {$_.Status -eq 'Unknown' -or $_.Status -eq 'Error'}).Count
