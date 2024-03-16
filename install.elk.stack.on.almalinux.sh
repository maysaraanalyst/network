#!/bin/bash

# Update package lists
sudo dnf update -y

# Install Java (required by Elasticsearch)
sudo dnf install java-11-openjdk-devel -y

# Add the Elastic repository
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch  # Import repository key
sudo dnf config-manager --add-repo https://artifacts.elastic.co/packages/oss/7.17/yum  # Replace version if needed

# Install Elasticsearch
sudo dnf install elasticsearch -y

# Enable and start Elasticsearch service
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service

# Add the Logstash repository
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch  # Import repository key (already imported)
sudo dnf config-manager --add-repo https://artifacts.elastic.co/packages/oss/7.17/yum  # Replace version if needed

# Install Logstash
sudo dnf install logstash -y

# Create a basic Logstash configuration file (replace with your actual configuration)
sudo touch /etc/logstash/conf.d/sample.conf
sudo cat << EOF >> /etc/logstash/conf.d/sample.conf
input {
  file {
    path => "/var/log/messages"
  }
}

output {
  stdout {
    codec => json
  }
}
EOF

# Enable and start Logstash service
sudo systemctl enable logstash.service
sudo systemctl start logstash.service

# Add the Kibana repository
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch  # Import repository key (already imported)
sudo dnf config-manager --add-repo https://artifacts.elastic.co/packages/oss/7.17/yum  # Replace version if needed

# Install Kibana
sudo dnf install kibana -y

# Enable and start Kibana service
sudo systemctl enable kibana.service
sudo systemctl start kibana.service

echo "ELK Stack (Elasticsearch, Logstash, Kibana) installation complete on AlmaLinux."
echo "** Access Kibana web interface at http://$(hostname -I | awk '{print $1}):5601**"
