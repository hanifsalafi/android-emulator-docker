#!/bin/bash

echo "========================================"
echo "  Redroid Android Emulator - Logs"
echo "========================================"
echo

if ! docker-compose ps | grep -q "Up"; then
    echo "[ERROR] No Redroid services are currently running!"
    echo "Please start the services first with: ./run.sh"
    exit 1
fi

echo "Choose log type:"
echo "1. All services"
echo "2. Redroid only"
echo "3. Controller only"
echo "4. Frontend only"
echo
read -p "Enter your choice (1-4): " choice

case $choice in
    1) docker-compose logs -f ;;
    2) docker-compose logs -f redroid ;;
    3) docker-compose logs -f websocket ;;
    4) docker-compose logs -f frontend ;;
    *) echo "Invalid choice. Showing all logs..."; docker-compose logs -f ;;
esac 