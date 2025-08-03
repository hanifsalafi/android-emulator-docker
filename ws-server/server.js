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
    
    // Use IP and port for traditional emulator
    exec('adb connect 38.47.180.165:5555', (error, stdout, stderr) => {
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
          if (stdout.includes('38.47.180.165:5555')) {
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
  
  // Try to connect ADB for each new client
  exec('adb connect 38.47.180.165:5555', (error, stdout, stderr) => {
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
  console.log(`Touch: x=${x}, y=${y}, action=${action}`);
  
  // Check if device is connected
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('38.47.180.165:5555')) {
      console.log('Device not connected, attempting to reconnect...');
      exec('adb connect 38.47.180.165:5555', (error, stdout, stderr) => {
        if (error) {
          console.log('Reconnection failed:', error.message);
          return;
        }
      });
    }
    
    // Execute touch command
    const command = `adb shell input touchscreen ${action} ${x} ${y}`;
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.log('Touch command error:', error.message);
      } else {
        console.log('Touch command executed successfully');
      }
    });
  });
}

function handleKey(keyCode, action) {
  console.log(`Key: keyCode=${keyCode}, action=${action}`);
  
  // Check if device is connected
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('38.47.180.165:5555')) {
      console.log('Device not connected, attempting to reconnect...');
      exec('adb connect 38.47.180.165:5555', (error, stdout, stderr) => {
        if (error) {
          console.log('Reconnection failed:', error.message);
          return;
        }
      });
    }
    
    // Execute key command
    const command = `adb shell input keyevent ${keyCode}`;
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.log('Key command error:', error.message);
      } else {
        console.log('Key command executed successfully');
      }
    });
  });
}

function handleCameraStream(data) {
  console.log('Camera stream data received, length:', data.length);
  
  // Convert base64 data to buffer
  const buffer = Buffer.from(data, 'base64');
  
  // Save to virtual video device
  const fs = require('fs');
  try {
    fs.writeFileSync('/dev/video10', buffer);
    console.log('Camera data written to /dev/video10');
  } catch (error) {
    console.log('Error writing to video device:', error.message);
  }
}

function handleScreenshot(clientId) {
  console.log('Screenshot request from client:', clientId);
  
  // Check if device is connected
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('38.47.180.165:5555')) {
      console.log('Device not connected, attempting to reconnect...');
      exec('adb connect 38.47.180.165:5555', (error, stdout, stderr) => {
        if (error) {
          console.log('Reconnection failed:', error.message);
          return;
        }
      });
    }
    
    // Take screenshot
    exec('adb shell screencap -p /sdcard/screenshot.png', (error, stdout, stderr) => {
      if (error) {
        console.log('Screenshot error:', error.message);
        return;
      }
      
      // Pull screenshot to host
      exec('adb pull /sdcard/screenshot.png /tmp/screenshot.png', (error, stdout, stderr) => {
        if (error) {
          console.log('Screenshot pull error:', error.message);
        } else {
          console.log('Screenshot saved to /tmp/screenshot.png');
          
          // Send screenshot to client
          const ws = connections.get(clientId);
          if (ws && ws.readyState === WebSocket.OPEN) {
            const fs = require('fs');
            try {
              const imageData = fs.readFileSync('/tmp/screenshot.png');
              const base64Data = imageData.toString('base64');
              ws.send(JSON.stringify({
                type: 'screenshot',
                data: base64Data
              }));
            } catch (error) {
              console.log('Error reading screenshot:', error.message);
            }
          }
        }
      });
    });
  });
}

function handleAppLaunch(packageName) {
  console.log('App launch request:', packageName);
  
  // Check if device is connected
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('38.47.180.165:5555')) {
      console.log('Device not connected, attempting to reconnect...');
      exec('adb connect 38.47.180.165:5555', (error, stdout, stderr) => {
        if (error) {
          console.log('Reconnection failed:', error.message);
          return;
        }
      });
    }
    
    // Launch app using monkey
    const command = `adb shell monkey -p ${packageName} -c android.intent.category.LAUNCHER 1`;
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.log('App launch error:', error.message);
      } else {
        console.log('App launched successfully');
      }
    });
  });
}

// HTTP API endpoints
app.get('/api/status', (req, res) => {
  exec('adb devices', (error, stdout, stderr) => {
    const isConnected = stdout.includes('38.47.180.165:5555');
    res.json({
      connected: isConnected,
      devices: stdout,
      timestamp: new Date().toISOString()
    });
  });
});

app.get('/api/apps', (req, res) => {
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('38.47.180.165:5555')) {
      res.json({ error: 'Device not connected' });
      return;
    }
    
    exec('adb shell pm list packages -3', (error, stdout, stderr) => {
      if (error) {
        res.json({ error: 'Failed to get apps' });
      } else {
        const apps = stdout.split('\n')
          .filter(line => line.startsWith('package:'))
          .map(line => line.replace('package:', ''));
        res.json({ apps });
      }
    });
  });
});

app.post('/api/install', (req, res) => {
  const { apkPath } = req.body;
  
  if (!apkPath) {
    res.json({ error: 'APK path required' });
    return;
  }
  
  exec('adb devices', (error, stdout, stderr) => {
    if (error || !stdout.includes('38.47.180.165:5555')) {
      res.json({ error: 'Device not connected' });
      return;
    }
    
    exec(`adb install ${apkPath}`, (error, stdout, stderr) => {
      if (error) {
        res.json({ error: 'Installation failed' });
      } else {
        res.json({ success: 'App installed successfully' });
      }
    });
  });
});