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

3. **Jalankan solusi (Pilih salah satu)**

   **Auto-detect setup:**
   ```bash
   ./cmd/run.sh
   ```

   **Minimal setup (eksplisit):**
   ```bash
   ./cmd/run-minimal.sh
   ```

### Akses
- **Frontend**: http://38.47.180.165:8050
- **Emulator (noVNC)**: http://38.47.180.165:6080
- **API Test**: http://38.47.180.165:8050/test-api.html

## 🔧 Script Management
| Script | Fungsi |
|--------|--------|
| `cmd/run.sh` | Menjalankan services (auto-detect setup) |
| `cmd/run-minimal.sh` | Menjalankan services (minimal setup) |
| `cmd/stop.sh` | Menghentikan semua services |
| `cmd/restart.sh` | Restart services dengan cleanup |
| `cmd/status.sh` | Menampilkan status services |
| `cmd/logs.sh` | Melihat logs services |
| `cmd/check-emulator.sh` | Cek status emulator & ADB |
| `cmd/fix-adb.sh` | Perbaiki masalah ADB connection |
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
### WebSocket (ws://38.47.180.165:9999)
Lihat detail di file `FEATURES.md`.

### HTTP API (http://38.47.180.165:3000)
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

### Masalah Umum

#### 1. **Emulator Blank Screen / Tidak Muncul**
```bash
# Cek status emulator
./cmd/check-emulator.sh

# Restart services
./cmd/restart.sh

# Cek logs emulator
docker logs -f emulator

# Akses langsung via noVNC
# Buka: http://38.47.180.165:6080
```

#### 2. **ADB Connection Error**
```bash
# Cek ADB connection
docker exec emulator-controller adb devices

# Fix ADB connection
./cmd/fix-adb.sh

# Restart controller
docker restart emulator-controller

# Cek logs controller
docker logs -f emulator-controller
```

#### 3. **Camera Tidak Berfungsi**
```bash
# Test camera
./cmd/test-camera.sh

# Cek virtual device
ls -l /dev/video10

# Load module manual
sudo modprobe v4l2loopback video_nr=10
```

#### 4. **Services Tidak Start**
```bash
# Cek Docker
docker info

# Cek disk space
df -h

# Cek memory
free -h

# Restart Docker
sudo systemctl restart docker
```

### Langkah Troubleshooting Lengkap

1. **Cek Status Dasar**
   ```bash
   ./cmd/status.sh
   ./cmd/check-emulator.sh
   ```

2. **Restart Services**
   ```bash
   ./cmd/restart.sh
   ```

3. **Monitor Logs**
   ```bash
   ./cmd/logs.sh
   ```

4. **Test Connectivity**
   ```bash
   ./cmd/test-all.sh
   ```

5. **Akses Alternatif**
   - **noVNC langsung**: http://38.47.180.165:6080
   - **API test**: http://38.47.180.165:8050/test-api.html

### Tips Penting

- **Emulator boot time**: 2-5 menit (normal)
- **KVM required**: Pastikan virtualization enabled di BIOS
- **Memory minimum**: 4GB RAM
- **Disk space**: 10GB free space
- **Browser**: Gunakan Chrome/Firefox terbaru

### Error Messages & Solusi

| Error | Solusi |
|-------|--------|
| `no devices/emulators found` | Restart services, tunggu emulator boot |
| `v4l2loopback module not found` | Install: `sudo apt install v4l2loopback-dkms` |
| `KVM not found` | Enable virtualization di BIOS |
| `Connection refused` | Cek Docker service, restart jika perlu |
| `Permission denied` | Jalankan dengan `sudo` atau tambahkan user ke docker group |

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