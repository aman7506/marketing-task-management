@echo off
REM Start backend in minimized window
start /min cmd /k "cd /d c:\Marketing Form\backend && dotnet run"

REM Wait 5 seconds for backend to start
timeout /t 5 /nobreak

REM Start frontend in minimized window
start /min cmd /k "cd /d c:\Marketing Form\frontend && npm start"

echo Marketing Task Application started!
echo Backend: http://localhost:5005
echo Frontend: http://localhost:4200
echo.
echo Check the minimized windows if needed.
timeout /t 10
