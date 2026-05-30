#!/bin/bash

# KDE Plasma Desktop Environment - Installation Script
# This script runs during devcontainer creation to finalize setup

set -e

echo "=== KDE Plasma Desktop Installation ==="

# Configure locales
echo "Configuring locales..."
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p /root/.vnc
mkdir -p /root/.config/pulse
mkdir -p /root/.local/share/applications
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Configure PulseAudio for container environment
echo "Configuring PulseAudio..."
mkdir -p /root/.config/pulse
cat > /root/.config/pulse/client.conf << 'EOF'
autospawn = no
daemon-binary = /bin/true
EOF

# Create VNC configuration
echo "Setting up VNC server configuration..."
mkdir -p /root/.vnc

# Create xvfb-run wrapper for VNC server
cat > /root/.vnc/xvfb_startup << 'EOF'
#!/bin/bash
/usr/bin/Xvfb :1 -screen 0 1920x1080x24 -ac &
XVFB_PID=$!
sleep 2
export DISPLAY=:1

# Start D-Bus session bus
eval "$(dbus-launch --sh-syntax)"

# Start PulseAudio
pulseaudio --start --exit-idle-time=-1 2>/dev/null || true

# Start KDE Plasma
/usr/bin/startkde > /tmp/kde.log 2>&1 &
KDE_PID=$!

# Wait for both processes
wait $KDE_PID $XVFB_PID
EOF

chmod +x /root/.vnc/xvfb_startup

# Create systemd service files (for manual startup if needed)
mkdir -p /etc/systemd/system

cat > /etc/systemd/system/vncserver.service << 'EOF'
[Unit]
Description=VNC Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/start-vncserver.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Configure KDE Plasma minimal settings
echo "Configuring KDE Plasma..."
mkdir -p /root/.config/plasmarc
cat > /root/.config/plasmarc << 'EOF'
[General]
theme=org.kde.desktop

[PlasmaPlugins]
enable-unredirected-fullscreen=false

[Containments]
version=2
EOF

mkdir -p /root/.config/kwinrc
cat > /root/.config/kwinrc << 'EOF'
[General]
BorderlessMaximizedWindows=true
SideSwitchScreen=false
SideSwitchTestOnEdge=false

[Compositing]
Enabled=false
CompositeMode=1

[ScreenEdges]
ElectricBorders=0
EOF

# Create Konsole configuration
mkdir -p /root/.config/konsolerc
cat > /root/.config/konsolerc << 'EOF'
[General]
StartInCurrentSessionDir=true
EOF

# Create Kate configuration
mkdir -p /root/.config/katerc
cat > /root/.config/katerc << 'EOF'
[General]
Start Session=manual
EOF

# Ensure permissions
chown -R root:root /root/.config
chmod -R 700 /root/.config

echo "=== Installation Complete ==="
echo "Desktop environment is ready for startup."
