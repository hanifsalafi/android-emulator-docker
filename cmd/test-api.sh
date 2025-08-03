#!/bin/bash

echo "========================================"
echo "  API Test - Android Emulator Controller"
echo "========================================"
echo

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "[ERROR] jq is not installed. Please install it first:"
    echo "sudo apt install jq"
    exit 1
fi

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "[ERROR] Services are not running!"
    echo "Please start services first with: ./run.sh"
    exit 1
fi

echo "Testing API endpoints..."
echo

echo "[1/3] /api/status"
if curl -s http://38.47.180.165:3000/api/status | jq .; then
    echo "[OK] Status API working"
else
    echo "[ERROR] Status API failed"
fi
echo

echo "[2/3] /api/apps"
if curl -s http://38.47.180.165:3000/api/apps | jq .; then
    echo "[OK] Apps API working"
else
    echo "[ERROR] Apps API failed"
fi
echo

echo "[3/3] WebSocket (manual test)"
echo "- Open http://38.47.180.165:8050/test-api.html in your browser"
echo "- Use the WebSocket test interface"
echo

echo "API test completed!" 