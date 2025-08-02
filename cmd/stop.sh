#!/bin/bash

echo "========================================"
echo "  Stopping Android Emulator Controller"
echo "========================================"
echo

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "[INFO] No services are currently running."
    exit 0
fi

echo "Stopping all services..."
docker-compose down

echo
echo "[OK] All services stopped successfully!"
echo
echo "To start again, run: ./run.sh" 