#!/bin/bash
# Week 2: Deploy Custom Rules and Decoders
# Run on Wazuh Manager

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
echo "  Week 2: Deploy Custom Rules & Decoders"
echo "=========================================="
echo ""

# Check if running on Wazuh Manager
if [ ! -f "/var/ossec/bin/wazuh-control" ]; then
    error "This script must run on Wazuh Manager"
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Backup existing files
log "Backing up existing rules and decoders..."
sudo cp /var/ossec/etc/rules/local_rules.xml /var/ossec/etc/rules/local_rules.xml.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
sudo cp /var/ossec/etc/decoders/local_decoder.xml /var/ossec/etc/decoders/local_decoder.xml.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# Copy custom rules
log "Deploying custom rules..."
if [ -f "$PROJECT_ROOT/rules/custom_brute_force_rules.xml" ]; then
    sudo cp "$PROJECT_ROOT/rules/custom_brute_force_rules.xml" /var/ossec/etc/rules/
    log "✓ Brute force rules deployed"
fi

if [ -f "$PROJECT_ROOT/rules/custom_fim_rules.xml" ]; then
    sudo cp "$PROJECT_ROOT/rules/custom_fim_rules.xml" /var/ossec/etc/rules/
    log "✓ FIM rules deployed"
fi

# Copy custom decoders
log "Deploying custom decoders..."
if [ -f "$PROJECT_ROOT/decoders/custom_decoders.xml" ]; then
    sudo cp "$PROJECT_ROOT/decoders/custom_decoders.xml" /var/ossec/etc/decoders/
    log "✓ Custom decoders deployed"
fi

# Update ossec.conf to include custom rules
log "Updating Wazuh configuration..."

# Check if custom rules are already included
if ! grep -q "custom_brute_force_rules.xml" /var/ossec/etc/ossec.conf; then
    sudo sed -i '/<ruleset>/a\    <include>custom_brute_force_rules.xml</include>' /var/ossec/etc/ossec.conf
    log "✓ Brute force rules included in config"
fi

if ! grep -q "custom_fim_rules.xml" /var/ossec/etc/ossec.conf; then
    sudo sed -i '/<ruleset>/a\    <include>custom_fim_rules.xml</include>' /var/ossec/etc/ossec.conf
    log "✓ FIM rules included in config"
fi

# Test rules syntax
log "Testing rules syntax..."
if sudo /var/ossec/bin/wazuh-logtest -t 2>&1 | grep -q "ERROR"; then
    error "Rules syntax test failed. Check configuration."
else
    log "✓ Rules syntax valid"
fi

# Restart Wazuh Manager
log "Restarting Wazuh Manager..."
sudo systemctl restart wazuh-manager

# Wait for manager to start
sleep 10

# Verify manager is running
if systemctl is-active --quiet wazuh-manager; then
    log "✓ Wazuh Manager restarted successfully"
else
    error "Wazuh Manager failed to start. Check logs: tail -f /var/ossec/logs/ossec.log"
fi

# Verify rules loaded
log "Verifying custom rules loaded..."
RULE_COUNT=$(sudo grep -r "rule id=\"100" /var/ossec/etc/rules/ | wc -l)

if [ "$RULE_COUNT" -gt 0 ]; then
    log "✓ Found $RULE_COUNT custom rules"
else
    error "No custom rules found"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo "=========================================="
echo ""
echo "Deployed Rules:"
echo "  - 100101: SSH Brute Force (5 attempts in 5 min)"
echo "  - 100102: Successful login after brute force"
echo "  - 100103: Password spray attack"
echo "  - 100201: Critical system file modified"
echo "  - 100202: Windows System32 modified"
echo "  - 100203: Web shell detection"
echo "  - 100301: SQL Injection attempt"
echo "  - 100302: Directory traversal"
echo ""
echo "Test Commands:"
echo "  # Test SSH brute force"
echo "  for i in {1..6}; do ssh wronguser@localhost; sleep 2; done"
echo ""
echo "  # Test FIM"
echo "  echo 'test' | sudo tee -a /etc/test_file.txt"
echo ""
echo "View alerts:"
echo "  sudo tail -f /var/ossec/logs/alerts/alerts.log"
echo ""
echo "=========================================="
