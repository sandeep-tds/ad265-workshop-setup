@echo off
setlocal enableextensions

REM ============================================================
REM  AD265 - npm packages installer
REM
REM  Installs required SAP MDK npm packages to C:\Software,
REM  then automatically launches the main setup script.
REM ============================================================

set "SETUP=%~dp0"

echo.
echo   AD265 - Installing npm packages
echo.

REM --- Check for npm ---
where npm >nul 2>&1
if errorlevel 1 (
  echo [ERROR] 'npm' was not found on PATH.
  echo.
  echo Please install Node.js from https://nodejs.org/ and try again.
  echo After installation, restart your terminal/command prompt.
  goto :fail
)

REM --- Create C:\Software if it doesn't exist ---
echo Installing SAP MDK npm packages to C:\Software...
if not exist "C:\Software" (
  mkdir "C:\Software"
  if errorlevel 1 (
    echo [ERROR] Could not create C:\Software directory.
    echo         You may need administrator rights or choose a different location.
    goto :fail
  )
)

REM --- Install the packages ---
npm install --prefix C:\Software @sap/mdk-tools @sap/mdk-mcp-server @sap/generator-mdk
if errorlevel 1 (
  echo.
  echo [ERROR] npm install failed.
  echo.
  echo Possible reasons:
  echo   - Network connection issues
  echo   - SAP npm registry not configured
  echo   - Authentication required
  echo.
  echo Please check your npm configuration and try again.
  goto :fail
)

echo.
echo   npm packages installed successfully!
echo.
echo   Now launching the main setup script...
echo.
timeout /t 2 /nobreak >nul

REM --- Launch the main setup script ---
if exist "%SETUP%setup-ad265.bat" (
  call "%SETUP%setup-ad265.bat"
  exit /b %ERRORLEVEL%
) else (
  echo [ERROR] Main setup script not found: %SETUP%setup-ad265.bat
  goto :fail
)

:fail
echo.
echo   npm package installation did NOT complete.
echo.
pause
endlocal
exit /b 1
