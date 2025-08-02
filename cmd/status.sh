#!/bin/bash

echo "========================================"
echo "  Android Emulator Controller - Status"
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

test_url "http://localhost:8080" "Frontend"
test_url "http://localhost:6080" "Emulator (noVNC)"
test_url "http://localhost:3000/api/status" "API"

echo
echo "Quick Access:"
echo "============="
echo "• Frontend: http://localhost:8080"
echo "• Emulator: http://localhost:6080"
echo "• API Test: http://localhost:8080/test-api.html" 