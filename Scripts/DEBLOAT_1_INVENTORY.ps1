# Auto-detect script directory
if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
# PHASE 1: INVENTORY CURRENT BLOAT

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "PHASE 1: BLOATWARE INVENTORY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Scanning installed AppX packages..." -ForegroundColor Yellow
$apps = Get-AppxPackage | Select-Object Name, PackageFullName | Sort-Object Name

Write-Host "Found $($apps.Count) AppX packages" -ForegroundColor Cyan
Write-Host ""

Write-Host "Apps that will be REMOVED:" -ForegroundColor Red
$apps | Where-Object {
    $_.Name -notmatch 'WindowsStore|Calculator|Photos|ScreenSketch|Paint'
} | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[2/3] Scanning telemetry services..." -ForegroundColor Yellow
$telemetryServices = Get-Service | Where-Object {
    $_.Name -match 'diagtrack|dmwappush|CDPUserSvc|OneSyncSvc|MessagingService|XblAuthManager|XblGameSave'
}

Write-Host "Found $($telemetryServices.Count) telemetry services running" -ForegroundColor Red
$telemetryServices | Select-Object Name, DisplayName, Status | Format-Table -AutoSize

Write-Host ""
Write-Host "[3/3] Exporting inventory..." -ForegroundColor Yellow
$apps | Export-Csv ".\bloatware_inventory.csv" -NoTypeInformation
$telemetryServices | Export-Csv ".\telemetry_services.csv" -NoTypeInformation

Write-Host "✓ Inventory saved to HQ" -ForegroundColor Green
Write-Host ""
Write-Host "Review files before proceeding to removal!" -ForegroundColor Yellow


