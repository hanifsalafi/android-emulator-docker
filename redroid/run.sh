#!/bin/bash

echo "========================================"
echo "  Starting Redroid Android Emulator"
echo "========================================"
echo

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "This solution is designed for Linux. Please run on a Linux system."
    exit 1
fi

# Check KVM
echo "[1/5] Checking KVM support..."
if [ -e /dev/kvm ]; then
    echo "[OK] KVM is available"
    ls -l /dev/kvm
else
    echo "[ERROR] KVM not found!"
    echo "Please enable virtualization in BIOS"
    exit 1
fi

# Check Docker
echo
echo "[2/5] Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker first."
    exit 1
fi
echo "[OK] Docker is running"

# Check if Redroid image exists
echo
echo "[3/5] Checking Redroid image..."
if ! docker images | grep -q "redroid/redroid"; then
    echo "Pulling Redroid image..."
    docker pull redroid/redroid:11.0.0-latest
fi
echo "[OK] Redroid image available"

# Start services
echo
echo "[4/5] Starting Redroid services..."
docker-compose up --build -d
echo "[OK] Services started"

# Wait for services
echo
echo "[5/5] Waiting for Redroid to boot (this may take 2-3 minutes)..."
sleep 60

echo
echo "========================================"
echo "  Redroid Status Check"
echo "========================================"
echo

# Check container status
echo "Container status:"
docker-compose ps

# Check if noVNC is accessible
echo
echo "Checking accessibility..."
if curl -s --max-time 10 "http://38.47.180.165:6080" > /dev/null 2>&1; then
    echo "[SUCCESS] noVNC is accessible at http://38.47.180.165:6080"
else
    echo "[WARNING] noVNC not accessible yet, may need more time"
fi

if curl -s --max-time 10 "http://38.47.180.165:8050" > /dev/null 2>&1; then
    echo "[SUCCESS] Frontend is accessible at http://38.47.180.165:8050"
else
    echo "[WARNING] Frontend not accessible yet"
fi

echo
echo "========================================"
echo "  Access Information"
echo "========================================"
echo
echo "📱 Redroid Access Points:"
echo "   Frontend: http://38.47.180.165:8050"
echo "   noVNC: http://38.47.180.165:6080"
echo "   API: http://38.47.180.165:3000/api/status"
echo
echo "🔧 Management:"
echo "   Stop: ./stop.sh"
echo "   Logs: ./logs.sh"
echo "   Status: ./status.sh"
echo
echo "💡 Tips:"
echo "   - Redroid boot time: 2-3 minutes"
echo "   - More stable than traditional emulator"
echo "   - Better performance and resource usage"
echo 