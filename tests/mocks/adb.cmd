@echo off

if /i "%~1"=="get-state" (
  if /i "%MOCK_DEVICE_STATE%"=="missing" exit /b 1
  echo device
  exit /b 0
)

if /i "%~1"=="shell" (
  if /i "%~2"=="getprop" (
    if defined MOCK_ANDROID_SDK (
      echo %MOCK_ANDROID_SDK%
    ) else (
      echo 35
    )
  )
  exit /b 0
)

if /i "%~1"=="install" (
  if defined MOCK_ADB_LOG echo %*>"%MOCK_ADB_LOG%"
  if defined MOCK_INSTALL_EXIT exit /b %MOCK_INSTALL_EXIT%
  exit /b 0
)

exit /b 0
