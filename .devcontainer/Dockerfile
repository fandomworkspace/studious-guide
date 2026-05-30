FROM mcr.microsoft.com/devcontainers/base:noble

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Update package lists and install essential dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Locales and language support
    locales \
    language-pack-en \
    # X11 and display server
    xserver-xvfb \
    x11-utils \
    x11-xserver-utils \
    dbus \
    dbus-x11 \
    # KDE Plasma and core components
    plasma-desktop \
    plasma-workspace \
    plasma-framework \
    kwin-x11 \
    kwin-common \
    sddm \
    # KDE Applications
    dolphin \
    konsole \
    kate \
    ark \
    gwenview \
    okular \
    kcalc \
    spectacle \
    ksystemmonitor \
    khelpcenter \
    # Firefox
    firefox \
    # VNC server and noVNC
    tigervnc-standalone-server \
    tigervnc-common \
    websockify \
    python3-numpy \
    # Audio support
    pulseaudio \
    alsa-utils \
    pavucontrol \
    # Additional utilities
    curl \
    wget \
    git \
    sudo \
    ca-certificates \
    mesa-utils \
    libgl1-mesa-glx \
    libxrender1 \
    libxrandr2 \
    fontconfig \
    fonts-dejavu \
    fonts-liberation \
    # Cleanup
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Generate locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Create codespace user if not exists (fallback)
RUN useradd -m -s /bin/bash -G sudo codespace 2>/dev/null || true

# Create necessary directories
RUN mkdir -p /root/.vnc \
    && mkdir -p /root/.config/pulse \
    && mkdir -p /root/.local/share/applications \
    && mkdir -p /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

# Configure PulseAudio for container
RUN echo "autospawn = no" >> /etc/pulse/client.conf

# Create VNC password file (default: password)
RUN echo "password" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# Copy startup scripts
COPY .devcontainer/scripts/start-desktop.sh /start-desktop.sh
COPY .devcontainer/scripts/install-desktop.sh /install-desktop.sh

RUN chmod +x /start-desktop.sh /install-desktop.sh

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/start-desktop.sh"]
