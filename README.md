# MassiVM

### Installation

First start a new blank codespace by going to https://github.com/codespaces/ and choosing the "Blank" template. Then copy and paste this command in your codespace terminal and hit enter.

```bash
curl -O https://raw.githubusercontent.com/your-username/MassiVM/main/install.sh
chmod +x install.sh
./install.sh
```

## About

MassiVM is a powerful virtual machine that can bypass school restrictions and provide a full desktop environment in GitHub Codespaces. It offers a complete Linux desktop experience with gaming, development, and productivity tools.

### Features

- 🖥️ **Full Desktop Environment**: Complete GUI desktop experience
- 🌐 **Web Browser Access**: Browse the web with full functionality
- 🎮 **Enhanced Gaming Support**: Steam, Wine, Lutris, RetroArch
- 🔧 **Development Tools**: VS Code, Node.js, Python, Go, Rust
- 📱 **Port Forwarding**: Access your apps through forwarded ports
- 🚀 **No External Auth**: Works entirely within GitHub Codespaces
- 🐳 **Docker Support**: Full containerization capabilities
- 🗄️ **Database Support**: PostgreSQL, Redis, MySQL
- 🎯 **Windows App Support**: Enhanced Wine integration
- 💾 **Persistent Storage**: Data backup and restore across sessions
- 🔄 **Auto-Backup**: Automatic hourly backups of your data
- ☁️ **Cloud Sync**: Export/import data to/from GitHub

### What You Get

- **Multiple Desktop Environments**: KDE Plasma, XFCE4, I3, GNOME, Cinnamon, LXQT
- **Web Browsers**: Firefox/Chrome with full web access
- **Development Tools**: VS Code, Docker, Node.js, Python, Go, Rust
- **Gaming Platform**: Steam, Wine, Lutris, RetroArch, PlayOnLinux
- **Database Tools**: PostgreSQL, Redis, MySQL
- **File Management**: Complete file system access
- **Terminal Access**: Multiple terminal windows

### How It Works

MassiVM creates a complete virtual desktop environment:
- **Docker Container**: Runs in a containerized environment
- **KasmVNC**: Web-based VNC access
- **Multiple Desktop Environments**: Choose your preferred DE
- **Port Forwarding**: Web access to applications
- **Enhanced Package Management**: Comprehensive development tools

### Usage

After installation:
1. Run the installer with custom options
2. Choose your desktop environment and applications
3. Access your desktop through the browser
4. Use the full Linux desktop environment
5. Install and run any applications
6. Browse the web with full functionality
7. Develop and test applications

### 💾 Persistent Storage

**Important**: GitHub Codespaces lose data when closed. MassiVM includes persistent storage features:

#### **Automatic Features:**
- **Persistent Data**: Files stored in `PersistentData/` directory
- **Auto-Backup**: Hourly backups to `Backups/` directory
- **Configuration**: Settings saved in `Save/` directory

#### **Manual Backup/Restore:**
```bash
# Create backup
./backup-massivm.sh

# Restore from backup
./restore-massivm.sh

# Manage storage
./persistent-storage.sh
```

#### **Cloud Sync:**
```bash
# Export data to GitHub
./export-to-github.sh

# Import data from GitHub
./import-from-github.sh
```

#### **Data That Persists:**
- ✅ **User files** (documents, downloads, pictures)
- ✅ **Steam games** and saves
- ✅ **Application settings** and configurations
- ✅ **Development projects** and code
- ✅ **Database data** (PostgreSQL, Redis)
- ✅ **Docker containers** and images

### Key Features

- **Complete Development Environment**: VS Code, Docker, databases
- **Comprehensive Gaming Support**: Steam, CS:GO, Minecraft, Lutris, RetroArch
- **Multiple Programming Languages**: Node.js, Python, Go, Rust support
- **Advanced Package Management**: Extensive pre-installed tools
- **Optimized Performance**: Fine-tuned for development and gaming workflows

### Resources

- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [KasmVNC Documentation](https://www.kasmweb.com/)
- [Ubuntu Desktop](https://ubuntu.com/desktop)
- [Docker Documentation](https://docs.docker.com/)

### License

Apache License 2.0 - See [LICENSE](LICENSE) file for details.

**Key Terms:**
- ✅ **Fork and PR freely** - No restrictions on contributions
- ✅ **Commercial use allowed** - With proper attribution
- ✅ **Patent protection** - Includes patent license grant
- ✅ **No liability** - Use at your own risk
- ✅ **Credit required** - Include NOTICE file and copyright
- ❌ **No selling** - Cannot be sold for monetary profit 