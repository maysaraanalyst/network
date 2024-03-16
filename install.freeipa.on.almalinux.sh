#!/bin/bash

# Update package lists
sudo dnf update -y

# Install required packages
sudo dnf install -y httpd httpd-devel openldap-devel compat-libs nss-tools authconfig policycoreutils-python openssl krb5-libs

# Configure firewalld for FreeIPA services (adjust ports if needed)
sudo firewall-cmd --permanent --add-port=389/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=80/tcp  # Optional for HTTP access to web UI
sudo firewall-cmd --reload

# Synchronize package database
sudo dnf makecache

# Enable Ipsilon (FreeIPA server) repository
sudo dnf config-manager --add-repo https://download.fedoraproject.org/pub/epel/8/Everything/x86_64/repodata/repofile.xml
sudo dnf config-manager --add-repo https://download.fedoraproject.org/pub/epel/epel8/Everything/x86_64/repodata/repofile.xml

# Install FreeIPA server package
sudo dnf install freeipa-server -y

# Initialize FreeIPA server (replace 'your_realm' with your desired realm name)
sudo realm join -v -u nobody --realm-setup your_realm

# Set the FreeIPA server password (enter password twice when prompted)
sudo realmpasswd

# Enable and start FreeIPA services
sudo systemctl enable named ipa{http,https,server,oddjobd,replication}
sudo systemctl start named ipa{http,https,server,oddjobd,replication}

echo "FreeIPA server installation complete on AlmaLinux."
echo "** Refer to FreeIPA documentation for further configuration: https://www.freeipa.org/page/Servers/**"
