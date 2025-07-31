#!/bin/bash
echo "**** Installing Counter-Strike: GO (Free) ****"

# Ensure Steam is installed first
if ! command -v steam &> /dev/null; then
    echo "Steam not found. Installing Steam first..."
    chmod +x /installable-apps/steam.sh
    /installable-apps/steam.sh
fi

# Install dependencies for CS:GO
echo "Installing CS:GO dependencies..."
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
    libatspi2.0-0

# Create CS:GO desktop shortcut
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/counter-strike-go.desktop << 'EOF'
[Desktop Entry]
Name=Counter-Strike: GO
Comment=Counter-Strike: Global Offensive - Free FPS Game
Exec=steam steam://rungameid/730
Icon=steam
Terminal=false
Type=Application
Categories=Game;ActionGame;Shooter;
Keywords=game;fps;shooter;counter-strike;free;
EOF

# Create CS:GO launcher script
cat > ~/csgo-launcher.sh << 'EOF'
#!/bin/bash
echo "Launching Counter-Strike: GO (Free)..."
echo "CS:GO is FREE to play on Steam!"
echo ""
echo "Starting Steam..."
steam steam://rungameid/730
EOF

chmod +x ~/csgo-launcher.sh
chmod +x ~/.local/share/applications/counter-strike-go.desktop

# Create CS:GO optimization script
cat > ~/csgo-optimize.sh << 'EOF'
#!/bin/bash
echo "Counter-Strike: GO Optimization Script"
echo "====================================="
echo ""
echo "This script will optimize your system for CS:GO:"

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

# Set Steam launch options for CS:GO
echo "Setting recommended Steam launch options for CS:GO:"
echo "Go to Steam -> Library -> Counter-Strike: GO -> Properties -> Launch Options"
echo "Add these options:"
echo "-novid -high -threads 4 -limitclientconst -nojoy -tickrate 128"
echo ""
echo "For better FPS, also add:"
echo "-freq 144 -refresh 144"
echo ""
echo "Optimization complete!"
EOF

chmod +x ~/csgo-optimize.sh

# Create CS:GO config script
cat > ~/csgo-config.sh << 'EOF'
#!/bin/bash
echo "Counter-Strike: GO Configuration Guide"
echo "====================================="
echo ""
echo "CS:GO is FREE to play! Here's how to get started:"
echo ""
echo "1. Launch Steam"
echo "2. Search for 'Counter-Strike: GO'"
echo "3. Click 'Play Now' (it's free!)"
echo "4. Download and install"
echo "5. Start playing!"
echo ""
echo "Tips for new players:"
echo "- Start with Casual mode"
echo "- Practice on aim maps"
echo "- Learn the basic maps (Dust 2, Mirage, Inferno)"
echo "- Use voice chat with your team"
echo ""
echo "For optimal performance, run: ~/csgo-optimize.sh"
EOF

chmod +x ~/csgo-config.sh

echo "**** Counter-Strike: GO installation completed ****"
echo ""
echo "🎮 CS:GO is FREE to play!"
echo ""
echo "To play CS:GO:"
echo "1. Launch Steam"
echo "2. Search for 'Counter-Strike: GO'"
echo "3. Click 'Play Now' (FREE!)"
echo "4. Download and install"
echo "5. Run: ~/csgo-launcher.sh"
echo ""
echo "For optimal performance, run: ~/csgo-optimize.sh"
echo "For configuration help, run: ~/csgo-config.sh"
echo ""
echo "✅ CS:GO is completely free - no purchase required!" 