@echo off
echo 🚀 Starting TrendX Backend (Simple Version)...
echo.

echo 📦 Installing dependencies...
call npm install

echo.
echo 🔧 Starting simple server (no MongoDB required)...
start "TrendX Backend" cmd /k "node simple-server.js"

echo.
echo ⏳ Waiting for server to start...
timeout /t 3 /nobreak > nul

echo.
echo 📊 Opening login page...
start http://localhost:3000/login.html

echo.
echo ✅ TrendX is ready!
echo.
echo 🔗 Available URLs:
echo   📝 Signup: http://localhost:3000/signup.html
echo   🔐 Login:  http://localhost:3000/login.html
echo   📊 Dashboard: http://localhost:3000/modern-admin-dashboard.html
echo   ❤️  Health: http://localhost:3000/health
echo.
echo 👤 Test Account (auto-created):
echo   Email: admin@trendx.com
echo   Password: admin123
echo.
pause