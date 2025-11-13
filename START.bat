@echo off
REM PSWeb Application Launcher
REM This script starts both backend and frontend servers

echo ================================================================================
echo PSWeb - PowerShell Script Executor
echo ================================================================================
echo.
echo Starting application servers...
echo.
echo Backend will run on: http://localhost:8000
echo Frontend will run on: http://localhost:3000
echo.
echo ================================================================================
echo.

REM Kill any existing processes on ports 8000 and 3000
echo [INFO] Checking for existing processes...
for /f "tokens=5" %%i in ('netstat -ano ^| findstr :8000') do taskkill /F /PID %%i >nul 2>&1
for /f "tokens=5" %%i in ('netstat -ano ^| findstr :3000') do taskkill /F /PID %%i >nul 2>&1

REM Start backend in new window with proper error handling
start "PSWeb Backend Server" /D "%~dp0" cmd /c "start-backend.bat"

REM Wait 5 seconds for backend to start
echo [INFO] Waiting for backend to start...
timeout /t 5 /nobreak >nul

REM Check if backend is running
netstat -ano | findstr :8000 >nul
if errorlevel 1 (
    echo [ERROR] Backend failed to start on port 8000
    echo Check the "PSWeb Backend Server" window for error details
    pause
    exit /b 1
)
echo [OK] Backend is running on port 8000

REM Start frontend in new window
start "PSWeb Frontend Server" /D "%~dp0" cmd /c "start-frontend.bat"

echo.
echo [OK] Application servers are starting in separate windows
echo.
echo Backend: Check "PSWeb Backend Server" window
echo Frontend: Check "PSWeb Frontend Server" window
echo.
echo The application will automatically open in your browser at:
echo http://localhost:3000
echo.
echo To stop the servers, close both terminal windows or press Ctrl+C in each.
echo.

pause
