#!/bin/bash

echo "Starting Android Emulator Controller..."

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "This solution is designed for Linux. Please run on a Linux system."
    exit 1
fi

# Detect setup type
SETUP_TYPE="unknown"
if modinfo v4l2loopback > /dev/null 2>&1 && [ -e /dev/video10 ]; then
    SETUP_TYPE="full"
elif command -v docker > /dev/null 2>&1 && command -v docker-compose > /dev/null 2>&1; then
    SETUP_TYPE="minimal"
else
    echo "[ERROR] No setup detected. Please run setup first:"
    echo "  Full setup: sudo ./cmd/setup.sh"
    echo "  Minimal setup: sudo ./cmd/setup-minimal.sh"
    exit 1
fi

echo "Detected setup type: $SETUP_TYPE"

# Setup based on detected type
if [ "$SETUP_TYPE" = "full" ]; then
    echo "Full setup detected - Camera streaming available"
    
    # Check if running as root for device access
    if [ "$EUID" -ne 0 ]; then
        echo "Running camera setup commands with sudo..."
        sudo modprobe v4l2loopback video_nr=10 card_label="VirtualCam" exclusive_caps=1
        sudo chmod 666 /dev/video10 2>/dev/null || true
        sudo chmod 666 /dev/kvm 2>/dev/null || true
    fi
    
    CAMERA_AVAILABLE=true
else
    echo "Minimal setup detected - Camera streaming not available"
    echo "To enable camera support, run: sudo ./cmd/setup.sh"
    
    CAMERA_AVAILABLE=false
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker first."
    exit 1
fi

# Build and start services
echo "Building and starting services..."
docker-compose up --build -d

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 30

# Check service status
echo "Checking service status..."
docker-compose ps

echo ""
echo "🎉 Android Emulator Controller is ready!"
echo ""
echo "📱 Access points:"
echo "   Frontend: http://localhost:9080"
echo "   Emulator (noVNC): http://localhost:6080"
echo ""
echo "🔧 Troubleshooting:"
echo "   View logs: ./cmd/logs.sh"
echo "   Check status: ./cmd/status.sh"
echo "   Restart: docker-compose restart"
echo "   Stop: ./cmd/stop.sh"
echo ""

if [ "$CAMERA_AVAILABLE" = true ]; then
    echo "📷 Camera setup (Available):"
    echo "   1. Open http://localhost:9080"
    echo "   2. Click 'Start Camera'"
    echo "   3. Allow camera access in browser"
    echo "   4. Camera will stream to emulator"
else
    echo "📷 Camera setup (Not available):"
    echo "   Camera streaming is not available in minimal setup"
    echo "   To enable camera: sudo ./cmd/setup.sh"
fi

echo ""
echo "🎮 Basic controls:"
echo "   - Click on emulator area for touch input"
echo "   - Use navigation buttons for movement"
echo "   - Load apps to manage applications" 