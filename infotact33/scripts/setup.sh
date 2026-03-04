#!/bin/bash
# Sentient Shield - Installation Script

set -e

echo "=========================================="
echo "Sentient Shield - EDR Setup"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Install Wazuh Manager
echo "[+] Installing Wazuh Manager..."
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
bash wazuh-install.sh -a

# Install Python dependencies
echo "[+] Installing Python dependencies..."
pip3 install -r requirements.txt

# Create necessary directories
echo "[+] Creating directories..."
mkdir -p /var/ossec/active-response/bin
mkdir -p /var/ossec/etc/rules
mkdir -p /var/ossec/logs

# Copy active response scripts
echo "[+] Copying active response scripts..."
cp active-response/*.sh /var/ossec/active-response/bin/
chmod +x /var/ossec/active-response/bin/*.sh

# Copy custom rules
echo "[+] Copying custom rules..."
cp rules/*.xml /var/ossec/etc/rules/

# Restart Wazuh Manager
echo "[+] Restarting Wazuh Manager..."
systemctl restart wazuh-manager

echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
