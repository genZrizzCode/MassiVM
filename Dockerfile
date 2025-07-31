FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="[MassiVM Mod] Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="massivm"

ARG DEBIAN_FRONTEND="noninteractive"

# prevent Ubuntu's firefox stub from being installed
COPY /root/etc/apt/preferences.d/firefox-no-snap /etc/apt/preferences.d/firefox-no-snap

COPY options.json /

COPY /root/ /

RUN \
  echo "**** install packages ****" && \
  # Remove any conflicting packages that might be pre-installed
  apt-get remove -y containerd docker.io docker-compose npm || true && \
  add-apt-repository -y ppa:mozillateam/ppa && \
  apt-get update && \
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
    && chmod +x /install-de.sh && \
    /install-de.sh

RUN \
  echo "**** install Node.js and npm ****" && \
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get update && \
  apt-get install -y nodejs && \
  npm install -g npm@10.8.2

RUN \
  echo "**** install Docker ****" && \
  apt-get update && \
  apt-get install -y ca-certificates curl gnupg && \
  install -m 0755 -d /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  chmod a+r /etc/apt/keyrings/docker.gpg && \
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  apt-get update && \
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

RUN \
  echo "**** install database clients ****" && \
  apt-get update && \
  apt-get install -y postgresql-client redis-tools

RUN \
  echo "**** install Go ****" && \
  apt-get update && \
  apt-get install -y golang-go

RUN \
  echo "**** install additional packages ****" && \
  # Install Rust with latest stable version
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
  . $HOME/.cargo/env && \
  rustup default stable && \
  rustup update && \
  # Install VS Code
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
  install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
  sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
  apt-get update && \
  apt-get install -y code && \
  # Install Google Chrome (clean up duplicates first)
  rm -f /etc/apt/sources.list.d/google-chrome.list && \
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list' && \
  apt-get update && \
  apt-get install -y google-chrome-stable && \
  # Install gaming packages and dependencies
  apt-get install -y wine64 default-jre libgdk-pixbuf2.0-0 && \
  # Install development tools
  apt-get install -y rustc cargo && \
  # Clean up
  rm -f packages.microsoft.gpg

RUN \
  chmod +x /installapps.sh && \
  /installapps.sh && \
  rm /installapps.sh

RUN \
  echo "**** install additional development tools ****" && \
  npm install -g yarn pnpm typescript ts-node nodemon climmander && \
  pip3 install --user pipenv virtualenv jupyter requests && \
  # Install Rust tools with compatible versions
  cargo install --locked cargo-edit@0.12.0 && \
  cargo install --locked cargo-watch@8.4.0 && \
  # Fix Steam permissions and cache issues
  mkdir -p /home/user/.steam && \
  chown -R 1000:1000 /home/user/.steam && \
  # Create Steam cache directory with proper permissions
  mkdir -p /home/user/.cache/steam && \
  chown -R 1000:1000 /home/user/.cache/steam && \
  # Set up update system
  mkdir -p /home/user/.local/share/applications && \
  chown -R 1000:1000 /home/user/.local

RUN \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
  
# ports and volumes
EXPOSE 3000 8080 5900
VOLUME /config 