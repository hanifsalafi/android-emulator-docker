#!/bin/bash

echo "========================================"
echo "  Restarting Traditional Android Emulator"
echo "========================================"
echo

# Stop all existing containers
echo "[1/6] Stopping all existing containers..."
docker-compose down 2>/dev/null || true

# Clean up
echo "[2/6] Cleaning up containers..."
docker container prune -f 2>/dev/null || true

# Check if running on Linux
echo "[3/6] Checking system requirements..."
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "This solution is designed for Linux. Please run on a Linux system."
    exit 1
fi

# Check Docker
echo "[4/6] Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker first."
    exit 1
fi
echo "[OK] Docker is running"

# Check KVM
echo "[5/6] Checking KVM support..."
if [ -e /dev/kvm ]; then
    echo "[OK] KVM is available"
    ls -l /dev/kvm
else
    echo "[ERROR] KVM not found!"
    echo "Please enable virtualization in BIOS"
    exit 1
fi

# Start services
echo "[6/6] Starting emulator services..."
docker-compose up --build -d

echo
echo "========================================"
echo "  Emulator Restart Complete"
echo "========================================"
echo

# Wait for services to start
echo "Waiting for services to start (60 seconds)..."
sleep 60

# Check container status
echo "Container status:"
docker-compose ps

# Check accessibility
echo
echo "Checking accessibility..."
if curl -s --max-time 10 "http://38.47.180.165:6080" > /dev/null 2>&1; then
    echo "[SUCCESS] noVNC is accessible at http://38.47.180.165:6080"
else
    echo "[WARNING] noVNC not accessible yet"
fi

if curl -s --max-time 10 "http://38.47.180.165:8050" > /dev/null 2>&1; then
    echo "[SUCCESS] Frontend is accessible at http://38.47.180.165:8050"
else
    echo "[WARNING] Frontend not accessible yet"
fi

if curl -s --max-time 10 "http://38.47.180.165:3000/api/status" > /dev/null 2>&1; then
    echo "[SUCCESS] API is accessible at http://38.47.180.165:3000/api/status"
else
    echo "[WARNING] API not accessible yet"
fi

echo
echo "========================================"
echo "  Access Information"
echo "========================================"
echo
echo "📱 Emulator Access Points:"
echo "   Frontend: http://38.47.180.165:8050"
echo "   noVNC: http://38.47.180.165:6080"
echo "   API: http://38.47.180.165:3000/api/status"
echo
echo "🔧 Management:"
echo "   Stop: ./cmd/stop.sh"
echo "   Logs: ./cmd/logs.sh"
echo "   Status: ./cmd/status.sh"
echo
echo "💡 Configuration:"
echo "   - Traditional Android Emulator (budtmo/docker-android)"
echo "   - ADB connects to: 38.47.180.165:5555"
echo "   - WebSocket on: port 9999"
echo "   - API on: port 3000"
echo 