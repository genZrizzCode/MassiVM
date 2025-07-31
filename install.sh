# Create logs directory
mkdir -p logs

# Start logging
LOG_FILE="logs/massivm_install_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🚀 Installing MassiVM..."
echo "========================"
echo "📝 Logging to: $LOG_FILE"

# Create simple log viewer
cat > view-logs.py << 'EOF'
#!/usr/bin/env python3
import os
import glob
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
from datetime import datetime

class LogHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            # Get all log files
            log_files = glob.glob('logs/*.log')
            log_files.sort(reverse=True)
            
            html = '''
            <!DOCTYPE html>
            <html>
            <head>
                <title>MassiVM Installation Logs</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
                    .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                    h1 { color: #333; text-align: center; }
                    .log-file { margin: 10px 0; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
                    .log-file a { color: #007bff; text-decoration: none; font-weight: bold; }
                    .log-file a:hover { text-decoration: underline; }
                    .timestamp { color: #666; font-size: 0.9em; }
                    .size { color: #28a745; font-weight: bold; }
                    pre { background: #f8f9fa; padding: 15px; border-radius: 4px; overflow-x: auto; white-space: pre-wrap; }
                    .refresh { text-align: center; margin: 20px 0; }
                    .refresh a { background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>📋 MassiVM Installation Logs</h1>
                    <div class="refresh">
                        <a href="/">🔄 Refresh Logs</a>
                    </div>
            '''
            
            if log_files:
                html += '<h2>Available Log Files:</h2>'
                for log_file in log_files:
                    stat = os.stat(log_file)
                    size = stat.st_size
                    mtime = datetime.fromtimestamp(stat.st_mtime)
                    size_str = f"{size/1024:.1f} KB" if size < 1024*1024 else f"{size/(1024*1024):.1f} MB"
                    
                    html += f'''
                    <div class="log-file">
                        <a href="/log/{os.path.basename(log_file)}">{os.path.basename(log_file)}</a>
                        <span class="timestamp"> - {mtime.strftime('%Y-%m-%d %H:%M:%S')}</span>
                        <span class="size">({size_str})</span>
                    </div>
                    '''
            else:
                html += '<p>No log files found.</p>'
            
            html += '''
                </div>
            </body>
            </html>
            '''
            
            self.wfile.write(html.encode())
            
        elif self.path.startswith('/log/'):
            log_name = self.path[5:]  # Remove '/log/'
            log_path = f'logs/{log_name}'
            
            if os.path.exists(log_path):
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()
                
                with open(log_path, 'r') as f:
                    content = f.read()
                self.wfile.write(content.encode())
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write(b'Log file not found')
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not found')

if __name__ == '__main__':
    port = 8081
    print(f"📋 Log viewer starting on http://localhost:{port}")
    print("Press Ctrl+C to stop")
    server = HTTPServer(('localhost', port), LogHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Log viewer stopped")
EOF

chmod +x view-logs.py

# Start log viewer in background
python3 view-logs.py &
LOG_VIEWER_PID=$!

echo "📋 Log viewer started at: http://localhost:8081"
echo ""

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

# Check if options.json exists, create default if not
if [ ! -f "MassiVM/options.json" ]; then
    echo "Creating default options.json..."
    cat > MassiVM/options.json << 'EOF'
{
  "defaultapps": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
  "programming": [3, 4, 5, 6],
  "apps": [5, 7, 8, 9],
  "enablekvm": false,
  "DE": "KDE Plasma (Heavy)"
}
EOF
fi

json_file="MassiVM/options.json"

# Check if Docker image was built successfully
if ! docker images | grep -q massivm; then
    echo "❌ Docker image 'massivm' not found. Installation failed."
    echo "Please check the Docker build output above for errors."
    exit 1
fi

# Stop and remove existing container if it exists
docker stop MassiVM 2>/dev/null || true
docker rm MassiVM 2>/dev/null || true

echo "🚀 Starting MassiVM container..."

# Start container with error handling
if jq ".enablekvm" "$json_file" 2>/dev/null | grep -q true; then
    docker run -d --name=MassiVM \
        -e PUID=1000 \
        -e PGID=1000 \
        --device=/dev/kvm \
        --security-opt seccomp=unconfined \
        -e TZ=Etc/UTC \
        -e SUBFOLDER=/ \
        -e TITLE=MassiVM \
        -p 3000:3000 \
        -p 8080:8080 \
        -p 5900:5900 \
        --shm-size="4gb" \
        -v "$(pwd)/Save:/config" \
        -v "$(pwd)/PersistentData:/home/user" \
        -v "$(pwd)/UserData:/root/.local" \
        --restart unless-stopped \
        massivm
else
    docker run -d --name=MassiVM \
        -e PUID=1000 \
        -e PGID=1000 \
        --security-opt seccomp=unconfined \
        -e TZ=Etc/UTC \
        -e SUBFOLDER=/ \
        -e TITLE=MassiVM \
        -p 3000:3000 \
        -p 8080:8080 \
        -p 5900:5900 \
        --shm-size="4gb" \
        -v "$(pwd)/Save:/config" \
        -v "$(pwd)/PersistentData:/home/user" \
        -v "$(pwd)/UserData:/root/.local" \
        --restart unless-stopped \
        massivm
fi

# Check if container started successfully
if docker ps | grep -q MassiVM; then
    echo ""
    echo "✅ MASSIVM WAS INSTALLED SUCCESSFULLY!"
    echo "======================================"
    echo ""
    echo "🌐 Access your desktop at: http://localhost:3000"
    echo "🖥️ VNC access at: localhost:5900"
    echo "🔧 Development port at: http://localhost:8080"
    echo ""
    echo "📁 Your data is stored in:"
    echo "   - PersistentData/ (user files)"
    echo "   - Save/ (configuration)"
    echo "   - UserData/ (application data)"
    echo ""
    echo "💾 Backup your data: ./backup-massivm.sh"
    echo "🔄 Restore data: ./restore-massivm.sh"
    echo ""
    echo "Container status:"
    docker ps | grep MassiVM
else
    echo "❌ Failed to start MassiVM container"
    echo "Container logs:"
    docker logs MassiVM 2>/dev/null || echo "No logs available"
    exit 1
fi

# Stop log viewer
kill $LOG_VIEWER_PID 2>/dev/null || true

echo ""
echo "📋 Installation complete! View logs at: http://localhost:8081"
echo "💡 To view logs later, run: python3 view-logs.py"
echo "" 