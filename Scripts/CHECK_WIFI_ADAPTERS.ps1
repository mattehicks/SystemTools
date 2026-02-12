# ============================================================================
# DUAL WIFI ADAPTER FIX - Updated for both NETGEAR + TP-Link
# Run this FIRST to get both adapters working before sleep fixes
# ============================================================================

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Dual WiFi Adapter Setup Check" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    pause
    exit
}

Write-Host "Checking WiFi adapters..." -ForegroundColor Yellow
Write-Host ""

# Check NETGEAR A6100
$netgear = Get-PnpDevice | Where-Object {$_.InstanceId -match 'VID_0846&PID_9052'}
Write-Host "[1/2] NETGEAR A6100 (Server network):" -ForegroundColor Cyan
if ($netgear -and $netgear.Status -eq 'OK') {
    Write-Host "      ✓ Working ($($netgear.Status))" -ForegroundColor Green
} elseif ($netgear) {
    Write-Host "      ✗ Status: $($netgear.Status)" -ForegroundColor Red
} else {
    Write-Host "      ✗ Not detected" -ForegroundColor Red
}

Write-Host ""

# Check TP-Link
$tplink = Get-PnpDevice | Where-Object {$_.InstanceId -match 'VID_2357&PID_011E'}
Write-Host "[2/2] TP-Link Wireless Nano (Second network):" -ForegroundColor Cyan
if ($tplink -and $tplink.Status -eq 'OK') {
    Write-Host "      ✓ Working ($($tplink.Status))" -ForegroundColor Green
} elseif ($tplink) {
    Write-Host "      ⚠ Status: $($tplink.Status)" -ForegroundColor Yellow
    
    if ($tplink.Status -eq 'Error') {
        $problemCode = (Get-PnpDeviceProperty -InstanceId $tplink.InstanceId -KeyName 'DEVPKEY_Device_ProblemCode' -ErrorAction SilentlyContinue).Data
        
        if ($problemCode -eq 22) {
            Write-Host "      Device is disabled - attempting to enable..." -ForegroundColor Yellow
            Enable-PnpDevice -InstanceId $tplink.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            $tplink = Get-PnpDevice -InstanceId $tplink.InstanceId
        } elseif ($problemCode -eq 28) {
            Write-Host "      ✗ Driver not installed (Problem Code 28)" -ForegroundColor Red
            Write-Host ""
            Write-Host "      SOLUTION: Install TP-Link driver" -ForegroundColor Yellow
            Write-Host "      1. Visit: https://www.tp-link.com/support/download/" -ForegroundColor White
            Write-Host "      2. Search for your model (check device label)" -ForegroundColor White
            Write-Host "      3. Download Windows 10 driver" -ForegroundColor White
            Write-Host "      4. Install and restart" -ForegroundColor White
            Write-Host "      5. Re-run this script" -ForegroundColor White
        }
    }
} else {
    Write-Host "      ✗ Not detected - is it plugged in?" -ForegroundColor Red
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan

# Check if both are working
$bothWorking = ($netgear.Status -eq 'OK') -and ($tplink.Status -eq 'OK')

if ($bothWorking) {
    Write-Host "✓ Both WiFi adapters working!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You're ready to run the sleep/wake fixes." -ForegroundColor Cyan
    Write-Host "NEXT: Run .\RUN_ALL_FIXES.ps1" -ForegroundColor Yellow
} else {
    Write-Host "⚠ One or more adapters need attention" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Fix adapter issues first, then run sleep/wake fixes." -ForegroundColor White
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Show network adapter status
Write-Host "Network Adapter Status:" -ForegroundColor Cyan
Get-NetAdapter | Where-Object {$_.InterfaceDescription -match 'NETGEAR|TP-Link'} | 
    Select-Object Name, InterfaceDescription, Status, LinkSpeed | 
    Format-Table -AutoSize

Write-Host ""
pause
