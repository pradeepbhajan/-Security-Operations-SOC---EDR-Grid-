#!/bin/bash
# Sentient Shield - Week 3: Active Response Configuration Script
# Automates the setup of active response mechanisms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="/var/log/sentient-shield-week3-setup.log"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

print_status "Starting Week 3: Active Response Configuration"
echo "$(date)" >> "$LOG_FILE"

# Step 1: Backup current configuration
print_status "Backing up current ossec.conf..."
cp /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.backup.week3.$(date +%Y%m%d_%H%M%S)

# Step 2: Check if active response scripts exist
print_status "Checking active response scripts..."
if [ ! -f "active-response/firewall-drop.sh" ]; then
    print_error "firewall-drop.sh not found in active-response/"
    exit 1
fi

if [ ! -f "active-response/disable-account.sh" ]; then
    print_error "disable-account.sh not found in active-response/"
    exit 1
fi

# Step 3: Deploy scripts to Wazuh directory
print_status "Deploying active response scripts..."
cp active-response/firewall-drop.sh /var/ossec/active-response/bin/
cp active-response/disable-account.sh /var/ossec/active-response/bin/

# Set correct permissions
chmod 750 /var/ossec/active-response/bin/firewall-drop.sh
chmod 750 /var/ossec/active-response/bin/disable-account.sh
chown root:wazuh /var/ossec/active-response/bin/firewall-drop.sh
chown root:wazuh /var/ossec/active-response/bin/disable-account.sh

print_status "Scripts deployed with correct permissions"

# Step 4: Add active response configuration to ossec.conf
print_status "Configuring active response in ossec.conf..."

# Check if active response already configured
if grep -q "<!-- Sentient Shield Active Response -->" /var/ossec/etc/ossec.conf; then
    print_warning "Active response already configured, skipping..."
else
    # Add configuration before </ossec_config>
    sed -i '/<\/ossec_config>/i \
  <!-- Sentient Shield Active Response -->\
  <command>\
    <name>firewall-drop</name>\
    <executable>firewall-drop.sh</executable>\
    <timeout_allowed>yes</timeout_allowed>\
  </command>\
\
  <command>\
    <name>disable-account</name>\
    <executable>disable-account.sh</executable>\
    <timeout_allowed>yes</timeout_allowed>\
  </command>\
\
  <!-- Response for SSH Brute Force (Rule 100101) -->\
  <active-response>\
    <command>firewall-drop</command>\
    <location>local</location>\
    <rules_id>100101</rules_id>\
    <timeout>3600</timeout>\
  </active-response>\
\
  <!-- Response for Login After Brute Force (Rule 100102) -->\
  <active-response>\
    <command>disable-account</command>\
    <location>local</location>\
    <rules_id>100102</rules_id>\
    <timeout>7200</timeout>\
  </active-response>\
\
  <!-- Response for Password Spray Attack (Rule 100103) -->\
  <active-response>\
    <command>firewall-drop</command>\
    <location>local</location>\
    <rules_id>100103</rules_id>\
    <timeout>3600</timeout>\
  </active-response>\
' /var/ossec/etc/ossec.conf

    print_status "Active response configuration added"
fi

# Step 5: Create active response log directory
print_status "Setting up logging..."
touch /var/ossec/logs/active-responses.log
chown wazuh:wazuh /var/ossec/logs/active-responses.log
chmod 660 /var/ossec/logs/active-responses.log

# Step 6: Restart Wazuh Manager
print_status "Restarting Wazuh Manager..."
systemctl restart wazuh-manager

# Wait for service to start
sleep 5

# Verify service is running
if systemctl is-active --quiet wazuh-manager; then
    print_status "Wazuh Manager restarted successfully"
else
    print_error "Wazuh Manager failed to start"
    print_warning "Check logs: sudo tail -f /var/ossec/logs/ossec.log"
    exit 1
fi

# Step 7: Restart Wazuh Agent (if running on same machine)
if systemctl list-units --full -all | grep -q wazuh-agent; then
    print_status "Restarting Wazuh Agent..."
    systemctl restart wazuh-agent
    sleep 3
    
    if systemctl is-active --quiet wazuh-agent; then
        print_status "Wazuh Agent restarted successfully"
    else
        print_warning "Wazuh Agent failed to restart"
    fi
fi

# Step 8: Verification
print_status "Verifying configuration..."

# Check if commands are defined
if grep -q "firewall-drop" /var/ossec/etc/ossec.conf; then
    print_status "firewall-drop command configured"
else
    print_error "firewall-drop command not found in configuration"
fi

if grep -q "disable-account" /var/ossec/etc/ossec.conf; then
    print_status "disable-account command configured"
else
    print_error "disable-account command not found in configuration"
fi

# Check if scripts exist and are executable
if [ -x /var/ossec/active-response/bin/firewall-drop.sh ]; then
    print_status "firewall-drop.sh is executable"
else
    print_error "firewall-drop.sh is not executable"
fi

if [ -x /var/ossec/active-response/bin/disable-account.sh ]; then
    print_status "disable-account.sh is executable"
else
    print_error "disable-account.sh is not executable"
fi

# Step 9: Create test user for brute force testing
print_status "Creating test user for brute force testing..."
if id "testuser" &>/dev/null; then
    print_warning "testuser already exists"
else
    useradd -m testuser
    echo "testuser:ComplexPassword123!" | chpasswd
    print_status "Test user 'testuser' created with password 'ComplexPassword123!'"
fi

# Step 10: Display summary
echo ""
echo "=========================================="
echo "  Week 3 Configuration Complete!"
echo "=========================================="
echo ""
print_status "Active Response Status:"
echo "  - firewall-drop: Configured for rules 100101, 100103"
echo "  - disable-account: Configured for rule 100102"
echo "  - Timeout: 3600 seconds (1 hour) for IP blocks"
echo "  - Timeout: 7200 seconds (2 hours) for account locks"
echo ""
print_status "Test User Created:"
echo "  - Username: testuser"
echo "  - Password: ComplexPassword123!"
echo ""
print_status "Next Steps:"
echo "  1. Test with brute force attack:"
echo "     hydra -l testuser -P passwords.txt ssh://$(hostname -I | awk '{print $1}') -t 4"
echo ""
echo "  2. Monitor active response:"
echo "     sudo tail -f /var/ossec/logs/active-responses.log"
echo ""
echo "  3. Check blocked IPs:"
echo "     sudo iptables -L INPUT -n"
echo ""
echo "  4. Run gate check:"
echo "     sudo bash scripts/week3-gate-check.sh"
echo ""
print_status "Configuration log saved to: $LOG_FILE"
echo ""

exit 0
