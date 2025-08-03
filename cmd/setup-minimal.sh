#!/bin/bash

echo "Setting up Android Emulator Controller (Minimal)..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Check if Docker is installed
echo "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker is not installed!"
    echo "Please install Docker first:"
    echo "sudo apt update && sudo apt install -y docker.io docker-compose"
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "[ERROR] docker-compose is not installed!"
    echo "Please install docker-compose first:"
    echo "sudo apt install -y docker-compose"
    exit 1
fi

echo "[OK] Docker and docker-compose are available"

# Check KVM
echo "Checking KVM support..."
if [ -e /dev/kvm ]; then
    echo "[OK] KVM is available"
    ls -l /dev/kvm
else
    echo "[WARNING] KVM not found. Please enable virtualization in BIOS"
    echo "This may affect emulator performance"
fi

# Check if v4l2loopback module is available
echo "Checking v4l2loopback module..."
if modinfo v4l2loopback > /dev/null 2>&1; then
    echo "[OK] v4l2loopback module is available"
    
    # Load v4l2loopback module
    echo "Loading v4l2loopback module..."
    modprobe v4l2loopback video_nr=10 card_label="VirtualCam" exclusive_caps=1
    
    # Check if virtual device was created
    if [ -e /dev/video10 ]; then
        echo "[OK] Virtual video device /dev/video10 created successfully"
        chmod 666 /dev/video10
    else
        echo "[WARNING] Failed to create virtual video device"
        echo "Camera streaming may not work properly"
    fi
else
    echo "[WARNING] v4l2loopback module not found"
    echo "Camera streaming will not be available"
    echo "To enable camera support, install:"
    echo "sudo apt install -y v4l2loopback-dkms v4l-utils ffmpeg"
fi

# Set KVM permissions
if [ -e /dev/kvm ]; then
    echo "Setting KVM permissions..."
    chmod 666 /dev/kvm
fi

# Start Docker service
echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

echo ""
echo "========================================"
echo "  Setup completed successfully!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Run: ./cmd/run.sh"
echo "2. Access: http://38.47.180.165:8050"
echo ""
echo "Note: Camera streaming requires v4l2loopback module"
echo "If not available, install: sudo apt install v4l2loopback-dkms" 