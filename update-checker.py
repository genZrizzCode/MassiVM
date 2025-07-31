#!/usr/bin/env python3
import os
import subprocess
import json
import time
from datetime import datetime
import requests

class MassiVMUpdater:
    def __init__(self):
        self.repo_url = "https://github.com/genZrizzCode/MassiVM"
        self.local_dir = "MassiVM"
        self.update_file = "update_status.json"
        self.last_check_file = "last_update_check.json"
        
    def get_remote_commit_hash(self):
        """Get the latest commit hash from the remote repository"""
        try:
            # Use GitHub API to get the latest commit
            api_url = "https://api.github.com/repos/genZrizzCode/MassiVM/commits/main"
            response = requests.get(api_url, timeout=10)
            if response.status_code == 200:
                return response.json()['sha']
            else:
                return None
        except Exception as e:
            print(f"Error getting remote commit: {e}")
            return None
    
    def get_local_commit_hash(self):
        """Get the current commit hash from the local repository"""
        try:
            if not os.path.exists(self.local_dir):
                return None
            
            result = subprocess.run(
                ['git', 'rev-parse', 'HEAD'],
                cwd=self.local_dir,
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                return result.stdout.strip()
            return None
        except Exception as e:
            print(f"Error getting local commit: {e}")
            return None
    
    def check_for_updates(self):
        """Check if there are updates available"""
        remote_hash = self.get_remote_commit_hash()
        local_hash = self.get_local_commit_hash()
        
        if not remote_hash:
            return False, "Could not fetch remote repository information"
        
        if not local_hash:
            return True, "Local repository not found, update needed"
        
        return remote_hash != local_hash, f"Remote: {remote_hash[:8]}, Local: {local_hash[:8]}"
    
    def perform_update(self):
        """Perform the update by pulling latest changes"""
        try:
            if not os.path.exists(self.local_dir):
                # Clone the repository if it doesn't exist
                subprocess.run(['git', 'clone', self.repo_url, self.local_dir], check=True)
                return True, "Repository cloned successfully"
            
            # Pull latest changes
            subprocess.run(['git', 'fetch', 'origin'], cwd=self.local_dir, check=True)
            subprocess.run(['git', 'reset', '--hard', 'origin/main'], cwd=self.local_dir, check=True)
            return True, "Repository updated successfully"
        except subprocess.CalledProcessError as e:
            return False, f"Update failed: {e}"
        except Exception as e:
            return False, f"Update error: {e}"
    
    def save_update_status(self, has_update, message):
        """Save the update status to a file"""
        status = {
            'timestamp': datetime.now().isoformat(),
            'has_update': has_update,
            'message': message,
            'checked': True
        }
        
        with open(self.update_file, 'w') as f:
            json.dump(status, f, indent=2)
    
    def get_last_check_time(self):
        """Get the last time we checked for updates"""
        try:
            if os.path.exists(self.last_check_file):
                with open(self.last_check_file, 'r') as f:
                    data = json.load(f)
                    return datetime.fromisoformat(data['last_check'])
            return None
        except:
            return None
    
    def save_check_time(self):
        """Save the current check time"""
        data = {
            'last_check': datetime.now().isoformat()
        }
        with open(self.last_check_file, 'w') as f:
            json.dump(data, f, indent=2)
    
    def should_check_for_updates(self, check_interval_hours=6):
        """Check if we should check for updates based on time interval"""
        last_check = self.get_last_check_time()
        if not last_check:
            return True
        
        time_diff = datetime.now() - last_check
        return time_diff.total_seconds() > (check_interval_hours * 3600)
    
    def run_update_check(self, auto_update=False):
        """Run the complete update check process"""
        if not self.should_check_for_updates():
            return
        
        print("🔍 Checking for MassiVM updates...")
        has_update, message = self.check_for_updates()
        
        if has_update:
            print(f"🔄 Update available: {message}")
            if auto_update:
                print("🔄 Performing automatic update...")
                success, update_message = self.perform_update()
                if success:
                    print(f"✅ {update_message}")
                    # Trigger container rebuild
                    self.trigger_rebuild()
                else:
                    print(f"❌ {update_message}")
            else:
                print("💡 Run with --auto-update to automatically apply updates")
        else:
            print("✅ MassiVM is up to date")
        
        self.save_update_status(has_update, message)
        self.save_check_time()
    
    def trigger_rebuild(self):
        """Trigger a rebuild of the Docker container"""
        try:
            print("🐳 Triggering container rebuild...")
            # Stop and remove existing container
            subprocess.run(['docker', 'stop', 'MassiVM'], capture_output=True)
            subprocess.run(['docker', 'rm', 'MassiVM'], capture_output=True)
            
            # Rebuild the image
            subprocess.run(['docker', 'build', '-t', 'massivm', 'MassiVM/', '--no-cache'], check=True)
            
            # Start the new container
            subprocess.run([
                'docker', 'run', '-d', '--name=MassiVM',
                '-e', 'PUID=1000', '-e', 'PGID=1000',
                '--security-opt', 'seccomp=unconfined',
                '-e', 'TZ=Etc/UTC', '-e', 'SUBFOLDER=/', '-e', 'TITLE=MassiVM',
                '-p', '3000:3000', '-p', '8080:8080', '-p', '5900:5900',
                '--shm-size=4gb',
                '-v', f'{os.getcwd()}/Save:/config',
                '-v', f'{os.getcwd()}/PersistentData:/home/user',
                '-v', f'{os.getcwd()}/UserData:/root/.local',
                '--restart', 'unless-stopped',
                'massivm'
            ], check=True)
            
            print("✅ Container rebuilt and restarted successfully")
        except subprocess.CalledProcessError as e:
            print(f"❌ Rebuild failed: {e}")
        except Exception as e:
            print(f"❌ Rebuild error: {e}")

def main():
    import argparse
    parser = argparse.ArgumentParser(description='MassiVM Update Checker')
    parser.add_argument('--auto-update', action='store_true', help='Automatically apply updates')
    parser.add_argument('--check-only', action='store_true', help='Only check for updates, don\'t apply')
    parser.add_argument('--force-check', action='store_true', help='Force check even if recently checked')
    
    args = parser.parse_args()
    
    updater = MassiVMUpdater()
    
    if args.force_check:
        # Clear last check time to force a check
        if os.path.exists(updater.last_check_file):
            os.remove(updater.last_check_file)
    
    if args.check_only:
        has_update, message = updater.check_for_updates()
        print(f"Update available: {has_update}")
        print(f"Message: {message}")
    else:
        updater.run_update_check(auto_update=args.auto_update)

if __name__ == "__main__":
    main() 