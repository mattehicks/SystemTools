# ============================================================================
# CLEAR ALL EVENT LOGS - Fresh Start for Tracking
# WARNING: This deletes ALL Windows event logs!
# Use this to get clean baseline before testing sleep/wake
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║          CLEAR ALL WINDOWS EVENT LOGS                     ║" -ForegroundColor Red
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

# Admin check
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell → Run as Administrator" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "WARNING: This will permanently delete ALL event logs!" -ForegroundColor Red
Write-Host ""
Write-Host "This includes:" -ForegroundColor Yellow
Write-Host "- System log (~43,000 events)" -ForegroundColor White
Write-Host "- Application log (~35,000 events)" -ForegroundColor White
Write-Host "- Security log" -ForegroundColor White
Write-Host "- All Microsoft/Windows logs" -ForegroundColor White
Write-Host "- All application-specific logs" -ForegroundColor White
Write-Host ""
Write-Host "PURPOSE:" -ForegroundColor Cyan
Write-Host "Clean slate for tracking sleep/wake events after fixes" -ForegroundColor White
Write-Host "Makes it easy to see only NEW events from testing" -ForegroundColor White
Write-Host ""
Write-Host "You can always view current logs later with Event Viewer" -ForegroundColor Gray
Write-Host ""

$confirm1 = Read-Host "Are you SURE you want to clear all logs? (YES/no)"
if ($confirm1 -ne "YES") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
$confirm2 = Read-Host "Really sure? This cannot be undone. (type: DELETE)"
if ($confirm2 -ne "DELETE") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Clearing Event Logs..." -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Get all logs
$logs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | Where-Object {$_.RecordCount -gt 0}
$totalLogs = $logs.Count
$cleared = 0
$failed = 0

Write-Host "Clearing logs... (this may take a minute)" -ForegroundColor Yellow

foreach ($log in $logs) {
    $logName = $log.LogName
    try {
        wevtutil.exe cl "$logName" 2>$null
        Write-Host "  ✓ Cleared: $logName" -ForegroundColor Green
        $cleared++
    } catch {
        Write-Host "  ✗ Failed: $logName" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Log Clearing Complete" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Results:" -ForegroundColor Yellow
Write-Host "  Total logs found: $totalLogs" -ForegroundColor White
Write-Host "  Successfully cleared: $cleared" -ForegroundColor Green
Write-Host "  Failed to clear: $failed" -ForegroundColor Red
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Run sleep/wake fixes: .\RUN_ALL_FIXES.ps1" -ForegroundColor White
Write-Host "2. Test sleep/wake functionality" -ForegroundColor White
Write-Host "3. Check Event Viewer for NEW events only" -ForegroundColor White
Write-Host ""
Write-Host "To view sleep events after testing:" -ForegroundColor Yellow
Write-Host "  Get-WinEvent -FilterHashtable @{LogName='System'; Id=506,507} | Select-Object TimeCreated, Message" -ForegroundColor Gray
Write-Host ""
pause
