@echo off
REM PSWeb Portable Deployment Package Creator
REM This script prepares a portable deployment package

echo ================================================================================
echo PSWeb - Creating Portable Deployment Package
echo ================================================================================
echo.

REM Check if running from project root
if not exist "backend\" (
    echo [ERROR] Please run this script from the PSWeb-main root directory
    pause
    exit /b 1
)

echo [STEP 1/5] Checking prerequisites...
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed
    pause
    exit /b 1
)
echo [OK] Python found: 
python --version

REM Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is not installed
    pause
    exit /b 1
)
echo [OK] Node.js found: 
node --version

echo.
echo [STEP 2/5] Setting up backend dependencies...
echo.

cd backend

REM Create virtual environment if it doesn't exist
if not exist ".venv\" (
    echo Creating Python virtual environment...
    python -m venv .venv
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment
        cd ..
        pause
        exit /b 1
    )
)

REM Install backend dependencies
echo Installing Python dependencies...
call .venv\Scripts\activate.bat
pip install --upgrade pip >nul 2>&1
pip install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Failed to install Python dependencies
    cd ..
    pause
    exit /b 1
)
echo [OK] Backend dependencies installed

REM Create .env if missing
if not exist ".env" (
    echo Creating .env file...
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

cd ..

echo.
echo [STEP 3/5] Setting up frontend dependencies...
echo.

cd frontend

REM Install frontend dependencies
if not exist "node_modules\" (
    echo Installing Node.js dependencies ^(this may take several minutes^)...
    npm install
    if errorlevel 1 (
        echo [ERROR] Failed to install Node.js dependencies
        cd ..
        pause
        exit /b 1
    )
    echo [OK] Frontend dependencies installed
) else (
    echo [OK] Frontend dependencies already installed
)

REM Create .env.local if missing
if not exist ".env.local" (
    echo Creating .env.local file...
    echo REACT_APP_BACKEND_URL=http://localhost:8000 > .env.local
    echo [OK] .env.local file created
)

cd ..

echo.
echo [STEP 4/5] Creating deployment package info...
echo.

REM Create package info file
(
    echo PSWeb Portable Deployment Package
    echo ===================================
    echo.
    echo Package created: %date% %time%
    echo.
    echo Contents:
    echo - Backend with Python virtual environment
    echo - Frontend with Node.js dependencies
    echo - All launcher scripts
    echo - Configuration files
    echo.
    echo Deployment Instructions:
    echo ------------------------
    echo 1. Copy entire PSWeb-main folder to target computer
    echo 2. Install Python 3.10+ and Node.js 18+ on target
    echo 3. Run START.bat to launch the application
    echo.
    echo No internet connection required for deployment!
    echo.
    echo Folder Sizes:
) > PACKAGE-INFO.txt

echo [OK] Package info created

echo.
echo [STEP 5/5] Verifying package integrity...
echo.

REM Verify critical folders exist
if not exist "backend\.venv\" (
    echo [WARNING] Backend .venv folder missing
) else (
    echo [OK] Backend virtual environment present
)

if not exist "frontend\node_modules\" (
    echo [WARNING] Frontend node_modules folder missing
) else (
    echo [OK] Frontend dependencies present
)

if not exist "START.bat" (
    echo [WARNING] START.bat launcher missing
) else (
    echo [OK] Launcher scripts present
)

echo.
echo ================================================================================
echo PORTABLE DEPLOYMENT PACKAGE READY!
echo ================================================================================
echo.
echo Package Location: %cd%
echo.
echo Package Contents:
echo   - backend\.venv\          (~200 MB) - Python dependencies
echo   - frontend\node_modules\  (~500 MB) - Node.js dependencies
echo   - All source code and scripts
echo.
echo Next Steps:
echo   1. Test locally by running START.bat
echo   2. Zip the entire PSWeb-main folder for transfer
echo   3. Extract on target computer
echo   4. Install Python 3.10+ and Node.js 18+
echo   5. Run START.bat
echo.
echo See DEPLOYMENT.md for detailed instructions
echo See PACKAGE-INFO.txt for package details
echo.
echo ================================================================================
pause
