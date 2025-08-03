#!/bin/bash

echo "========================================"
echo "  Fixing Emulator Crash Issues"
echo "========================================"
echo

# Check KVM
echo "[1/5] Checking KVM..."
if [ -e /dev/kvm ]; then
    echo "[OK] KVM is available"
else
    echo "[ERROR] KVM not found!"
    exit 1
fi

# Stop services
echo
echo "[2/5] Stopping services..."
docker-compose down
echo "[OK] Services stopped"

# Clean up
echo
echo "[3/5] Cleaning up..."
docker container prune -f
docker system prune -f
echo "[OK] Cleanup completed"

# Start services
echo
echo "[4/5] Starting services..."
docker-compose up --build -d
echo "[OK] Services started"

# Monitor
echo
echo "[5/5] Monitoring boot process..."
echo "Waiting for emulator to boot (5 minutes)..."
echo

# Monitor for 5 minutes
timeout=300
elapsed=0

while [ $elapsed -lt $timeout ]; do
    # Check if container is running
    if ! docker ps | grep -q "android-emulator"; then
        echo "[ERROR] Emulator container stopped!"
        exit 1
    fi
    
    # Check if noVNC is accessible
    if curl -s --max-time 5 "http://localhost:6080" > /dev/null 2>&1; then
        echo "[SUCCESS] noVNC is accessible!"
        break
    fi
    
    echo "Waiting... ($elapsed/$timeout seconds)"
    sleep 30
    elapsed=$((elapsed+30))
done

echo
echo "========================================"
echo "  Final Status"
echo "========================================"
echo "Container status:"
docker-compose ps

echo
echo "Access points:"
echo "- Frontend: http://localhost:8050"
echo "- noVNC: http://localhost:6080"
echo
echo "Monitor logs:"
echo "docker logs -f android-emulator"
echo 