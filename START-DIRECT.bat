@echo off
REM PSWeb Application Launcher - Direct Version
REM This script starts both backend and frontend servers directly

echo ================================================================================
echo PSWeb - PowerShell Script Executor - DIRECT STARTUP
echo ================================================================================
echo.

REM Kill any existing processes on ports 8000 and 3000
echo [INFO] Checking for existing processes...
for /f "tokens=5" %%i in ('netstat -ano ^| findstr :8000 2^>nul') do (
    echo Killing process %%i on port 8000
    taskkill /F /PID %%i >nul 2>&1
)
for /f "tokens=5" %%i in ('netstat -ano ^| findstr :3000 2^>nul') do (
    echo Killing process %%i on port 3000
    taskkill /F /PID %%i >nul 2>&1
)

echo.
echo ================================================================================
echo STARTING BACKEND SERVER
echo ================================================================================
echo.

REM Change to backend directory
cd /d "%~dp0backend"

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.10+ from https://www.python.org/downloads/
    pause
    exit /b 1
)
echo [OK] Python found: 
python --version

REM Check if virtual environment exists
if not exist ".venv\" (
    echo [ERROR] Virtual environment not found
    echo Please run CREATE-PACKAGE.bat first to set up the environment
    pause
    exit /b 1
)
echo [OK] Virtual environment found

REM Check if .env exists
if not exist ".env" (
    echo [SETUP] Creating default .env file...
    (
        echo MONGO_URL=mongodb://localhost:27017
        echo DB_NAME=psweb
        echo CORS_ORIGINS=*
        echo HOST=0.0.0.0
        echo PORT=8000
        echo RELOAD=false
    ) > .env
    echo [OK] .env file created
)

REM Start backend in background using START command
echo.
echo [INFO] Starting backend server in new window...
start "PSWeb Backend - DO NOT CLOSE" /MIN cmd /k "call .venv\Scripts\activate.bat && python server.py"

REM Wait for backend to start
echo [INFO] Waiting for backend to start...
timeout /t 8 /nobreak >nul

REM Check if backend is running
:check_backend
netstat -ano | findstr :8000 >nul
if errorlevel 1 (
    echo [WARNING] Backend not detected yet, waiting 2 more seconds...
    timeout /t 2 /nobreak >nul
    netstat -ano | findstr :8000 >nul
    if errorlevel 1 (
        echo [ERROR] Backend failed to start on port 8000
        echo Check the "PSWeb Backend - DO NOT CLOSE" window for errors
        pause
        exit /b 1
    )
)
echo [OK] Backend is running on http://localhost:8000

REM Change to frontend directory
cd /d "%~dp0frontend"

echo.
echo ================================================================================
echo STARTING FRONTEND SERVER
echo ================================================================================
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is not installed or not in PATH
    echo Please install Node.js 18+ from https://nodejs.org/
    pause
    exit /b 1
)
echo [OK] Node.js found:
node --version

REM Check if node_modules exists
if not exist "node_modules\" (
    echo [ERROR] node_modules folder not found
    echo Please run CREATE-PACKAGE.bat first to install dependencies
    pause
    exit /b 1
)
echo [OK] Frontend dependencies found

REM Create .env.local if it doesn't exist
if not exist ".env.local" (
    echo [SETUP] Creating .env.local file...
    echo REACT_APP_BACKEND_URL=http://localhost:8000 > .env.local
    echo [OK] .env.local file created
)

REM Start frontend server in background
echo.
echo [INFO] Starting frontend server in new window...
start "PSWeb Frontend - DO NOT CLOSE" /MIN cmd /k "npm start"

REM Wait for frontend to start
echo [INFO] Waiting for frontend to start...
timeout /t 10 /nobreak >nul

echo.
echo ================================================================================
echo APPLICATION READY!
echo ================================================================================
echo.
echo Backend Server: http://localhost:8000
echo Frontend App:   http://localhost:3000
echo.
echo Both servers are running in separate minimized windows.
echo The frontend should automatically open in your browser.
echo.
echo To stop the application:
echo - Close the "PSWeb Backend - DO NOT CLOSE" window
echo - Close the "PSWeb Frontend - DO NOT CLOSE" window
echo.
echo ================================================================================

REM Try to open the application in the default browser
timeout /t 3 /nobreak >nul
start http://localhost:3000

echo.
echo Press any key to exit this launcher (servers will continue running)...
pause >nul
