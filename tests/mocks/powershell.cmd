@echo off

echo %* | findstr /c:"Invoke-RestMethod" >nul
if not errorlevel 1 (
  if defined MOCK_CAMSUNG_API_FAIL exit /b 1
  if defined MOCK_CAMSUNG_VERSION (
    set "mock_camsung_version=%MOCK_CAMSUNG_VERSION%"
  ) else (
    set "mock_camsung_version=1.2.1"
  )
  call echo %%mock_camsung_version%%;https://github.com/ericswpark/camsung/releases/download/%%mock_camsung_version%%/app-release.apk;C6E0087EE2E5AF899E3245902A21A788D8A6DDCEA137825B1E25C38871BE38F5
  exit /b 0
)

echo %* | findstr /c:"Invoke-WebRequest" >nul
if not errorlevel 1 (
  >"%camsung_apk%" echo mock apk
  exit /b 0
)

echo %* | findstr /c:"Get-FileHash" >nul
if not errorlevel 1 (
  if defined MOCK_HASH_MISMATCH (
    echo 0000000000000000000000000000000000000000000000000000000000000000
  ) else (
    echo %camsung_sha256%
  )
  exit /b 0
)

exit /b 1
