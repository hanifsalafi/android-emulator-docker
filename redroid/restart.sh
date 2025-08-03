#!/bin/bash

echo "========================================"
echo "  Restarting Redroid with New Display"
echo "========================================"
echo

# Stop all Redroid services
echo "[1/4] Stopping all Redroid services..."
docker-compose down 2>/dev/null || true
docker stop redroid-novnc 2>/dev/null || true
docker rm redroid-novnc 2>/dev/null || true
docker stop redroid-display 2>/dev/null || true
docker rm redroid-display 2>/dev/null || true

# Clean up any remaining containers
echo "[2/4] Cleaning up containers..."
docker container prune -f 2>/dev/null || true

# Start services with new configuration
echo "[3/4] Starting Redroid with new display service..."
docker-compose up --build -d

# Wait for services to start
echo "[4/4] Waiting for services to start (60 seconds)..."
sleep 60

echo
echo "========================================"
echo "  Redroid Restart Complete"
echo "========================================"
echo

# Check container status
echo "Container status:"
docker-compose ps

# Check accessibility
echo
echo "Checking accessibility..."
if curl -s --max-time 10 "http://38.47.180.165:6080" > /dev/null 2>&1; then
    echo "[SUCCESS] Redroid Display is accessible at http://38.47.180.165:6080"
else
    echo "[WARNING] Redroid Display not accessible yet"
fi

if curl -s --max-time 10 "http://38.47.180.165:8050" > /dev/null 2>&1; then
    echo "[SUCCESS] Frontend is accessible at http://38.47.180.165:8050"
else
    echo "[WARNING] Frontend not accessible yet"
fi

echo
echo "========================================"
echo "  Access Information"
echo "========================================"
echo
echo "📱 Redroid Access Points:"
echo "   Frontend: http://38.47.180.165:8050"
echo "   Display: http://38.47.180.165:6080"
echo "   API: http://38.47.180.165:3000/api/status"
echo
echo "🔧 Management:"
echo "   Stop: ./stop.sh"
echo "   Logs: ./logs.sh"
echo "   Status: ./status.sh"
echo "   Verify: ./verify.sh"
echo
echo "💡 New Features:"
echo "   - ADB screenshot-based display"
echo "   - Auto-refresh capability"
echo "   - Real-time status monitoring"
echo 