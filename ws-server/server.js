const WebSocket = require('ws');
const express = require('express');
const cors = require('cors');
const { spawn } = require('child_process');
const { exec } = require('child_process');

const app = express();
app.use(cors());
app.use(express.json());

const wss = new WebSocket.Server({ port: 9999 });
const httpServer = app.listen(3000, () => {
  console.log('HTTP Server running on port 3000');
});

const connections = new Map();

// ADB connection retry mechanism
function connectADB(maxAttempts = 10) {
  let attempts = 0;
  
  function tryConnect() {
    attempts++;
    console.log(`ADB connection attempt ${attempts}/${maxAttempts}`);
    
    // Use correct ADB connect format (without port)
    exec('adb connect emulator-5554', (error, stdout, stderr) => {
      if (error) {
        console.log('ADB connection error:', error.message);
        if (attempts < maxAttempts) {
          console.log('Retrying in 10 seconds...');
          setTimeout(tryConnect, 10000);
        } else {
          console.log('Failed to connect ADB after maximum attempts');
        }
      } else {
        console.log('ADB connected successfully:', stdout);
        // Verify connection
        exec('adb devices', (error, stdout, stderr) => {
          if (stdout.includes('emulator-5554')) {
            console.log('Emulator confirmed connected:', stdout);
          } else {
            console.log('Emulator not found in devices list');
          }
        });
      }
    });
  }
  
  tryConnect();
}

// Initialize ADB connection on startup
connectADB();

wss.on('connection', (ws, req) => {
  const clientId = Date.now().toString();
  connections.set(clientId, ws);
  console.log(`Client ${clientId} connected`);
  
  // Try to connect ADB for each new client (without port)
  exec('adb connect emulator-5554', (error, stdout, stderr) => {
    if (error) {
      console.log('ADB connection error:', error.message);
    } else {
      console.log('ADB connected:', stdout);
    }
  });
  
  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data);
      handleMessage(clientId, message);
    } catch (error) {
      console.error('Error parsing message:', error);
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
  console.log(`Touch: ${action} at (${x}, ${y})`);
  
  // Check if emulator is connected first
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('emulator-5554')) {
      console.log('Emulator not connected, attempting to connect...');
      exec('adb connect emulator-5554', (error, stdout, stderr) => {
        if (error) {
          console.log('Failed to connect to emulator');
          return;
        }
        // Retry touch command after connection
        setTimeout(() => handleTouch(x, y, action), 2000);
      });
      return;
    }
    
    // Execute touch command
    exec(`adb shell input tap ${x} ${y}`, (error, stdout, stderr) => {
      if (error) {
        console.log('Touch command error:', error);
      } else {
        console.log('Touch command executed successfully');
      }
    });
  });
}

function handleKey(keyCode, action) {
  console.log(`Key: ${action} keyCode ${keyCode}`);
  
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('emulator-5554')) {
      console.log('Emulator not connected for key command');
      return;
    }
    
    exec(`adb shell input keyevent ${keyCode}`, (error, stdout, stderr) => {
      if (error) {
        console.log('Key command error:', error);
      } else {
        console.log('Key command executed successfully');
      }
    });
  });
}

function handleCameraStream(data) {
  // Check if v4l2loopback is available
  exec('ls /dev/video10', (error, stdout, stderr) => {
    if (error) {
      console.log('Virtual video device not available for camera streaming');
      return;
    }
    
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
  });
}

function handleScreenshot(clientId) {
  console.log('Taking screenshot...');
  
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('emulator-5554')) {
      console.log('Emulator not connected for screenshot');
      return;
    }
    
    exec('adb shell screencap -p /sdcard/screenshot.png', (error, stdout, stderr) => {
      if (error) {
        console.log('Screenshot capture error:', error);
        return;
      }
      
      exec('adb pull /sdcard/screenshot.png /tmp/screenshot.png', (error, stdout, stderr) => {
        if (error) {
          console.log('Screenshot pull error:', error);
        } else {
          console.log('Screenshot saved to /tmp/screenshot.png');
          const ws = connections.get(clientId);
          if (ws && ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({
              type: 'screenshot_ready',
              path: '/tmp/screenshot.png'
            }));
          }
        }
      });
    });
  });
}

function handleAppLaunch(packageName) {
  console.log(`Launching app: ${packageName}`);
  
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('emulator-5554')) {
      console.log('Emulator not connected for app launch');
      return;
    }
    
    exec(`adb shell monkey -p ${packageName} -c android.intent.category.LAUNCHER 1`, (error, stdout, stderr) => {
      if (error) {
        console.log('App launch error:', error);
      } else {
        console.log('App launched successfully');
      }
    });
  });
}

// API endpoints
app.get('/api/status', (req, res) => {
  exec('adb devices', (error, stdout, stderr) => {
    if (error) {
      res.json({ status: 'error', message: 'ADB not available' });
    } else {
      const isConnected = stdout.includes('emulator-5554');
      res.json({ 
        status: 'success', 
        connected: isConnected,
        devices: stdout.trim()
      });
    }
  });
});

app.get('/api/apps', (req, res) => {
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('emulator-5554')) {
      res.json({ status: 'error', message: 'Emulator not connected' });
      return;
    }
    
    exec('adb shell pm list packages -3', (error, stdout, stderr) => {
      if (error) {
        res.json({ status: 'error', message: 'Failed to get apps' });
      } else {
        const apps = stdout.split('\n')
          .filter(line => line.startsWith('package:'))
          .map(line => line.replace('package:', ''));
        res.json({ status: 'success', apps: apps });
      }
    });
  });
});

app.post('/api/install', (req, res) => {
  const { apkPath } = req.body;
  if (!apkPath) {
    res.json({ status: 'error', message: 'APK path required' });
    return;
  }
  
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('emulator-5554')) {
      res.json({ status: 'error', message: 'Emulator not connected' });
      return;
    }
    
    exec(`adb install ${apkPath}`, (error, stdout, stderr) => {
      if (error) {
        res.json({ status: 'error', message: 'Installation failed' });
      } else {
        res.json({ status: 'success', message: 'APK installed successfully' });
      }
    });
  });
});

console.log('WebSocket server running on port 9999');
console.log('HTTP API server running on port 3000');