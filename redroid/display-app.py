import os
import time
import subprocess
import threading
from flask import Flask, Response, render_template_string
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Redroid Display</title>
    <style>
        body { margin: 0; padding: 20px; font-family: Arial, sans-serif; }
        .container { max-width: 1200px; margin: 0 auto; }
        .status { padding: 10px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .screenshot { max-width: 100%; border: 1px solid #ddd; border-radius: 5px; }
        .controls { margin: 20px 0; }
        button { padding: 10px 20px; margin: 5px; border: none; border-radius: 5px; cursor: pointer; }
        .primary { background: #007bff; color: white; }
        .secondary { background: #6c757d; color: white; }
        .auto-refresh { background: #28a745; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Redroid Android Display</h1>
        <div id="status" class="status">Checking Redroid status...</div>
        <div class="controls">
            <button class="primary" onclick="takeScreenshot()">Take Screenshot</button>
            <button class="secondary" onclick="refreshStatus()">Refresh Status</button>
            <button class="auto-refresh" onclick="toggleAutoRefresh()">Start Auto Refresh</button>
        </div>
        <div id="screenshot-container"></div>
    </div>
    <script>
        let autoRefreshInterval = null;
        
        function takeScreenshot() {
            fetch('/screenshot')
                .then(response => response.blob())
                .then(blob => {
                    const url = URL.createObjectURL(blob);
                    const img = document.createElement('img');
                    img.src = url;
                    img.className = 'screenshot';
                    const container = document.getElementById('screenshot-container');
                    container.innerHTML = '';
                    container.appendChild(img);
                })
                .catch(error => {
                    console.error('Error:', error);
                    document.getElementById('status').innerHTML = '<div class="status error">Error taking screenshot</div>';
                });
        }
        
        function refreshStatus() {
            fetch('/status')
                .then(response => response.json())
                .then(data => {
                    const statusDiv = document.getElementById('status');
                    if (data.connected) {
                        statusDiv.innerHTML = '<div class="status success">Redroid connected: ' + data.device + '</div>';
                    } else {
                        statusDiv.innerHTML = '<div class="status error">Redroid not connected</div>';
                    }
                });
        }
        
        function toggleAutoRefresh() {
            const button = event.target;
            if (autoRefreshInterval) {
                clearInterval(autoRefreshInterval);
                autoRefreshInterval = null;
                button.textContent = 'Start Auto Refresh';
                button.className = 'auto-refresh';
            } else {
                autoRefreshInterval = setInterval(takeScreenshot, 2000);
                button.textContent = 'Stop Auto Refresh';
                button.className = 'secondary';
            }
        }
        
        // Auto-refresh status
        refreshStatus();
        setInterval(refreshStatus, 10000);
    </script>
</body>
</html>
"""

def ensure_adb_connection():
    """Ensure ADB is connected to Redroid with persistent connection"""
    try:
        # Start ADB server first
        subprocess.run(['adb', 'start-server'], timeout=10, capture_output=True)
        time.sleep(2)  # Wait for server to be ready
        
        # Kill any existing ADB connections
        subprocess.run(['adb', 'kill-server'], timeout=5, capture_output=True)
        time.sleep(2)
        subprocess.run(['adb', 'start-server'], timeout=10, capture_output=True)
        time.sleep(2)
        
        # Try multiple connection methods with retry
        connection_methods = [
            ['adb', 'connect', '38.47.180.165:5555']
        ]
        
        for method in connection_methods:
            try:
                print(f"Trying ADB connection: {' '.join(method)}")
                result = subprocess.run(method, timeout=15, capture_output=True, text=True)
                print(f"ADB connection result: {result.stdout}")
                
                if 'connected' in result.stdout.lower() or 'already connected' in result.stdout.lower():
                    # Verify connection is stable
                    time.sleep(3)
                    verify_result = subprocess.run(['adb', 'devices'], timeout=10, capture_output=True, text=True)
                    print(f"ADB devices verification: {verify_result.stdout}")
                    
                    if '38.47.180.165:5555' in verify_result.stdout or 'device' in verify_result.stdout:
                        print("ADB connection verified successfully")
                        return True
                    else:
                        print("ADB connection not stable, retrying...")
                        continue
                        
            except Exception as e:
                print(f"ADB connection failed for {' '.join(method)}: {e}")
                continue
        
        return False
    except Exception as e:
        print(f"ADB connection error: {e}")
        return False

def execute_adb_command(command, timeout=15):
    """Execute ADB command with connection check"""
    try:
        # Check if device is still connected
        devices_result = subprocess.run(['adb', 'devices'], timeout=10, capture_output=True, text=True)
        if 'device' not in devices_result.stdout or '38.47.180.165:5555' not in devices_result.stdout:
            print("Device not connected, reconnecting...")
            if not ensure_adb_connection():
                return False, "Failed to reconnect to device"
        
        # Execute the command
        result = subprocess.run(command, timeout=timeout, capture_output=True, text=True)
        return True, result.stdout
    except Exception as e:
        return False, str(e)

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/status')
def status():
    try:
        # Ensure ADB connection
        if not ensure_adb_connection():
            return {'connected': False, 'device': 'ADB connection failed'}
        
        success, output = execute_adb_command(['adb', 'devices'])
        if not success:
            return {'connected': False, 'device': f'Error: {output}'}
        
        devices = output.strip().split('\n')[1:]
        connected = any('device' in device for device in devices if device.strip())
        device_info = devices[0] if devices else 'No device'
        return {'connected': connected, 'device': device_info}
    except Exception as e:
        return {'connected': False, 'device': f'Error: {str(e)}'}

@app.route('/screenshot')
def screenshot():
    try:
        # Take screenshot using ADB with connection check
        success, output = execute_adb_command(['adb', 'shell', 'screencap', '-p', '/sdcard/screenshot.png'])
        if not success:
            return f'Screenshot capture failed: {output}', 500
        
        success, output = execute_adb_command(['adb', 'pull', '/sdcard/screenshot.png', '/tmp/screenshot.png'])
        if not success:
            return f'Screenshot pull failed: {output}', 500
        
        # Read and return the image
        with open('/tmp/screenshot.png', 'rb') as f:
            image_data = f.read()
        
        return Response(image_data, mimetype='image/png')
    except Exception as e:
        return str(e), 500

if __name__ == '__main__':
    print("Starting Redroid Display App...")
    
    # Wait for Redroid to be ready
    print("Waiting for Redroid to be ready...")
    time.sleep(30)
    
    # Try to establish ADB connection
    print("Establishing ADB connection...")
    if ensure_adb_connection():
        print("ADB connection established successfully")
    else:
        print("Warning: ADB connection failed, will retry on requests")
    
    print("Starting Flask app on port 6080...")
    app.run(host='0.0.0.0', port=6080, debug=False) 