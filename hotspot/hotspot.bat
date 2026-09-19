@echo off
setlocal
set "ACTION=%~1"
if not defined ACTION set "ACTION=toggle"

rem --- auto elevate (hotspot API needs admin) ---
net session >nul 2>&1
if errorlevel 1 (
    powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath '%~f0' -ArgumentList '%ACTION%'"
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0hotspot.ps1" %ACTION%
timeout /t 3 >nul
