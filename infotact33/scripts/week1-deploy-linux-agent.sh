#!/bin/bash
# Week 1: Linux Agent Deployment Script
# Run this on the target Linux server

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <wazuh-manager-ip>"
    exit 1
fi

MANAGER_IP=$1

echo "=========================================="
echo "  Deploying Wazuh Linux Agent"
echo "  Manager IP: $MANAGER_IP"
echo "=========================================="

# Add Wazuh repository
echo "[+] Adding Wazuh repository..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

# Update and install
echo "[+] Installing Wazuh agent..."
apt update
apt install wazuh-agent -y

# Configure manager IP
echo "[+] Configuring manager IP..."
sed -i "s/MANAGER_IP/$MANAGER_IP/g" /var/ossec/etc/ossec.conf

# Enable and start
echo "[+] Starting Wazuh agent..."
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

# Verify
sleep 3
if systemctl is-active --quiet wazuh-agent; then
    echo "✓ Wazuh agent installed and running"
    echo ""
    echo "Agent ID will be assigned by manager"
    echo "Check manager dashboard for agent status"
else
    echo "✗ Agent failed to start"
    echo "Check logs: tail -f /var/ossec/logs/ossec.log"
    exit 1
fi

echo "=========================================="
