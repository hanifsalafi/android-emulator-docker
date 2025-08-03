#!/bin/bash

echo "========================================"
echo "  Debugging Redroid Issues"
echo "========================================"
echo

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "[ERROR] No Redroid services are currently running!"
    echo "Please start services first with: ./run.sh"
    exit 1
fi

echo "[1/6] Checking Redroid container status..."
docker ps | grep android-redroid || echo "Redroid container not found"

echo
echo "[2/6] Checking Redroid image..."
docker images | grep redroid || echo "Redroid image not found"

echo
echo "[3/6] Checking Redroid container logs..."
echo "Last 20 lines of Redroid logs:"
docker logs --tail 20 android-redroid 2>/dev/null || echo "No Redroid logs found"

echo
echo "[4/6] Checking Redroid container processes..."
docker exec android-redroid ps aux 2>/dev/null || echo "Cannot access Redroid container"

echo
echo "[5/6] Checking Redroid container filesystem..."
docker exec android-redroid ls -la / 2>/dev/null || echo "Cannot access Redroid filesystem"

echo
echo "[6/6] Testing Redroid connectivity..."
echo "Testing ADB connection:"
docker exec redroid-controller adb connect 38.47.180.165:5555 2>/dev/null || echo "ADB connection failed"

echo "ADB devices:"
docker exec redroid-controller adb devices 2>/dev/null || echo "ADB devices command failed"

echo
echo "========================================"
echo "  Troubleshooting Steps"
echo "========================================"
echo

echo "If Redroid is not working:"
echo "1. Check if Redroid image is correct: docker images | grep redroid"
echo "2. Try pulling fresh image: docker pull redroid/redroid:11.0.0-latest"
echo "3. Restart Redroid: ./stop.sh && ./run.sh"
echo "4. Check KVM: ls -l /dev/kvm"
echo "5. Check system resources: free -h && df -h"
echo
echo "Alternative Redroid images to try:"
echo "- redroid/redroid:10.0.0-latest"
echo "- redroid/redroid:12.0.0-latest"
echo "- redroid/redroid:13.0.0-latest"
echo 