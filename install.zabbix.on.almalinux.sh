#!/bin/bash

# Update package lists
dnf update -y

# Disable any existing Zabbix packages from EPEL (if present)
dnf exclude epel:zabbix* -y

# Install Zabbix repository
dnf install https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm -y

# Choose Zabbix version (adjust if needed)
ZABBIX_VERSION="6.4"

# Install Zabbix server, frontend, agent, and additional dependencies
dnf install zabbix-server-$ZABBIX_VERSION zabbix-web-mysql-$ZABBIX_VERSION zabbix-apache-conf-$ZABBIX_VERSION zabbix-sql-scripts-$ZABBIX_VERSION zabbix-selinux-policy-$ZABBIX_VERSION zabbix-agent-$ZABBIX_VERSION mariadb-server php-fpm php-mysqlmod php-gd php-xml php-json -y

# Start MariaDB service
systemctl start mariadb

# Secure MariaDB with a strong password
mysql_secure_installation

# Create the initial Zabbix database
mysql -u root -p << EOF
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@localhost IDENTIFIED BY 'strong_password';
FLUSH PRIVILEGES;
EOF

# Import initial schema for Zabbix database
zcat /usr/share/doc/zabbix-server-$ZABBIX_VERSION/schema.sql.gz | mysql -u zabbix zabbix

# Enable and start Zabbix server, web interface, and agent services
systemctl enable zabbix-server zabbix-httpd-apache zabbix-agent.service
systemctl start zabbix-server zabbix-httpd-apache zabbix-agent.service

# Open firewall ports (if needed)
# Replace these with the actual ports used by Zabbix if different
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=10050/tcp
firewall-cmd --reload

# (Optional) Set SELinux contexts (if required)
# semanage fcontext -a -t httpd_sys_rw_content /var/www/html/zabbix/upload/
# restorecon -R /var/www/html/zabbix/upload/

echo "Zabbix server, frontend, and agent are now installed on AlmaLinux."
echo "Remember to replace 'strong_password' with a strong password for the Zabbix database user."
echo "Access the Zabbix web interface at http://<your_server_ip_or_hostname>/zabbix to complete the configuration."
