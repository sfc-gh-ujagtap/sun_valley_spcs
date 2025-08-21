@echo off
REM Sun Valley React App Startup Script for Windows
REM This script starts both the Express backend server and React frontend development server

echo 🏔️  Starting Sun Valley React App Servers
echo ========================================

REM Check if we're in the right directory
if not exist "package.json" (
    echo ❌ Error: package.json not found. Please run this script from the sun-valley-react directory.
    pause
    exit /b 1
)

REM Check if node_modules exists
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    npm install
)

echo 🚀 Starting Express backend server on port 3002...
start "Backend Server" cmd /k "node server.js"

REM Wait a moment for backend to start
timeout /t 3 /nobreak >nul

echo 🚀 Starting React development server on port 3000...
start "Frontend Server" cmd /k "npm start"

echo.
echo 🎉 Both servers are starting!
echo    📱 Frontend: http://localhost:3000
echo    🔧 Backend:  http://localhost:3002
echo.
echo Press any key to close this window...
echo (The servers will continue running in separate windows)
pause >nul
