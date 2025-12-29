@echo off
echo ========================================
echo Starting Frontend Server on LAN IP
echo ========================================
echo.

cd /d "%~dp0frontend"

echo Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo Error: Node.js is not installed or not in PATH
    pause
    exit /b 1
)

echo Checking Angular CLI...
ng version >nul 2>&1
if errorlevel 1 (
    echo Angular CLI not found globally. Checking local installation...
    if exist "node_modules\.bin\ng.cmd" (
        set NG_CMD=.\node_modules\.bin\ng.cmd
    ) else (
        echo Installing Angular CLI locally...
        call npm install @angular/cli --save-dev
        set NG_CMD=.\node_modules\.bin\ng.cmd
    )
) else (
    set NG_CMD=ng
)

if not exist "node_modules" (
    echo.
    echo Installing dependencies...
    call npm install
)

echo.
echo Starting frontend server on port 1010...
echo Frontend will be accessible at:
echo   - http://localhost:1010
echo   - http://172.1.3.201:1010
echo   - http://[YourLANIP]:1010
echo.
echo API Backend: http://172.1.3.201:5000
echo SignalR Hub: http://172.1.3.201:5000/notificationHub
echo.
echo Press Ctrl+C to stop the server
echo.

%NG_CMD% serve --port 1010 --host 0.0.0.0 --open

pause

