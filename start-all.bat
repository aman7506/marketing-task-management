@echo off
echo 🚀 Starting Marketing Form Application...
echo ===============================================

echo 🔄 Starting Backend API...
start "Backend API" cmd /k "cd backend && dotnet run"

timeout /t 5 /nobreak >nul

echo 🔄 Starting Frontend...
start "Frontend" cmd /k "cd frontend && npm start"

echo ===============================================
echo 🎉 Application started successfully!
echo 📱 Frontend: http://localhost:4200
echo 🔧 Backend API: http://localhost:5000
echo 📊 API Documentation: http://localhost:5000/swagger
echo ===============================================
echo Press any key to exit...
pause >nul
