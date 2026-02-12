# CREATE SCHEDULED TASK - AUTOMATED SPYWARE CHECK
# Run as Administrator

Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "CREATE AUTOMATED SPYWARE CHECK TASK" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Auto-detect script directory
if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}

$scriptPath = Join-Path $PSScriptRoot "AUTOMATED_SPYWARE_CHECK.ps1"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Cannot find AUTOMATED_SPYWARE_CHECK.ps1" -ForegroundColor Red
    Write-Host "Expected location: $scriptPath" -ForegroundColor Gray
    pause
    exit 1
}

Write-Host "Script location: $scriptPath" -ForegroundColor Gray
Write-Host ""

# Task configuration
$taskName = "SpywareCheck-Weekly"
$taskDescription = "Automated weekly check for re-enabled Microsoft spyware services"

Write-Host "Task configuration:" -ForegroundColor Yellow
Write-Host "  Name: $taskName" -ForegroundColor White
Write-Host "  Schedule: Weekly (Sunday 2:00 AM)" -ForegroundColor White
Write-Host "  Script: $scriptPath" -ForegroundColor White
Write-Host "  Run as: SYSTEM" -ForegroundColor White
Write-Host "  Privileges: Highest" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Create this scheduled task? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Creating scheduled task..." -ForegroundColor Yellow

# Delete existing task if present
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "  Removing existing task..." -ForegroundColor Gray
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Create action
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""

# Create trigger (Weekly on Sunday at 2 AM)
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am

# Create settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable:$false `
    -MultipleInstances IgnoreNew

# Create principal (run as SYSTEM with highest privileges)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

# Register task
$task = Register-ScheduledTask `
    -TaskName $taskName `
    -Description $taskDescription `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Force

if ($task) {
    Write-Host ""
    Write-Host "✓ Scheduled task created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Task details:" -ForegroundColor Cyan
    Write-Host "  Name: $taskName" -ForegroundColor White
    Write-Host "  Schedule: Every Sunday at 2:00 AM" -ForegroundColor White
    Write-Host "  Next run: $(($task.Triggers[0]).StartBoundary)" -ForegroundColor White
    Write-Host "  Status: $($task.State)" -ForegroundColor White
    Write-Host ""
    Write-Host "The task will:" -ForegroundColor Yellow
    Write-Host "  • Check if spyware services have been re-enabled" -ForegroundColor White
    Write-Host "  • Automatically disable them if found" -ForegroundColor White
    Write-Host "  • Create log in %TEMP% folder" -ForegroundColor White
    Write-Host "  • Run silently in background" -ForegroundColor White
    Write-Host ""
    
    # Test run option
    $testRun = Read-Host "Test run the task now? (y/n)"
    if ($testRun -eq 'y') {
        Write-Host ""
        Write-Host "Running task now..." -ForegroundColor Yellow
        Start-ScheduledTask -TaskName $taskName
        Start-Sleep -Seconds 3
        
        # Check result
        $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName
        Write-Host ""
        Write-Host "Last run: $($taskInfo.LastRunTime)" -ForegroundColor Cyan
        Write-Host "Last result: $($taskInfo.LastTaskResult)" -ForegroundColor Cyan
        Write-Host ""
        
        # Show log
        $latestLog = Get-ChildItem $env:TEMP -Filter "SpywareCheck_*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latestLog) {
            Write-Host "Latest log:" -ForegroundColor Yellow
            Get-Content $latestLog.FullName | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        }
    }
} else {
    Write-Host "✗ Failed to create scheduled task" -ForegroundColor Red
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "TASK SETUP COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "To manage this task:" -ForegroundColor Cyan
Write-Host "  • Open: Task Scheduler (taskschd.msc)" -ForegroundColor White
Write-Host "  • Navigate to: Task Scheduler Library" -ForegroundColor White
Write-Host "  • Find: $taskName" -ForegroundColor White
Write-Host ""
Write-Host "To remove this task:" -ForegroundColor Cyan
Write-Host "  Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false" -ForegroundColor White
Write-Host ""

pause
