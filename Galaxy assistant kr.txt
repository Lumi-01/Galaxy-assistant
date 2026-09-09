@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title Galaxy Assistant

call :require_adb || exit /b 1

:menu
cls
echo ================================================================
echo Galaxy Assistant
echo ================================================================
echo 1. USB 디버깅 활성화 방법
echo 2. 카메라 셔터음 설정 비활성화
echo 3. 카메라 셔터음 설정 복원
echo 4. 배터리 정보 확인
echo 5. 종료
echo.
set "choice="
set /p "choice=메뉴 번호를 입력하세요: "
if "%choice%"=="1" goto debug_help
if "%choice%"=="2" goto silence
if "%choice%"=="3" goto restore
if "%choice%"=="4" goto battery
if "%choice%"=="5" exit /b 0
goto menu

:require_adb
where adb >nul 2>&1
if errorlevel 1 (
  echo ADB를 찾지 못했습니다. Android Platform Tools를 설치하거나 adb.exe를 이 파일과 같은 폴더에 넣으세요.
  pause
  exit /b 1
)
exit /b 0

:require_device
adb get-state 2>nul | findstr /x /c:"device" >nul
if errorlevel 1 (
  echo 승인된 기기를 찾지 못했습니다. USB 연결을 확인하고 휴대전화에서 디버깅을 허용하세요.
  exit /b 1
)
exit /b 0

:debug_help
cls
echo 1. 설정 ^> 휴대전화 정보 ^> 소프트웨어 정보를 엽니다.
echo 2. 빌드번호를 7번 누릅니다.
echo 3. 개발자 옵션에서 USB 디버깅을 켭니다.
echo 4. 휴대전화를 연결하고 디버깅 허용 창을 승인합니다.
pause
goto menu

:silence
cls
call :require_device || goto wait_menu
adb shell settings put system csc_pref_camera_forced_shuttersound_key 0
if errorlevel 1 (
  echo 설정 변경에 실패했습니다.
) else (
  echo 카메라 셔터음 강제 설정을 비활성화했습니다.
)
goto wait_menu

:restore
cls
call :require_device || goto wait_menu
adb shell settings put system csc_pref_camera_forced_shuttersound_key 1
if errorlevel 1 (
  echo 설정 복원에 실패했습니다.
) else (
  echo 카메라 셔터음 설정을 복원했습니다.
)
goto wait_menu

:battery
cls
call :require_device || goto wait_menu
set "battery_log=%TEMP%\galaxy-assistant-%RANDOM%-%RANDOM%.txt"
adb shell dumpsys battery >"%battery_log%" 2>nul
if errorlevel 1 (
  echo 배터리 정보를 불러오지 못했습니다.
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
echo 배터리 잔량: %level%%%
echo 배터리 전압: %voltage_text%
echo 배터리 수명: %health%%%
echo 예상 사이클: %cycles%회
del /q "%battery_log%" >nul 2>&1
goto wait_menu

:wait_menu
echo.
pause
goto menu
