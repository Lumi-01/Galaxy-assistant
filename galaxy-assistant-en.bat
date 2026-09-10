@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Galaxy Assistant

call :require_adb || exit /b 1

:menu
cls
echo ================================================================
echo Galaxy Assistant
echo ================================================================
echo 1. USB debugging instructions
echo 2. Disable forced camera shutter sound
echo 3. Restore camera shutter sound
echo 4. Check battery information
echo 5. Install Camsung
echo 6. Exit
echo.
set "choice="
set /p "choice=Choose an option: "
if "%choice%"=="1" goto debug_help
if "%choice%"=="2" goto silence
if "%choice%"=="3" goto restore
if "%choice%"=="4" goto battery
if "%choice%"=="5" goto install_camsung
if "%choice%"=="6" exit /b 0
goto menu

:require_adb
where adb >nul 2>&1
if errorlevel 1 (
  echo ADB was not found. Install Android Platform Tools or place adb.exe next to this script.
  pause
  exit /b 1
)
exit /b 0

:require_device
adb get-state 2>nul | findstr /x /c:"device" >nul
if errorlevel 1 (
  echo No authorized device was found. Check the USB cable and approve USB debugging on the phone.
  exit /b 1
)
exit /b 0

:debug_help
cls
echo 1. Open Settings ^> About phone ^> Software information.
echo 2. Tap Build number seven times.
echo 3. Open Developer options and enable USB debugging.
echo 4. Connect the phone and approve the authorization prompt.
pause
goto menu

:silence
cls
call :require_device || goto wait_menu
adb shell settings put system csc_pref_camera_forced_shuttersound_key 0
if errorlevel 1 (
  echo Failed to change the setting.
) else (
  echo The forced shutter-sound setting was disabled.
)
goto wait_menu

:restore
cls
call :require_device || goto wait_menu
adb shell settings put system csc_pref_camera_forced_shuttersound_key 1
if errorlevel 1 (
  echo Failed to restore the setting.
) else (
  echo The shutter-sound setting was restored.
)
goto wait_menu

:battery
cls
call :require_device || goto wait_menu
set "battery_log=%TEMP%\galaxy-assistant-%RANDOM%-%RANDOM%.txt"
adb shell dumpsys battery >"%battery_log%" 2>nul
if errorlevel 1 (
  echo Failed to read battery information.
  del /q "%battery_log%" >nul 2>&1
  goto wait_menu
)
set "level=N/A"
set "voltage=N/A"
set "health=N/A"
set "usage=N/A"
for /f "tokens=2 delims=:" %%A in ('findstr /r /c:"^[ ]*level:" "%battery_log%"') do set "level=%%A"
for /f "tokens=2 delims=:" %%A in ('findstr /r /c:"^[ ]*voltage:" "%battery_log%"') do set "voltage=%%A"
for /f "tokens=2 delims=:" %%A in ('findstr /c:"mSavedBatteryAsoc" "%battery_log%"') do set "health=%%A"
for /f "tokens=2 delims=:" %%A in ('findstr /c:"mSavedBatteryUsage" "%battery_log%"') do set "usage=%%A"
for %%V in (level voltage health usage) do for /f "tokens=*" %%A in ("!%%V!") do set "%%V=%%A"
set "voltage_text=%voltage% mV"
set "cycles=N/A"
set /a voltage_number=voltage 2>nul
if not errorlevel 1 (
  set /a voltage_whole=voltage_number / 1000, voltage_fraction=voltage_number %% 1000
  set "voltage_fraction=00!voltage_fraction!"
  set "voltage_text=!voltage_whole!.!voltage_fraction:~-3! V"
)
set /a usage_number=usage 2>nul
if not errorlevel 1 set /a cycles=usage_number / 100
echo Battery level: %level%%%
echo Battery voltage: %voltage_text%
echo Battery health: %health%%%
echo Estimated cycles: %cycles%
del /q "%battery_log%" >nul 2>&1
goto wait_menu

:install_camsung
cls
call :require_device || goto wait_menu
echo This installs Camsung 1.2.1 from its official GitHub release.
echo Source: https://github.com/ericswpark/camsung
echo.
choice /c YN /n /m "Continue? [Y/N]: "
if errorlevel 2 goto menu

set "camsung_version=1.2.1"
set "camsung_url=https://github.com/ericswpark/camsung/releases/download/1.2.1/app-release.apk"
set "camsung_sha256=C6E0087EE2E5AF899E3245902A21A788D8A6DDCEA137825B1E25C38871BE38F5"
set "camsung_apk=%TEMP%\camsung-1.2.1-%RANDOM%-%RANDOM%.apk"
set "download_sha="
echo Downloading the APK...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri $env:camsung_url -OutFile $env:camsung_apk"
if errorlevel 1 (
  echo Failed to download the APK.
  del /q "%camsung_apk%" >nul 2>&1
  goto wait_menu
)

for /f "usebackq delims=" %%H in (`powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -LiteralPath $env:camsung_apk).Hash"`) do set "download_sha=%%H"
if /i not "!download_sha!"=="!camsung_sha256!" (
  echo APK integrity verification failed. Installation was stopped.
  del /q "%camsung_apk%" >nul 2>&1
  goto wait_menu
)

set "android_sdk="
set "android_sdk_number=0"
for /f "delims=" %%A in ('adb shell getprop ro.build.version.sdk 2^>nul') do set "android_sdk=%%A"
echo Android SDK: !android_sdk!
if defined android_sdk (
  set /a android_sdk_number=android_sdk 2>nul
)
if !android_sdk_number! GEQ 34 (
  adb install --bypass-low-target-sdk-block -r "%camsung_apk%"
) else (
  adb install -r "%camsung_apk%"
)
set "install_result=!errorlevel!"
del /q "%camsung_apk%" >nul 2>&1
if not "!install_result!"=="0" (
  echo Failed to install Camsung.
) else (
  echo Camsung was installed successfully.
  echo Open the app and enable its switch. Tap the lock icon to reapply it after boot.
  echo Set the phone to Vibrate or Mute when using the silent-camera feature.
)
goto wait_menu

:wait_menu
echo.
pause
goto menu
