@echo off
setlocal enableextensions

REM ============================================================
REM  AD265 - One-click workshop setup (Windows)
REM
REM  IMPORTANT: run from Windows Explorer (double-click) or a Desktop
REM  shortcut - NOT from the VS Code integrated terminal, because this
REM  script closes and reopens VS Code (that would kill its own terminal).
REM
REM  What it does:
REM    1. Clones MDKApp (which ships the Cline coach harness) to the Desktop.
REM    2. Installs the Cline config (SAP AI Core + mdk-mcp) into the user
REM       profile, then restarts VS Code on the project.
REM
REM  git and VS Code are validated up front, so a missing tool fails before
REM  any config is touched. No administrator rights are required. On failure
REM  it pauses so the error stays readable.
REM ============================================================

set "SETUP=%~dp0"
set "CLINE_SRC=%SETUP%cline\data"
set "MDK_URL=https://github.com/jitendrakansal/MDKApp.git"
set "PROJECT=%USERPROFILE%\Desktop\MDKApp"
set "CLINE_DEST=%USERPROFILE%\.cline\data"
set "CLINE_BAK=%USERPROFILE%\.cline\data.bak"
set "CODEEXE="
set "CODECLI="
set "_BACKED_UP="

echo.
echo   AD265 - workshop setup
echo   Setup   : %SETUP%
echo   Project : %PROJECT%
echo.

REM --- 0. Verify the Cline config template ships next to this script ---
if not exist "%CLINE_SRC%" (
  echo [ERROR] Cline config template not found:
  echo         %CLINE_SRC%
  echo         Run this script from the setup\ folder of the 2026TechEd repo.
  goto :fail
)

REM --- 1. Clone the MDKApp project (ships the coach harness) ---
where git >nul 2>&1
if errorlevel 1 (
  echo [ERROR] 'git' was not found on PATH. Install Git or open a shell that has it.
  goto :fail
)
if exist "%PROJECT%\.git" (
  echo MDKApp already present - using the existing clone; your work is kept.
  goto :cloned
)
echo Cloning MDKApp...
git clone "%MDK_URL%" "%PROJECT%"
if errorlevel 1 (
  echo [ERROR] Clone failed. If %PROJECT% already exists, remove or rename it;
  echo         otherwise check your network and that the folder is writable.
  goto :fail
)
:cloned

REM --- 2. Resolve VS Code up front, so a missing install fails BEFORE any
REM        config is backed up or replaced (leaving the user's config intact).
if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe" set "CODEEXE=%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe"
if not defined CODEEXE if exist "%ProgramFiles%\Microsoft VS Code\Code.exe" set "CODEEXE=%ProgramFiles%\Microsoft VS Code\Code.exe"
if not defined CODEEXE if exist "%ProgramFiles(x86)%\Microsoft VS Code\Code.exe" set "CODEEXE=%ProgramFiles(x86)%\Microsoft VS Code\Code.exe"
where code >nul 2>&1
if not errorlevel 1 set "CODECLI=1"
if defined CODEEXE goto :vscode_ok
if defined CODECLI goto :vscode_ok
echo [ERROR] VS Code was not found. Install it or add the 'code' command to PATH.
goto :fail
:vscode_ok

REM --- 3a. Back up any existing Cline config (single rolling backup) ---
if not exist "%CLINE_DEST%" goto :backup_done
echo Backing up existing Cline config to %CLINE_BAK% ...
if exist "%CLINE_BAK%" rmdir /S /Q "%CLINE_BAK%"
if exist "%CLINE_BAK%" echo [ERROR] Previous backup could not be removed; your config is unchanged.
if exist "%CLINE_BAK%" goto :fail
xcopy "%CLINE_DEST%" "%CLINE_BAK%\" /E /I /H /Y >nul
if errorlevel 1 echo [ERROR] Backup failed. Aborting so nothing is lost.
if errorlevel 1 goto :fail
set "_BACKED_UP=1"
:backup_done

REM --- 3b. Close VS Code so it cannot rewrite the config on exit ---
tasklist /FI "IMAGENAME eq Code.exe" 2>nul | find /I "Code.exe" >nul
if errorlevel 1 goto :vscode_closed
echo Closing VS Code...
taskkill /IM Code.exe /F >nul 2>&1
set /a _tries=0
:vscode_wait
tasklist /FI "IMAGENAME eq Code.exe" 2>nul | find /I "Code.exe" >nul
if errorlevel 1 goto :vscode_closed
set /a _tries+=1
if %_tries% geq 15 (
  echo [ERROR] VS Code could not be closed; Cline configuration was not installed.
  echo         Close VS Code manually and run setup again.
  goto :fail
)
timeout /t 1 /nobreak >nul
goto :vscode_wait
:vscode_closed

REM --- 3c. Install the Cline config (replace entirely; backup taken above) ---
echo Installing Cline config ...
if exist "%CLINE_DEST%" rmdir /S /Q "%CLINE_DEST%"
if exist "%CLINE_DEST%" echo [ERROR] Existing Cline config could not be removed (a file may be in use).
if exist "%CLINE_DEST%" goto :install_failed
mkdir "%CLINE_DEST%" 2>nul
if not exist "%CLINE_DEST%" echo [ERROR] Could not create the Cline config directory.
if not exist "%CLINE_DEST%" goto :install_failed
xcopy "%CLINE_SRC%" "%CLINE_DEST%\" /E /I /H /Y >nul
if errorlevel 1 echo [ERROR] Installing the Cline config failed.
if errorlevel 1 goto :install_failed
goto :config_done
:install_failed
if exist "%CLINE_DEST%" rmdir /S /Q "%CLINE_DEST%"
if defined _BACKED_UP echo Restoring your previous config...
if defined _BACKED_UP xcopy "%CLINE_BAK%" "%CLINE_DEST%\" /E /I /H /Y >nul
goto :fail
:config_done

REM --- 3d. Reopen VS Code on the MDKApp project (resolved in step 2) ---
echo Starting VS Code on MDKApp...
if defined CODEEXE (
  start "" "%CODEEXE%" "%PROJECT%"
  goto :launched
)
start "" /min cmd /c code "%PROJECT%"
:launched

echo.
echo   Done. VS Code is opening on your MDKApp project with Cline ready.
echo   The AD265 coach rules ship with the project.
echo.
echo   When prompted, trust the workspace so the MDK editor and Cline work.
echo.
endlocal
exit /b 0

:fail
echo.
echo   Setup did NOT complete. See the messages above.
echo.
pause
endlocal
exit /b 1
