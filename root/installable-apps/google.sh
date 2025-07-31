#!/bin/bash
echo "**** Installing Google as Default Browser ****"

# Browsers are already installed in Dockerfile
echo "Browsers already installed. Configuring Google as default..."

# Set Google as default search engine and homepage for all browsers
echo "Setting Google as default search engine..."

# Firefox configuration
mkdir -p ~/.mozilla/firefox/default/prefs
cat > ~/.mozilla/firefox/default/prefs/user.js << 'EOF'
user_pref("browser.startup.homepage", "https://www.google.com");
user_pref("browser.search.defaultenginename", "Google");
user_pref("browser.search.selectedEngine", "Google");
user_pref("browser.urlbar.placeholderName", "Google");
user_pref("browser.newtabpage.activity-stream.default.sites", "https://www.google.com");
EOF

# Chromium configuration
mkdir -p ~/.config/chromium/Default
cat > ~/.config/chromium/Default/Preferences << 'EOF'
{
  "browser": {
    "startup": {
      "startup_urls": ["https://www.google.com"]
    }
  },
  "search": {
    "default_search_provider": {
      "enabled": true,
      "search_url": "https://www.google.com/search?q={searchTerms}",
      "name": "Google"
    }
  }
}
EOF

# Google Chrome configuration
mkdir -p ~/.config/google-chrome/Default
cat > ~/.config/google-chrome/Default/Preferences << 'EOF'
{
  "browser": {
    "startup": {
      "startup_urls": ["https://www.google.com"]
    }
  },
  "search": {
    "default_search_provider": {
      "enabled": true,
      "search_url": "https://www.google.com/search?q={searchTerms}",
      "name": "Google"
    }
  }
}
EOF

# Create desktop shortcuts for Google
mkdir -p ~/.local/share/applications

# Google Chrome shortcut
cat > ~/.local/share/applications/google-chrome.desktop << 'EOF'
[Desktop Entry]
Name=Google Chrome
Comment=Access Google Search and Services
Exec=google-chrome --new-window https://www.google.com
Icon=google-chrome
Terminal=false
Type=Application
Categories=Network;WebBrowser;
Keywords=google;search;browser;web;
EOF

# Firefox with Google shortcut
cat > ~/.local/share/applications/firefox-google.desktop << 'EOF'
[Desktop Entry]
Name=Firefox (Google)
Comment=Firefox with Google as default
Exec=firefox --new-window https://www.google.com
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
Keywords=google;search;browser;web;
EOF

# Chromium with Google shortcut
cat > ~/.local/share/applications/chromium-google.desktop << 'EOF'
[Desktop Entry]
Name=Chromium (Google)
Comment=Chromium with Google as default
Exec=chromium-browser --new-window https://www.google.com
Icon=chromium-browser
Terminal=false
Type=Application
Categories=Network;WebBrowser;
Keywords=google;search;browser;web;
EOF

# Make shortcuts executable
chmod +x ~/.local/share/applications/google-chrome.desktop
chmod +x ~/.local/share/applications/firefox-google.desktop
chmod +x ~/.local/share/applications/chromium-google.desktop

# Set Google Chrome as default browser
xdg-settings set default-web-browser google-chrome.desktop

# Create Google launcher script
cat > ~/google-launcher.sh << 'EOF'
#!/bin/bash
echo "🌐 Launching Google..."
echo "Opening Google in your default browser..."

# Try to launch Google Chrome first
if command -v google-chrome &> /dev/null; then
    google-chrome --new-window https://www.google.com
elif command -v chromium-browser &> /dev/null; then
    chromium-browser --new-window https://www.google.com
elif command -v firefox &> /dev/null; then
    firefox --new-window https://www.google.com
else
    echo "No browser found. Installing Firefox..."
    sudo apt-get update
    sudo apt-get install -y firefox
    firefox --new-window https://www.google.com
fi
EOF

chmod +x ~/google-launcher.sh

# Create Google search script
cat > ~/google-search.sh << 'EOF'
#!/bin/bash
echo "🔍 Google Search Launcher"
echo "========================="

if [ -z "$1" ]; then
    echo "Usage: ./google-search.sh 'your search query'"
    echo "Example: ./google-search.sh 'how to install steam'"
    exit 1
fi

SEARCH_QUERY="$*"
ENCODED_QUERY=$(echo "$SEARCH_QUERY" | sed 's/ /+/g')
GOOGLE_URL="https://www.google.com/search?q=$ENCODED_QUERY"

echo "Searching for: $SEARCH_QUERY"
echo "Opening: $GOOGLE_URL"

# Try to launch in browser
if command -v google-chrome &> /dev/null; then
    google-chrome "$GOOGLE_URL"
elif command -v chromium-browser &> /dev/null; then
    chromium-browser "$GOOGLE_URL"
elif command -v firefox &> /dev/null; then
    firefox "$GOOGLE_URL"
else
    echo "No browser found. Please install a browser first."
fi
EOF

chmod +x ~/google-search.sh

echo "**** Google installation completed ****"
echo ""
echo "✅ Google is now set as default across all environments!"
echo ""
echo "🌐 Available shortcuts:"
echo "   - Google Chrome: ~/.local/share/applications/google-chrome.desktop"
echo "   - Firefox (Google): ~/.local/share/applications/firefox-google.desktop"
echo "   - Chromium (Google): ~/.local/share/applications/chromium-google.desktop"
echo ""
echo "🔧 Available scripts:"
echo "   - Launch Google: ~/google-launcher.sh"
echo "   - Search Google: ~/google-search.sh 'your query'"
echo ""
echo "🎯 All browsers now default to Google search and homepage!" 