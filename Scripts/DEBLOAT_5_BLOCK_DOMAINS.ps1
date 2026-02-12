# BLOCK MICROSOFT TELEMETRY DOMAINS
# Phase 5: Add telemetry domains to hosts file (redirects to 0.0.0.0)
# Run with TrustedInstaller

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "PHASE 5: BLOCK TELEMETRY DOMAINS (HOSTS FILE)" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host ""

$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$backupFile = "C:\Windows\System32\drivers\etc\hosts.backup"

# Backup hosts file
Write-Host "[1/3] Backing up hosts file..." -ForegroundColor Yellow
if (-not (Test-Path $backupFile)) {
    Copy-Item $hostsFile $backupFile -Force
    Write-Host "✓ Backup created: $backupFile" -ForegroundColor Green
} else {
    Write-Host "✓ Backup already exists" -ForegroundColor Green
}
Write-Host ""

# Microsoft telemetry/tracking domains
$telemetryDomains = @(
    # Core telemetry
    'vortex.data.microsoft.com',
    'vortex-win.data.microsoft.com',
    'telecommand.telemetry.microsoft.com',
    'telecommand.telemetry.microsoft.com.nsatc.net',
    'oca.telemetry.microsoft.com',
    'oca.telemetry.microsoft.com.nsatc.net',
    'sqm.telemetry.microsoft.com',
    'sqm.telemetry.microsoft.com.nsatc.net',
    'watson.telemetry.microsoft.com',
    'watson.telemetry.microsoft.com.nsatc.net',
    
    # Data collection
    'redir.metaservices.microsoft.com',
    'choice.microsoft.com',
    'choice.microsoft.com.nsatc.net',
    'df.telemetry.microsoft.com',
    'reports.wes.df.telemetry.microsoft.com',
    'wes.df.telemetry.microsoft.com',
    'services.wes.df.telemetry.microsoft.com',
    'sqm.df.telemetry.microsoft.com',
    'telemetry.microsoft.com',
    'watson.ppe.telemetry.microsoft.com',
    'telemetry.appex.bing.net',
    'telemetry.urs.microsoft.com',
    'telemetry.appex.bing.net:443',
    
    # Settings sync
    'settings-sandbox.data.microsoft.com',
    'vortex-sandbox.data.microsoft.com',
    
    # Feedback & surveys
    'survey.watson.microsoft.com',
    'watson.live.com',
    'watson.microsoft.com',
    'feedback.windows.com',
    'feedback.microsoft-hohm.com',
    'feedback.search.microsoft.com',
    
    # Diagnostics
    'statsfe2.ws.microsoft.com',
    'corpext.msitadfs.glbdns2.microsoft.com',
    'compatexchange.cloudapp.net',
    'cs1.wpc.v0cdn.net',
    'a-0001.a-msedge.net',
    'statsfe2.update.microsoft.com.akadns.net',
    'diagnostics.support.microsoft.com',
    'corp.sts.microsoft.com',
    'statsfe1.ws.microsoft.com',
    
    # Advertising & tracking
    'pre.footprintpredict.com',
    'i1.services.social.microsoft.com',
    'i1.services.social.microsoft.com.nsatc.net',
    
    # Cortana & Bing
    'www.bing.com',
    'g.msn.com',
    'a.ads1.msn.com',
    'a.ads2.msn.com',
    'adnexus.net',
    'adnxs.com',
    'aidps.atdmt.com',
    
    # Windows Update telemetry (NOT update downloads)
    'sls.update.microsoft.com.akadns.net',
    'fe2.update.microsoft.com.akadns.net',
    
    # Office telemetry
    'officeclient.microsoft.com',
    'self.events.data.microsoft.com',
    
    # Windows Defender telemetry (keeps protection, blocks reporting)
    'wdcp.microsoft.com',
    'wdcpalt.microsoft.com'
)

Write-Host "[2/3] Checking current hosts file..." -ForegroundColor Yellow
$hostsContent = Get-Content $hostsFile

$newEntries = @()
$alreadyBlocked = 0

foreach ($domain in $telemetryDomains) {
    if ($hostsContent -match [regex]::Escape($domain)) {
        $alreadyBlocked++
    } else {
        $newEntries += "0.0.0.0 $domain"
    }
}

Write-Host "Already blocked: $alreadyBlocked domains" -ForegroundColor Gray
Write-Host "To be added:     $($newEntries.Count) domains" -ForegroundColor Yellow
Write-Host ""

if ($newEntries.Count -gt 0) {
    Write-Host "[3/3] Adding entries to hosts file..." -ForegroundColor Yellow
    
    # Add header
    Add-Content -Path $hostsFile -Value "`n# ============================================="
    Add-Content -Path $hostsFile -Value "# Microsoft Telemetry & Tracking Domains Block"
    Add-Content -Path $hostsFile -Value "# Added: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Add-Content -Path $hostsFile -Value "# ============================================="
    
    # Add domains
    foreach ($entry in $newEntries) {
        Add-Content -Path $hostsFile -Value $entry
        Write-Host "  BLOCKED: $entry" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "✓ Added $($newEntries.Count) domains to hosts file" -ForegroundColor Green
} else {
    Write-Host "[3/3] All domains already blocked" -ForegroundColor Green
}

Write-Host ""
Write-Host "[4/4] Flushing DNS cache..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "✓ DNS cache flushed" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "TELEMETRY DOMAINS BLOCKED" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Total blocked:   $($telemetryDomains.Count) domains" -ForegroundColor Red
Write-Host "Backup location: $backupFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "Microsoft can no longer:" -ForegroundColor Yellow
Write-Host "  ✓ Send telemetry data" -ForegroundColor White
Write-Host "  ✓ Track your usage" -ForegroundColor White
Write-Host "  ✓ Collect diagnostics" -ForegroundColor White
Write-Host "  ✓ Send advertising IDs" -ForegroundColor White
Write-Host "  ✓ Sync activity data" -ForegroundColor White
Write-Host ""
pause
