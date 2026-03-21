# ============================================================================
# DYNAMIC NETWORK ADAPTER CHECK & REPAIR
# Works on any machine - auto-discovers all adapters, diagnoses issues,
# attempts remediation. No hardcoded VIDs/PIDs.
# ============================================================================

$ErrorActionPreference = "Continue"

Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "  NETWORK ADAPTER CHECK & REPAIR (Dynamic)" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
Write-Host ""

# Admin check
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "WARNING: Not running as Admin - repair actions will be limited" -ForegroundColor Yellow
    Write-Host "Right-click PowerShell -> Run as Administrator for full repair" -ForegroundColor Yellow
    Write-Host ""
}

$logEntries = @()
$logEntries += "Network Adapter Check - $(Get-Date)"
$logEntries += "=" * 60

# -- PHASE 1: DISCOVER ALL NETWORK ADAPTERS -----------------------------------
Write-Host "[1/5] Discovering network adapters..." -ForegroundColor Yellow
Write-Host ""

$pnpAdapters = Get-PnpDevice | Where-Object {
    $_.Class -match '^Net$' -or
    ($_.Class -match 'Bluetooth' -and $_.FriendlyName -match 'Network|Bluetooth')
}

$netAdapters = Get-NetAdapter -ErrorAction SilentlyContinue

$totalIssues = 0
$totalFixed = 0

foreach ($pnp in ($pnpAdapters | Sort-Object Status)) {
    $statusColor = switch ($pnp.Status) {
        'OK'       { 'Green' }
        'Error'    { 'Red' }
        'Degraded' { 'Yellow' }
        'Unknown'  { 'Yellow' }
        default    { 'Gray' }
    }

    $icon = switch ($pnp.Status) {
        'OK'    { '[OK]' }
        'Error' { '[!!]' }
        default { '[??]' }
    }

    Write-Host "  $icon $($pnp.FriendlyName)" -ForegroundColor $statusColor
    Write-Host "      Status: $($pnp.Status)  |  Class: $($pnp.Class)  |  ID: $($pnp.InstanceId)" -ForegroundColor Gray
    $logEntries += "$icon $($pnp.FriendlyName) - $($pnp.Status)"

    $osMatch = $netAdapters | Where-Object { $_.InterfaceDescription -eq $pnp.FriendlyName }
    if ($osMatch) {
        Write-Host "      Link: $($osMatch.Status)  |  Speed: $($osMatch.LinkSpeed)  |  MAC: $($osMatch.MacAddress)" -ForegroundColor Gray
    }

    # -- DIAGNOSE PROBLEM CODES ------------------------------------------------
    if ($pnp.Status -ne 'OK') {
        $totalIssues++
        $problemCode = $null
        try {
            $problemCode = (Get-PnpDeviceProperty -InstanceId $pnp.InstanceId -KeyName 'DEVPKEY_Device_ProblemCode' -ErrorAction SilentlyContinue).Data
        } catch {}

        if ($problemCode) {
            $diagnosis = switch ($problemCode) {
                1  { "Device not configured correctly" }
                10 { "Device cannot start" }
                12 { "Not enough resources" }
                14 { "Device requires restart to work" }
                16 { "Not all resources identified" }
                18 { "Reinstall drivers" }
                22 { "Device is disabled" }
                24 { "Device not present / not working / not all drivers installed" }
                28 { "Driver not installed" }
                31 { "Device not working properly (Windows can't load drivers)" }
                32 { "Driver for this device was disabled (registry)" }
                43 { "Windows stopped this device (reported problems)" }
                44 { "Application or service shut down this device" }
                45 { "Device not currently connected" }
                48 { "Software for this device blocked (known compatibility issues)" }
                52 { "Windows cannot verify digital signature of drivers" }
                default { "Problem code: $problemCode" }
            }
            Write-Host "      PROBLEM: $diagnosis (Code $problemCode)" -ForegroundColor Red
            $logEntries += "  PROBLEM: $diagnosis (Code $problemCode)"
        }

        # -- AUTO-REPAIR ATTEMPTS ----------------------------------------------
        if ($isAdmin) {
            $repaired = $false

            # Code 22: Device disabled -> try enable
            if ($problemCode -eq 22) {
                Write-Host "      REPAIR: Attempting to enable device..." -ForegroundColor Cyan
                try {
                    Enable-PnpDevice -InstanceId $pnp.InstanceId -Confirm:$false -ErrorAction Stop
                    Start-Sleep -Seconds 2
                    $recheck = Get-PnpDevice -InstanceId $pnp.InstanceId
                    if ($recheck.Status -eq 'OK') {
                        Write-Host "      FIXED: Device re-enabled successfully" -ForegroundColor Green
                        $repaired = $true
                        $totalFixed++
                    }
                } catch {
                    Write-Host "      FAILED: Could not enable - $($_.Exception.Message)" -ForegroundColor Red
                }
            }

            # Code 14: Needs restart
            if ($problemCode -eq 14) {
                Write-Host "      INFO: This device will work after a system restart" -ForegroundColor Yellow
            }

            # Code 28: No driver -> attempt Windows driver install
            if ($problemCode -eq 28) {
                Write-Host "      REPAIR: Attempting driver scan (pnputil)..." -ForegroundColor Cyan
                try {
                    $scanResult = pnputil /scan-devices 2>&1
                    Start-Sleep -Seconds 5
                    $recheck = Get-PnpDevice -InstanceId $pnp.InstanceId
                    if ($recheck.Status -eq 'OK') {
                        Write-Host "      FIXED: Driver found and installed" -ForegroundColor Green
                        $repaired = $true
                        $totalFixed++
                    } else {
                        Write-Host "      INFO: No driver found automatically. Manual install needed." -ForegroundColor Yellow
                    }
                } catch {
                    Write-Host "      FAILED: $($_.Exception.Message)" -ForegroundColor Red
                }
            }

            # Code 31/43: Device malfunction -> disable/re-enable cycle
            if ($problemCode -in @(31, 43, 10) -and -not $repaired) {
                Write-Host "      REPAIR: Attempting disable/re-enable cycle..." -ForegroundColor Cyan
                try {
                    Disable-PnpDevice -InstanceId $pnp.InstanceId -Confirm:$false -ErrorAction Stop
                    Start-Sleep -Seconds 2
                    Enable-PnpDevice -InstanceId $pnp.InstanceId -Confirm:$false -ErrorAction Stop
                    Start-Sleep -Seconds 3
                    $recheck = Get-PnpDevice -InstanceId $pnp.InstanceId
                    if ($recheck.Status -eq 'OK') {
                        Write-Host "      FIXED: Device recovered after reset" -ForegroundColor Green
                        $totalFixed++
                    } else {
                        Write-Host "      INFO: Still in error. May need driver reinstall or is physically broken." -ForegroundColor Yellow
                    }
                } catch {
                    Write-Host "      FAILED: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
    Write-Host ""
}

# -- PHASE 2: CHECK CONNECTIVITY ----------------------------------------------
Write-Host "[2/5] Checking connectivity..." -ForegroundColor Yellow

$connectedAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -or $_.MediaConnectionState -eq 'Connected' }
if ($connectedAdapters.Count -gt 0) {
    Write-Host "  Connected adapters: $($connectedAdapters.Count)" -ForegroundColor Green
    foreach ($ca in $connectedAdapters) {
        $ipInfo = Get-NetIPAddress -InterfaceIndex $ca.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
        $gateway = Get-NetRoute -InterfaceIndex $ca.ifIndex -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Select-Object -First 1
        Write-Host "    $($ca.Name): $($ipInfo.IPAddress) | GW: $($gateway.NextHop) | $($ca.LinkSpeed)" -ForegroundColor White
    }
} else {
    Write-Host "  WARNING: No connected network adapters!" -ForegroundColor Red
    $totalIssues++
}
Write-Host ""

# -- PHASE 3: DNS RESOLUTION TEST ---------------------------------------------
Write-Host "[3/5] Testing DNS resolution..." -ForegroundColor Yellow
$dnsTargets = @('google.com', 'cloudflare.com')
$dnsOK = 0
foreach ($target in $dnsTargets) {
    try {
        $result = Resolve-DnsName $target -Type A -DnsOnly -ErrorAction Stop | Select-Object -First 1
        Write-Host "  $target -> $($result.IPAddress)" -ForegroundColor Green
        $dnsOK++
    } catch {
        Write-Host "  $target -> FAILED" -ForegroundColor Red
    }
}
if ($dnsOK -eq 0) {
    Write-Host "  DNS completely broken! Check adapter config or hosts file." -ForegroundColor Red
    $totalIssues++
}
Write-Host ""

# -- PHASE 4: PING TEST -------------------------------------------------------
Write-Host "[4/5] Testing reachability (ping)..." -ForegroundColor Yellow
$pingTargets = @('8.8.8.8', '1.1.1.1')
foreach ($pt in $pingTargets) {
    $ping = Test-Connection -ComputerName $pt -Count 2 -Quiet -ErrorAction SilentlyContinue
    if ($ping) {
        Write-Host "  $pt -> OK" -ForegroundColor Green
    } else {
        Write-Host "  $pt -> UNREACHABLE" -ForegroundColor Red
        $totalIssues++
    }
}
Write-Host ""

# -- PHASE 5: RECENT ERROR EVENTS ---------------------------------------------
Write-Host "[5/5] Checking recent network errors (last 24h)..." -ForegroundColor Yellow
$since = (Get-Date).AddHours(-24)
$networkErrors = @()

try {
    $networkErrors += Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ProviderName = 'Microsoft-Windows-NetworkProfile', 'Tcpip', 'NDIS', 'e1iexpress', 'Netwtw10', 'NETwNs64'
        Level = 1,2,3
        StartTime = $since
    } -ErrorAction SilentlyContinue
} catch {}

if ($networkErrors.Count -gt 0) {
    Write-Host "  Found $($networkErrors.Count) network-related event(s):" -ForegroundColor Yellow
    $networkErrors | Sort-Object TimeCreated -Descending | Select-Object -First 10 | ForEach-Object {
        $lvl = switch ($_.Level) { 1 {'CRIT'} 2 {'ERR'} 3 {'WARN'} default {'INFO'} }
        $color = switch ($_.Level) { 1 {'Red'} 2 {'Red'} 3 {'Yellow'} default {'Gray'} }
        Write-Host "    [$lvl] $($_.TimeCreated.ToString('HH:mm:ss')) $($_.ProviderName): $($_.Message.Substring(0, [Math]::Min(120, $_.Message.Length)))" -ForegroundColor $color
    }
    $logEntries += "Network errors in last 24h: $($networkErrors.Count)"
} else {
    Write-Host "  No network errors in last 24 hours" -ForegroundColor Green
}
Write-Host ""

# -- SUMMARY -------------------------------------------------------------------
Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "  RESULTS" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
Write-Host ""

$adapterCount = ($pnpAdapters | Measure-Object).Count
$okCount = ($pnpAdapters | Where-Object { $_.Status -eq 'OK' } | Measure-Object).Count

Write-Host "  Adapters found:    $adapterCount" -ForegroundColor White
Write-Host "  Working (OK):      $okCount" -ForegroundColor Green
Write-Host "  Issues found:      $totalIssues" -ForegroundColor $(if ($totalIssues -eq 0) {'Green'} else {'Red'})
Write-Host "  Auto-fixed:        $totalFixed" -ForegroundColor $(if ($totalFixed -gt 0) {'Green'} else {'Gray'})
Write-Host ""

if ($totalIssues -eq 0) {
    Write-Host "  All network adapters healthy." -ForegroundColor Green
} elseif ($totalFixed -eq $totalIssues) {
    Write-Host "  All issues resolved. Restart recommended." -ForegroundColor Green
} else {
    Write-Host "  Some issues remain. Manual intervention may be needed." -ForegroundColor Yellow
    Write-Host "  Suggestions:" -ForegroundColor Cyan
    Write-Host "    - Update drivers via Device Manager or manufacturer site" -ForegroundColor White
    Write-Host "    - Run: pnputil /scan-devices" -ForegroundColor White
    Write-Host "    - Run: netsh winsock reset  (then restart)" -ForegroundColor White
    Write-Host "    - Run: netsh int ip reset   (then restart)" -ForegroundColor White
}

$logPath = "$PSScriptRoot\network_check_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$logEntries += ""
$logEntries += "Adapters: $adapterCount | OK: $okCount | Issues: $totalIssues | Fixed: $totalFixed"
$logEntries | Out-File -FilePath $logPath -Force
Write-Host ""
Write-Host "  Log saved: $logPath" -ForegroundColor Gray
Write-Host ""
pause
