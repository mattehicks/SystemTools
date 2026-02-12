# PHASE 2: REMOVE BLOATWARE APPS
# Run with: NSudoLC.exe -U:T -P:E powershell -File DEBLOAT_2_REMOVE_APPS.ps1

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "PHASE 2: REMOVE BLOATWARE APPS" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host ""

# Apps to KEEP (whitelist)
$keepApps = @(
    'Microsoft.WindowsStore',
    'Microsoft.WindowsCalculator',
    'Microsoft.Windows.Photos',
    'Microsoft.ScreenSketch',
    'Microsoft.Paint'
)

Write-Host "Apps that will be KEPT:" -ForegroundColor Green
$keepApps | ForEach-Object { Write-Host "  ✓ $_" -ForegroundColor White }
Write-Host ""

$confirm = Read-Host "Remove all other apps? (Type 'YES' to confirm)"
if ($confirm -ne 'YES') {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit
}

Write-Host ""
$removed = 0
$kept = 0

# Get all AppX packages
$apps = Get-AppxPackage

foreach ($app in $apps) {
    $remove = $true
    
    # Check whitelist
    foreach ($keep in $keepApps) {
        if ($app.Name -eq $keep) {
            $remove = $false
            $kept++
            Write-Host "KEEP: $($app.Name)" -ForegroundColor Green
            break
        }
    }
    
    if ($remove) {
        Write-Host "REMOVING: $($app.Name)" -ForegroundColor Red
        
        try {
            # Remove for current user
            Remove-AppxPackage -Package $app.PackageFullName -ErrorAction Stop
            
            # Remove provisioned package (prevents reinstall for new users)
            $provisioned = Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*$($app.Name)*" }
            if ($provisioned) {
                Remove-AppxProvisionedPackage -Online -PackageName $provisioned.PackageName -ErrorAction SilentlyContinue
            }
            
            $removed++
        } catch {
            Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "BLOATWARE REMOVAL COMPLETE!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Removed: $removed apps" -ForegroundColor Red
Write-Host "Kept:    $kept apps" -ForegroundColor Green
Write-Host ""
pause
