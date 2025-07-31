#!/bin/bash

# Start the update notifier in the background
cd /home/user
python3 update-notifier.py &
UPDATE_NOTIFIER_PID=$!

# Store the PID for later cleanup
echo $UPDATE_NOTIFIER_PID > /tmp/update-notifier.pid

# Run initial update check
python3 update-checker.py --check-only

echo "🔄 MassiVM Update System Started"
echo "📱 Desktop notifications will appear for updates"
echo "🖱️ Use 'MassiVM Update Checker' from Applications menu"
echo "⚡ Use 'MassiVM Auto Update' for automatic updates" 