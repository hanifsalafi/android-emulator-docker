#!/bin/bash

echo "Initializing Android Emulator Controller..."

# Wait for emulator to be ready
echo "Waiting for emulator to be ready..."
sleep 30

# Load v4l2loopback module
echo "Loading v4l2loopback module..."
modprobe v4l2loopback video_nr=10 card_label="VirtualCam" exclusive_caps=1

# Wait for virtual device
echo "Waiting for virtual video device..."
while [ ! -e /dev/video10 ]; do
    sleep 1
done

echo "Virtual video device ready: /dev/video10"

# Start the server
echo "Starting server..."
node server.js 