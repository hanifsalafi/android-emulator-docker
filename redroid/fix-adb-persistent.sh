#!/bin/bash

echo "========================================"
echo "  Fixing Redroid ADB Persistent Connection"
echo "========================================"
echo

# Stop all existing containers
echo "[1/6] Stopping all existing containers..."
docker-compose down 2>/dev/null || true
docker stop redroid-novnc 2>/dev/null || true
docker rm redroid-novnc 2>/dev/null || true
docker stop redroid-display 2>/dev/null || true
docker rm redroid-display 2>/dev/null || true

# Clean up
echo "[2/6] Cleaning up containers..."
docker container prune -f 2>/dev/null || true

# Check if display-app.py exists
echo "[3/6] Checking display app file..."
if [ ! -f "display-app.py" ]; then
    echo "[ERROR] display-app.py not found!"
    echo "Please make sure display-app.py exists in the redroid directory"
    exit 1
fi
echo "[OK] display-app.py found"

# Check if frontend Dockerfile exists
echo "[4/6] Checking frontend Dockerfile..."
if [ ! -f "../frontend/Dockerfile" ]; then
    echo "[ERROR] ../frontend/Dockerfile not found!"
    echo "Please make sure Dockerfile exists in the frontend directory"
    exit 1
fi
echo "[OK] frontend/Dockerfile found"

# Validate docker-compose.yml
echo "[5/6] Validating docker-compose.yml..."
if docker-compose config > /dev/null 2>&1; then
    echo "[OK] docker-compose.yml is valid"
else
    echo "[ERROR] docker-compose.yml has syntax errors!"
    docker-compose config
    exit 1
fi

# Start services
echo "[6/6] Starting Redroid services with persistent ADB..."
docker-compose up --build -d

echo
echo "========================================"
echo "  Redroid ADB Persistent Fix Complete"
echo "========================================"
echo

# Wait for services to start
echo "Waiting for services to start (120 seconds)..."
sleep 120

# Check container status
echo "Container status:"
docker-compose ps

# Check ADB connection multiple times
echo
echo "Checking ADB connection stability..."
for i in {1..5}; do
    echo "Test $i/5:"
    echo "Testing ADB from redroid-controller:"
    docker exec redroid-controller adb devices 2>/dev/null || echo "ADB not available in controller"
    
    echo "Testing ADB from redroid-display:"
    docker exec redroid-display adb devices 2>/dev/null || echo "ADB not available in display"
    
    if [ $i -lt 5 ]; then
        echo "Waiting 10 seconds before next test..."
        sleep 10
    fi
done

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

if curl -s --max-time 10 "http://38.47.180.165:3000/api/status" > /dev/null 2>&1; then
    echo "[SUCCESS] API is accessible at http://38.47.180.165:3000/api/status"
else
    echo "[WARNING] API not accessible yet"
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
echo "💡 ADB Persistent Fixes:"
echo "   - ADB server restart before connection"
echo "   - Connection verification after connect"
echo "   - Auto-reconnect on command execution"
echo "   - Better error handling and logging"
echo 