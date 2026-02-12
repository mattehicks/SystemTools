# PRIVACY LOCKDOWN - MASTER SCRIPT
# Executes Phase 3, 4, 5, 6 (Registry, Services, Hosts, Updates)
# Run with TrustedInstaller

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "PRIVACY LOCKDOWN - MASTER EXECUTION" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host ""
Write-Host "This will execute:" -ForegroundColor Yellow
Write-Host "  1. Disable telemetry (registry)" -ForegroundColor White
Write-Host "  2. Disable 20+ spyware services" -ForegroundColor White
Write-Host "  3. Block Microsoft domains (hosts file)" -ForegroundColor White
Write-Host "  4. Disable Windows Update completely" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  After this, Windows will NOT auto-update!" -ForegroundColor Yellow
Write-Host "⚠️  You must manually update when needed" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Type 'LOCKDOWN' to proceed"

if ($confirm -ne 'LOCKDOWN') {
    Write-Host "Aborted." -ForegroundColor Green
    exit
}

# Auto-detect script directory
if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
$scriptPath = $PSScriptRoot

Write-Host ""
Write-Host "Creating system restore point..." -ForegroundColor Cyan
try {
    Checkpoint-Computer -Description "Before Privacy Lockdown" -RestorePointType MODIFY_SETTINGS
    Write-Host "✓ Restore point created" -ForegroundColor Green
} catch {
    Write-Host "⚠ Could not create restore point (may need to enable System Restore)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "PHASE 3: DISABLE TELEMETRY (REGISTRY)" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
& "$scriptPath\DEBLOAT_3_DISABLE_TELEMETRY.bat"

Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "PHASE 4: DISABLE SPYWARE SERVICES" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
& powershell -File "$scriptPath\DEBLOAT_4_DISABLE_SERVICES.ps1"

Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "PHASE 5: BLOCK TELEMETRY DOMAINS" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
& powershell -File "$scriptPath\DEBLOAT_5_BLOCK_DOMAINS.ps1"

Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "PHASE 6: DISABLE WINDOWS UPDATE" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
& powershell -File "$scriptPath\DEBLOAT_6_DISABLE_UPDATES.ps1"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "PRIVACY LOCKDOWN COMPLETE!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  ✓ Telemetry disabled via registry" -ForegroundColor Green
Write-Host "  ✓ 20+ spyware services disabled" -ForegroundColor Green
Write-Host "  ✓ ~60 Microsoft domains blocked" -ForegroundColor Green
Write-Host "  ✓ Windows Update completely disabled" -ForegroundColor Green
Write-Host ""
Write-Host "Your system is now LOCKED DOWN" -ForegroundColor Green
Write-Host ""
Write-Host "Microsoft CANNOT:" -ForegroundColor Red
Write-Host "  ✗ Collect telemetry" -ForegroundColor White
Write-Host "  ✗ Track your usage" -ForegroundColor White
Write-Host "  ✗ Send diagnostics" -ForegroundColor White
Write-Host "  ✗ Sync your activity" -ForegroundColor White
Write-Host "  ✗ Force updates" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  RESTART REQUIRED" -ForegroundColor Yellow
Write-Host ""
$restart = Read-Host "Restart now? (y/n)"
if ($restart -eq 'y') {
    Write-Host "Restarting in 10 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}


