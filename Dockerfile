FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="[MassiVM Optimized] Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="massivm"

ARG DEBIAN_FRONTEND="noninteractive"

# prevent Ubuntu's firefox stub from being installed
COPY /root/etc/apt/preferences.d/firefox-no-snap /etc/apt/preferences.d/firefox-no-snap

COPY options.json /

# Copy all root files at once to reduce layers
COPY /root/ /

# Consolidate all package installations into a single RUN command for better caching
RUN \
  echo "**** install all packages in single layer ****" && \
  # Remove any conflicting packages that might be pre-installed
  apt-get remove -y containerd docker.io docker-compose npm || true && \
  # Add all repositories at once
  add-apt-repository -y ppa:mozillateam/ppa && \
  # Single apt-get update
  apt-get update && \
  # Install all packages in one command
  DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    firefox \
    chromium-browser \
    jq \
    wget \
    curl \
    git \
    build-essential \
    python3 \
    python3-pip \
    vim \
    nano \
    htop \
    tree \
    software-properties-common \
    libfontconfig1-dev \
    pkg-config \
    libfreetype6-dev \
    libx11-dev \
    libxrandr-dev \
    libxcb1-dev \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libssl-dev \
    libssl3 \
    openssl \
    ca-certificates \
    gnupg \
    postgresql-client \
    redis-tools \
    golang-go \
    wine64 \
    default-jre \
    libgdk-pixbuf2.0-0 && \
  # Install Node.js and npm
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g npm@10.8.2 && \
  # Install Docker
  install -m 0755 -d /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  chmod a+r /etc/apt/keyrings/docker.gpg && \
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
  # Install VS Code (pre-compiled binary)
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
  install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
  sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
  # Install Google Chrome (pre-compiled binary)
  rm -f /etc/apt/sources.list.d/google-chrome.list && \
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list' && \
  # Final package installation
  apt-get update && \
  apt-get install -y code google-chrome-stable && \
  # Clean up package files
  rm -f packages.microsoft.gpg && \
  # Install desktop environment
  chmod +x /install-de.sh && \
  /install-de.sh && \
  # Install applications
  chmod +x /installapps.sh && \
  /installapps.sh && \
  rm /installapps.sh && \
  # Install additional development tools
  npm install -g yarn pnpm typescript ts-node nodemon climmander && \
  pip3 install --user pipenv virtualenv jupyter requests && \
  # Install pre-compiled Rust tools (much faster)
  curl -L https://github.com/killercup/cargo-edit/releases/download/v0.12.0/cargo-edit-v0.12.0-x86_64-unknown-linux-gnu.tar.gz | tar -xz -C /usr/local/bin/ && \
  curl -L https://github.com/watchexec/cargo-watch/releases/download/v8.4.0/cargo-watch-v8.4.0-x86_64-unknown-linux-gnu.tar.gz | tar -xz -C /usr/local/bin/ cargo-watch-v8.4.0-x86_64-unknown-linux-gnu/cargo-watch && \
  chmod +x /usr/local/bin/cargo-edit /usr/local/bin/cargo-watch && \
  # Fix Steam permissions and cache issues
  mkdir -p /home/user/.steam /home/user/.cache/steam /home/user/.local/share/applications && \
  chown -R 1000:1000 /home/user/.steam /home/user/.cache/steam /home/user/.local && \
  # Set up update system
  mkdir -p /home/user/.local/share/applications && \
  chown -R 1000:1000 /home/user/.local && \
  # Final cleanup
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
  
# ports and volumes
EXPOSE 3000 8080 5900
VOLUME /config 