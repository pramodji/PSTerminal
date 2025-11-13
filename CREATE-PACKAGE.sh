#!/usr/bin/env bash
# PSWeb Portable Deployment Package Creator
# This script prepares a portable deployment package

set -e

echo "================================================================================"
echo "PSWeb - Creating Portable Deployment Package"
echo "================================================================================"
echo ""

# Check if running from project root
if [ ! -d "backend" ]; then
    echo "[ERROR] Please run this script from the PSWeb-main root directory"
    exit 1
fi

echo "[STEP 1/5] Checking prerequisites..."
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 is not installed"
    exit 1
fi
echo "[OK] Python found: $(python3 --version)"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "[ERROR] Node.js is not installed"
    exit 1
fi
echo "[OK] Node.js found: $(node --version)"

echo ""
echo "[STEP 2/5] Setting up backend dependencies..."
echo ""

cd backend

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv .venv
fi

# Install backend dependencies
echo "Installing Python dependencies..."
source .venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt
echo "[OK] Backend dependencies installed"

# Create .env if missing
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cat > .env << EOF
MONGO_URL=mongodb://localhost:27017
DB_NAME=psweb
CORS_ORIGINS=*
HOST=0.0.0.0
PORT=8000
RELOAD=false
EOF
    echo "[OK] .env file created"
fi

cd ..

echo ""
echo "[STEP 3/5] Setting up frontend dependencies..."
echo ""

cd frontend

# Install frontend dependencies
if [ ! -d "node_modules" ]; then
    echo "Installing Node.js dependencies (this may take several minutes)..."
    npm install
    echo "[OK] Frontend dependencies installed"
else
    echo "[OK] Frontend dependencies already installed"
fi

# Create .env.local if missing
if [ ! -f ".env.local" ]; then
    echo "Creating .env.local file..."
    echo "REACT_APP_BACKEND_URL=http://localhost:8000" > .env.local
    echo "[OK] .env.local file created"
fi

cd ..

echo ""
echo "[STEP 4/5] Creating deployment package info..."
echo ""

# Create package info file
cat > PACKAGE-INFO.txt << EOF
PSWeb Portable Deployment Package
===================================

Package created: $(date)

Contents:
- Backend with Python virtual environment
- Frontend with Node.js dependencies
- All launcher scripts
- Configuration files

Deployment Instructions:
------------------------
1. Copy entire PSWeb-main folder to target computer
2. Install Python 3.10+ and Node.js 18+ on target
3. Run ./START.sh to launch the application

No internet connection required for deployment!

EOF

echo "[OK] Package info created"

echo ""
echo "[STEP 5/5] Verifying package integrity..."
echo ""

# Verify critical folders exist
if [ ! -d "backend/.venv" ]; then
    echo "[WARNING] Backend .venv folder missing"
else
    echo "[OK] Backend virtual environment present"
fi

if [ ! -d "frontend/node_modules" ]; then
    echo "[WARNING] Frontend node_modules folder missing"
else
    echo "[OK] Frontend dependencies present"
fi

if [ ! -f "START.sh" ]; then
    echo "[WARNING] START.sh launcher missing"
else
    echo "[OK] Launcher scripts present"
fi

# Make scripts executable
chmod +x START.sh start-backend.sh start-frontend.sh 2>/dev/null || true

echo ""
echo "================================================================================"
echo "PORTABLE DEPLOYMENT PACKAGE READY!"
echo "================================================================================"
echo ""
echo "Package Location: $(pwd)"
echo ""
echo "Package Contents:"
echo "  - backend/.venv/          (~200 MB) - Python dependencies"
echo "  - frontend/node_modules/  (~500 MB) - Node.js dependencies"
echo "  - All source code and scripts"
echo ""
echo "Next Steps:"
echo "  1. Test locally by running ./START.sh"
echo "  2. Tar/zip the entire PSWeb-main folder for transfer"
echo "  3. Extract on target computer"
echo "  4. Install Python 3.10+ and Node.js 18+"
echo "  5. Run ./START.sh"
echo ""
echo "See DEPLOYMENT.md for detailed instructions"
echo "See PACKAGE-INFO.txt for package details"
echo ""
echo "================================================================================"
