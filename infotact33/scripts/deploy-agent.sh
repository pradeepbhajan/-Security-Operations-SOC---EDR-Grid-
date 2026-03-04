#!/bin/bash
# Deploy Wazuh Agent to Remote Host

if [ $# -lt 2 ]; then
    echo "Usage: $0 <target-ip> <manager-ip>"
    exit 1
fi

TARGET_IP=$1
MANAGER_IP=$2

echo "Deploying Wazuh agent to $TARGET_IP..."

# Copy agent package
scp wazuh-agent-installer.sh root@$TARGET_IP:/tmp/

# Install agent
ssh root@$TARGET_IP << EOF
    bash /tmp/wazuh-agent-installer.sh
    
    # Configure manager IP
    sed -i "s/MANAGER_IP/$MANAGER_IP/g" /var/ossec/etc/ossec.conf
    
    # Start agent
    systemctl enable wazuh-agent
    systemctl start wazuh-agent
    
    echo "Agent deployed successfully!"
EOF
