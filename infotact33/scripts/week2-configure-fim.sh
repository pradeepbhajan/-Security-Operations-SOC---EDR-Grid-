#!/bin/bash
# Week 2: Automated FIM Configuration Script
# Configures File Integrity Monitoring on Linux agents

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

echo "=========================================="
echo "  Week 2: FIM Configuration"
echo "=========================================="
echo ""

# Check if Wazuh agent is installed
if [ ! -f "/var/ossec/bin/wazuh-control" ]; then
    error "Wazuh agent not found. Please install agent first."
fi

# Backup original config
log "Backing up original configuration..."
sudo cp /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.backup.$(date +%Y%m%d_%H%M%S)

# Create FIM configuration
log "Configuring File Integrity Monitoring..."

FIM_CONFIG='
  <!-- File Integrity Monitoring Configuration -->
  <syscheck>
    <disabled>no</disabled>
    <frequency>300</frequency>
    <scan_on_start>yes</scan_on_start>
    
    <!-- Critical System Files -->
    <directories check_all="yes" realtime="yes" report_changes="yes">/etc</directories>
    <directories check_all="yes" realtime="yes">/usr/bin</directories>
    <directories check_all="yes" realtime="yes">/usr/sbin</directories>
    <directories check_all="yes" realtime="yes">/bin</directories>
    <directories check_all="yes" realtime="yes">/sbin</directories>
    
    <!-- Web Application Directory -->
    <directories check_all="yes" realtime="yes" report_changes="yes">/var/www</directories>
    
    <!-- SSH Configuration -->
    <directories check_all="yes" realtime="yes" report_changes="yes">/etc/ssh</directories>
    
    <!-- Cron Jobs -->
    <directories check_all="yes" realtime="yes">/etc/cron.d</directories>
    <directories check_all="yes" realtime="yes">/etc/cron.daily</directories>
    <directories check_all="yes" realtime="yes">/var/spool/cron</directories>
    
    <!-- Ignore temporary files -->
    <ignore>/etc/mtab</ignore>
    <ignore>/etc/hosts.deny</ignore>
    <ignore>/etc/mail/statistics</ignore>
    <ignore>/etc/random-seed</ignore>
    <ignore>/etc/adjtime</ignore>
    <ignore>/etc/prelink.cache</ignore>
    
    <!-- Alert on new files -->
    <alert_new_files>yes</alert_new_files>
  </syscheck>
'

# Check if syscheck already configured
if grep -q "<syscheck>" /var/ossec/etc/ossec.conf; then
    log "Syscheck section already exists, updating..."
    # Remove old syscheck section
    sudo sed -i '/<syscheck>/,/<\/syscheck>/d' /var/ossec/etc/ossec.conf
fi

# Add FIM configuration before </ossec_config>
sudo sed -i "/<\/ossec_config>/i $FIM_CONFIG" /var/ossec/etc/ossec.conf

log "FIM configuration added"

# Create test directory
log "Creating test directory for FIM verification..."
sudo mkdir -p /var/www/test
sudo chmod 755 /var/www/test

# Restart agent
log "Restarting Wazuh agent..."
sudo systemctl restart wazuh-agent

# Wait for agent to start
sleep 5

# Verify agent is running
if systemctl is-active --quiet wazuh-agent; then
    log "✓ Wazuh agent restarted successfully"
else
    error "Wazuh agent failed to start. Check logs: tail -f /var/ossec/logs/ossec.log"
fi

# Create initial test file
log "Creating initial test file..."
echo "Initial content - $(date)" | sudo tee /var/www/test/fim_test.txt > /dev/null

log "Waiting 15 seconds for initial scan..."
sleep 15

# Modify test file to trigger alert
log "Modifying test file to trigger FIM alert..."
echo "Modified content - $(date)" | sudo tee -a /var/www/test/fim_test.txt > /dev/null

echo ""
echo "=========================================="
echo -e "${GREEN}✓ FIM Configuration Complete!${NC}"
echo "=========================================="
echo ""
echo "Monitored Directories:"
echo "  - /etc (critical system files)"
echo "  - /usr/bin, /usr/sbin (binaries)"
echo "  - /var/www (web applications)"
echo "  - /etc/ssh (SSH configuration)"
echo "  - /etc/cron.d, /var/spool/cron (scheduled tasks)"
echo ""
echo "Test file created: /var/www/test/fim_test.txt"
echo ""
echo "Next Steps:"
echo "1. Check Wazuh Dashboard for FIM alert (should appear within 5 seconds)"
echo "2. Look for Rule 550 (File modified)"
echo "3. Verify file path and changes are shown"
echo ""
echo "Manual test:"
echo "  echo 'test' | sudo tee -a /var/www/test/fim_test.txt"
echo ""
echo "=========================================="
