#!/bin/bash

# Update package lists
sudo dnf update -y

# Install BIND and ISC DHCP server
sudo dnf install bind bind-utils isc-dhcp-server -y

# Set firewall rules for DNS and DHCP (adjust ports if needed)
sudo firewall-cmd --permanent --add-port=53/udp
sudo firewall-cmd --permanent --add-port=67/udp
sudo firewall-cmd --reload

# Inform user about configuration files
echo "BIND configuration file: /etc/named.conf"
echo "DHCP configuration file: /etc/dhcp/dhcpd.conf"

# Start and enable services
sudo systemctl start named
sudo systemctl start dhcpd
sudo systemctl enable named
sudo systemctl enable dhcpd

echo "BIND and ISC DHCP server installation complete!"
