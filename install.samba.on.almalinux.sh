#!/bin/bash

# Update package lists
sudo dnf update -y

# Install Samba packages
sudo dnf install samba samba-common samba-client -y

# Create a directory for your Samba share (replace '/path/to/share' with your desired location)
sudo mkdir -p /path/to/share

# Set ownership of the share directory (adjust user/group if needed)
sudo chown -R nobody:nogroup /path/to/share

# Configure Samba with a basic share definition
sudo nano /etc/samba/smb.conf

# Add the following lines to the end of the file, replacing '/path/to/share' with your actual path:

[your_share_name]
    path = /path/to/share
    public = yes
    writable = yes
    guest ok = yes  # Uncomment for guest access (security risk, use with caution!)

# Save the configuration file (Ctrl+O, then Enter key) and exit the editor (Ctrl+X)

# Test Samba configuration for syntax errors
sudo testparm /etc/samba/smb.conf

# Enable and start Samba services
sudo systemctl enable smb nmb
sudo systemctl start smb nmb

echo "Samba server installation complete on AlmaLinux."
echo "** Access the Samba share from Windows machines using \\\\<server_IP>\\your_share_name**"
echo "** Consider security implications of public access and guest ok options!**"
