# KDE Plasma Desktop Environment for GitHub Codespaces

A complete, production-ready GitHub Codespaces development environment featuring a full KDE Plasma desktop experience accessible directly from your web browser via noVNC.

## Features

✅ **Full Desktop Environment**
- KDE Plasma 5 desktop with X11 display server
- Native Linux desktop experience in the browser
- 1920x1080 resolution at 24-bit color depth

✅ **Remote Access**
- noVNC web-based VNC viewer (no client installation needed)
- WebSocket-based connection via websockify
- Automatic port forwarding in Codespaces
- Secure HTTPS support

✅ **Pre-installed Applications**
- **Firefox** - Full web browser
- **Dolphin** - File manager with advanced features
- **Konsole** - Powerful terminal emulator
- **Kate** - Advanced text editor with syntax highlighting
- **Spectacle** - Screenshot and screen recording tool
- **Ark** - Archive manager (zip, tar, 7z, etc.)
- **Gwenview** - Image viewer with editing capabilities
- **Okular** - PDF reader and document viewer
- **KCalc** - Scientific calculator
- **KSystemMonitor** - System resource monitoring

✅ **Optimizations**
- Minimal resource footprint optimized for container environments
- Automatic startup and recovery of critical services
- Audio support via PulseAudio (where container allows)
- Pre-configured for low-memory environments
- Non-interactive installation (no user input required)

## Quick Start

### 1. Create Codespace from this Branch

```bash
# The devcontainer configuration will be automatically detected
# GitHub will build the environment using the Dockerfile and configuration
```

### 2. Wait for Setup to Complete

The setup process takes 3-5 minutes on first launch:
- Docker image build
- Package installation
- Desktop environment configuration
- VNC and noVNC setup

Monitor progress in the Codespaces creation logs.

### 3. Access the Desktop

Once setup is complete, you'll see in the terminal:

```
=========================================
KDE Plasma Desktop is Ready!
=========================================

Access the desktop at:
  http://localhost:6080/vnc.html

Or via Codespaces forwarded port:
  https://<your-codespace-url>/ports/6080
```

### 4. Open in Browser

- **Local Development**: Navigate to `http://localhost:6080/vnc.html`
- **Codespaces**: Click the forwarded port link for port 6080, or append `/ports/6080` to your Codespace URL

### 5. Use the Desktop

The desktop is immediately ready to use with a full taskbar, applications menu, and all utilities.

## Accessing Applications

### From the Taskbar
- Click the application icons at the bottom of the screen
- Right-click for context menus

### From the Application Menu
- Click the application menu icon (bottom-left)
- Search or browse categories

### From Terminal (Konsole)
Launch any application from the terminal:
```bash
firefox &
kate /path/to/file &
dolphin /path/to/folder &
```

## File Management

### Access Files
- Use **Dolphin** file manager for graphical access
- Files are located in `/workspace` by default
- Your repository is available at the project root

### Edit Files
- **Kate** provides full IDE-like editing with syntax highlighting
- **VS Code** remains available via command line: `code .`

### Upload/Download
- Use Dolphin's web integration
- Copy files via terminal: `cp /local/path /workspace/`

## Development Workflow

### Example: Web Development

```bash
# Open terminal in Konsole
# Install Node.js packages
npm install

# Start development server
npm run dev

# Open Firefox
# Navigate to http://localhost:3000
```

### Example: Python Development

```bash
# Open Konsole
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Edit with Kate
kate script.py

# Run with Konsole
python script.py
```

## Port Forwarding

Codespaces automatically forwards these ports:

| Port | Service | Use |
|------|---------|-----|
| 6080 | noVNC Web | Browser desktop access |
| 5900 | VNC Server | Direct VNC client access (if needed) |

### Forward Additional Ports

In Codespaces terminal:
```bash
# Codespaces automatically detects listening ports
# Or manually configure in .devcontainer/devcontainer.json
```

## Troubleshooting

### Desktop Not Loading

**Symptoms**: Blank screen or connection refused

**Solution**:
```bash
# Check if services are running
ps aux | grep -E "Xvfb|vncserver|websockify|startkde"

# Check logs
tail -f /tmp/kde.log
tail -f /tmp/websockify.log

# Restart desktop (if available in your setup)
# Kill and restart: supervisor or manual restart
```

### Slow Performance

**Symptoms**: Laggy mouse/keyboard response

**Solutions**:
- Reduce browser window size
- Close unnecessary applications
- Check system resources: KSystemMonitor
- Use direct VNC if WebSocket has latency:
  ```bash
  vncviewer localhost:5900
  ```

### Applications Not Launching

**Symptoms**: App icons don't respond

**Solution**:
```bash
# Launch from terminal to see error messages
konsole &
kate &
dolphin &

# Check if D-Bus is running
ps aux | grep dbus
```

### Audio Not Working

**Symptoms**: No sound from applications

**Current Status**: Audio support depends on container permissions. If not working:
- Some container environments restrict audio device access
- This is a known limitation in certain cloud environments
- Consider this environment read-only for audio

## Advanced Configuration

### Change Resolution

Edit `.devcontainer/scripts/start-desktop.sh`:

```bash
# Find this line:
Xvfb :1 -screen 0 1920x1080x24 -ac -extension GLX

# Change to your desired resolution (e.g., 1280x720):
Xvfb :1 -screen 0 1280x720x24 -ac -extension GLX
```

### Customize VNC Password

Edit `.devcontainer/Dockerfile`:

```bash
# Find this line:
RUN echo "password" | vncpasswd -f > /root/.vnc/passwd

# Change "password" to your desired password
```

### Install Additional Applications

Add packages to `.devcontainer/Dockerfile` in the `apt-get install` section:

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    # ... existing packages ...
    gimp \
    vlc \
    blender \
    && rm -rf /var/lib/apt/lists/*
```

## System Information

### Specifications

- **Base OS**: Ubuntu 24.04 LTS (Noble)
- **Desktop Environment**: KDE Plasma 5
- **Display Server**: X11 (Xvfb)
- **VNC Server**: TigerVNC
- **Web Interface**: noVNC with WebSocket (websockify)
- **Default User**: root
- **Display Resolution**: 1920x1080x24
- **DPI**: 96 (standard)

### Resource Usage

- **Disk**: ~3-4GB (depends on installed applications)
- **Memory**: ~800MB-1.2GB at idle (KDE Plasma + services)
- **CPU**: Minimal at idle, scales with application usage

## Files and Directories

```
.devcontainer/
├── devcontainer.json          # Codespaces configuration
├── Dockerfile                 # Container image definition
└── scripts/
    ├── install-desktop.sh     # One-time setup script
    └── start-desktop.sh       # Runtime startup script
```

## Environment Variables

These are automatically set:

- `DISPLAY=:1` - X display number
- `LANG=en_US.UTF-8` - Language locale
- `LC_ALL=en_US.UTF-8` - All locales

## Logs and Debugging

View runtime logs to debug issues:

```bash
# KDE Plasma logs
tail -f /tmp/kde.log

# Websockify (noVNC) logs
tail -f /tmp/websockify.log

# Xvfb (X server) logs (if enabled)
tail -f /tmp/xvfb.log

# Check running processes
ps aux | grep -E "X|vnc|websockify|kde"

# Monitor system resources
# Open KSystemMonitor from desktop menu
```

## Performance Tips

1. **Use Firefox's hardware acceleration** (if available)
   - Settings → Performance → Enable hardware acceleration

2. **Disable unnecessary desktop effects**
   - System Settings → Workspace Behavior → Desktop Effects

3. **Close unused applications** to free memory

4. **Use Konsole instead of Dolphin for heavy file operations**
   - Terminal operations are generally faster

5. **Monitor resources with KSystemMonitor**
   - Available in application menu

## Security Notes

⚠️ **For Development Use Only**

- Default VNC password is "password" - change in production
- No authentication on websockify connection by default
- Codespaces provides authentication at the platform level
- Do not expose ports publicly without additional security

## Keyboard and Mouse

### Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super` (Win key) | Open application menu |
| `Alt+Tab` | Switch applications |
| `Super+D` | Show desktop |
| `Super+E` | Open file manager |
| `Ctrl+Alt+T` | Open terminal |
| `F11` (in browser) | Full screen desktop |

### Mouse

- Standard mouse, trackpad, or touch input
- Right-click for context menus
- Scroll wheel supported
- Drag-and-drop works normally

## Support and Contributions

For issues or improvements:

1. **Check logs** first (see Troubleshooting section)
2. **Verify Codespace health** - rebuild if needed
3. **Report issues** on GitHub with logs attached

## What's Next?

Once your desktop is running:

- **Web Development**: Open Firefox and start coding
- **File Management**: Use Dolphin to organize your project
- **Editing**: Use Kate or your favorite terminal editor
- **Version Control**: Use Konsole for git commands
- **Development**: Install your language runtimes and tools

## License

This configuration is provided as-is for GitHub Codespaces development environments.

## Changelog

### Version 1.0 (2026-05-30)

- ✅ Initial release
- ✅ Full KDE Plasma 5 integration
- ✅ noVNC web interface
- ✅ TigerVNC server
- ✅ All core KDE applications pre-installed
- ✅ Automatic startup and recovery
- ✅ Complete documentation
- ✅ Production-ready configuration

---

**Happy coding in your KDE Plasma desktop!** 🚀
