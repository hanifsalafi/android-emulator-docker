#!/bin/bash

echo "========================================"
echo "  Restarting Android Emulator Controller"
echo "========================================"
echo

# Stop all services
echo "[1/4] Stopping all services..."
docker-compose down
echo "[OK] Services stopped"

# Clean up any leftover containers
echo "[2/4] Cleaning up containers..."
docker container prune -f > /dev/null 2>&1
echo "[OK] Containers cleaned up"

# Wait a moment
echo "[3/4] Waiting for cleanup..."
sleep 5

# Start services
echo "[4/4] Starting services..."
docker-compose up --build -d
echo "[OK] Services started"

echo
echo "========================================"
echo "  Services Restarted Successfully!"
echo "========================================"
echo
echo "Waiting for emulator to boot (this may take 2-5 minutes)..."
echo
echo "📱 Access points:"
echo "   Frontend: http://38.47.180.165:8050"
echo "   Emulator (noVNC): http://38.47.180.165:6080"
echo
echo "🔧 Monitoring:"
echo "   Check status: ./cmd/status.sh"
echo "   View logs: ./cmd/logs.sh"
echo "   Check emulator: ./cmd/check-emulator.sh"
echo
echo "💡 Tips:"
echo "   - Emulator boot time: 2-5 minutes"
echo "   - Check logs if emulator doesn't appear"
echo "   - Use noVNC directly if frontend has issues"
echo 