#!/bin/bash

# Set Keycloak version (adjust as needed)
KEYCLOAK_VERSION="19.0.0"

# Define installation directory
INSTALL_DIR=/opt/keycloak

# Update system packages
sudo dnf update -y

# Install Java 11 OpenJDK and unzip
sudo dnf install java-11-openjdk-devel unzip -y

# Create Keycloak user and group
sudo useradd -s /sbin/nologin keycloak

# Download Keycloak distribution
wget https://downloads.jboss.org/keycloak/latest/keycloak-$KEYCLOAK_VERSION.zip

# Extract Keycloak archive
unzip keycloak-$KEYCLOAK_VERSION.zip -d $INSTALL_DIR

# Set ownership of Keycloak directory
sudo chown -R keycloak:keycloak $INSTALL_DIR

# Configure firewall (replace with your specific rules if needed)
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --reload

# Enable and Start Keycloak service (systemd)
sudo systemctl enable keycloak.service
sudo systemctl start keycloak.service

# Print success message
echo "Keycloak has been installed and started successfully."
echo "Access the admin console at http://localhost:8080/auth/admin"

# (Optional) Create a systemd service file for Keycloak
cat << EOF > /etc/systemd/system/keycloak.service
[Unit]
Description=Keycloak Server
After=network.target

[Service]
Type=simple
User=keycloak
Group=keycloak
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/bin/kc.sh start-dev
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd (if service file was created)
sudo systemctl daemon-reload
