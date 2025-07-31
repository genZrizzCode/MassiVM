#!/bin/bash
echo "**** Installing Counter-Strike 2 ****"

# Ensure Steam is installed first
if ! command -v steam &> /dev/null; then
    echo "Steam not found. Installing Steam first..."
    chmod +x /installable-apps/steam.sh
    /installable-apps/steam.sh
fi

# Install additional dependencies for CS2
echo "Installing CS2 dependencies..."
sudo apt-get update
sudo apt-get install -y \
    lib32gcc-s1 \
    lib32stdc++6 \
    libc6-i386 \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglu1-mesa \
    libxcursor1 \
    libxrandr2 \
    libxss1 \
    libxtst6 \
    libasound2 \
    libpulse0 \
    libdbus-1-3 \
    libgtk-3-0 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrender1 \
    libxtst6 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libatspi2.0-0 \
    libxss1 \
    libxrandr2 \
    libasound2 \
    libpulse0

# Create CS2 desktop shortcut
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/counter-strike-2.desktop << 'EOF'
[Desktop Entry]
Name=Counter-Strike 2
Comment=Counter-Strike 2 - Tactical FPS Game
Exec=steam steam://rungameid/730
Icon=steam
Terminal=false
Type=Application
Categories=Game;ActionGame;Shooter;
Keywords=game;fps;shooter;counter-strike;
EOF

# Create CS2 launcher script
cat > ~/cs2-launcher.sh << 'EOF'
#!/bin/bash
echo "Launching Counter-Strike 2..."
echo "Note: You need to own CS2 on Steam to play"
echo "If you don't own it, you can purchase it from Steam"
echo ""
echo "Starting Steam..."
steam steam://rungameid/730
EOF

chmod +x ~/cs2-launcher.sh
chmod +x ~/.local/share/applications/counter-strike-2.desktop

# Create CS2 optimization script
cat > ~/cs2-optimize.sh << 'EOF'
#!/bin/bash
echo "Counter-Strike 2 Optimization Script"
echo "===================================="
echo ""
echo "This script will optimize your system for CS2:"

# Set performance governor
echo "Setting performance governor..."
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Disable compositor for better performance
echo "Disabling compositor for better performance..."
if command -v kwin_x11 &> /dev/null; then
    kwin_x11 --replace &
elif command -v gnome-shell &> /dev/null; then
    gsettings set org.gnome.mutter experimental-features "['kms-modifiers']"
fi

# Set Steam launch options for CS2
echo "Setting recommended Steam launch options for CS2:"
echo "Go to Steam -> Library -> Counter-Strike 2 -> Properties -> Launch Options"
echo "Add these options:"
echo "-novid -high -threads 4 -limitclientconst -nojoy"
echo ""
echo "Optimization complete!"
EOF

chmod +x ~/cs2-optimize.sh

echo "**** Counter-Strike 2 installation completed ****"
echo ""
echo "To play CS2:"
echo "1. Launch Steam"
echo "2. Purchase CS2 if you don't own it"
echo "3. Install CS2 through Steam"
echo "4. Run: ~/cs2-launcher.sh"
echo ""
echo "For optimal performance, run: ~/cs2-optimize.sh"
echo ""
echo "Note: CS2 requires a Steam account and purchase of the game" 