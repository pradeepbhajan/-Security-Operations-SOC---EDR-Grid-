#!/bin/bash
# Sentient Shield - Week 3: Gate Check
# Validates that all Week 3 requirements are met

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

print_pass() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((PASS_COUNT++))
}

print_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    ((FAIL_COUNT++))
}

print_warn() {
    echo -e "${YELLOW}[! WARN]${NC} $1"
    ((WARN_COUNT++))
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

echo "=========================================="
echo "  Week 3: Active Response Gate Check"
echo "=========================================="
echo ""
echo "Validating Week 3 implementation..."
echo ""

# Check 1: Active Response Configuration
print_info "Check 1: Active Response Configuration"
if grep -q "firewall-drop" /var/ossec/etc/ossec.conf && \
   grep -q "disable-account" /var/ossec/etc/ossec.conf; then
    print_pass "Active response commands configured in ossec.conf"
else
    print_fail "Active response commands not found in ossec.conf"
fi

if grep -q "<active-response>" /var/ossec/etc/ossec.conf; then
    RESPONSE_COUNT=$(grep -c "<active-response>" /var/ossec/etc/ossec.conf)
    print_pass "Active response rules configured ($RESPONSE_COUNT rules)"
else
    print_fail "No active response rules configured"
fi
echo ""

# Check 2: Response Scripts Deployment
print_info "Check 2: Response Scripts Deployment"
if [ -f /var/ossec/active-response/bin/firewall-drop.sh ]; then
    print_pass "firewall-drop.sh deployed"
else
    print_fail "firewall-drop.sh not found"
fi

if [ -f /var/ossec/active-response/bin/disable-account.sh ]; then
    print_pass "disable-account.sh deployed"
else
    print_fail "disable-account.sh not found"
fi
echo ""

# Check 3: Script Permissions
print_info "Check 3: Script Permissions"
if [ -x /var/ossec/active-response/bin/firewall-drop.sh ]; then
    print_pass "firewall-drop.sh is executable"
else
    print_fail "firewall-drop.sh is not executable"
fi

if [ -x /var/ossec/active-response/bin/disable-account.sh ]; then
    print_pass "disable-account.sh is executable"
else
    print_fail "disable-account.sh is not executable"
fi

# Check ownership
FIREWALL_OWNER=$(stat -c '%U:%G' /var/ossec/active-response/bin/firewall-drop.sh 2>/dev/null || echo "unknown")
if [ "$FIREWALL_OWNER" = "root:wazuh" ]; then
    print_pass "firewall-drop.sh has correct ownership (root:wazuh)"
else
    print_warn "firewall-drop.sh ownership is $FIREWALL_OWNER (expected root:wazuh)"
fi
echo ""

# Check 4: Wazuh Services
print_info "Check 4: Wazuh Services Status"
if systemctl is-active --quiet wazuh-manager; then
    print_pass "Wazuh Manager is running"
else
    print_fail "Wazuh Manager is not running"
fi

if systemctl list-units --full -all | grep -q wazuh-agent; then
    if systemctl is-active --quiet wazuh-agent; then
        print_pass "Wazuh Agent is running"
    else
        print_fail "Wazuh Agent is not running"
    fi
else
    print_warn "Wazuh Agent not installed on this system"
fi
echo ""

# Check 5: Active Response Logging
print_info "Check 5: Active Response Logging"
if [ -f /var/ossec/logs/active-responses.log ]; then
    print_pass "Active response log file exists"
    
    LOG_SIZE=$(stat -c%s /var/ossec/logs/active-responses.log)
    if [ "$LOG_SIZE" -gt 0 ]; then
        print_pass "Active response log has entries ($LOG_SIZE bytes)"
        
        # Show recent entries
        RECENT_BLOCKS=$(grep -c "Successfully blocked" /var/ossec/logs/active-responses.log 2>/dev/null || echo "0")
        RECENT_UNBLOCKS=$(grep -c "Successfully unblocked" /var/ossec/logs/active-responses.log 2>/dev/null || echo "0")
        print_info "  - Total blocks: $RECENT_BLOCKS"
        print_info "  - Total unblocks: $RECENT_UNBLOCKS"
    else
        print_warn "Active response log is empty (no responses triggered yet)"
    fi
else
    print_fail "Active response log file not found"
fi
echo ""

# Check 6: iptables Functionality
print_info "Check 6: iptables Functionality"
if command -v iptables &> /dev/null; then
    print_pass "iptables is installed"
    
    # Test iptables access
    if iptables -L INPUT -n &> /dev/null; then
        print_pass "iptables is accessible"
        
        # Check for any active blocks
        BLOCKED_IPS=$(iptables -L INPUT -n | grep -c "DROP" || echo "0")
        if [ "$BLOCKED_IPS" -gt 0 ]; then
            print_pass "Active IP blocks found: $BLOCKED_IPS"
        else
            print_warn "No active IP blocks (this is normal if no attacks detected)"
        fi
    else
        print_fail "Cannot access iptables"
    fi
else
    print_fail "iptables is not installed"
fi
echo ""

# Check 7: Detection Rules (from Week 2)
print_info "Check 7: Detection Rules (Prerequisites)"
BRUTE_FORCE_RULE=$(grep -c "100101" /var/ossec/etc/rules/local_rules.xml 2>/dev/null || echo "0")
if [ "$BRUTE_FORCE_RULE" -gt 0 ]; then
    print_pass "Brute force detection rule (100101) exists"
else
    print_fail "Brute force detection rule (100101) not found"
fi

LOGIN_AFTER_BF=$(grep -c "100102" /var/ossec/etc/rules/local_rules.xml 2>/dev/null || echo "0")
if [ "$LOGIN_AFTER_BF" -gt 0 ]; then
    print_pass "Login after brute force rule (100102) exists"
else
    print_fail "Login after brute force rule (100102) not found"
fi

PASSWORD_SPRAY=$(grep -c "100103" /var/ossec/etc/rules/local_rules.xml 2>/dev/null || echo "0")
if [ "$PASSWORD_SPRAY" -gt 0 ]; then
    print_pass "Password spray rule (100103) exists"
else
    print_fail "Password spray rule (100103) not found"
fi
echo ""

# Check 8: Test User
print_info "Check 8: Test User for Brute Force Testing"
if id "testuser" &>/dev/null; then
    print_pass "Test user 'testuser' exists"
else
    print_warn "Test user 'testuser' not found (create with: sudo useradd -m testuser)"
fi
echo ""

# Check 9: Alert Correlation
print_info "Check 9: Alert and Response Correlation"
if [ -f /var/ossec/logs/alerts/alerts.log ]; then
    TOTAL_ALERTS=$(grep -c "Rule: 100101\|Rule: 100102\|Rule: 100103" /var/ossec/logs/alerts/alerts.log 2>/dev/null || echo "0")
    if [ "$TOTAL_ALERTS" -gt 0 ]; then
        print_pass "Brute force alerts detected: $TOTAL_ALERTS"
    else
        print_warn "No brute force alerts yet (run tests to generate alerts)"
    fi
else
    print_fail "Alerts log not found"
fi
echo ""

# Check 10: Response Time Test
print_info "Check 10: Response Time Test"
print_info "Testing manual IP block response time..."

TEST_IP="192.168.99.99"
START_TIME=$(date +%s%N)

/var/ossec/active-response/bin/firewall-drop.sh add - "$TEST_IP" - 100101 &> /dev/null

END_TIME=$(date +%s%N)
RESPONSE_TIME=$(( (END_TIME - START_TIME) / 1000000 ))

if [ "$RESPONSE_TIME" -lt 10000 ]; then
    print_pass "Response time: ${RESPONSE_TIME}ms (< 10 seconds)"
else
    print_warn "Response time: ${RESPONSE_TIME}ms (> 10 seconds)"
fi

# Cleanup test
/var/ossec/active-response/bin/firewall-drop.sh delete - "$TEST_IP" - - &> /dev/null
echo ""

# Final Summary
echo "=========================================="
echo "  Gate Check Summary"
echo "=========================================="
echo ""
echo -e "${GREEN}Passed:${NC} $PASS_COUNT"
echo -e "${RED}Failed:${NC} $FAIL_COUNT"
echo -e "${YELLOW}Warnings:${NC} $WARN_COUNT"
echo ""

# Determine overall status
if [ "$FAIL_COUNT" -eq 0 ]; then
    if [ "$WARN_COUNT" -eq 0 ]; then
        echo -e "${GREEN}✓ GATE CHECK PASSED${NC}"
        echo ""
        echo "All Week 3 requirements met!"
        echo "You are ready to proceed to Week 4: Threat Simulation"
        EXIT_CODE=0
    else
        echo -e "${YELLOW}⚠ GATE CHECK PASSED WITH WARNINGS${NC}"
        echo ""
        echo "Week 3 core requirements met, but some warnings present."
        echo "Review warnings above before proceeding to Week 4."
        EXIT_CODE=0
    fi
else
    echo -e "${RED}✗ GATE CHECK FAILED${NC}"
    echo ""
    echo "Please fix the failed checks before proceeding to Week 4."
    echo "Review the failed items above and re-run this script."
    EXIT_CODE=1
fi

echo ""
echo "Next Steps:"
echo "  1. Review any failed or warning items above"
echo "  2. Test with real brute force attack:"
echo "     hydra -l testuser -P passwords.txt ssh://$(hostname -I | awk '{print $1}') -t 4"
echo "  3. Monitor active response:"
echo "     sudo tail -f /var/ossec/logs/active-responses.log"
echo "  4. Proceed to Week 4 when ready"
echo ""

exit $EXIT_CODE
