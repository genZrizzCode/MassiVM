git clone https://github.com/genZrizzCode/MassiVM
cd MassiVM
pip install textual
sleep 2
python3 installer.py
docker build -t massivm . --no-cache
cd ..

sudo apt update
sudo apt install -y jq

# Create persistent storage directories
mkdir -p Save
mkdir -p PersistentData
mkdir -p Backups
mkdir -p UserData

# Copy configuration files
cp -r MassiVM/root/config/* Save

# Create persistent data structure
mkdir -p PersistentData/{home,steam,downloads,documents,pictures,music,videos,projects}

# Create backup script
cat > backup-massivm.sh << 'EOF'
#!/bin/bash
echo "🔄 Creating MassiVM backup..."
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="Backups/massivm_backup_$BACKUP_DATE"

mkdir -p "$BACKUP_DIR"

# Backup important directories
cp -r PersistentData "$BACKUP_DIR/"
cp -r Save "$BACKUP_DIR/"
cp -r UserData "$BACKUP_DIR/"

# Create backup info
cat > "$BACKUP_DIR/backup_info.txt" << EOL
MassiVM Backup
Date: $(date)
Backup ID: $BACKUP_DATE
Contents:
- PersistentData: User files and data
- Save: Configuration files
- UserData: Application data

To restore: Copy these directories back to your MassiVM folder
EOL

echo "✅ Backup created: $BACKUP_DIR"
echo "📁 Backup size: $(du -sh "$BACKUP_DIR" | cut -f1)"
EOF

chmod +x backup-massivm.sh

# Create restore script
cat > restore-massivm.sh << 'EOF'
#!/bin/bash
echo "🔄 MassiVM Restore Tool"
echo "======================"

if [ ! -d "Backups" ]; then
    echo "❌ No backups found!"
    exit 1
fi

echo "Available backups:"
ls -la Backups/ | grep massivm_backup

echo ""
read -p "Enter backup name to restore (e.g., massivm_backup_20241201_143022): " BACKUP_NAME

if [ ! -d "Backups/$BACKUP_NAME" ]; then
    echo "❌ Backup not found!"
    exit 1
fi

echo "🔄 Restoring from $BACKUP_NAME..."

# Stop container if running
docker stop MassiVM 2>/dev/null || true
docker rm MassiVM 2>/dev/null || true

# Restore data
cp -r "Backups/$BACKUP_NAME/PersistentData" . 2>/dev/null || true
cp -r "Backups/$BACKUP_NAME/Save" . 2>/dev/null || true
cp -r "Backups/$BACKUP_NAME/UserData" . 2>/dev/null || true

echo "✅ Restore completed!"
echo "🚀 Restart MassiVM to apply changes"
EOF

chmod +x restore-massivm.sh

# Create auto-backup script
cat > auto-backup.sh << 'EOF'
#!/bin/bash
# Auto-backup script - runs every hour
while true; do
    sleep 3600  # 1 hour
    ./backup-massivm.sh
done
EOF

chmod +x auto-backup.sh

json_file="MassiVM/options.json"
if jq ".enablekvm" "$json_file" | grep -q true; then
    docker run -d --name=MassiVM -e PUID=1000 -e PGID=1000 --device=/dev/kvm --security-opt seccomp=unconfined -e TZ=Etc/UTC -e SUBFOLDER=/ -e TITLE=MassiVM -p 3000:3000 -p 8080:8080 -p 5900:5900 --shm-size="4gb" -v $(pwd)/Save:/config -v $(pwd)/PersistentData:/home/user -v $(pwd)/UserData:/root/.local --restart unless-stopped massivm
else
    docker run -d --name=MassiVM -e PUID=1000 -e PGID=1000 --security-opt seccomp=unconfined -e TZ=Etc/UTC -e SUBFOLDER=/ -e TITLE=MassiVM -p 3000:3000 -p 8080:8080 -p 5900:5900 --shm-size="4gb" -v $(pwd)/Save:/config -v $(pwd)/PersistentData:/home/user -v $(pwd)/UserData:/root/.local --restart unless-stopped massivm
fi
clear
echo "MASSIVM WAS INSTALLED SUCCESSFULLY! Check The Port Tab"
echo "🌐 Access at: http://localhost:3000"
echo "🖥️ VNC at: localhost:5900"
echo "🔧 Development at: http://localhost:8080" 