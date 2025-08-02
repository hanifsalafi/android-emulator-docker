# Android Emulator Controller

Solusi lengkap untuk mengakses dan mengontrol emulator Android langsung dari browser dengan dukungan kamera browser dan kontrol interaktif.

## 🎯 Fitur Utama
- Kontrol emulator Android melalui browser
- Touch & keyboard input
- Streaming kamera browser ke emulator
- Screenshot emulator
- Manajemen aplikasi (list, launch, install)
- Web interface responsif
- WebSocket & HTTP API
- Dockerized

## 🚀 Quick Start (Ubuntu/Linux)

### Prasyarat
- Ubuntu 20.04/22.04 (atau distro Linux lain)
- Docker & docker-compose
- Browser modern (Chrome/Firefox)

### Instalasi
1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd android-emulator-docker
   ```

2. **Setup Environment (Pilih salah satu)**

   **Option A: Setup Lengkap (dengan kamera)**
   ```bash
   sudo apt update && sudo apt install -y docker.io docker-compose ffmpeg v4l2loopback-dkms v4l-utils jq
   sudo modprobe v4l2loopback video_nr=10 card_label="VirtualCam" exclusive_caps=1
   sudo ./cmd/setup.sh
   ```

   **Option B: Setup Minimal (tanpa kamera)**
   ```bash
   sudo ./cmd/setup-minimal.sh
   ```

3. **Jalankan solusi**
   ```bash
   ./cmd/run.sh
   ```

### Akses
- **Frontend**: http://localhost:8080
- **Emulator (noVNC)**: http://localhost:6080
- **API Test**: http://localhost:8080/test-api.html

## 🔧 Script Management
| Script | Fungsi |
|--------|--------|
| `cmd/run.sh` | Menjalankan semua services |
| `cmd/stop.sh` | Menghentikan semua services |
| `cmd/status.sh` | Menampilkan status services |
| `cmd/logs.sh` | Melihat logs services |
| `cmd/test-all.sh` | Menjalankan semua test & verifikasi |
| `cmd/test-api.sh` | Test API endpoints |
| `cmd/test-camera.sh` | Test kamera & virtual device |
| `cmd/setup.sh` | Setup environment lengkap (root) |
| `cmd/setup-minimal.sh` | Setup environment minimal (root) |

## 🎮 Cara Penggunaan
- Klik area emulator untuk tap
- Gunakan tombol navigasi (▲▼◀▶)
- Klik "Start Camera" untuk streaming kamera browser ke emulator
- Klik "Load Apps" untuk melihat aplikasi terinstall
- Klik nama aplikasi untuk menjalankan

## 🌐 API Endpoints
### WebSocket (ws://localhost:9999)
Lihat detail di file `FEATURES.md`.

### HTTP API (http://localhost:3000)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/status` | GET | Status koneksi ADB |
| `/api/apps` | GET | Daftar aplikasi terinstall |
| `/api/install` | POST | Install APK |

## 📷 Kamera Support
- **Setup Lengkap**: Kamera streaming tersedia
- **Setup Minimal**: Kamera streaming tidak tersedia (perlu install manual)
- Untuk troubleshooting, jalankan `./cmd/test-camera.sh`

## 🆘 Troubleshooting
- **Cek status**: `./cmd/status.sh`
- **Lihat logs**: `./cmd/logs.sh`
- **Test semua**: `./cmd/test-all.sh`
- **Test kamera**: `./cmd/test-camera.sh`
- **Test API**: `./cmd/test-api.sh`
- **Restart**: `docker-compose restart`
- **Stop**: `./cmd/stop.sh`

## 📋 Requirements
- Docker
- 4GB RAM (minimum)
- 10GB free disk space

## 🔒 Security
- WebSocket & HTTP API tanpa authentication (untuk development)
- Untuk production, tambahkan SSL/TLS & authentication

## 📄 License
MIT License

---
**Happy Emulating! 🎮📱**