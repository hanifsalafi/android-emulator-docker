# Redroid Android Emulator

Solusi Android emulator modern menggunakan Redroid yang lebih stabil dan efisien.

## 🚀 Keunggulan Redroid

- ✅ **Lebih stabil** - Tidak ada service crash
- ✅ **Lebih ringan** - Resource usage lebih efisien  
- ✅ **Lebih cepat** - Boot time 2-3 menit
- ✅ **Lebih modern** - Android 11+ dengan kernel modern
- ✅ **Lebih mudah** - Setup lebih sederhana

## 📋 Prasyarat

- Ubuntu 20.04/22.04 (atau distro Linux lain)
- Docker & docker-compose
- KVM support enabled
- Browser modern (Chrome/Firefox)

## 🚀 Quick Start

### 1. Setup Environment
```bash
# Di server Linux Anda
cd redroid

# Set permissions
chmod +x *.sh
```

### 2. Jalankan Redroid
```bash
./run.sh
```

### 3. Akses
- **Frontend**: http://38.47.180.165:8050
- **noVNC**: http://38.47.180.165:6080
- **API**: http://38.47.180.165:3000/api/status

## 🔧 Script Management

| Script | Fungsi |
|--------|--------|
| `run.sh` | Menjalankan Redroid services |
| `stop.sh` | Menghentikan semua services |
| `status.sh` | Menampilkan status services |
| `logs.sh` | Melihat logs services |

## 🎮 Cara Penggunaan

- Klik area emulator untuk tap
- Gunakan tombol navigasi (▲▼◀▶)
- Klik "Start Camera" untuk streaming kamera browser ke emulator
- Klik "Load Apps" untuk melihat aplikasi terinstall
- Klik nama aplikasi untuk menjalankan

## 🌐 API Endpoints

### WebSocket (ws://38.47.180.165:9999)
- Touch events
- Keyboard events
- Camera streaming
- App management

### HTTP API (http://38.47.180.165:3000)
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/status` | GET | Status koneksi ADB |
| `/api/apps` | GET | Daftar aplikasi terinstall |
| `/api/install` | POST | Install APK |

## 📷 Kamera Support

- **Setup Lengkap**: Kamera streaming tersedia
- **Setup Minimal**: Kamera streaming tidak tersedia
- Untuk troubleshooting, jalankan `./status.sh`

## 🆘 Troubleshooting

### Masalah Umum

#### 1. **Redroid Tidak Boot**
```bash
# Cek KVM
ls -l /dev/kvm

# Cek logs
./logs.sh

# Restart
./stop.sh && ./run.sh
```

#### 2. **noVNC Tidak Bisa Diakses**
```bash
# Cek status
./status.sh

# Cek logs Redroid
docker logs -f android-redroid
```

#### 3. **ADB Connection Error**
```bash
# Cek ADB
docker exec redroid-controller adb devices

# Restart controller
docker restart redroid-controller
```

## 📊 Perbandingan dengan Emulator Tradisional

| Feature | Redroid | Traditional Emulator |
|---------|---------|---------------------|
| **Boot Time** | 2-3 menit | 5-10 menit |
| **Stability** | ✅ Sangat stabil | ❌ Service crash |
| **Resource Usage** | ✅ Efisien | ❌ Resource intensive |
| **Setup** | ✅ Mudah | ❌ Kompleks |
| **Performance** | ✅ Cepat | ❌ Lambat |

## 🔒 Security

- WebSocket & HTTP API tanpa authentication (untuk development)
- Untuk production, tambahkan SSL/TLS & authentication

## 📄 License

MIT License

---
**Happy Redroid Emulating! 🎮📱** 