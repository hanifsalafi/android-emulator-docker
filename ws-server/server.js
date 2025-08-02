const WebSocket = require('ws');
const express = require('express');
const cors = require('cors');
const { spawn } = require('child_process');
const { exec } = require('child_process');

const app = express();
app.use(cors());
app.use(express.json());

// WebSocket server untuk kontrol emulator
const wss = new WebSocket.Server({ port: 9999 });

// HTTP server untuk API
const httpServer = app.listen(3000, () => {
  console.log('HTTP Server running on port 3000');
});

// Menyimpan koneksi WebSocket
const connections = new Map();

wss.on('connection', (ws, req) => {
  const clientId = Date.now().toString();
  connections.set(clientId, ws);
  
  console.log(`Client ${clientId} connected`);

  // Inisialisasi ADB connection
  exec('adb connect emulator-5554', (error, stdout, stderr) => {
    if (error) {
      console.log('ADB connection error:', error);
    } else {
      console.log('ADB connected:', stdout);
    }
  });

  // Handle pesan dari client
  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data);
      handleMessage(clientId, message);
    } catch (error) {
      console.log('Error parsing message:', error);
    }
  });

  ws.on('close', () => {
    connections.delete(clientId);
    console.log(`Client ${clientId} disconnected`);
  });
});

function handleMessage(clientId, message) {
  switch (message.type) {
    case 'touch':
      handleTouch(message.x, message.y, message.action);
      break;
    case 'key':
      handleKey(message.keyCode, message.action);
      break;
    case 'camera_stream':
      handleCameraStream(message.data);
      break;
    case 'screenshot':
      handleScreenshot(clientId);
      break;
    case 'app_launch':
      handleAppLaunch(message.packageName);
      break;
    default:
      console.log('Unknown message type:', message.type);
  }
}

function handleTouch(x, y, action) {
  const command = `adb shell input ${action} ${x} ${y}`;
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.log('Touch command error:', error);
    }
  });
}

function handleKey(keyCode, action) {
  const command = `adb shell input keyevent ${keyCode}`;
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.log('Key command error:', error);
    }
  });
}

function handleCameraStream(data) {
  // Stream kamera ke virtual device
  const ffmpeg = spawn('ffmpeg', [
    '-f', 'webm',
    '-i', 'pipe:0',
    '-f', 'v4l2',
    '-pix_fmt', 'yuv420p',
    '-s', '640x480',
    '/dev/video10'
  ]);

  ffmpeg.stdin.write(Buffer.from(data));
  ffmpeg.stderr.on('data', data => {
    console.log('FFmpeg:', data.toString());
  });
}

function handleScreenshot(clientId) {
  exec('adb shell screencap -p /sdcard/screenshot.png', (error) => {
    if (!error) {
      exec('adb pull /sdcard/screenshot.png /tmp/screenshot.png', (error) => {
        if (!error) {
          const ws = connections.get(clientId);
          if (ws) {
            ws.send(JSON.stringify({
              type: 'screenshot_ready',
              path: '/tmp/screenshot.png'
            }));
          }
        }
      });
    }
  });
}

function handleAppLaunch(packageName) {
  const command = `adb shell monkey -p ${packageName} -c android.intent.category.LAUNCHER 1`;
  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.log('App launch error:', error);
    }
  });
}

// API endpoints
app.get('/api/status', (req, res) => {
  exec('adb devices', (error, stdout, stderr) => {
    if (error) {
      res.json({ status: 'error', message: error.message });
    } else {
      res.json({ status: 'success', devices: stdout });
    }
  });
});

app.get('/api/apps', (req, res) => {
  exec('adb shell pm list packages -3', (error, stdout, stderr) => {
    if (error) {
      res.json({ status: 'error', message: error.message });
    } else {
      const apps = stdout.split('\n')
        .filter(line => line.startsWith('package:'))
        .map(line => line.replace('package:', ''));
      res.json({ status: 'success', apps });
    }
  });
});

app.post('/api/install', (req, res) => {
  const { apkPath } = req.body;
  exec(`adb install ${apkPath}`, (error, stdout, stderr) => {
    if (error) {
      res.json({ status: 'error', message: error.message });
    } else {
      res.json({ status: 'success', message: 'App installed successfully' });
    }
  });
});

console.log('WebSocket server running on port 9999');
console.log('HTTP API server running on port 3000');