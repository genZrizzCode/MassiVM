#!/usr/bin/env python3
import os
import json
import subprocess
from datetime import datetime
import time

def show_desktop_notification(title, message, urgency="normal"):
    """Show a desktop notification"""
    try:
        # Try to use notify-send if available
        subprocess.run([
            'notify-send', 
            '--urgency', urgency,
            '--app-name', 'MassiVM',
            title, 
            message
        ], check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        # Fallback to zenity if notify-send is not available
        try:
            subprocess.run([
                'zenity', 
                '--info',
                '--title', title,
                '--text', message,
                '--width', '400',
                '--height', '200'
            ], check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            # Final fallback - just print to console
            print(f"🔔 {title}: {message}")

def check_update_status():
    """Check if there are updates available"""
    update_file = "update_status.json"
    
    if not os.path.exists(update_file):
        return None
    
    try:
        with open(update_file, 'r') as f:
            data = json.load(f)
            return data
    except:
        return None

def create_update_desktop_file():
    """Create a desktop file for the update checker"""
    desktop_content = """[Desktop Entry]
Name=MassiVM Update Checker
Comment=Check for MassiVM updates
Exec=python3 /home/user/update-checker.py --check-only
Icon=system-software-update
Terminal=true
Type=Application
Categories=System;Settings;
Keywords=update;massivm;check;
"""
    
    desktop_dir = "/home/user/.local/share/applications"
    os.makedirs(desktop_dir, exist_ok=True)
    
    with open(f"{desktop_dir}/massivm-update-checker.desktop", 'w') as f:
        f.write(desktop_content)
    
    # Make it executable
    os.chmod(f"{desktop_dir}/massivm-update-checker.desktop", 0o755)

def create_auto_update_desktop_file():
    """Create a desktop file for automatic updates"""
    desktop_content = """[Desktop Entry]
Name=MassiVM Auto Update
Comment=Automatically update MassiVM
Exec=python3 /home/user/update-checker.py --auto-update
Icon=system-software-update
Terminal=true
Type=Application
Categories=System;Settings;
Keywords=update;massivm;auto;
"""
    
    desktop_dir = "/home/user/.local/share/applications"
    os.makedirs(desktop_dir, exist_ok=True)
    
    with open(f"{desktop_dir}/massivm-auto-update.desktop", 'w') as f:
        f.write(desktop_content)
    
    # Make it executable
    os.chmod(f"{desktop_dir}/massivm-auto-update.desktop", 0o755)

def main():
    """Main function to check and notify about updates"""
    print("🔍 MassiVM Update Notifier Starting...")
    
    # Create desktop files
    create_update_desktop_file()
    create_auto_update_desktop_file()
    
    # Check for updates every 30 minutes
    while True:
        status = check_update_status()
        
        if status and status.get('has_update', False):
            show_desktop_notification(
                "MassiVM Update Available",
                "A new version of MassiVM is available. Run 'MassiVM Update Checker' to apply updates.",
                "normal"
            )
        elif status and not status.get('has_update', False):
            # Only show "up to date" message once per day
            last_check = status.get('timestamp', '')
            if last_check:
                try:
                    check_time = datetime.fromisoformat(last_check)
                    now = datetime.now()
                    if (now - check_time).days >= 1:
                        show_desktop_notification(
                            "MassiVM Status",
                            "MassiVM is up to date.",
                            "low"
                        )
                except:
                    pass
        
        # Wait 30 minutes before next check
        time.sleep(1800)  # 30 minutes

if __name__ == "__main__":
    main() 