#!/bin/bash

echo "💾 MassiVM Persistent Storage Manager"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    echo -e "${BLUE}[STORAGE]${NC} $1"
}

# Check if running in GitHub Codespaces
if [[ -n "$CODESPACES" ]]; then
    print_warning "Running in GitHub Codespaces - data will be lost when Codespace closes!"
    print_status "Use backup features to preserve your data"
else
    print_status "Running locally - data should persist"
fi

# Show current storage status
print_header "Current Storage Status"
echo "=========================="

if [ -d "PersistentData" ]; then
    echo "📁 PersistentData: $(du -sh PersistentData 2>/dev/null | cut -f1 || echo 'Empty')"
    echo "   - Home files: $(ls PersistentData/home/ 2>/dev/null | wc -l) files"
    echo "   - Steam data: $(ls PersistentData/steam/ 2>/dev/null | wc -l) files"
    echo "   - Downloads: $(ls PersistentData/downloads/ 2>/dev/null | wc -l) files"
    echo "   - Documents: $(ls PersistentData/documents/ 2>/dev/null | wc -l) files"
    echo "   - Projects: $(ls PersistentData/projects/ 2>/dev/null | wc -l) files"
else
    print_error "PersistentData directory not found!"
fi

if [ -d "Backups" ]; then
    BACKUP_COUNT=$(ls Backups/ 2>/dev/null | grep massivm_backup | wc -l)
    echo "💾 Backups: $BACKUP_COUNT backup(s) available"
    if [ $BACKUP_COUNT -gt 0 ]; then
        echo "   Latest: $(ls -t Backups/ | grep massivm_backup | head -1)"
    fi
else
    print_error "Backups directory not found!"
fi

echo ""

# Menu options
echo "Available Actions:"
echo "1. Create backup now"
echo "2. Restore from backup"
echo "3. Show backup details"
echo "4. Clean old backups"
echo "5. Export data to GitHub"
echo "6. Import data from GitHub"
echo "7. Setup auto-backup"
echo "8. Show storage usage"
echo "9. Exit"

read -p "Choose an option (1-9): " choice

case $choice in
    1)
        print_header "Creating Backup"
        if [ -f "backup-massivm.sh" ]; then
            ./backup-massivm.sh
        else
            print_error "Backup script not found!"
        fi
        ;;
    2)
        print_header "Restoring from Backup"
        if [ -f "restore-massivm.sh" ]; then
            ./restore-massivm.sh
        else
            print_error "Restore script not found!"
        fi
        ;;
    3)
        print_header "Backup Details"
        if [ -d "Backups" ]; then
            echo "Available backups:"
            ls -la Backups/ | grep massivm_backup
            echo ""
            read -p "Enter backup name to view details: " BACKUP_NAME
            if [ -d "Backups/$BACKUP_NAME" ]; then
                echo "Backup details for $BACKUP_NAME:"
                cat "Backups/$BACKUP_NAME/backup_info.txt" 2>/dev/null || echo "No info file found"
                echo ""
                echo "Contents:"
                ls -la "Backups/$BACKUP_NAME/"
            else
                print_error "Backup not found!"
            fi
        else
            print_error "No backups found!"
        fi
        ;;
    4)
        print_header "Cleaning Old Backups"
        if [ -d "Backups" ]; then
            echo "Current backups:"
            ls -la Backups/ | grep massivm_backup
            echo ""
            read -p "Enter backup name to delete (or 'all' for all): " DELETE_BACKUP
            if [ "$DELETE_BACKUP" = "all" ]; then
                rm -rf Backups/massivm_backup_*
                print_status "All backups deleted"
            elif [ -d "Backups/$DELETE_BACKUP" ]; then
                rm -rf "Backups/$DELETE_BACKUP"
                print_status "Backup $DELETE_BACKUP deleted"
            else
                print_error "Backup not found!"
            fi
        else
            print_error "No backups found!"
        fi
        ;;
    5)
        print_header "Export Data to GitHub"
        echo "This will create a GitHub repository with your data"
        read -p "Enter GitHub username: " GITHUB_USER
        read -p "Enter repository name: " REPO_NAME
        
        # Create export script
        cat > export-to-github.sh << EOF
#!/bin/bash
echo "Exporting data to GitHub..."
git init
git add PersistentData/ Save/ UserData/
git commit -m "MassiVM data export - $(date)"
git branch -M main
git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git
git push -u origin main
echo "✅ Data exported to https://github.com/$GITHUB_USER/$REPO_NAME"
EOF
        chmod +x export-to-github.sh
        print_status "Export script created: ./export-to-github.sh"
        print_warning "Run the script after creating the GitHub repository"
        ;;
    6)
        print_header "Import Data from GitHub"
        read -p "Enter GitHub repository URL: " GITHUB_REPO
        
        # Create import script
        cat > import-from-github.sh << EOF
#!/bin/bash
echo "Importing data from GitHub..."
git clone $GITHUB_REPO temp-import
cp -r temp-import/PersistentData . 2>/dev/null || true
cp -r temp-import/Save . 2>/dev/null || true
cp -r temp-import/UserData . 2>/dev/null || true
rm -rf temp-import
echo "✅ Data imported from GitHub"
EOF
        chmod +x import-from-github.sh
        print_status "Import script created: ./import-from-github.sh"
        ;;
    7)
        print_header "Setup Auto-Backup"
        echo "Auto-backup will create backups every hour"
        read -p "Start auto-backup in background? (y/n): " AUTO_BACKUP
        if [ "$AUTO_BACKUP" = "y" ]; then
            nohup ./auto-backup.sh > auto-backup.log 2>&1 &
            print_status "Auto-backup started in background"
            print_status "Log file: auto-backup.log"
        fi
        ;;
    8)
        print_header "Storage Usage"
        echo "Disk usage:"
        df -h .
        echo ""
        echo "Directory sizes:"
        du -sh PersistentData/ 2>/dev/null || echo "PersistentData: Not found"
        du -sh Backups/ 2>/dev/null || echo "Backups: Not found"
        du -sh Save/ 2>/dev/null || echo "Save: Not found"
        du -sh UserData/ 2>/dev/null || echo "UserData: Not found"
        ;;
    9)
        print_status "Exiting..."
        exit 0
        ;;
    *)
        print_error "Invalid option!"
        ;;
esac

echo ""
print_status "Storage management complete!" 