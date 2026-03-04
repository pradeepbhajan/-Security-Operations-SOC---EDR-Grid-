#!/bin/bash
# Week 1: Automated Infrastructure Setup Script
# Sentient Shield - Wazuh Manager Installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    error "Please run as root (sudo)"
fi

echo "=========================================="
echo "  Sentient Shield - Week 1 Setup"
echo "  Infrastructure & Agent Deployment"
echo "=========================================="
echo ""

# Step 1: System Requirements Check
log "Checking system requirements..."

# Check RAM
TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM" -lt 4 ]; then
    warning "RAM is less than 4GB. Recommended: 8GB+"
fi

# Check disk space
DISK_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$DISK_SPACE" -lt 50 ]; then
    warning "Disk space is less than 50GB. Recommended: 50GB+"
fi

# Check CPU cores
CPU_CORES=$(nproc)
if [ "$CPU_CORES" -lt 2 ]; then
    warning "CPU cores less than 2. Recommended: 4 cores"
fi

log "System check complete: ${TOTAL_RAM}GB RAM, ${DISK_SPACE}GB disk, ${CPU_CORES} CPU cores"

# Step 2: Update system
log "Updating system packages..."
apt update && apt upgrade -y

# Step 3: Install dependencies
log "Installing required packages..."
apt install -y curl apt-transport-https lsb-release gnupg wget unzip

# Step 4: Download Wazuh installation script
log "Downloading Wazuh installation script..."
cd /tmp
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh

if [ ! -f "wazuh-install.sh" ]; then
    error "Failed to download Wazuh installation script"
fi

# Step 5: Install Wazuh (All-in-One)
log "Installing Wazuh Manager, Indexer, and Dashboard..."
log "This may take 10-15 minutes..."

bash wazuh-install.sh -a -i

if [ $? -ne 0 ]; then
    error "Wazuh installation failed"
fi

# Step 6: Save credentials
log "Saving installation credentials..."
CREDS_FILE="/root/wazuh-credentials.txt"
if [ -f "/tmp/wazuh-install-files/wazuh-passwords.txt" ]; then
    cp /tmp/wazuh-install-files/wazuh-passwords.txt "$CREDS_FILE"
    chmod 600 "$CREDS_FILE"
    log "Credentials saved to: $CREDS_FILE"
else
    warning "Credentials file not found. Check /tmp/wazuh-install-files/"
fi

# Step 7: Verify services
log "Verifying Wazuh services..."

sleep 10

systemctl is-active --quiet wazuh-manager && log "✓ Wazuh Manager is running" || error "Wazuh Manager is not running"
systemctl is-active --quiet wazuh-indexer && log "✓ Wazuh Indexer is running" || error "Wazuh Indexer is not running"
systemctl is-active --quiet wazuh-dashboard && log "✓ Wazuh Dashboard is running" || error "Wazuh Dashboard is not running"

# Step 8: Configure firewall
log "Configuring firewall rules..."

if command -v ufw &> /dev/null; then
    ufw allow 1514/tcp comment "Wazuh Agent Communication"
    ufw allow 1515/tcp comment "Wazuh Agent Enrollment"
    ufw allow 55000/tcp comment "Wazuh API"
    ufw allow 443/tcp comment "Wazuh Dashboard"
    ufw allow 9200/tcp comment "Wazuh Indexer"
    log "✓ UFW firewall rules configured"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=1514/tcp
    firewall-cmd --permanent --add-port=1515/tcp
    firewall-cmd --permanent --add-port=55000/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --permanent --add-port=9200/tcp
    firewall-cmd --reload
    log "✓ Firewalld rules configured"
else
    warning "No firewall detected. Please configure manually."
fi

# Step 9: Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Step 10: Create Week 1 completion report
REPORT_FILE="/root/week1-completion-report.txt"
cat > "$REPORT_FILE" << EOF
========================================
Sentient Shield - Week 1 Completion Report
========================================

Installation Date: $(date)
Server IP: $SERVER_IP

SERVICES STATUS:
- Wazuh Manager: $(systemctl is-active wazuh-manager)
- Wazuh Indexer: $(systemctl is-active wazuh-indexer)
- Wazuh Dashboard: $(systemctl is-active wazuh-dashboard)

ACCESS INFORMATION:
- Dashboard URL: https://$SERVER_IP
- API URL: https://$SERVER_IP:55000
- Credentials: See $CREDS_FILE

NEXT STEPS:
1. Access dashboard at https://$SERVER_IP
2. Deploy Linux agent (see docs/week1-infrastructure-deployment.md)
3. Deploy Windows agent
4. Install Sysmon on Windows
5. Verify all agents show "Active" status

AGENT DEPLOYMENT COMMANDS:
Linux Agent:
  curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
  echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
  apt update && apt install wazuh-agent -y
  sed -i "s/MANAGER_IP/$SERVER_IP/g" /var/ossec/etc/ossec.conf
  systemctl enable wazuh-agent && systemctl start wazuh-agent

Windows Agent:
  Download from: https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.0-1.msi
  Install with: msiexec.exe /i wazuh-agent-4.7.0-1.msi /q WAZUH_MANAGER="$SERVER_IP"

========================================
EOF

log "Week 1 completion report saved to: $REPORT_FILE"

# Final output
echo ""
echo "=========================================="
echo -e "${GREEN}✓ Week 1 Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Dashboard URL: https://$SERVER_IP"
echo "Credentials: $CREDS_FILE"
echo "Report: $REPORT_FILE"
echo ""
echo "Next: Deploy agents on target systems"
echo "See: docs/week1-infrastructure-deployment.md"
echo "=========================================="
