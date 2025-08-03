#!/bin/bash

set -e

echo "========================================"
echo "  Complete Test - Android Emulator Controller (Linux)"
echo "========================================"
echo

echo "[1/6] Checking Docker..."
if ! docker info > /dev/null 2>&1; then
  echo "[ERROR] Docker is not running!"
  echo "Please start Docker first."
  exit 1
fi
echo "[OK] Docker is running."

echo "[2/6] Checking docker-compose..."
if ! docker-compose --version > /dev/null 2>&1; then
  echo "[ERROR] docker-compose is not available!"
  exit 1
fi
echo "[OK] docker-compose is available."

echo "[3/6] Starting services..."
docker-compose up --build -d
echo "[OK] Services started."

echo "[4/6] Waiting for services to be ready..."
sleep 30

echo "[5/6] Checking service status..."
docker-compose ps
echo

echo "[6/6] Testing endpoints..."
echo

# Test endpoints
function test_url() {
  local url=$1
  local name=$2
  if curl -s --max-time 10 "$url" > /dev/null; then
    echo "[OK] $name is accessible ($url)"
  else
    echo "[ERROR] $name is not accessible ($url)"
  fi
}

test_url "http://38.47.180.165:8050" "Frontend"
test_url "http://38.47.180.165:6080" "Emulator (noVNC)"
test_url "http://38.47.180.165:3000/api/status" "API"

echo

echo "========================================"
echo "         🎉 TEST COMPLETED! 🎉         "
echo "========================================"
echo

echo "All basic tests completed!"
echo "- Open http://38.47.180.165:8050 to use the controller"
echo "- Run ./cmd/run.sh for normal usage"
echo "- See README.md for more info"
echo 