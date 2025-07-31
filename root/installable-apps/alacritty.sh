#!/bin/bash
echo "**** Installing Alacritty Terminal ****"

# Install dependencies
sudo apt-get update
sudo apt-get install -y \
    cmake \
    pkg-config \
    libfreetype6-dev \
    libfontconfig1-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev \
    python3

# Install Rust (required for Alacritty)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env

# Install Alacritty
cargo install alacritty

# Create desktop entry
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/alacritty.desktop << 'EOF'
[Desktop Entry]
Name=Alacritty
Comment=A fast, cross-platform, OpenGL terminal emulator
Exec=alacritty
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
EOF

# Set as default terminal (optional)
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator ~/.cargo/bin/alacritty 50

echo "**** Alacritty Terminal installation completed ****" 