#!/bin/bash
echo "**** Installing Alacritty Terminal ****"

# Install pre-compiled Alacritty binary (much faster)
curl -L https://github.com/alacritty/alacritty/releases/download/v0.15.1/alacritty-v0.15.1-ubuntu_20_04_amd64.deb -o /tmp/alacritty.deb
dpkg -i /tmp/alacritty.deb || apt-get install -f -y
rm /tmp/alacritty.deb

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
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 50

echo "**** Alacritty Terminal installation completed ****" 