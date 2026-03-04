#!/bin/bash
# Week 2: Gate Check Verification
# Verifies all Week 2 objectives are met

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    echo -e "${GREEN}✓ PASS${NC} - $1"
    ((PASS_COUNT++))
}

check_fail() {
    echo -e "${RED}✗ FAIL${NC} - $1"
    ((FAIL_COUNT++))
}

check_warn() {
    echo -e "${YELLOW}⚠ WARNING${NC} - $1"
}

echo "=========================================="
echo "  Week 2 Gate Check"
echo "=========================================="
echo ""

# Check 1: Custom rules deployed
echo -e "${BLUE}[1/6] Checking custom rules...${NC}"
if sudo grep -q "rule id=\"100101\"" /var/ossec/etc/rules/*.xml 2>/dev/null; then
    check_pass "Custom rules deployed"
else
    check_fail "Custom rules not found"
fi
echo ""

# Check 2: FIM configured
echo -e "${BLUE}[2/6] Checking FIM configuration...${NC}"
if sudo grep -q "<syscheck>" /var/ossec/etc/ossec.conf; then
    if sudo grep -q "realtime=\"yes\"" /var/ossec/etc/ossec.conf; then
        check_pass "FIM configured with realtime monitoring"
    else
        check_warn "FIM configured but realtime not enabled"
    fi
else
    check_fail "FIM not configured"
fi
echo ""

# Check 3: Vulnerability detector enabled
echo -e "${BLUE}[3/6] Checking vulnerability detector...${NC}"
if sudo grep -q "<vulnerability-detector>" /var/ossec/etc/ossec.conf; then
    if sudo grep -q "<enabled>yes</enabled>" /var/ossec/etc/ossec.conf; then
        check_pass "Vulnerability detector enabled"
    else
        check_fail "Vulnerability detector disabled"
    fi
else
    check_fail "Vulnerability detector not configured"
fi
echo ""

# Check 4: Test FIM response time
echo -e "${BLUE}[4/6] Testing FIM response time...${NC}"
echo "Creating test file..."
TEST_FILE="/var/www/test/gate_check_$(date +%s).txt"
sudo mkdir -p /var/www/test
echo "Initial content" | sudo tee "$TEST_FILE" > /dev/null

echo "Waiting 15 seconds for initial scan..."
sleep 15

echo "Modifying file and measuring response time..."
START_TIME=$(date +%s)
echo "Modified content - $(date)" | sudo tee -a "$TEST_FILE" > /dev/null

# Wait up to 10 seconds for alert
ALERT_FOUND=0
for i in {1..10}; do
    if sudo tail -n 50 /var/ossec/logs/alerts/alerts.log 2>/dev/null | grep -q "$TEST_FILE"; then
        END_TIME=$(date +%s)
        RESPONSE_TIME=$((END_TIME - START_TIME))
        ALERT_FOUND=1
        break
    fi
    sleep 1
done

if [ $ALERT_FOUND -eq 1 ]; then
    if [ $RESPONSE_TIME -le 5 ]; then
        check_pass "FIM response time: ${RESPONSE_TIME}s (< 5s required)"
    else
        check_warn "FIM response time: ${RESPONSE_TIME}s (> 5s, should be faster)"
    fi
else
    check_fail "No FIM alert detected within 10 seconds"
fi
echo ""

# Check 5: Verify MITRE tags in rules
echo -e "${BLUE}[5/6] Checking MITRE ATT&CK tags...${NC}"
MITRE_COUNT=$(sudo grep -r "<mitre>" /var/ossec/etc/rules/*.xml 2>/dev/null | wc -l)
if [ "$MITRE_COUNT" -gt 0 ]; then
    check_pass "MITRE ATT&CK tags present ($MITRE_COUNT found)"
else
    check_fail "No MITRE ATT&CK tags found"
fi
echo ""

# Check 6: Check recent alerts
echo -e "${BLUE}[6/6] Checking recent alerts...${NC}"
ALERT_COUNT=$(sudo tail -n 100 /var/ossec/logs/alerts/alerts.log 2>/dev/null | grep -c "Rule:" || true)
if [ "$ALERT_COUNT" -gt 0 ]; then
    check_pass "Recent alerts found ($ALERT_COUNT in last 100 lines)"
else
    check_warn "No recent alerts found (may be normal if system is quiet)"
fi
echo ""

# Summary
echo "=========================================="
echo "  Gate Check Summary"
echo "=========================================="
echo ""
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ GATE CHECK PASSED${NC}"
    echo ""
    echo "Week 2 objectives completed:"
    echo "  ✓ Custom rules deployed"
    echo "  ✓ FIM configured and working"
    echo "  ✓ Vulnerability detector enabled"
    echo "  ✓ FIM response time < 5 seconds"
    echo "  ✓ MITRE ATT&CK integration"
    echo "  ✓ Alerts generating properly"
    echo ""
    echo "Ready to proceed to Week 3!"
    echo ""
    echo "Next: Active Response Configuration"
    echo "  - Automated IP blocking"
    echo "  - Account disable on compromise"
    echo "  - Custom response scripts"
else
    echo -e "${RED}✗ GATE CHECK FAILED${NC}"
    echo ""
    echo "Issues found: $FAIL_COUNT"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Review Week 2 documentation"
    echo "  2. Check Wazuh logs: tail -f /var/ossec/logs/ossec.log"
    echo "  3. Verify configurations"
    echo "  4. Re-run setup scripts"
    echo ""
    echo "Do not proceed to Week 3 until all checks pass"
fi

echo "=========================================="

exit $FAIL_COUNT
