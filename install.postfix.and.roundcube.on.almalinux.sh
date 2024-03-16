#!/bin/bash

# Update package lists
sudo dnf update -y

# Install required packages
sudo dnf install postfix dovecot dovecot-imapd dovecot-pop3d php php-imap php-mysqli php-mbstring mariadb mariadb-server mariadb-devel roundcube webserver-config -y

# Initialize MySQL database
sudo mysql_secure_installation

# Start and enable MySQL
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Create Roundcube database
sudo mysql -u root -p  -e "CREATE DATABASE roundcube CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -u root -p  -e "GRANT ALL PRIVILEGES ON roundcube.* TO 'roundcube'@'localhost' IDENTIFIED BY 'your_password';"

# Replace 'your_password' with a strong password

# Configure Postfix (basic)
sudo postconf myhostname=your_domain.com
sudo postconf relayhost=

# Replace 'your_domain.com' with your actual domain name
# Set relayhost if your server doesn't handle outbound emails directly

# Start and enable Postfix and Dovecot
sudo systemctl start postfix
sudo systemctl enable postfix
sudo systemctl start dovecot
sudo systemctl enable dovecot

# Enable Roundcube web server module (adjust for your web server)
sudo semanage port -a http_port,tcp_port 80 apache

# Replace 'apache' with your actual web server name if different

# Create Roundcube configuration
sudo roundcube-install-defaults --verbose -u root -p

# Follow on-screen instructions to complete Roundcube config

echo "Postfix and Roundcube installation complete!"
echo "**Remember to configure Postfix and Roundcube further for your specific needs.**"
