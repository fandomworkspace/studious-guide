#!/bin/bash

# KDE Plasma Desktop Environment - Startup Script
# This script starts the X11 server, VNC server, and noVNC when the Codespace starts

set -e

echo "=== Starting KDE Plasma Desktop Environment ==="

# Export display variable
export DISPLAY=:1
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Create necessary runtime directories
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix
mkdir -p /var/run/dbus

# Start D-Bus daemon
echo "Starting D-Bus daemon..."
if ! pgrep -x dbus-daemon > /dev/null; then
    dbus-daemon --system 2>/dev/null || true
    sleep 1
fi

# Start PulseAudio daemon
echo "Starting PulseAudio..."
pulseaudio --start --exit-idle-time=-1 2>/dev/null || true
sleep 1

# Start Xvfb (X Virtual Frame Buffer)
echo "Starting X11 server (Xvfb)..."
Xvfb :1 -screen 0 1920x1080x24 -ac -extension GLX >/dev/null 2>&1 &
XVFB_PID=$!
echo "Xvfb PID: $XVFB_PID"
sleep 2

# Verify X server is running
if ! ps -p $XVFB_PID > /dev/null; then
    echo "ERROR: Failed to start Xvfb"
    exit 1
fi

# Initialize X11 session directory
eval "$(dbus-launch --sh-syntax)"

# Start VNC server (TigerVNC)
echo "Starting TigerVNC server..."

# Create VNC startup script
cat > /tmp/vncserver_start.sh << 'VNCSCRIPT'
#!/bin/bash
export DISPLAY=:1
export LANG=en_US.UTF-8

# Start KDE Plasma
echo "Starting KDE Plasma..."
startkde > /tmp/kde.log 2>&1 &
KDE_PID=$!

# Wait for KDE to start
sleep 3

# Keep process running
wait $KDE_PID
VNCSCRIPT

chmod +x /tmp/vncserver_start.sh

# Start VNC server with proper resolution and settings
vncserver :5900 -geometry 1920x1080 -depth 24 -dpi 96 -rfbport 5900 >/dev/null 2>&1 &
VNC_PID=$!
echo "VNC Server started at :5900 (PID: $VNC_PID)"
sleep 2

# Verify VNC server is running
if ! ps -p $VNC_PID > /dev/null 2>&1; then
    echo "WARNING: VNC server may not have started correctly"
fi

# Start KDE Plasma session
echo "Starting KDE Plasma session..."
export DISPLAY=:1
startkde > /tmp/kde.log 2>&1 &
KDE_PID=$!
echo "KDE Plasma PID: $KDE_PID"
sleep 3

# Start websockify (converts WebSocket to VNC socket)
echo "Starting noVNC/websockify..."

# Create noVNC HTML file if it doesn't exist
mkdir -p /usr/share/novnc
if [ ! -f /usr/share/novnc/vnc.html ]; then
    cat > /usr/share/novnc/vnc.html << 'NOVNCHTML'
<!DOCTYPE html>
<html>
<head>
    <title>KDE Plasma Desktop</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        html, body {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
            overflow: hidden;
            background: #1a1a1a;
        }
        #canvas {
            display: block;
            width: 100%;
            height: 100%;
        }
    </style>
</head>
<body>
    <div id="screen"></div>
    <script type="module">
        import RFB from 'https://cdn.jsdelivr.net/npm/@novnc/novnc@1.4.0/core/rfb.js';
        
        let rfb;
        
        function updateStatus(text, style = 'normal') {
            console.log(text);
        }
        
        function connFail(e) {
            let msg = e.detail.clean ? 'Disconnected' : 'Connection Failed';
            updateStatus(msg, 'error');
        }
        
        function connClose(e) {
            updateStatus('Disconnected', 'normal');
        }
        
        function updateDesktopName(e) {
            document.title = 'KDE Plasma - ' + rfb.desktopName;
        }
        
        // Get the protocol from current location
        const proto = window.location.protocol === 'https:' ? 'wss' : 'ws';
        const host = window.location.hostname;
        const port = window.location.port;
        const path = '/websockify';
        
        console.log('Connecting to VNC at:', proto + '://' + host + ':' + port + path);
        
        rfb = new RFB(
            document.getElementById('screen'),
            proto + '://' + host + ':' + port + path,
            { credentials: { password: 'password' } }
        );
        
        rfb.addEventListener('connect', () => {
            updateStatus('Connected');
        });
        rfb.addEventListener('disconnect', connClose);
        rfb.addEventListener('desktopname', updateDesktopName);
        rfb.addEventListener('error', connFail);
        
        // Request full screen
        window.addEventListener('fullscreenchange', () => {
            if (document.fullscreenElement) {
                rfb.focus();
            }
        });
    </script>
</body>
</html>
NOVNCHTML
fi

# Start websockify on port 6080
websockify --web=/usr/share/novnc 6080 localhost:5900 > /tmp/websockify.log 2>&1 &
WEBSOCKIFY_PID=$!
echo "noVNC/websockify started on port 6080 (PID: $WEBSOCKIFY_PID)"

echo ""
echo "========================================="
echo "KDE Plasma Desktop is Ready!"
echo "========================================="
echo ""
echo "Access the desktop at:"
echo "  http://localhost:6080/vnc.html"
echo ""
echo "Or via Codespaces forwarded port:"
echo "  https://<your-codespace-url>/ports/6080"
echo ""
echo "Desktop Details:"
echo "  Display: $DISPLAY"
echo "  Resolution: 1920x1080"
echo "  VNC Port: 5900"
echo "  WebSocket Port: 6080"
echo ""
echo "Available Applications:"
echo "  - Firefox (browser)"
echo "  - Dolphin (file manager)"
echo "  - Konsole (terminal)"
echo "  - Kate (text editor)"
echo "  - Spectacle (screenshot tool)"
echo "  - Ark (archive manager)"
echo "  - Gwenview (image viewer)"
echo "  - Okular (PDF reader)"
echo "  - KCalc (calculator)"
echo "  - KSystemMonitor (system monitor)"
echo ""
echo "Logs:"
echo "  KDE: /tmp/kde.log"
echo "  Websockify: /tmp/websockify.log"
echo ""

# Keep the script running
echo "Keeping desktop environment alive..."
while true; do
    sleep 10
    # Check if critical processes are still running
    if ! ps -p $XVFB_PID > /dev/null 2>&1; then
        echo "ERROR: X server has stopped"
        break
    fi
    if ! ps -p $WEBSOCKIFY_PID > /dev/null 2>&1; then
        echo "WARNING: Websockify has stopped, restarting..."
        websockify --web=/usr/share/novnc 6080 localhost:5900 > /tmp/websockify.log 2>&1 &
        WEBSOCKIFY_PID=$!
    fi
done
