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
echo "[1/6] Checking KVM support..."
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
echo "[2/6] Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker first."
    exit 1
fi
echo "[OK] Docker is running"

# Check if Redroid image exists
echo
echo "[3/6] Checking Redroid image..."
if ! docker images | grep -q "redroid/redroid"; then
    echo "Pulling Redroid image..."
    docker pull redroid/redroid:11.0.0-latest
fi
echo "[OK] Redroid image available"

# Start services
echo
echo "[4/6] Starting Redroid services..."
docker-compose up --build -d
echo "[OK] Services started"

# Wait for Redroid to boot
echo
echo "[5/6] Waiting for Redroid to boot (this may take 2-3 minutes)..."
sleep 60

# Setup noVNC for Redroid
echo
echo "[6/6] Setting up noVNC access..."
echo "Starting noVNC container for Redroid..."

# Start noVNC container for Redroid
docker run -d \
  --name redroid-novnc \
  --network redroid_redroid-network \
  -p 6080:6080 \
  -e DISPLAY=:0 \
  --volumes-from android-redroid \
  theasp/novnc:latest \
  /bin/bash -c "
    # Install x11vnc if not available
    apt-get update && apt-get install -y x11vnc || true
    
    # Start VNC server
    x11vnc -display :0 -nopw -listen 38.47.180.165 -xkb -ncache 10 -ncache_cr -forever &
    
    # Start noVNC
    /usr/bin/websockify --web /usr/share/novnc/ 6080 38.47.180.165:5900
  "

echo "[OK] noVNC setup completed"

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