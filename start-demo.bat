@echo off
title Madadgaar Backend
cd /d "%~dp0"

where node >nul 2>nul
if not errorlevel 1 goto have_node
if exist "%ProgramFiles%\nodejs\node.exe" goto add_node_path

echo.
echo  Node.js is not installed. Installing it now (needs internet)...
echo  If Windows asks "Do you want to allow this app to make changes", click YES.
echo.
where winget >nul 2>nul
if errorlevel 1 goto manual_node
winget install --id OpenJS.NodeJS.LTS -e --silent --accept-package-agreements --accept-source-agreements
if not exist "%ProgramFiles%\nodejs\node.exe" goto manual_node

:add_node_path
set "PATH=%ProgramFiles%\nodejs;%PATH%"

:have_node
if exist "backend\local-server\node_modules" goto launch
echo Installing backend parts for the first time, please wait...
pushd backend\local-server
call npm install
popd
if not exist "backend\local-server\node_modules" (
  echo.
  echo  Install failed. Check your internet connection and try again.
  pause
  exit /b 1
)

:launch
start "Madadgaar Apps" cmd /k node "%~dp0demo-web\serve-apps.js"
ping -n 4 127.0.0.1 >nul
start "" http://localhost:5173
start "" http://localhost:5174
start "" http://localhost:5175

echo.
echo ============================================================
echo   MADADGAAR IS RUNNING
echo.
echo   On this laptop (opened in your browser):
echo        Customer app     http://localhost:5173
echo        Helper app       http://localhost:5174
echo        Admin dashboard  http://localhost:5175
echo.
echo   Laptop address for the PHONE APPS (pick the one that
echo   matches your hotspot):
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do for /f "tokens=*" %%b in ("%%a") do echo        http://%%b:4000
echo.
echo   Test from a phone's Chrome:  http://ADDRESS:4000/api/health
echo.
echo   KEEP BOTH WINDOWS OPEN during the demo.
echo   If Windows asks about the firewall, tick both boxes and Allow.
echo ============================================================
echo.
cd backend\local-server
node src\server.js
pause
exit /b 0

:manual_node
echo.
echo  Could not install Node.js automatically.
echo  Opening the download page: click the big LTS button, install it,
echo  then double-click start-demo.bat again.
start "" https://nodejs.org
pause
exit /b 1
