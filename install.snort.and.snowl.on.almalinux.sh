#!/bin/bash

# Update package lists
sudo dnf update -y

# Install dependencies
sudo dnf install gcc gcc-c++ automake autoconf libpcap-devel openssl-devel libtool make mariadb-server mariadb-devel httpd httpd-devel php php-mbstring php-xml php-gd php-json -y

# Configure and start MariaDB (replace 'your_password' with a strong password)
sudo mysql_secure_installation << EOF
y
your_password
your_password
y
y
y
y
EOF
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service

# Create the Snort user and database
sudo mysql -u root -p"your_password" << EOF
CREATE DATABASE snort CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON snort.* TO 'snortuser'@'localhost' IDENTIFIED BY 'snort_password';
FLUSH PRIVILEGES;
EOF

# Download Snort source code (replace version if needed)
SNORT_VERSION="3.3.0"
wget https://www.snort.org/downloads/snort-src-${SNORT_VERSION}.tar.gz
tar -xvf snort-src-${SNORT_VERSION}.tar.gz

# Build and install Snort (adjust options as needed)
cd snort-src-${SNORT_VERSION}
./configure --prefix=/usr/local/snort --enable-sourcefire --with-mysql --with-libpcap --with-openssl
make
sudo make install

# Create Snort configuration directory
sudo mkdir -p /etc/snort

# Copy basic Snort configuration files (replace paths if needed)
sudo cp /usr/local/snort/etc/snort.conf /etc/snort/snort.conf
sudo cp /usr/local/snort/etc/classification.conf /etc/snort/classification.conf
sudo cp /usr/local/snort/etc/rules/community.rules /etc/snort/rules/community.rules

# Configure Snort rules (update and add custom rules as needed)
sudo echo "include /etc/snort/rules/community.rules" >> /etc/snort/snort.conf

# Set Snort user and group ownership for configuration files
sudo chown -R snort:snort /etc/snort

# Download Snowl pre-built binary (replace version if needed)
SNOWL_VERSION="5.0.3"
wget https://github.com/SecurityOnion/snowl/releases/download/v${SNOWL_VERSION}/snowl_${SNOWL_VERSION}-linux_x86_64.tar.gz
tar -xvf snowl_${SNOWL_VERSION}-linux_x86_64.tar.gz
sudo mv snowl_${SNOWL_VERSION}-linux_x86_64/snowl /usr/local/bin/snowl

# Configure Snowl with Snort connection details
sudo echo "[database]" >> /etc/snowl.conf
sudo echo "host = localhost" >> /etc/snowl.conf
sudo echo "port = 3306" >> /etc/snowl.conf
sudo echo "database = snort" >> /etc/snowl.conf
sudo echo "user = snortuser" >> /etc/snowl.conf
sudo echo "password = snort_password" >> /etc/snowl.conf

# (Optional) Create a systemd service file for Snort
# Refer to Snort documentation for details on service file creation

# Enable and start MariaDB service (already started earlier)
# sudo systemctl enable mariadb.service
# sudo systemctl start mariadb.service

# Start Snort (replace with your chosen method, e.g., systemd service)
# sudo /usr/local/snort/bin/snort -d

echo "Snort and Snowl GUI installation complete on AlmaLinux."
echo "** Configure Snort rules (/etc/snort/rules) as needed. **"
echo "** Access Snowl web interface at http://localhost:5500 (default port). **"
echo "** Default username/password for Snowl: admin/admin (Change the password!)**"
