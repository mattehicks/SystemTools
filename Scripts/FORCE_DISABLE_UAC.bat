@echo off
echo ============================================================
echo BRUTE FORCE UAC DISABLE - TrustedInstaller Mode
echo ============================================================
echo.

echo Setting EnableLUA to 0...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f

echo Setting ConsentPromptBehaviorAdmin to 0...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f

echo Setting ConsentPromptBehaviorUser to 0...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorUser /t REG_DWORD /d 0 /f

echo Setting EnableInstallerDetection to 0...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableInstallerDetection /t REG_DWORD /d 0 /f

echo Setting EnableSecureUIAPaths to 0...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableSecureUIAPaths /t REG_DWORD /d 0 /f

echo Setting EnableUIADesktopToggle to 0...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableUIADesktopToggle /t REG_DWORD /d 0 /f

echo Setting PromptOnSecureDesktop to 0...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f

echo Setting ValidateAdminCodeSignatures to 0...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ValidateAdminCodeSignatures /t REG_DWORD /d 0 /f

echo.
echo ============================================================
echo Verifying changes...
echo ============================================================
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

echo.
echo ============================================================
echo DONE! Now RESTART your computer.
echo ============================================================
echo.
pause
