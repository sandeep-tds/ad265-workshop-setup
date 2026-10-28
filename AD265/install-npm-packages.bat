@echo off
setlocal enableextensions enabledelayedexpansion

REM ============================================================
REM  AD265 - npm packages installer
REM
REM  Installs required SAP MDK npm packages to C:\Software,
REM  then automatically launches the main setup script.
REM ============================================================

set "SETUP=%~dp0"
set "LOGFILE=%SETUP%install-log.txt"

echo. > "%LOGFILE%"
echo Installation started at %DATE% %TIME% >> "%LOGFILE%"
echo Setup directory: %SETUP% >> "%LOGFILE%"
echo. >> "%LOGFILE%"

echo.
echo   AD265 - Installing npm packages
echo   ================================
echo.
echo   Setup directory: %SETUP%
echo   Log file: %LOGFILE%
echo.
echo Press any key to start installation...
pause >nul
echo.

REM --- Check for npm ---
echo [1/3] Checking for npm...
echo [1/3] Checking for npm... >> "%LOGFILE%"
where npm >nul 2>&1
if errorlevel 1 (
  echo [ERROR] 'npm' was not found on PATH. >> "%LOGFILE%"
  echo [ERROR] 'npm' was not found on PATH.
  echo.
  echo Please install Node.js from https://nodejs.org/ and try again.
  echo After installation, restart your terminal/command prompt.
  goto :fail
)
echo       npm found: OK
echo       npm found: OK >> "%LOGFILE%"
echo.

REM --- Create C:\Software if it doesn't exist ---
echo [2/3] Preparing installation directory...
if not exist "C:\Software" (
  echo       Creating C:\Software...
  mkdir "C:\Software"
  if errorlevel 1 (
    echo [ERROR] Could not create C:\Software directory.
    echo         You may need administrator rights or choose a different location.
    goto :fail
  )
  echo       Directory created: OK
) else (
  echo       C:\Software already exists: OK
)
echo.

REM --- Install the packages ---
echo [3/3] Installing SAP MDK npm packages to C:\Software...
echo       This may take a few minutes...
echo.
echo Running: npm install --prefix C:\Software @sap/mdk-tools @sap/mdk-mcp-server @sap/generator-mdk
echo Running: npm install --prefix C:\Software @sap/mdk-tools @sap/mdk-mcp-server @sap/generator-mdk >> "%LOGFILE%"
echo.
call npm install --prefix C:\Software @sap/mdk-tools @sap/mdk-mcp-server @sap/generator-mdk >> "%LOGFILE%" 2>&1
set NPM_EXIT_CODE=!ERRORLEVEL!
echo.
echo npm completed with exit code: !NPM_EXIT_CODE!
echo npm completed with exit code: !NPM_EXIT_CODE! >> "%LOGFILE%"
echo.
if !NPM_EXIT_CODE! neq 0 (
  echo.
  echo [ERROR] npm install failed with exit code !NPM_EXIT_CODE!
  echo.
  echo Possible reasons:
  echo   - Network connection issues
  echo   - SAP npm registry not configured
  echo   - Authentication required
  echo   - Packages not accessible
  echo.
  echo Please check your npm configuration and try again.
  echo.
  goto :fail
)

echo.
echo   ================================
echo   npm packages installed successfully!
echo   ================================
echo.
echo   Now launching the main setup script...
echo.

REM --- Launch the main setup script ---
echo Checking for main setup script...
if not exist "%SETUP%setup-ad265.bat" (
  echo [ERROR] Main setup script not found: %SETUP%setup-ad265.bat
  echo         Expected location: %SETUP%
  echo.
  goto :fail
)
echo Found: %SETUP%setup-ad265.bat
echo Launching setup-ad265.bat in 2 seconds...
echo.
timeout /t 2 /nobreak >nul

call "%SETUP%setup-ad265.bat"
set SETUP_EXIT_CODE=!ERRORLEVEL!
echo.
echo Main setup script completed with exit code !SETUP_EXIT_CODE!
if !SETUP_EXIT_CODE! neq 0 (
  echo.
  echo [WARNING] Setup script returned error code !SETUP_EXIT_CODE!
  pause
)
endlocal
exit /b !SETUP_EXIT_CODE!

:fail
echo.
echo   ================================
echo   Setup did NOT complete.
echo   ================================
echo.
echo   Check the log file for details: %LOGFILE%
echo.
echo Installation failed at %DATE% %TIME% >> "%LOGFILE%"
pause
endlocal
exit /b 1
