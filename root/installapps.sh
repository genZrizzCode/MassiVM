#!/bin/bash

json_file="/options.json"

# Default Apps
if jq ".defaultapps | contains([0])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/wine.sh
    /installable-apps/wine.sh
fi
if jq ".defaultapps | contains([1])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/google.sh
    /installable-apps/google.sh
fi
if jq ".defaultapps | contains([2])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/xarchiver.sh
    /installable-apps/xarchiver.sh
fi
if jq ".defaultapps | contains([3])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/discord.sh
    /installable-apps/discord.sh
fi
if jq ".defaultapps | contains([4])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/steam.sh
    /installable-apps/steam.sh
fi
if jq ".defaultapps | contains([5])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/minecraft.sh
    /installable-apps/minecraft.sh
fi
if jq ".defaultapps | contains([6])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/vscode.sh
    /installable-apps/vscode.sh
fi
if jq ".defaultapps | contains([7])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/docker.sh
    /installable-apps/docker.sh
fi
if jq ".defaultapps | contains([8])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/postgresql.sh
    /installable-apps/postgresql.sh
fi
if jq ".defaultapps | contains([9])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/redis.sh
    /installable-apps/redis.sh
fi
if jq ".defaultapps | contains([10])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/alacritty.sh
    /installable-apps/alacritty.sh
fi

# Programming Tools
if jq ".programming | contains([0])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/openjdk-8-jre.sh
    /installable-apps/openjdk-8-jre.sh
fi
if jq ".programming | contains([1])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/openjdk-17-jre.sh
    /installable-apps/openjdk-17-jre.sh
fi
if jq ".programming | contains([2])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/vscodium.sh
    /installable-apps/vscodium.sh
fi
if jq ".programming | contains([3])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/nodejs-tools.sh
    /installable-apps/nodejs-tools.sh
fi
if jq ".programming | contains([4])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/python-tools.sh
    /installable-apps/python-tools.sh
fi
if jq ".programming | contains([5])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/go-tools.sh
    /installable-apps/go-tools.sh
fi
if jq ".programming | contains([6])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/rust-tools.sh
    /installable-apps/rust-tools.sh
fi

# Additional Apps
if jq ".apps | contains([0])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/vlc.sh
    /installable-apps/vlc.sh
fi
if jq ".apps | contains([1])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/libreoffice.sh
    /installable-apps/libreoffice.sh
fi
if jq ".apps | contains([2])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/synaptic.sh
    /installable-apps/synaptic.sh
fi
if jq ".apps | contains([3])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/aqemu.sh
    /installable-apps/aqemu.sh
fi
if jq ".apps | contains([4])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/tlauncher.sh
    /installable-apps/tlauncher.sh
fi
if jq ".apps | contains([5])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/csgo.sh
    /installable-apps/csgo.sh
fi
if jq ".apps | contains([6])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/cs2.sh
    /installable-apps/cs2.sh
fi
if jq ".apps | contains([7])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/lutris.sh
    /installable-apps/lutris.sh
fi
if jq ".apps | contains([8])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/retroarch.sh
    /installable-apps/retroarch.sh
fi
if jq ".apps | contains([9])" "$json_file" | grep -q true; then
    chmod +x /installable-apps/playonlinux.sh
    /installable-apps/playonlinux.sh
fi

# MassiVM specific installations
echo "Installing MassiVM specific tools..."

# Install additional development tools
npm install -g yarn pnpm typescript ts-node nodemon
pip3 install --user pipenv virtualenv jupyter

# Install VS Code extensions if VS Code is installed
if command -v code &> /dev/null; then
    code --install-extension ms-vscode.vscode-typescript-next
    code --install-extension ms-python.python
    code --install-extension ms-vscode.vscode-json
    code --install-extension bradlc.vscode-tailwindcss
    code --install-extension ms-vscode.vscode-docker
    code --install-extension ms-vscode.vscode-go
    code --install-extension rust-lang.rust-analyzer
fi

# clean stuff
rm -rf /installable-apps
