#!/bin/bash

# Update package lists
sudo dnf update -y

# Install dependencies
sudo dnf install firewalld wget -y

# Create Prometheus user and directory
sudo useradd --system -r prometheus
sudo mkdir -p /etc/prometheus
sudo chown prometheus:prometheus /etc/prometheus

# Download Prometheus binary
PROMETHEUS_VERSION="2.39.2"  # Update version if needed
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-linux-amd64-${PROMETHEUS_VERSION}.tar.gz
tar -xvf prometheus-linux-amd64-${PROMETHEUS_VERSION}.tar.gz
sudo mv prometheus-linux-amd64-${PROMETHEUS_VERSION}/* /etc/prometheus

# Configure Prometheus systemd service
sudo touch /etc/systemd/system/prometheus.service
sudo cat << EOF >> /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/etc/prometheus/prometheus --config.file /etc/prometheus/prometheus.yml

[Install]
WantedBy=multi-user.target
EOF

# Create a basic Prometheus configuration file
sudo touch /etc/prometheus/prometheus.yml
sudo cat << EOF >> /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

# Alertmanager configuration (replace with your actual setup)
alertmanager_config:
  # - static_configs:
  #   - targets: ['localhost:9093']

# Example scrape configs for common targets
scrape_configs:
  # Node exporter scrape configuration
  - job_name: 'node_exporter'
    static_configs:
    - targets: ['localhost:9100']
EOF

# Reload systemd daemon and enable/start Prometheus service
sudo systemctl daemon-reload
sudo systemctl enable prometheus.service
sudo systemctl start prometheus.service

# Install Grafana
sudo dnf install grafana -y

# Configure Grafana systemd service (adjust port if needed)
sudo sed -i 's/http_port=3000/http_port=8080/g' /etc/grafana/grafana.ini

# Enable and start Grafana service
sudo systemctl enable grafana-server.service
sudo systemctl start grafana-server.service

echo "Prometheus and Grafana are installed and running on AlmaLinux."
echo "** Access Grafana on http://$(hostname -I | awk '{print $1}'):8080 (default port might be different) **"
echo "** Default Grafana username/password: admin/admin (Change the password!)**"
