@echo off
echo Disabling UAC via Registry...
echo.
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f
echo.
echo Checking new value...
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA
echo.
echo If EnableLUA is now 0x0, restart your computer for changes to take effect.
echo.
pause
