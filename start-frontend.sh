#!/usr/bin/env bash
# PSWeb Frontend Startup Script (Linux/Mac)
# This script automatically sets up and runs the frontend development server

set -e

echo "================================================================================"
echo "PSWeb Frontend - Automated Startup"
echo "================================================================================"
echo ""

cd "$(dirname "$0")/frontend"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "[ERROR] Node.js is not installed"
    echo "Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi

echo "[OK] Node.js found: $(node --version)"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "[ERROR] npm is not installed"
    exit 1
fi

echo "[OK] npm found: $(npm --version)"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo ""
    echo "[ERROR] node_modules folder not found"
    echo "Please ensure the complete project folder with dependencies is copied"
    echo "or run 'npm install' manually in the frontend directory"
    exit 1
else
    echo "[OK] Dependencies found"
fi

# Create .env.local if it doesn't exist
if [ ! -f ".env.local" ]; then
    echo ""
    echo "[SETUP] Creating .env.local file..."
    echo "REACT_APP_BACKEND_URL=http://localhost:8000" > .env.local
    echo "[OK] .env.local file created"
fi

# Start the development server
echo ""
echo "================================================================================"
echo "Starting Frontend Development Server"
echo "The application will open at http://localhost:3000"
echo "Press Ctrl+C to stop the server"
echo "================================================================================"
echo ""

npm start
