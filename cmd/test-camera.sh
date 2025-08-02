#!/bin/bash

echo "========================================"
echo "  Camera Test - Android Emulator Controller"
echo "========================================"
echo

echo "[1/3] Checking virtual video device..."
if [ -e /dev/video10 ]; then
  echo "[OK] Virtual video device /dev/video10 found."
else
  echo "[ERROR] Virtual video device /dev/video10 not found!"
  echo "Please run: sudo modprobe v4l2loopback video_nr=10"
  exit 1
fi

echo "[2/3] Checking FFmpeg..."
if ffmpeg -version > /dev/null 2>&1; then
  echo "[OK] FFmpeg is available."
else
  echo "[ERROR] FFmpeg is not installed!"
  exit 1
fi

echo "[3/3] Testing camera streaming..."
echo "- Open http://localhost:9080 in your browser."
echo "- Click 'Start Camera' and allow camera access."
echo "- Open camera app in emulator (http://localhost:6080)."
echo "- You should see your browser camera feed in the emulator."
echo

echo "Camera test completed!" 