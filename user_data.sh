#!/bin/bash
set -e

# ===================================================
# Combined bootstrap: Docker CE + Jenkins LTS
# Runs automatically at EC2 launch via user_data (as root)
# ===================================================

exec > >(tee /var/log/user-data.log) 2>&1

echo "========================================="
echo " Installing Docker CE on Ubuntu 24.04"
echo "========================================="

echo "Updating system..."
apt update
apt upgrade -y

echo "Removing old/conflicting Docker packages (including containerd from Ubuntu repos)..."
apt remove -y docker docker-engine docker.io docker-compose docker-compose-v2 \
  docker-doc podman-docker containerd containerd.io runc || true
apt autoremove -y

echo "Installing required dependencies..."
apt install -y ca-certificates curl

echo "Adding Docker's official GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
  > /etc/apt/sources.list.d/docker.list

echo "Updating package list..."
apt update

echo "Installing Docker CE (official packages only)..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Enabling Docker service..."
systemctl enable docker
systemctl start docker

echo "Adding default ubuntu user to docker group..."
usermod -aG docker ubuntu || true

echo ""
echo "=========================================="
echo "Docker installation completed successfully!"
echo "=========================================="
docker --version
docker compose version

echo "========================================="
echo " Installing Jenkins LTS on Ubuntu 24.04"
echo "========================================="

echo "[1/8] Installing required packages (Docker already installed above)..."
apt install -y curl wget fontconfig openjdk-21-jre ca-certificates

echo "[2/8] Checking Java installation..."
java -version

echo "[3/8] Checking for Docker..."
if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed: $(docker --version)"
    systemctl enable --now docker
else
    echo "WARNING: Docker not found, Jenkins will not be able to use Docker."
fi

echo "[4/8] Removing old/conflicting Jenkins repository configurations..."
rm -f /etc/apt/sources.list.d/jenkins.list
rm -f /etc/apt/keyrings/jenkins-keyring.asc
rm -f /usr/share/keyrings/jenkins-keyring.asc

echo "[5/8] Creating APT keyrings directory..."
install -d -m 0755 /etc/apt/keyrings

echo "[6/8] Installing the current Jenkins 2026 GPG signing key..."
curl -fsSL \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  -o /etc/apt/keyrings/jenkins-keyring.asc
chmod 644 /etc/apt/keyrings/jenkins-keyring.asc

echo "[7/8] Adding Jenkins LTS repository..."
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list

echo "[8/8] Installing Jenkins..."
apt update
apt install -y jenkins

if command -v docker >/dev/null 2>&1; then
    echo "Granting Jenkins access to Docker..."
    usermod -aG docker jenkins
else
    echo "Skipping Docker group assignment (Docker not installed)."
fi

echo "Enabling Jenkins service..."
systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins

echo
echo "========================================="
echo " Jenkins installation completed!"
echo "========================================="
echo
systemctl --no-pager status jenkins || true

echo
echo "Initial Admin Password:"
cat /var/lib/jenkins/secrets/initialAdminPassword || echo "(not generated yet, check again shortly)"

echo
echo "========================================="
echo " SETUP COMPLETE "
echo "========================================="

git clone https://github.com/vaish8913/simpletravel.git /opt/simpletravel
cd /opt/simpletravel
docker build -t simpletravel:latest .
docker rm -f web 2>/dev/null || true
docker run -d --name web --restart unless-stopped -p 7080:80 simpletravel:latest
