#!/bin/bash

# Define Bacula version (adjust if needed)
BACULA_VERSION="11.0.1"

# Update package lists
sudo dnf update -y

# Install Bacula Server packages (Director, Storage Daemon, and File Daemon)
sudo dnf install bacula-server bacula-director bacula-console -y

# Install Bacula Client package (for backing up client machines)
sudo dnf install bacula-client -y

# Initialize the Bacula storage directories (adjust paths if needed)
sudo bacula-dir -i -c /etc/bacula/bacula-dir.conf
sudo bacula-sd -i -c /etc/bacula/bacula-sd.conf

# Enable and start Bacula services
sudo systemctl enable bacula-dir bacula-sd bacula-fd
sudo systemctl start bacula-dir bacula-sd bacula-fd

# (Optional) Open firewall ports for Bacula (Director web UI - 9001, Storage Daemon - 9101)
# sudo firewall-cmd --permanent --add-port=9001/tcp
# sudo firewall-cmd --permanent --add-port=9101/tcp
# sudo firewall-cmd --reload

echo "Bacula $BACULA_VERSION installation complete on AlmaLinux."
echo "** Please refer to Bacula documentation for configuration: https://www.bacula.org/documentation/documentation/**"
