#!/usr/bin/env bash
# PSWeb Application Launcher (Linux/Mac)
# This script starts both backend and frontend servers

echo "================================================================================"
echo "PSWeb - PowerShell Script Executor"
echo "================================================================================"
echo ""
echo "Starting application servers..."
echo ""
echo "Backend will run on: http://localhost:8000"
echo "Frontend will run on: http://localhost:3000"
echo ""
echo "================================================================================"
echo ""

# Make scripts executable
chmod +x "$(dirname "$0")/start-backend.sh"
chmod +x "$(dirname "$0")/start-frontend.sh"

# Start backend in background
echo "[OK] Starting backend server..."
"$(dirname "$0")/start-backend.sh" &
BACKEND_PID=$!

# Wait for backend to start
sleep 3

# Start frontend in background
echo "[OK] Starting frontend server..."
"$(dirname "$0")/start-frontend.sh" &
FRONTEND_PID=$!

echo ""
echo "[OK] Application servers started"
echo ""
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "The application will open in your browser at:"
echo "http://localhost:3000"
echo ""
echo "To stop the servers, press Ctrl+C"
echo ""

# Handle Ctrl+C
trap "echo ''; echo 'Stopping servers...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" INT

# Wait for processes
wait
