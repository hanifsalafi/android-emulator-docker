#!/bin/bash

echo "========================================"
echo "  Verifying Android Redroid Status"
echo "========================================"
echo

# Check if services are running
if ! docker-compose ps | grep -q "Up"; then
    echo "[ERROR] No Redroid services are currently running!"
    echo "Please start services first with: ./run.sh"
    exit 1
fi

echo "[1/8] Checking container status..."
docker-compose ps

echo
echo "[2/8] Checking Redroid container specifically..."
if docker ps | grep -q "android-redroid"; then
    echo "[OK] android-redroid container is running"
    docker ps | grep android-redroid
else
    echo "[ERROR] android-redroid container not found!"
    exit 1
fi

echo
echo "[3/8] Checking Redroid container logs..."
echo "Last 20 lines of Redroid logs:"
docker logs --tail 20 android-redroid 2>/dev/null || echo "No Redroid logs found"

echo
echo "[4/8] Checking Redroid container processes..."
echo "Running processes in Redroid container:"
docker exec android-redroid ps aux 2>/dev/null || echo "Cannot access Redroid container processes"

echo
echo "[5/8] Checking Android system properties..."
echo "Android version:"
docker exec android-redroid getprop ro.build.version.release 2>/dev/null || echo "Cannot get Android version"

echo "Android API level:"
docker exec android-redroid getprop ro.build.version.sdk 2>/dev/null || echo "Cannot get API level"

echo "Device model:"
docker exec android-redroid getprop ro.product.model 2>/dev/null || echo "Cannot get device model"

echo
echo "[6/8] Checking ADB connection..."
echo "ADB devices:"
docker exec redroid-controller adb devices 2>/dev/null || echo "ADB not available"

echo "Testing ADB connection to Redroid:"
docker exec redroid-controller adb connect localhost:5555 2>/dev/null || echo "ADB connection failed"

echo "ADB devices after connection:"
docker exec redroid-controller adb devices 2>/dev/null || echo "ADB devices command failed"

echo
echo "[7/8] Checking Android services..."
echo "Running Android services:"
docker exec android-redroid dumpsys activity services | head -20 2>/dev/null || echo "Cannot get Android services"

echo
echo "[8/8] Checking Android apps..."
echo "Installed apps (first 10):"
docker exec android-redroid pm list packages -3 | head -10 2>/dev/null || echo "Cannot get installed apps"

echo
echo "========================================"
echo "  Accessibility Test"
echo "========================================"
echo

# Test noVNC accessibility
echo "Testing noVNC accessibility..."
if curl -s --max-time 10 "http://localhost:6080" > /dev/null 2>&1; then
    echo "[SUCCESS] noVNC is accessible at http://localhost:6080"
else
    echo "[ERROR] noVNC is not accessible"
fi

# Test frontend accessibility
echo "Testing frontend accessibility..."
if curl -s --max-time 10 "http://localhost:8050" > /dev/null 2>&1; then
    echo "[SUCCESS] Frontend is accessible at http://localhost:8050"
else
    echo "[ERROR] Frontend is not accessible"
fi

# Test API accessibility
echo "Testing API accessibility..."
if curl -s --max-time 10 "http://localhost:3000/api/status" > /dev/null 2>&1; then
    echo "[SUCCESS] API is accessible at http://localhost:3000/api/status"
else
    echo "[ERROR] API is not accessible"
fi

echo
echo "========================================"
echo "  Summary"
echo "========================================"
echo

# Count successful checks
success_count=0
total_checks=8

if docker ps | grep -q "android-redroid"; then
    echo "✅ Container running"
    success_count=$((success_count+1))
else
    echo "❌ Container not running"
fi

if docker logs android-redroid 2>/dev/null | grep -q "Android"; then
    echo "✅ Android logs found"
    success_count=$((success_count+1))
else
    echo "❌ No Android logs"
fi

if docker exec android-redroid getprop ro.build.version.release 2>/dev/null | grep -q "[0-9]"; then
    echo "✅ Android version detected"
    success_count=$((success_count+1))
else
    echo "❌ Android version not detected"
fi

if docker exec redroid-controller adb devices 2>/dev/null | grep -q "device"; then
    echo "✅ ADB device connected"
    success_count=$((success_count+1))
else
    echo "❌ ADB device not connected"
fi

if curl -s --max-time 5 "http://localhost:6080" > /dev/null 2>&1; then
    echo "✅ noVNC accessible"
    success_count=$((success_count+1))
else
    echo "❌ noVNC not accessible"
fi

if curl -s --max-time 5 "http://localhost:8050" > /dev/null 2>&1; then
    echo "✅ Frontend accessible"
    success_count=$((success_count+1))
else
    echo "❌ Frontend not accessible"
fi

if curl -s --max-time 5 "http://localhost:3000/api/status" > /dev/null 2>&1; then
    echo "✅ API accessible"
    success_count=$((success_count+1))
else
    echo "❌ API not accessible"
fi

if docker exec android-redroid pm list packages 2>/dev/null | grep -q "package:"; then
    echo "✅ Android apps detected"
    success_count=$((success_count+1))
else
    echo "❌ No Android apps detected"
fi

echo
echo "========================================"
echo "  Final Result: $success_count/$total_checks checks passed"
echo "========================================"

if [ $success_count -eq $total_checks ]; then
    echo "🎉 Android Redroid is running perfectly!"
elif [ $success_count -ge 6 ]; then
    echo "✅ Android Redroid is running well with minor issues"
elif [ $success_count -ge 4 ]; then
    echo "⚠️  Android Redroid is partially running"
else
    echo "❌ Android Redroid has significant issues"
fi

echo
echo "Access URLs:"
echo "- Frontend: http://localhost:8050"
echo "- noVNC: http://localhost:6080"
echo "- API: http://localhost:3000/api/status"
echo 