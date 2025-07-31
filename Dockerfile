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
    && chmod +x /install-de.sh && \
    /install-de.sh

RUN \
  echo "**** install Node.js and npm ****" && \
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get update && \
  apt-get install -y nodejs && \
  npm install -g npm@latest

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
  # Install Rust
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
  . $HOME/.cargo/env && \
  # Install VS Code
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
  install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
  sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
  apt-get update && \
  apt-get install -y code && \
  # Install Google Chrome
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
  apt-get update && \
  apt-get install -y google-chrome-stable && \
  # Install gaming packages
  apt-get install -y wine64 && \
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
  npm install -g yarn pnpm typescript ts-node nodemon && \
  pip3 install --user pipenv virtualenv jupyter

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