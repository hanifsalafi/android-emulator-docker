#!/bin/bash

echo "========================================"
echo "  Android Emulator Status Check"
echo "========================================"
echo

# Check if Docker is running
echo "[1/7] Checking Docker status..."
if docker info > /dev/null 2>&1; then
    echo "[OK] Docker is running"
else
    echo "[ERROR] Docker is not running"
    exit 1
fi

# Check container status
echo
echo "[2/7] Checking container status..."
if docker-compose ps | grep -q "Up"; then
    echo "[OK] Services are running"
    docker-compose ps
else
    echo "[ERROR] Services are not running"
    echo "Please start services first: ./cmd/run.sh"
    exit 1
fi

# Check emulator container logs
echo
echo "[3/7] Checking emulator container logs..."
echo "Last 20 lines of emulator logs:"
docker logs --tail 20 emulator 2>/dev/null || echo "No emulator logs found"

# Check controller container logs
echo
echo "[4/7] Checking controller container logs..."
echo "Last 20 lines of controller logs:"
docker logs --tail 20 emulator-controller 2>/dev/null || echo "No controller logs found"

# Check ADB connection from controller
echo
echo "[5/7] Checking ADB connection..."
echo "Current ADB devices:"
docker exec emulator-controller adb devices 2>/dev/null || echo "ADB not available in controller"

# Check ADB server status
echo
echo "[6/7] Checking ADB server status..."
if docker exec emulator-controller adb version > /dev/null 2>&1; then
    echo "[OK] ADB is available"
    echo "ADB version:"
    docker exec emulator-controller adb version
else
    echo "[ERROR] ADB is not available"
fi

# Check if emulator is accessible via noVNC
echo
echo "[7/7] Checking emulator accessibility..."
if curl -s --max-time 10 "http://38.47.180.165:6080" > /dev/null 2>&1; then
    echo "[OK] Emulator noVNC is accessible at http://38.47.180.165:6080"
else
    echo "[ERROR] Emulator noVNC is not accessible"
fi

echo
echo "========================================"
echo "  ADB Connection Test"
echo "========================================"
echo

# Test ADB connection
echo "Testing ADB connection to emulator-5554..."
if docker exec emulator-controller adb connect emulator-5554 2>/dev/null; then
    echo "[OK] ADB connect command executed"
else
    echo "[ERROR] ADB connect command failed"
fi

echo "Current devices after connection attempt:"
docker exec emulator-controller adb devices 2>/dev/null || echo "ADB devices command failed"

echo
echo "========================================"
echo "  Troubleshooting Tips"
echo "========================================"
echo
echo "If emulator is not working:"
echo "1. Check if KVM is enabled: ls -l /dev/kvm"
echo "2. Restart services: ./cmd/restart.sh"
echo "3. Fix ADB connection: ./cmd/fix-adb.sh"
echo "4. Check emulator logs: docker logs -f emulator"
echo "5. Check controller logs: docker logs -f emulator-controller"
echo "6. Wait longer for emulator to boot (can take 2-5 minutes)"
echo
echo "To access emulator directly:"
echo "- noVNC: http://38.47.180.165:6080"
echo "- Frontend: http://38.47.180.165:8050"
echo
echo "Common ADB issues:"
echo "- 'Name or service not known': Emulator not ready, wait longer"
echo "- 'Connection refused': ADB server issue, run ./cmd/fix-adb.sh"
echo "- 'No devices found': Emulator not booted, check logs"
echo 