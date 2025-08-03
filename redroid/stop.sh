#!/bin/bash

echo "========================================"
echo "  Stopping Redroid Android Emulator"
echo "========================================"
echo

# Stop noVNC container if running
if docker ps | grep -q "redroid-novnc"; then
    echo "Stopping noVNC container..."
    docker stop redroid-novnc
    docker rm redroid-novnc
fi

if ! docker-compose ps | grep -q "Up"; then
    echo "[INFO] No Redroid services are currently running."
    exit 0
fi

echo "Stopping all Redroid services..."
docker-compose down

echo
echo "[OK] All Redroid services stopped successfully!"
echo
echo "To start again, run: ./run.sh" 