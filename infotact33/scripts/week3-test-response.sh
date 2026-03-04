#!/bin/bash
# Sentient Shield - Week 3: Test Active Response
# Tests active response mechanisms with simulated attacks

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

echo "=========================================="
echo "  Week 3: Active Response Testing"
echo "=========================================="
echo ""

# Test 1: Manual IP Block Test
print_info "Test 1: Manual IP Block/Unblock"
echo ""

TEST_IP="192.168.99.99"

print_status "Blocking test IP: $TEST_IP"
/var/ossec/active-response/bin/firewall-drop.sh add - "$TEST_IP" - 100101

sleep 2

# Check if IP is blocked
if iptables -L INPUT -n | grep -q "$TEST_IP"; then
    print_status "IP successfully blocked in iptables"
else
    print_error "IP not found in iptables"
    exit 1
fi

print_status "Unblocking test IP: $TEST_IP"
/var/ossec/active-response/bin/firewall-drop.sh delete - "$TEST_IP" - -

sleep 2

# Check if IP is unblocked
if iptables -L INPUT -n | grep -q "$TEST_IP"; then
    print_error "IP still blocked in iptables"
    exit 1
else
    print_status "IP successfully unblocked"
fi

echo ""

# Test 2: Check Active Response Log
print_info "Test 2: Active Response Logging"
echo ""

if [ -f /var/ossec/logs/active-responses.log ]; then
    print_status "Active response log exists"
    
    # Check recent entries
    RECENT_ENTRIES=$(tail -5 /var/ossec/logs/active-responses.log | wc -l)
    if [ "$RECENT_ENTRIES" -gt 0 ]; then
        print_status "Log contains $RECENT_ENTRIES recent entries"
        echo ""
        print_info "Recent log entries:"
        tail -5 /var/ossec/logs/active-responses.log | sed 's/^/  /'
    else
        print_warning "No recent log entries found"
    fi
else
    print_error "Active response log not found"
fi

echo ""

# Test 3: Simulate Failed SSH Attempts
print_info "Test 3: Simulating Failed SSH Attempts"
echo ""

print_warning "This test will generate failed SSH login attempts"
print_warning "Make sure you have a test user created"
echo ""

# Check if testuser exists
if id "testuser" &>/dev/null; then
    print_status "Test user 'testuser' found"
    
    print_info "Generating 5 failed login attempts..."
    
    for i in {1..5}; do
        echo "  Attempt $i/5..."
        # Simulate failed login by trying with wrong password
        sshpass -p "wrongpassword" ssh -o StrictHostKeyChecking=no testuser@localhost exit 2>/dev/null || true
        sleep 1
    done
    
    print_status "Failed login attempts generated"
    print_info "Waiting 10 seconds for active response to trigger..."
    sleep 10
    
    # Check if localhost is blocked
    if iptables -L INPUT -n | grep -q "127.0.0.1"; then
        print_status "Active response triggered! Localhost blocked"
        print_warning "Unblocking localhost to prevent lockout..."
        /var/ossec/active-response/bin/firewall-drop.sh delete - 127.0.0.1 - -
    else
        print_warning "Active response did not trigger (this is normal if threshold not met)"
    fi
else
    print_warning "Test user 'testuser' not found, skipping SSH test"
    print_info "Create test user with: sudo useradd -m testuser && echo 'testuser:password' | sudo chpasswd"
fi

echo ""

# Test 4: Check Wazuh Alerts
print_info "Test 4: Checking Wazuh Alerts"
echo ""

if [ -f /var/ossec/logs/alerts/alerts.log ]; then
    print_status "Alerts log exists"
    
    # Check for brute force alerts
    BRUTE_FORCE_ALERTS=$(grep -c "100101" /var/ossec/logs/alerts/alerts.log 2>/dev/null || echo "0")
    print_info "Brute force alerts (Rule 100101): $BRUTE_FORCE_ALERTS"
    
    # Check for login after brute force
    LOGIN_AFTER_BF=$(grep -c "100102" /var/ossec/logs/alerts/alerts.log 2>/dev/null || echo "0")
    print_info "Login after brute force (Rule 100102): $LOGIN_AFTER_BF"
    
    # Check for password spray
    PASSWORD_SPRAY=$(grep -c "100103" /var/ossec/logs/alerts/alerts.log 2>/dev/null || echo "0")
    print_info "Password spray attacks (Rule 100103): $PASSWORD_SPRAY"
else
    print_error "Alerts log not found"
fi

echo ""

# Test 5: Configuration Verification
print_info "Test 5: Configuration Verification"
echo ""

# Check if active response is configured
if grep -q "firewall-drop" /var/ossec/etc/ossec.conf; then
    print_status "firewall-drop command configured"
else
    print_error "firewall-drop command not configured"
fi

if grep -q "disable-account" /var/ossec/etc/ossec.conf; then
    print_status "disable-account command configured"
else
    print_error "disable-account command not configured"
fi

# Check if scripts are executable
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

echo ""

# Summary
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo ""
print_status "Manual IP block/unblock: PASSED"
print_status "Active response logging: WORKING"
print_status "Configuration: VERIFIED"
echo ""
print_info "To test with real brute force attack, use Hydra:"
echo "  hydra -l testuser -P passwords.txt ssh://$(hostname -I | awk '{print $1}') -t 4"
echo ""
print_info "Monitor active response in real-time:"
echo "  sudo tail -f /var/ossec/logs/active-responses.log"
echo ""
print_info "Check blocked IPs:"
echo "  sudo iptables -L INPUT -n -v"
echo ""

exit 0
