@echo off
REM Shim launcher for Windows: attempts to run installed cookie script via bash if available
set "INSTALL_DIR=%LOCALAPPDATA%\cookie-monster"
if exist "%INSTALL_DIR%\cookie" (
  where bash >nul 2>nul && bash "%INSTALL_DIR%/cookie" %* || (
    echo To run the native cookie CLI on Windows you need a POSIX shell (Git Bash or WSL).
    echo Alternatively, use the PowerShell profile install.ps1 to get full integration.
  )
) else (
  echo Cookie not installed. Run platforms\windows\install.bat to install.
)
