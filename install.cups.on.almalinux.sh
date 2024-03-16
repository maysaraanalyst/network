#!/bin/bash

# Update package lists
sudo dnf update -y

# Install CUPS package
sudo dnf install cups -y

# Enable and start CUPS services
sudo systemctl enable cups
sudo systemctl start cups

# Open firewall port for CUPS (adjust if needed)
sudo firewall-cmd --permanent --add-port=631/tcp
sudo firewall-cmd --reload

# (Optional) Configure web interface access (not recommended for production)
# Uncomment the following line if desired
# sudo usermod -aG lpadmin <username>  # Replace `<username>` with your actual username

echo "CUPS server installation complete on AlmaLinux."
echo "** Access CUPS web interface (if enabled) at http://localhost:631/ **"
echo "** Warning: Web interface access should be restricted in production environments. **"
