#!/bin/bash

echo "========================================"
echo "  Fixing VNC Web Service Issues"
echo "========================================"
echo

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "[ERROR] Services are not running!"
    echo "Please start services first: ./cmd/run.sh"
    exit 1
fi

echo "[1/6] Checking current port status..."
echo "Port 6080 status:"
netstat -tlnp | grep 6080 || echo "Port 6080 not listening"

echo "Docker port mapping:"
docker port android-emulator | grep 6080 || echo "Port 6080 not mapped"

echo
echo "[2/6] Checking VNC service status..."
echo "VNC services in emulator:"
docker logs android-emulator 2>/dev/null | grep -E "(vnc_web|vnc_server)" | tail -10

echo
echo "[3/6] Restarting emulator container..."
docker restart android-emulator
echo "[OK] Emulator container restarted"

echo
echo "[4/6] Waiting for VNC services to start..."
sleep 30

echo
echo "[5/6] Checking VNC service status after restart..."
echo "VNC services status:"
docker logs android-emulator 2>/dev/null | grep -E "(vnc_web|vnc_server)" | tail -10

echo
echo "[6/6] Testing VNC accessibility..."
timeout=120  # 2 minutes
elapsed=0

while [ $elapsed -lt $timeout ]; do
    if curl -s --max-time 5 "http://38.47.180.165:6080" > /dev/null 2>&1; then
        echo "[SUCCESS] VNC is accessible at http://38.47.180.165:6080"
        break
    else
        echo "Waiting for VNC... ($elapsed/$timeout seconds)"
        sleep 10
        elapsed=$((elapsed+10))
    fi
done

if [ $elapsed -ge $timeout ]; then
    echo "[ERROR] VNC not accessible after $timeout seconds"
fi

echo
echo "========================================"
echo "  Final Status"
echo "========================================"
echo "Container status:"
docker-compose ps

echo
echo "Port status:"
netstat -tlnp | grep 6080 || echo "Port 6080 not listening"

echo
echo "Docker port mapping:"
docker port android-emulator

echo
echo "========================================"
echo "  Troubleshooting Steps"
echo "========================================"
echo
echo "If VNC still not accessible:"
echo "1. Check emulator logs: docker logs -f android-emulator"
echo "2. Check if vnc_web service is running"
echo "3. Try complete restart: ./cmd/restart.sh"
echo "4. Check firewall: sudo ufw status"
echo
echo "Alternative access:"
echo "- Frontend: http://38.47.180.165:8050"
echo "- API: http://38.47.180.165:3000/api/status"
echo 