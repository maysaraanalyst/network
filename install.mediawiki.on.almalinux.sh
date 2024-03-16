#!/bin/bash

# Update package lists
sudo dnf update -y

# Install required packages
sudo dnf install mariadb-server mariadb-devel nginx php php-mbstring php-xml php-gd php-json -y

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

# Create the MediaWiki database and user
sudo mysql -u root -p"your_password" << EOF
CREATE DATABASE mediawiki CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON mediawiki.* TO 'mediawikiuser'@'localhost' IDENTIFIED BY 'mediawiki_password';
FLUSH PRIVILEGES;
EOF

# Download MediaWiki source code (replace version if needed)
MEDIAWIKI_VERSION="1.38.2"
wget https://download.wikimedia.org/mediawiki/versions/<span class="math-inline">\{MEDIAWIKI\_VERSION\}/archive/mediawiki\-</span>{MEDIAWIKI_VERSION}.tar.gz
tar -xvf mediawiki-<span class="math-inline">\{MEDIAWIKI\_VERSION\}\.tar\.gz
\# Move MediaWiki files to document root
sudo mv mediawiki\-</span>{MEDIAWIKI_VERSION}/* /var/www/html/mediawiki

# Set ownership and permissions for web server access
sudo chown -R apache:apache /var/www/html/mediawiki

# Configure SELinux context (if enabled)
if [ -f /usr/sbin/setsebool ]; then
  sudo setsebool -P httpd_can_network_connect on
fi

# Configure Nginx
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak  # Backup original config
sudo cat << EOF > /etc/nginx/nginx.conf
user  nginx;

worker_processes auto;

pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
  worker_connections 768;
  # Increase this if needed based on expected traffic
}

http {
  sendfile on;
  # Consider adjusting buffer sizes based on server configuration
  client_max_body_size 10m;

  server {
    listen 80;
    server_name localhost;

    location / {
      root /var/www/html/mediawiki;
      index index.php index.html index.htm;
      try_files $uri $uri/ /index.php?<span class="math-inline">args;
location \~ \\\.php</span> {
        include /etc/nginx/fastcgi_params.conf;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
      }
    }

    location ~ /\.ht {
      deny all;
    }
  }
}
EOF

# Adjust fastcgi_params.conf for your PHP configuration if needed
sudo cp /etc/nginx/fastcgi_params /etc/nginx/fastcgi_params.conf.bak

# Enable and start Nginx service
sudo systemctl enable nginx.service
sudo systemctl start nginx.service

# Create a basic configuration file for MediaWiki (replace with actual settings)
echo "<?php
\$wgServer = 'http://localhost';
\$wgMetaNamespace = 'Project';
\$wgEnableInstantCommons = false;

// Database settings
\$wgDBtype = 'mysql';
\$wgDBserver = 'localhost';
\$wgDBuser = 'mediawikiuser';
\$wgDBpassword = 'mediawiki_password';
\$wgDBname = 'mediawiki';

// Enable debug mode for initial setup (remove later!)
\$wgDebugMode = true;
\$wgShowDebug = true;

?>" > /var/www/html/mediawiki/LocalSettings.php

# Set file permissions for LocalSettings.php
sudo chmod 660 /var/www/html/mediawiki/LocalSettings.php

# Open web browser and navigate to http://localhost to complete installation

echo "MediaWiki installation complete on AlmaLinux (using Nginx)."
echo "** Access the MediaWiki web interface at http://localhost and follow the on-screen instructions to complete the setup process. **"
echo "** Remember to remove debug mode from LocalSettings.
