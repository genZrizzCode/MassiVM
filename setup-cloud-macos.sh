#!/bin/bash

# Cloud macOS Development Environment Setup Script
# This script helps set up SSH keys and basic configuration for MacStadium

set -e

echo "🚀 Setting up Cloud macOS Development Environment"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

# Check if running on Chromebook
if [[ -f /etc/chrome_dev.conf ]]; then
    print_status "Detected Chromebook environment"
else
    print_warning "This script is optimized for Chromebook but will work on other systems"
fi

# Check for existing SSH keys
if [[ -f ~/.ssh/id_rsa ]]; then
    print_warning "SSH key already exists at ~/.ssh/id_rsa"
    read -p "Do you want to create a new key for MacStadium? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        SSH_KEY_PATH="~/.ssh/macstadium_rsa"
    else
        SSH_KEY_PATH="~/.ssh/id_rsa"
    fi
else
    SSH_KEY_PATH="~/.ssh/id_rsa"
fi

# Generate SSH key if needed
if [[ ! -f $SSH_KEY_PATH ]]; then
    print_header "Generating SSH key for MacStadium access"
    read -p "Enter your email address: " EMAIL
    
    ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f $SSH_KEY_PATH -N ""
    print_status "SSH key generated successfully"
else
    print_status "Using existing SSH key: $SSH_KEY_PATH"
fi

# Display public key
print_header "Your SSH Public Key (add this to MacStadium):"
echo "=================================================="
cat ${SSH_KEY_PATH}.pub
echo "=================================================="

# Create SSH config for easy connection
print_header "Creating SSH configuration"
mkdir -p ~/.ssh

cat >> ~/.ssh/config << EOF

# MacStadium Cloud Configuration
Host macstadium
    HostName YOUR_INSTANCE_IP_HERE
    User YOUR_USERNAME_HERE
    IdentityFile $SSH_KEY_PATH
    Port 22
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ForwardAgent yes
    LocalForward 3000 localhost:3000
    LocalForward 8080 localhost:8080
    LocalForward 5900 localhost:5900
EOF

print_status "SSH config created at ~/.ssh/config"
print_warning "Remember to update the HostName and User in ~/.ssh/config"

# Create connection helper script
cat > connect-macstadium.sh << 'EOF'
#!/bin/bash

echo "🔗 Connecting to MacStadium Cloud macOS Instance"
echo "================================================"

# Check if SSH config exists
if [[ ! -f ~/.ssh/config ]]; then
    echo "❌ SSH config not found. Please run setup-cloud-macos.sh first"
    exit 1
fi

# Check if macstadium host is configured
if ! grep -q "Host macstadium" ~/.ssh/config; then
    echo "❌ MacStadium host not configured in SSH config"
    echo "Please update ~/.ssh/config with your instance details"
    exit 1
fi

echo "✅ Connecting to MacStadium..."
echo "📱 Port forwarding enabled:"
echo "   - Local port 3000 → Remote port 3000 (Web apps)"
echo "   - Local port 8080 → Remote port 8080 (Alternative web apps)"
echo "   - Local port 5900 → Remote port 5900 (VNC desktop)"
echo ""
echo "🌐 Access your web apps at:"
echo "   - http://localhost:3000"
echo "   - http://localhost:8080"
echo ""
echo "🖥️  For VNC desktop access, use a VNC viewer with:"
echo "   - Host: localhost"
echo "   - Port: 5900"
echo ""
echo "Press Ctrl+C to disconnect"
echo ""

ssh macstadium
EOF

chmod +x connect-macstadium.sh
print_status "Connection helper script created: ./connect-macstadium.sh"

# Create development environment setup script for the remote macOS
cat > setup-macos-dev.sh << 'EOF'
#!/bin/bash

# Development Environment Setup for Remote macOS
# Run this script on your MacStadium instance

set -e

echo "🛠️  Setting up macOS Development Environment"
echo "============================================="

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew already installed"
fi

# Install Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    echo "🔧 Installing Xcode Command Line Tools..."
    xcode-select --install
else
    echo "✅ Xcode Command Line Tools already installed"
fi

# Install common development tools
echo "📦 Installing development tools..."
brew install git node python3 docker

# Install additional useful tools
echo "📦 Installing additional tools..."
brew install \
    wget \
    curl \
    vim \
    nano \
    tree \
    htop \
    jq \
    yq \
    bat \
    fd \
    ripgrep \
    fzf

# Install Node.js tools
echo "📦 Installing Node.js development tools..."
npm install -g yarn pnpm typescript ts-node nodemon

# Install Python tools
echo "📦 Installing Python development tools..."
pip3 install --user pipenv virtualenv

# Set up Git configuration
echo "⚙️  Setting up Git configuration..."
read -p "Enter your Git name: " GIT_NAME
read -p "Enter your Git email: " GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main

# Enable VNC for desktop access
echo "🖥️  Setting up VNC access..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
    -activate -configure -access -on \
    -clientopts -setvnclegacy -vnclegacy yes \
    -clientopts -setvncpw -vncpw "macstadium123" \
    -restart -agent -privs -all

echo "✅ Development environment setup complete!"
echo ""
echo "🔗 You can now:"
echo "   - Use SSH to connect: ssh macstadium"
echo "   - Access VNC desktop on port 5900"
echo "   - Run web applications on ports 3000/8080"
echo ""
echo "📝 Next steps:"
echo "   1. Clone your repositories"
echo "   2. Install project-specific dependencies"
echo "   3. Start developing!"
EOF

print_status "Remote setup script created: ./setup-macos-dev.sh"
print_warning "Upload and run this script on your MacStadium instance"

# Create a simple project template
mkdir -p macos-dev-template
cat > macos-dev-template/README.md << 'EOF'
# macOS Cloud Development Project

This project is set up for development on a cloud macOS instance.

## Quick Start

1. **Connect to your MacStadium instance:**
   ```bash
   ./connect-macstadium.sh
   ```

2. **Set up the development environment:**
   ```bash
   # Upload and run the setup script
   scp setup-macos-dev.sh macstadium:~/
   ssh macstadium
   chmod +x setup-macos-dev.sh
   ./setup-macos-dev.sh
   ```

3. **Clone your project:**
   ```bash
   git clone <your-repo-url>
   cd <your-project>
   ```

4. **Install dependencies:**
   ```bash
   # For Node.js projects
   npm install
   
   # For Python projects
   pip3 install -r requirements.txt
   ```

5. **Start development:**
   ```bash
   # Your development commands here
   npm start
   ```

## Port Forwarding

The connection script automatically forwards these ports:
- **3000**: Web applications
- **8080**: Alternative web applications  
- **5900**: VNC desktop access

Access your apps at:
- http://localhost:3000
- http://localhost:8080

## VNC Desktop Access

1. Install a VNC viewer on your Chromebook
2. Connect to `localhost:5900`
3. Use password: `macstadium123`

## Tips

- Use `screen` or `tmux` for persistent sessions
- Set up automatic backups of your work
- Consider using VS Code Remote SSH extension
- Keep your instance updated regularly
EOF

print_status "Project template created in: ./macos-dev-template/"

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "📋 Next Steps:"
echo "1. Sign up for MacStadium Cloud: https://cloud.macstadium.com/"
echo "2. Create a macOS instance"
echo "3. Add your SSH public key to MacStadium"
echo "4. Update ~/.ssh/config with your instance details"
echo "5. Run: ./connect-macstadium.sh"
echo ""
echo "📚 For more information, see: macos-cloud-setup.md"
echo ""
print_warning "Remember to keep your SSH keys secure and never share them!" 