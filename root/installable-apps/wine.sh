echo "**** install wine ****"
# Wine is already installed in Dockerfile
echo "Wine already installed. Configuring additional components..."
dpkg --add-architecture i386
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y wine32
