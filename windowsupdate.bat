@echo off
ECHO This script will set the maximum Windows Update pause period to 365 days.
ECHO.
ECHO It requires administrative privileges to modify the registry.
ECHO If you are not running as an administrator, the script will fail.
ECHO.
pause
ECHO Setting the maximum Windows Update pause period to 365 days...
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "FlightSettingsMaxPauseDays" /t REG_DWORD /d 365 /f
ECHO.
ECHO The registry change is complete.
ECHO.
ECHO To apply the one-year pause, go to:
ECHO Settings > Update & Security > Windows Update > Advanced options,
ECHO and select a date.
ECHO.
pause
