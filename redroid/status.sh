#!/bin/bash

echo "========================================"
echo "  Redroid Android Emulator - Status"
echo "========================================"
echo

# Check Docker status
echo "Checking Docker status..."
if docker info > /dev/null 2>&1; then
    echo "[OK] Docker is running"
else
    echo "[ERROR] Docker is not running"
    exit 1
fi

echo
echo "Service Status:"
echo "==============="
docker-compose ps

echo
echo "Port Status:"
echo "============"
echo "Checking if ports are accessible..."

# Test endpoints
test_url() {
    local url=$1
    local name=$2
    if curl -s --max-time 5 "$url" > /dev/null 2>&1; then
        echo "[OK] $name is accessible ($url)"
    else
        echo "[ERROR] $name is not accessible ($url)"
    fi
}

test_url "http://38.47.180.165:8050" "Frontend"
test_url "http://38.47.180.165:6080" "Redroid (noVNC)"
test_url "http://38.47.180.165:3000/api/status" "API"

echo
echo "Quick Access:"
echo "============="
echo "• Frontend: http://38.47.180.165:8050"
echo "• Redroid: http://38.47.180.165:6080"
echo "• API Test: http://38.47.180.165:8050/test-api.html"

echo
echo "Container Logs:"
echo "==============="
echo "Redroid container logs (last 10 lines):"
docker logs --tail 10 android-redroid 2>/dev/null || echo "No Redroid logs found"

echo
echo "Controller logs (last 10 lines):"
docker logs --tail 10 redroid-controller 2>/dev/null || echo "No controller logs found" 