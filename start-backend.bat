@echo off
REM PSWeb Backend Startup Script
REM This script automatically sets up and runs the backend server

echo ================================================================================
echo PSWeb Backend Server - Automated Startup
echo ================================================================================
echo.

cd /d "%~dp0backend"

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.10+ from https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [OK] Python found
python --version

REM Check if virtual environment exists
if not exist ".venv\" (
    echo.
    echo [SETUP] Creating virtual environment...
    python -m venv .venv
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment
        pause
        exit /b 1
    )
    echo [OK] Virtual environment created
)

REM Activate virtual environment and install dependencies
echo.
echo [SETUP] Installing/updating dependencies...
call .venv\Scripts\activate.bat
pip install --upgrade pip >nul 2>&1
pip install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)

echo [OK] Dependencies installed

REM Create .env if it doesn't exist
if not exist ".env" (
    echo.
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

REM Start the server
echo.
echo ================================================================================
echo Starting Backend Server on http://localhost:8000
echo Press Ctrl+C to stop the server
echo ================================================================================
echo.

python server.py
if errorlevel 1 (
    echo.
    echo [ERROR] Backend server failed to start
    echo Check the error messages above
    pause
    exit /b 1
)

echo.
echo [INFO] Backend server stopped
pause
