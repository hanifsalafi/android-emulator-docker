#!/bin/bash

echo "Setting up Android Emulator Controller..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Install required packages
echo "Installing required packages..."
apt-get update
apt-get install -y \
    v4l2loopback-dkms \
    v4l-utils \
    ffmpeg \
    docker.io \
    docker-compose

# Load v4l2loopback module
echo "Loading v4l2loopback module..."
modprobe v4l2loopback video_nr=10 card_label="VirtualCam" exclusive_caps=1

# Make module persistent
echo "v4l2loopback video_nr=10 card_label=VirtualCam exclusive_caps=1" >> /etc/modules

# Check KVM
echo "Checking KVM support..."
if [ -e /dev/kvm ]; then
    echo "KVM is available"
    ls -l /dev/kvm
else
    echo "KVM not found. Please enable virtualization in BIOS"
    exit 1
fi

# Create virtual video device
echo "Creating virtual video device..."
if [ -e /dev/video10 ]; then
    echo "Virtual video device /dev/video10 created successfully"
else
    echo "Failed to create virtual video device"
    exit 1
fi

# Set permissions
echo "Setting device permissions..."
chmod 666 /dev/video10
chmod 666 /dev/kvm

echo "Setup completed successfully!"
echo "You can now run: docker-compose up -d" 