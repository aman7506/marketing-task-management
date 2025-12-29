@echo off
echo Restarting Frontend with Clean Configuration...

REM Kill any existing Node processes
echo Stopping existing frontend processes...
taskkill /f /im node.exe >nul 2>&1

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Change to frontend directory
cd frontend

REM Install any missing dependencies
echo Checking dependencies...
npm install --silent

REM Start with clean configuration
echo Starting frontend with clean configuration...
echo This should eliminate the deprecation warnings.

REM Start the frontend
npm start

REM Return to parent directory
cd ..
