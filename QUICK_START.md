# 🚀 Quick Start Guide (Ubuntu/Linux)

## Prasyarat
- Ubuntu 20.04/22.04 (atau distro Linux lain)
- Docker & docker-compose
- Browser modern (Chrome/Firefox)

## Langkah Cepat
```bash
# 1. Clone repository
git clone <repository-url>
cd android-emulator-docker

# 2. Install dependencies
sudo apt update && sudo apt install -y docker.io docker-compose ffmpeg v4l2loopback-dkms v4l-utils jq

# 3. Aktifkan virtual camera
sudo modprobe v4l2loopback video_nr=10 card_label="VirtualCam" exclusive_caps=1

# 4. Jalankan setup (opsional)
sudo ./cmd/setup.sh

# 5. Jalankan solusi
./cmd/run.sh
```

## Akses
- **Frontend**: http://localhost:8080
- **Emulator (noVNC)**: http://localhost:6080
- **API Test**: http://localhost:8080/test-api.html

## Script Management
| Script | Fungsi |
|--------|--------|
| `cmd/run.sh` | Menjalankan semua services |
| `cmd/stop.sh` | Menghentikan semua services |
| `cmd/status.sh` | Menampilkan status services |
| `cmd/logs.sh` | Melihat logs services |
| `cmd/test-all.sh` | Menjalankan semua test & verifikasi |
| `cmd/test-api.sh` | Test API endpoints |
| `cmd/test-camera.sh` | Test kamera & virtual device |
| `cmd/setup.sh` | Setup environment (root) |

## Troubleshooting
- **Cek status**: `./cmd/status.sh`
- **Lihat logs**: `./cmd/logs.sh`
- **Test semua**: `./cmd/test-all.sh`
- **Test kamera**: `./cmd/test-camera.sh`
- **Test API**: `./cmd/test-api.sh`
- **Restart**: `docker-compose restart`
- **Stop**: `./cmd/stop.sh`

---
**Happy Emulating! 🎮📱** 