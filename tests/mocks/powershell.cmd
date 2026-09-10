@echo off

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
