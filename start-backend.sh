#!/usr/bin/env bash
# PSWeb Backend Startup Script (Linux/Mac)
# This script automatically sets up and runs the backend server

set -e

echo "================================================================================"
echo "PSWeb Backend Server - Automated Startup"
echo "================================================================================"
echo ""

cd "$(dirname "$0")/backend"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 is not installed"
    echo "Please install Python 3.10+ from your package manager"
    exit 1
fi

echo "[OK] Python found: $(python3 --version)"

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo ""
    echo "[SETUP] Creating virtual environment..."
    python3 -m venv .venv
    echo "[OK] Virtual environment created"
fi

# Activate virtual environment and install dependencies
echo ""
echo "[SETUP] Installing/updating dependencies..."
source .venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt
echo "[OK] Dependencies installed"

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo ""
    echo "[SETUP] Creating default .env file..."
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

# Start the server
echo ""
echo "================================================================================"
echo "Starting Backend Server on http://localhost:8000"
echo "Press Ctrl+C to stop the server"
echo "================================================================================"
echo ""

python server.py
