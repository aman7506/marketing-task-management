@echo off
echo ========================================
echo Starting Backend Server on LAN IP
echo ========================================
echo.

cd /d "%~dp0backend"

echo Cleaning project...
call dotnet clean

echo.
echo Restoring dependencies...
call dotnet restore

echo.
echo Building project...
call dotnet build --configuration Release

if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Starting backend server on http://0.0.0.0:5000...
echo Backend will be accessible at:
echo   - http://localhost:5000
echo   - http://172.1.3.201:5000
echo   - http://[YourLANIP]:5000
echo.
echo Swagger UI: http://172.1.3.201:5000/swagger
echo.
echo Press Ctrl+C to stop the server
echo.

dotnet run --urls "http://0.0.0.0:5000"

pause

