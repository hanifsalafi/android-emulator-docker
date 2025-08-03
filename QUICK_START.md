# 🚀 Quick Start Guide (Ubuntu/Linux)

## Prasyarat
- Ubuntu 20.04/22.04 (atau distro Linux lain)
- Docker & docker-compose
- Browser modern (Chrome/Firefox)

## Langkah Cepat

### Option A: Setup Lengkap (dengan kamera)
```bash
# 1. Clone repository
git clone <repository-url>
cd android-emulator-docker

# 2. Install dependencies
sudo apt update && sudo apt install -y docker.io docker-compose ffmpeg v4l2loopback-dkms v4l-utils jq

# 3. Aktifkan virtual camera
sudo modprobe v4l2loopback video_nr=10 card_label="VirtualCam" exclusive_caps=1

# 4. Jalankan setup
sudo ./cmd/setup.sh

# 5. Jalankan solusi
./cmd/run.sh
```

### Option B: Setup Minimal (tanpa kamera)
```bash
# 1. Clone repository
git clone <repository-url>
cd android-emulator-docker

# 2. Jalankan setup minimal
sudo ./cmd/setup-minimal.sh

# 3. Jalankan solusi (pilih salah satu)
./cmd/run.sh                    # Auto-detect setup
# atau
./cmd/run-minimal.sh            # Minimal setup eksplisit
```

## Akses
- **Frontend**: http://38.47.180.165:8050
- **Emulator (noVNC)**: http://38.47.180.165:6080
- **API Test**: http://38.47.180.165:8050/test-api.html

## Script Management
| Script | Fungsi |
|--------|--------|
| `cmd/run.sh` | Menjalankan services (auto-detect setup) |
| `cmd/run-minimal.sh` | Menjalankan services (minimal setup) |
| `cmd/stop.sh` | Menghentikan semua services |
| `cmd/status.sh` | Menampilkan status services |
| `cmd/logs.sh` | Melihat logs services |
| `cmd/test-all.sh` | Menjalankan semua test & verifikasi |
| `cmd/test-api.sh` | Test API endpoints |
| `cmd/test-camera.sh` | Test kamera & virtual device |
| `cmd/setup.sh` | Setup environment lengkap (root) |
| `cmd/setup-minimal.sh` | Setup environment minimal (root) |

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