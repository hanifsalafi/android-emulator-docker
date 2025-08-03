#!/bin/bash

echo "========================================"
echo "  Fixing Redroid YAML and Restarting"
echo "========================================"
echo

# Stop all existing containers
echo "[1/5] Stopping all existing containers..."
docker-compose down 2>/dev/null || true
docker stop redroid-novnc 2>/dev/null || true
docker rm redroid-novnc 2>/dev/null || true
docker stop redroid-display 2>/dev/null || true
docker rm redroid-display 2>/dev/null || true

# Clean up
echo "[2/5] Cleaning up containers..."
docker container prune -f 2>/dev/null || true

# Check if display-app.py exists
echo "[3/5] Checking display app file..."
if [ ! -f "display-app.py" ]; then
    echo "[ERROR] display-app.py not found!"
    echo "Please make sure display-app.py exists in the redroid directory"
    exit 1
fi
echo "[OK] display-app.py found"

# Validate docker-compose.yml
echo "[4/5] Validating docker-compose.yml..."
if docker-compose config > /dev/null 2>&1; then
    echo "[OK] docker-compose.yml is valid"
else
    echo "[ERROR] docker-compose.yml has syntax errors!"
    docker-compose config
    exit 1
fi

# Start services
echo "[5/5] Starting Redroid services..."
docker-compose up --build -d

echo
echo "========================================"
echo "  Redroid Restart Complete"
echo "========================================"
echo

# Wait for services to start
echo "Waiting for services to start (60 seconds)..."
sleep 60

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
echo "💡 Features:"
echo "   - ADB screenshot-based display"
echo "   - Auto-refresh capability"
echo "   - Real-time status monitoring"
echo 