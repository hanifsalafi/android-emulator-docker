#!/bin/bash

echo "========================================"
echo "  Stopping Redroid Android Emulator"
echo "========================================"
echo

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