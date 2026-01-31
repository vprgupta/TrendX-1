@echo off
echo 🚀 Starting TrendX Backend...
echo.

echo 📦 Installing dependencies...
call npm install

echo.
echo 🔧 Starting server...
start "TrendX Backend" cmd /k "npm run dev"

echo.
echo ⏳ Waiting for server to start...
timeout /t 5 /nobreak > nul

echo.
echo 🌱 Adding sample data...
node add-sample-data.js

echo.
echo 📊 Opening dashboard...
start admin-dashboard.html

echo.
echo ✅ TrendX Backend is ready!
echo 📍 Backend: http://localhost:3000
echo 📊 Dashboard: admin-dashboard.html
echo.
pause