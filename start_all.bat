@echo off
echo ========================================
echo    Marketing Form - Complete Setup
echo ========================================
echo.

echo Starting Backend Server...
start "Backend Server" cmd /k "cd /d E:\Marketing Form\backend && dotnet run --project MarketingTaskAPI.csproj"

echo.
echo Waiting 5 seconds for backend to start...
timeout /t 5 /nobreak > nul

echo.
echo Starting Frontend Server...
start "Frontend Server" cmd /k "cd /d E:\Marketing Form\frontend && npm start"

echo.
echo ========================================
echo    Both servers are starting...
echo ========================================
echo.
echo Backend:  http://localhost:5000
echo Frontend: http://localhost:4200
echo Test API: E:\Marketing Form\test_api.html
echo.
echo Press any key to exit...
pause > nul
