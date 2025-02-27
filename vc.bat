@echo off
setlocal enabledelayedexpansion

title Audio and Microphone Control

:: Check for PowerShell
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo PowerShell is required for this script but was not found.
    echo Please install PowerShell and try again.
    pause
    exit /b 1
)

:main_menu
cls
echo =============================================
echo         AUDIO AND MICROPHONE CONTROL
echo =============================================
echo.
echo  1. Audio Controls
echo  2. Microphone Controls
echo  3. Reset All Settings
echo  4. Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto audio_controls
if "%choice%"=="2" goto microphone_controls
if "%choice%"=="3" goto reset_all
if "%choice%"=="4" goto end_script
goto main_menu

:audio_controls
cls
echo =============================================
echo              AUDIO CONTROLS
echo =============================================
echo.
echo Listing applications playing audio...
echo.

:: Use PowerShell to list audio sessions
powershell -command "Add-Type -AssemblyName System.Windows.Forms; Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class Audio { [DllImport(\"user32.dll\")] public static extern IntPtr GetForegroundWindow(); }'; $apps = Get-Process | Where-Object {$_.MainWindowTitle -ne \"\" -and $_.MainWindowHandle -ne 0}; $i = 1; $apps | ForEach-Object { Write-Host \"$i. $($_.MainWindowTitle) (PID: $($_.Id))\"; $i++ }"

echo.
echo 0. Back to Main Menu
echo.
set /p app_choice="Enter application number to reduce volume to 10%% (or 0 to go back): "

if "%app_choice%"=="0" goto main_menu

:: Validate the input
powershell -command "$count = (Get-Process | Where-Object {$_.MainWindowTitle -ne \"\" -and $_.MainWindowHandle -ne 0}).Count; if (%app_choice% -gt $count -or %app_choice% -lt 1) { exit 1 } else { exit 0 }"
if %errorlevel% neq 0 (
    echo Invalid selection.
    timeout /t 2 >nul
    goto audio_controls
)

:: Get the PID of the selected app
for /f "tokens=*" %%a in ('powershell -command "$apps = Get-Process | Where-Object {$_.MainWindowTitle -ne \"\" -and $_.MainWindowHandle -ne 0}; $apps[%app_choice%-1].Id"') do set selected_pid=%%a

:: Set volume to 10% for the selected application
echo Setting volume to 10%% for the selected application...
powershell -command "$volume = New-Object -ComObject WScript.Shell; $volume.SendKeys([char]37); Start-Sleep -Milliseconds 100; $volume.AppActivate(%selected_pid%); Start-Sleep -Milliseconds 100; for ($i=0; $i -lt 50; $i++) { $volume.SendKeys([char]174); Start-Sleep -Milliseconds 10 }; for ($i=0; $i -lt 5; $i++) { $volume.SendKeys([char]175); Start-Sleep -Milliseconds 10 }"

echo Volume for the selected application has been reduced to approximately 10%%.
pause
goto audio_controls

:microphone_controls
cls
echo =============================================
echo            MICROPHONE CONTROLS
echo =============================================
echo.
echo  1. Enable Microphone
echo  2. Disable Microphone
echo  3. Back to Main Menu
echo.
set /p mic_choice="Enter your choice (1-3): "

if "%mic_choice%"=="1" (
    echo Enabling microphone...
    powershell -command "Add-Type -TypeDefinition 'using System.Runtime.InteropServices; [Guid(\"5CDF2C82-841E-4546-9722-0CF74078229A\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IAudioEndpointVolume { int GetMasterVolumeLevelScalar(out float level); int SetMasterVolumeLevelScalar(float level, System.Guid eventContext); int GetMute(out bool mute); int SetMute([MarshalAs(UnmanagedType.Bool)] bool mute, System.Guid eventContext); } [Guid(\"D666063F-1587-4E43-81F1-B948E807363F\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IMMDevice { int Activate([MarshalAs(UnmanagedType.LPStruct)] Guid iid, int dwClsCtx, IntPtr pActivationParams, [MarshalAs(UnmanagedType.IUnknown)] out object ppInterface); } [Guid(\"A95664D2-9614-4F35-A746-DE8DB63617E6\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IMMDeviceEnumerator { int EnumAudioEndpoints(int dataFlow, int dwStateMask, out IMMDeviceCollection ppDevices); int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice ppEndpoint); } [Guid(\"0BD7A1BE-7A1A-44DB-8397-CC5392387B5E\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IMMDeviceCollection { int GetCount(out int pcDevices); int Item(int nDevice, out IMMDevice ppDevice); } [ComImport, Guid(\"BCDE0395-E52F-467C-8E3D-C4579291692E\")] public class MMDeviceEnumeratorComObject { } public class Audio { public static void SetMicrophoneMute(bool mute) { var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator; IMMDevice device; enumerator.GetDefaultAudioEndpoint(2, 0, out device); object endpoint; device.Activate(typeof(IAudioEndpointVolume).GUID, 0, IntPtr.Zero, out endpoint); var volume = endpoint as IAudioEndpointVolume; volume.SetMute(mute, Guid.Empty); } }'; [Audio]::SetMicrophoneMute($false)"
    echo Microphone has been enabled.
    pause
    goto microphone_controls
)

if "%mic_choice%"=="2" (
    echo Disabling microphone...
    powershell -command "Add-Type -TypeDefinition 'using System.Runtime.InteropServices; [Guid(\"5CDF2C82-841E-4546-9722-0CF74078229A\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IAudioEndpointVolume { int GetMasterVolumeLevelScalar(out float level); int SetMasterVolumeLevelScalar(float level, System.Guid eventContext); int GetMute(out bool mute); int SetMute([MarshalAs(UnmanagedType.Bool)] bool mute, System.Guid eventContext); } [Guid(\"D666063F-1587-4E43-81F1-B948E807363F\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IMMDevice { int Activate([MarshalAs(UnmanagedType.LPStruct)] Guid iid, int dwClsCtx, IntPtr pActivationParams, [MarshalAs(UnmanagedType.IUnknown)] out object ppInterface); } [Guid(\"A95664D2-9614-4F35-A746-DE8DB63617E6\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IMMDeviceEnumerator { int EnumAudioEndpoints(int dataFlow, int dwStateMask, out IMMDeviceCollection ppDevices); int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice ppEndpoint); } [Guid(\"0BD7A1BE-7A1A-44DB-8397-CC5392387B5E\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IMMDeviceCollection { int GetCount(out int pcDevices); int Item(int nDevice, out IMMDevice ppDevice); } [ComImport, Guid(\"BCDE0395-E52F-467C-8E3D-C4579291692E\")] public class MMDeviceEnumeratorComObject { } public class Audio { public static void SetMicrophoneMute(bool mute) { var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator; IMMDevice device; enumerator.GetDefaultAudioEndpoint(2, 0, out device); object endpoint; device.Activate(typeof(IAudioEndpointVolume).GUID, 0, IntPtr.Zero, out endpoint); var volume = endpoint as IAudioEndpointVolume; volume.SetMute(mute, Guid.Empty); } }'; [Audio]::SetMicrophoneMute($true)"
    echo Microphone has been disabled.
    pause
    goto microphone_controls
)

if "%mic_choice%"=="3" goto main_menu
goto microphone_controls

:reset_all
cls
echo =============================================
echo            RESET ALL SETTINGS
echo =============================================
echo.
echo This will:
echo  - Reset all application volumes to default
echo  - Enable the microphone
echo.
set /p confirm="Are you sure you want to reset all settings? (Y/N): "
if /i "%confirm%"=="Y" (
    echo Resetting all audio settings...
    
    :: Reset all app volumes (by using the system volume mixer)
    powershell -command "$volume = New-Object -ComObject WScript.Shell; $volume.SendKeys([char]37); Start-Sleep -Milliseconds 100; $processes = Get-Process | Where-Object {$_.MainWindowTitle -ne \"\" -and $_.MainWindowHandle -ne 0}; foreach ($process in $processes) { try { $volume.AppActivate($process.Id); Start-Sleep -Milliseconds 100; for ($i=0; $i -lt 50; $i++) { $volume.SendKeys([char]174); Start-Sleep -Milliseconds 10 }; for ($i=0; $i -lt 30; $i++) { $volume.SendKeys([char]175); Start-Sleep -Milliseconds 10 } } catch { continue } }"
    
    :: Enable microphone
    powershell -command "Add-Type -TypeDefinition 'using System.Runtime.InteropServices; [Guid(\"5CDF2C82-841E-4546-9722-0CF74078229A\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IAudioEndpointVolume { int GetMasterVolumeLevelScalar(out float level); int SetMasterVolumeLevelScalar(float level, System.Guid eventContext); int GetMute(out bool mute); int SetMute([MarshalAs(UnmanagedType.Bool)] bool mute, System.Guid eventContext); } [Guid(\"D666063F-1587-4E43-81F1-B948E807363F\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IMMDevice { int Activate([MarshalAs(UnmanagedType.LPStruct)] Guid iid, int dwClsCtx, IntPtr pActivationParams, [MarshalAs(UnmanagedType.IUnknown)] out object ppInterface); } [Guid(\"A95664D2-9614-4F35-A746-DE8DB63617E6\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IMMDeviceEnumerator { int EnumAudioEndpoints(int dataFlow, int dwStateMask, out IMMDeviceCollection ppDevices); int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice ppEndpoint); } [Guid(\"0BD7A1BE-7A1A-44DB-8397-CC5392387B5E\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] public interface IMMDeviceCollection { int GetCount(out int pcDevices); int Item(int nDevice, out IMMDevice ppDevice); } [ComImport, Guid(\"BCDE0395-E52F-467C-8E3D-C4579291692E\")] public class MMDeviceEnumeratorComObject { } public class Audio { public static void SetMicrophoneMute(bool mute) { var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator; IMMDevice device; enumerator.GetDefaultAudioEndpoint(2, 0, out device); object endpoint; device.Activate(typeof(IAudioEndpointVolume).GUID, 0, IntPtr.Zero, out endpoint); var volume = endpoint as IAudioEndpointVolume; volume.SetMute(mute, Guid.Empty); } }'; [Audio]::SetMicrophoneMute($false)"
    
    echo All settings have been reset to default.
    pause
)
goto main_menu

:end_script
cls
echo Thank you for using the Audio and Microphone Control tool.
echo Goodbye!
timeout /t 2 >nul
exit /b 0
