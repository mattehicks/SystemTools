# Create NSudo Desktop Shortcuts

Write-Host "Creating NSudo shortcuts..." -ForegroundColor Cyan
Write-Host ""

# TrustedInstaller CMD Shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\TrustedInstaller CMD.lnk")
$Shortcut.TargetPath = "C:\Tools\NSudo\NSudo_8.2_All_Components\NSudo Launcher\x64\NSudoLC.exe"
$Shortcut.Arguments = "-U:T -P:E cmd"
$Shortcut.WorkingDirectory = "C:\Tools\NSudo\NSudo_8.2_All_Components\NSudo Launcher\x64"
$Shortcut.Description = "Command Prompt as TrustedInstaller (Highest Privilege)"
$Shortcut.Save()
Write-Host "✓ Created: TrustedInstaller CMD.lnk" -ForegroundColor Green

# TrustedInstaller PowerShell Shortcut
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\TrustedInstaller PS.lnk")
$Shortcut.TargetPath = "C:\Tools\NSudo\NSudo_8.2_All_Components\NSudo Launcher\x64\NSudoLC.exe"
$Shortcut.Arguments = "-U:T -P:E powershell"
$Shortcut.WorkingDirectory = "C:\Tools\NSudo\NSudo_8.2_All_Components\NSudo Launcher\x64"
$Shortcut.Description = "PowerShell as TrustedInstaller (Highest Privilege)"
$Shortcut.Save()
Write-Host "✓ Created: TrustedInstaller PS.lnk" -ForegroundColor Green

# SYSTEM CMD Shortcut
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\SYSTEM CMD.lnk")
$Shortcut.TargetPath = "C:\Temp\PsExec64.exe"
$Shortcut.Arguments = "-accepteula -s -i cmd"
$Shortcut.WorkingDirectory = "C:\Temp"
$Shortcut.Description = "Command Prompt as NT AUTHORITY\SYSTEM"
$Shortcut.Save()
Write-Host "✓ Created: SYSTEM CMD.lnk" -ForegroundColor Green

# SYSTEM PowerShell Shortcut
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\SYSTEM PS.lnk")
$Shortcut.TargetPath = "C:\Temp\PsExec64.exe"
$Shortcut.Arguments = "-accepteula -s -i powershell"
$Shortcut.WorkingDirectory = "C:\Temp"
$Shortcut.Description = "PowerShell as NT AUTHORITY\SYSTEM"
$Shortcut.Save()
Write-Host "✓ Created: SYSTEM PS.lnk" -ForegroundColor Green

# NSudo GUI Shortcut
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\NSudo GUI.lnk")
$Shortcut.TargetPath = "C:\Tools\NSudo\NSudo_8.2_All_Components\NSudo Launcher\x64\NSudoLG.exe"
$Shortcut.WorkingDirectory = "C:\Tools\NSudo\NSudo_8.2_All_Components\NSudo Launcher\x64"
$Shortcut.Description = "NSudo Launcher with GUI"
$Shortcut.Save()
Write-Host "✓ Created: NSudo GUI.lnk" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "ALL SHORTCUTS CREATED!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Check your Desktop for:" -ForegroundColor Cyan
Write-Host "  • TrustedInstaller CMD" -ForegroundColor White
Write-Host "  • TrustedInstaller PS" -ForegroundColor White
Write-Host "  • SYSTEM CMD" -ForegroundColor White
Write-Host "  • SYSTEM PS" -ForegroundColor White
Write-Host "  • NSudo GUI" -ForegroundColor White
Write-Host ""
Write-Host "Next: Disable UAC and restart!" -ForegroundColor Yellow
