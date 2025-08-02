#!/bin/bash

echo "========================================"
echo "  Android Emulator Controller - Logs"
echo "========================================"
echo

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "[ERROR] No services are currently running!"
    echo "Please start the services first with: ./run.sh"
    exit 1
fi

echo "Choose log type:"
echo "1. All services"
echo "2. Emulator only"
echo "3. Controller only"
echo "4. Frontend only"
echo

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo "Showing logs for all services..."
        docker-compose logs -f
        ;;
    2)
        echo "Showing emulator logs..."
        docker-compose logs -f emulator
        ;;
    3)
        echo "Showing controller logs..."
        docker-compose logs -f websocket
        ;;
    4)
        echo "Showing frontend logs..."
        docker-compose logs -f frontend
        ;;
    *)
        echo "Invalid choice. Showing all logs..."
        docker-compose logs -f
        ;;
esac 