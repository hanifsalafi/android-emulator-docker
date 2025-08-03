#!/bin/bash

echo "Starting Android Emulator Controller (Minimal Setup)..."

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "This solution is designed for Linux. Please run on a Linux system."
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose > /dev/null 2>&1; then
    echo "docker-compose is not available. Please install it first."
    exit 1
fi

echo "Minimal setup detected - Camera streaming not available"
echo "To enable camera support, run: sudo ./cmd/setup.sh"

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
echo "   Frontend: http://38.47.180.165:8050"
echo "   Emulator (noVNC): http://38.47.180.165:6080"
echo ""
echo "🔧 Troubleshooting:"
echo "   View logs: ./cmd/logs.sh"
echo "   Check status: ./cmd/status.sh"
echo "   Restart: docker-compose restart"
echo "   Stop: ./cmd/stop.sh"
echo ""
echo "📷 Camera setup (Not available):"
echo "   Camera streaming is not available in minimal setup"
echo "   To enable camera: sudo ./cmd/setup.sh"
echo ""
echo "🎮 Basic controls:"
echo "   - Click on emulator area for touch input"
echo "   - Use navigation buttons for movement"
echo "   - Load apps to manage applications"
echo ""
echo "💡 Note: This is minimal setup without camera support"
echo "   For full features including camera, run: sudo ./cmd/setup.sh" 