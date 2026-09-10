@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title Galaxy Assistant

call :require_adb || exit /b 1

if /i "%~1"=="--install-camsung" (
  set "non_interactive=1"
  set "assume_yes=1"
  goto install_camsung
)

:menu
cls
echo ================================================================
echo Galaxy Assistant
echo ================================================================
echo 1. USB 디버깅 활성화 방법
echo 2. 카메라 셔터음 설정 비활성화
echo 3. 카메라 셔터음 설정 복원
echo 4. 배터리 정보 확인
echo 5. Camsung 설치
echo 6. 종료
echo.
set "choice="
set /p "choice=메뉴 번호를 입력하세요: "
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

:install_camsung
cls
set "action_result=1"
call :require_device || goto install_camsung_done
echo Camsung 1.2.1을 공식 GitHub 릴리스에서 내려받아 설치합니다.
echo 출처: https://github.com/ericswpark/camsung
echo.
if not defined assume_yes (
  choice /c YN /n /m "계속하시겠습니까? [Y/N]: "
  if errorlevel 2 (
    set "action_result=2"
    goto install_camsung_done
  )
)

set "camsung_version=1.2.1"
set "camsung_url=https://github.com/ericswpark/camsung/releases/download/1.2.1/app-release.apk"
set "camsung_sha256=C6E0087EE2E5AF899E3245902A21A788D8A6DDCEA137825B1E25C38871BE38F5"
set "camsung_apk=%TEMP%\camsung-1.2.1-%RANDOM%-%RANDOM%.apk"
set "download_sha="
echo APK를 내려받는 중입니다...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri $env:camsung_url -OutFile $env:camsung_apk"
if errorlevel 1 (
  echo APK 다운로드에 실패했습니다.
  del /q "%camsung_apk%" >nul 2>&1
  goto install_camsung_done
)

for /f "usebackq delims=" %%H in (`powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -LiteralPath $env:camsung_apk).Hash"`) do set "download_sha=%%H"
if /i not "!download_sha!"=="!camsung_sha256!" (
  echo APK 무결성 검증에 실패하여 설치를 중단했습니다.
  del /q "%camsung_apk%" >nul 2>&1
  goto install_camsung_done
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
  echo Camsung 설치에 실패했습니다.
  set "action_result=!install_result!"
) else (
  echo Camsung 설치가 완료되었습니다.
  echo 휴대전화에서 앱을 열고 스위치를 켜세요. 부팅 시 자동 적용은 잠금 아이콘을 누르세요.
  echo 카메라 무음 기능을 사용할 때는 휴대전화를 진동 또는 무음 모드로 설정하세요.
  set "action_result=0"
)

:install_camsung_done
if defined non_interactive exit /b !action_result!
goto wait_menu

:wait_menu
echo.
pause
goto menu
