#!/bin/bash

echo "Initializing Android Emulator Controller..."

# Wait longer for emulator to be ready
echo "Waiting for emulator to be ready..."
sleep 60

# Try to load v4l2loopback module (ignore if not available)
echo "Loading v4l2loopback module..."
if modprobe v4l2loopback video_nr=10 card_label="VirtualCam" exclusive_caps=1 2>/dev/null; then
    echo "v4l2loopback module loaded successfully"
else
    echo "v4l2loopback module not available, continuing without camera support"
fi

# Wait for virtual video device (if module was loaded)
if lsmod | grep -q v4l2loopback; then
    echo "Waiting for virtual video device..."
    timeout=30
    while [ $timeout -gt 0 ] && [ ! -e /dev/video10 ]; do 
        sleep 1
        timeout=$((timeout-1))
    done
    
    if [ -e /dev/video10 ]; then
        echo "Virtual video device ready: /dev/video10"
    else
        echo "Virtual video device not available"
    fi
else
    echo "Skipping virtual video device setup"
fi

# Wait for emulator and try ADB connection multiple times
echo "Waiting for emulator and setting up ADB connection..."
max_attempts=10
attempt=1

while [ $attempt -le $max_attempts ]; do
    echo "ADB connection attempt $attempt/$max_attempts"
    
    # Try to connect to emulator
    adb connect emulator-5554 2>/dev/null
    
    # Check if device is connected
    if adb devices | grep -q "emulator-5554"; then
        echo "ADB connected successfully to emulator-5554"
        break
    else
        echo "ADB connection failed, waiting 10 seconds..."
        sleep 10
        attempt=$((attempt+1))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "Warning: Could not connect to emulator via ADB after $max_attempts attempts"
    echo "Emulator may still be starting up..."
fi

echo "Starting server..."
node server.js 