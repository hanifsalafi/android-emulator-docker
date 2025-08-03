#!/bin/bash

echo "========================================"
echo "  Fixing ADB Connection Issues"
echo "========================================"
echo

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "[ERROR] Services are not running!"
    echo "Please start services first: ./cmd/run.sh"
    exit 1
fi

echo "[1/5] Checking current ADB status..."
docker exec emulator-controller adb devices

echo
echo "[2/5] Killing ADB server..."
docker exec emulator-controller adb kill-server

echo
echo "[3/5] Starting ADB server..."
docker exec emulator-controller adb start-server

echo
echo "[4/5] Waiting for emulator to be ready..."
sleep 10

echo
echo "[5/5] Attempting ADB connection..."
max_attempts=5
attempt=1

while [ $attempt -le $max_attempts ]; do
    echo "Attempt $attempt/$max_attempts"
    
    # Try to connect
    docker exec emulator-controller adb connect emulator-5554
    
    # Check if connected
    if docker exec emulator-controller adb devices | grep -q "emulator-5554"; then
        echo "[SUCCESS] ADB connected to emulator-5554"
        break
    else
        echo "[FAILED] ADB connection attempt $attempt"
        if [ $attempt -lt $max_attempts ]; then
            echo "Waiting 10 seconds before retry..."
            sleep 10
        fi
        attempt=$((attempt+1))
    fi
done

echo
echo "========================================"
echo "  Final ADB Status"
echo "========================================"
docker exec emulator-controller adb devices

echo
echo "========================================"
echo "  Troubleshooting Tips"
echo "========================================"
echo
echo "If ADB still not connected:"
echo "1. Check emulator logs: docker logs -f emulator"
echo "2. Restart services: ./cmd/restart.sh"
echo "3. Wait longer for emulator boot (2-5 minutes)"
echo "4. Check KVM: ls -l /dev/kvm"
echo
echo "To test ADB manually:"
echo "docker exec -it emulator-controller bash"
echo "adb devices"
echo "adb connect emulator-5554"
echo 