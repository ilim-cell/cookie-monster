@echo off
REM Simple Windows installer using curl and tar (no PowerShell required)
setlocal enabledelayedexpansion

:: Default locations
set "LOCALAPPDATA_DIR=%LOCALAPPDATA%"
if "%LOCALAPPDATA_DIR%"=="" set "LOCALAPPDATA_DIR=%USERPROFILE%\AppData\Local"
set "INSTALL_DIR=%LOCALAPPDATA_DIR%\cookie-monster"
set "TMP_ZIP=%TEMP%\cookie-monster.zip"

:download
echo Downloading latest release...
curl -L -o "%TMP_ZIP%" "https://github.com/ilim-cell/cookie-monster/releases/latest/download/cookie-monster.zip" 2>nul
if errorlevel 1 (
  echo curl not available or failed; attempting PowerShell fallback...
  powershell -NoProfile -Command "try { Invoke-WebRequest -Uri 'https://github.com/ilim-cell/cookie-monster/releases/latest/download/cookie-monster.zip' -OutFile '%TMP_ZIP%'; exit 0 } catch { exit 1 }"
  if errorlevel 1 (
    echo Failed to download release. Ensure curl or PowerShell is available.
    exit /b 1
  )
)

:extract
echo Extracting to %INSTALL_DIR%...
mkdir "%INSTALL_DIR%" 2>nul
tar -xf "%TMP_ZIP%" -C "%INSTALL_DIR%" 2>nul
if errorlevel 1 (
  echo tar extraction failed or tar not available; attempting PowerShell Expand-Archive fallback...
  powershell -NoProfile -Command "try { Expand-Archive -LiteralPath '%TMP_ZIP%' -DestinationPath '%INSTALL_DIR%' -Force; exit 0 } catch { exit 1 }"
  if errorlevel 1 (
    echo Failed to extract archive. Ensure tar, Expand-Archive (PowerShell) or unzip is available.
    exit /b 1
  )
)

:shim
echo Creating shim in %%USERPROFILE%%\bin if present...
if not exist "%USERPROFILE%\bin" mkdir "%USERPROFILE%\bin" 2>nul
copy /Y "%INSTALL_DIR%\cookie" "%USERPROFILE%\bin\cookie" >nul 2>nul || (
  echo Could not copy shim; you may need to add %INSTALL_DIR% to your PATH manually.
)
echo Installed to %INSTALL_DIR%
echo If you want to run the native shell script on Windows, install a POSIX shell (Git Bash or WSL) or use the shipped PowerShell fragment.
endlocal
exit /b 0
