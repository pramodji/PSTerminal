@echo off
REM PSWeb Frontend Startup Script
REM This script automatically sets up and runs the frontend development server

echo ================================================================================
echo PSWeb Frontend - Automated Startup
echo ================================================================================
echo.

cd /d "%~dp0frontend"

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is not installed or not in PATH
    echo Please install Node.js 18+ from https://nodejs.org/
    pause
    exit /b 1
)

echo [OK] Node.js found
node --version

REM Check if npm is installed
npm --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] npm is not installed or not in PATH
    pause
    exit /b 1
)

echo [OK] npm found
npm --version

REM Check if node_modules exists
if not exist "node_modules\" (
    echo.
    echo [ERROR] node_modules folder not found
    echo Please ensure the complete project folder with dependencies is copied
    echo or run 'npm install' manually in the frontend directory
    pause
    exit /b 1
) else (
    echo [OK] Dependencies found
)

REM Create .env.local if it doesn't exist
if not exist ".env.local" (
    echo.
    echo [SETUP] Creating .env.local file...
    echo REACT_APP_BACKEND_URL=http://localhost:8000 > .env.local
    echo [OK] .env.local file created
)

REM Start the development server
echo.
echo ================================================================================
echo Starting Frontend Development Server
echo The application will open at http://localhost:3000
echo Press Ctrl+C to stop the server
echo ================================================================================
echo.

npm start
if errorlevel 1 (
    echo.
    echo [ERROR] Frontend server failed to start
    echo Check the error messages above
    pause
    exit /b 1
)

echo.
echo [INFO] Frontend server stopped
pause
