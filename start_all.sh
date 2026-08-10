#!/bin/bash
set -e

echo "========================================================"
echo " Starting HelloCare: FastAPI Backend + Flutter Web App"
echo "========================================================"

# Track child PIDs for cleanup on EXIT/SIGINT
BACKEND_PID=""

cleanup() {
  echo ""
  echo "[Launcher] Shutting down HelloCare services..."
  if [ -n "$BACKEND_PID" ]; then
    echo "[Launcher] Terminating FastAPI Backend (PID: $BACKEND_PID)..."
    kill -9 "$BACKEND_PID" 2>/dev/null || true
  fi
  echo "[Launcher] Cleanup complete. Goodbye!"
  exit 0
}

trap cleanup EXIT SIGINT SIGTERM

# 1. Start Python FastAPI Backend in background
echo "[1/2] Starting Python FastAPI Backend on http://localhost:8081 ..."
cd backend
if [ ! -d "venv" ]; then
  echo "[Backend] Creating Python virtual environment..."
  python3 -m venv venv
  venv/bin/pip install -r requirements.txt
fi

venv/bin/python main.py &
BACKEND_PID=$!
cd ..

# Wait briefly for FastAPI server to initialize
sleep 2
echo "[Backend] FastAPI running (PID: $BACKEND_PID)."
echo "[Backend] Live Swagger Docs available at: http://localhost:8081/docs"

# 2. Launch Flutter Web Frontend
echo "[2/2] Launching Flutter Web App in Chrome..."
flutter run -d chrome

