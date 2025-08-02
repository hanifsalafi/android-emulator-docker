#!/bin/bash

echo "Starting Android Emulator Controller..."

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "This solution is designed for Linux. Please run on a Linux system."
    exit 1
fi

# Check if running as root for device access
if [ "$EUID" -ne 0 ]; then
    echo "Running setup commands with sudo..."
    sudo modprobe v4l2loopback video_nr=10 card_label="VirtualCam" exclusive_caps=1
    sudo chmod 666 /dev/video10 2>/dev/null || true
    sudo chmod 666 /dev/kvm 2>/dev/null || true
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
echo "   Frontend: http://localhost:8080"
echo "   Emulator (noVNC): http://localhost:6080"
echo ""
echo "🔧 Troubleshooting:"
echo "   View logs: docker-compose logs -f"
echo "   Restart: docker-compose restart"
echo "   Stop: docker-compose down"
echo ""
echo "📷 Camera setup:"
echo "   1. Open http://localhost:8080"
echo "   2. Click 'Start Camera'"
echo "   3. Allow camera access in browser"
echo "   4. Camera will stream to emulator" 