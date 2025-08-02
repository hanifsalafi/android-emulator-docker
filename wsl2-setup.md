# Setup Android Emulator Controller di Ubuntu/Linux

Panduan ini untuk menjalankan solusi Android Emulator Controller di Ubuntu/Linux dengan dukungan kamera penuh.

## Prasyarat

1. **Ubuntu 20.04/22.04** (atau distro Linux lain)
2. **Docker** & **docker-compose**
3. **ffmpeg**, **v4l2loopback-dkms**, **v4l-utils**, **jq**

## Setup Environment

### 1. Update system
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install dependencies
```bash
sudo apt install -y \
    v4l2loopback-dkms \
    v4l-utils \
    ffmpeg \
    docker.io \
    docker-compose \
    jq
```

### 3. Load v4l2loopback module
```bash
sudo modprobe v4l2loopback video_nr=10 card_label="VirtualCam" exclusive_caps=1
```

### 4. Make module persistent (opsional)
```bash
echo "v4l2loopback video_nr=10 card_label=VirtualCam exclusive_caps=1" | sudo tee -a /etc/modules
```

## Setup Project

### 1. Clone project
```bash
git clone <repository-url>
cd android-emulator-docker
```

### 2. Set permissions (opsional)
```bash
chmod +x cmd/*.sh
```

### 3. Run setup (opsional)
```bash
sudo ./cmd/setup.sh
```

### 4. Start services
```bash
./cmd/run.sh
```

## Troubleshooting

### Kamera tidak terdeteksi
```bash
# Cek video devices
ls -l /dev/video*

# Reload module
sudo modprobe -r v4l2loopback
sudo modprobe v4l2loopback video_nr=10
```

### Docker tidak berjalan
```bash
# Start Docker service
sudo service docker start

# Check status
sudo service docker status
```

### Permission denied
```bash
# Set permissions
sudo chmod 666 /dev/video10
sudo chmod 666 /dev/kvm
```

## Performance Tips

1. **Memory allocation**: Pastikan sistem memiliki cukup RAM (minimal 4GB)
2. **CPU cores**: Alokasikan minimal 2 CPU cores
3. **Storage**: Gunakan SSD untuk performa lebih baik

## Access Points
- **Frontend**: http://localhost:9080
- **Emulator (noVNC)**: http://localhost:6080
- **API Test**: http://localhost:9080/test-api.html

---
**Happy Emulating! 🎮📱** 