const WebSocket = require('ws');
const { spawn } = require('child_process');

console.log('Testing camera streaming...');

// Test WebSocket connection
const ws = new WebSocket('ws://38.47.180.165:9999');

ws.on('open', () => {
    console.log('Connected to WebSocket server');
    
    // Test camera stream message
    const testData = new Array(1024).fill(0); // Dummy video data
    ws.send(JSON.stringify({
        type: 'camera_stream',
        data: testData
    }));
    
    console.log('Sent test camera data');
    
    setTimeout(() => {
        ws.close();
        console.log('Test completed');
    }, 2000);
});

ws.on('message', (data) => {
    console.log('Received:', data.toString());
});

ws.on('error', (error) => {
    console.error('WebSocket error:', error);
});

// Test virtual video device
const { exec } = require('child_process');
exec('ls -l /dev/video*', (error, stdout, stderr) => {
    if (error) {
        console.error('Error checking video devices:', error);
    } else {
        console.log('Available video devices:');
        console.log(stdout);
    }
});

// Test FFmpeg
exec('ffmpeg -version', (error, stdout, stderr) => {
    if (error) {
        console.error('FFmpeg not available:', error);
    } else {
        console.log('FFmpeg is available');
    }
}); 