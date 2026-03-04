#!/bin/bash
# Week 2: Test Detection Rules
# Generates test events to verify rules are working

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

test_header() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "  $1"
    echo -e "==========================================${NC}"
    echo ""
}

echo "=========================================="
echo "  Week 2: Detection Rules Testing"
echo "=========================================="
echo ""
echo "This script will generate test events to verify:"
echo "  1. File Integrity Monitoring (FIM)"
echo "  2. SSH Brute Force Detection"
echo "  3. Web Attack Detection (if web server available)"
echo ""
read -p "Press Enter to continue..."

# Test 1: File Integrity Monitoring
test_header "Test 1: File Integrity Monitoring"

log "Creating test file..."
sudo mkdir -p /var/www/test
echo "Original content - $(date)" | sudo tee /var/www/test/detection_test.txt

log "Waiting 10 seconds for initial scan..."
sleep 10

log "Modifying file (should trigger FIM alert)..."
echo "Modified content - $(date)" | sudo tee -a /var/www/test/detection_test.txt

log "✓ FIM test complete"
echo "Expected: Rule 550 (File modified) within 5 seconds"
echo "Check: Dashboard → Security Events → Filter: rule.id:550"

sleep 5

# Test 2: SSH Brute Force
test_header "Test 2: SSH Brute Force Detection"

log "Generating 6 failed SSH login attempts..."
for i in {1..6}; do
    echo "Attempt $i/6..."
    ssh -o ConnectTimeout=2 wronguser@localhost 2>/dev/null || true
    sleep 2
done

log "✓ Brute force test complete"
echo "Expected: Rule 100101 (SSH brute force) after 5 attempts"
echo "Check: Dashboard → Security Events → Filter: rule.id:100101"

sleep 5

# Test 3: Critical File Modification
test_header "Test 3: Critical System File Alert"

log "Creating test file in /etc..."
echo "test content" | sudo tee /etc/sentient_shield_test.conf

log "Waiting 10 seconds..."
sleep 10

log "Modifying critical file..."
echo "modified" | sudo tee -a /etc/sentient_shield_test.conf

log "✓ Critical file test complete"
echo "Expected: Rule 100201 (Critical system file modified)"
echo "Check: Dashboard → Security Events → Filter: rule.id:100201"

sleep 5

# Test 4: Multiple File Modifications (Ransomware Simulation)
test_header "Test 4: Ransomware Pattern Detection"

log "Creating multiple test files..."
for i in {1..15}; do
    echo "File $i" | sudo tee /var/www/test/ransomware_test_$i.txt > /dev/null
done

log "Waiting 10 seconds for initial scan..."
sleep 10

log "Modifying multiple files rapidly (simulating ransomware)..."
for i in {1..15}; do
    echo "Encrypted" | sudo tee -a /var/www/test/ransomware_test_$i.txt > /dev/null
done

log "✓ Ransomware pattern test complete"
echo "Expected: Rule 100205 (Multiple files modified - Ransomware)"
echo "Check: Dashboard → Security Events → Filter: rule.id:100205"

sleep 5

# Test 5: Web Attack (if curl available)
if command -v curl &> /dev/null; then
    test_header "Test 5: Web Attack Detection"
    
    # Check if web server is running
    if systemctl is-active --quiet apache2 || systemctl is-active --quiet nginx; then
        log "Testing SQL injection pattern..."
        curl -s "http://localhost/index.php?id=1' OR '1'='1" > /dev/null 2>&1 || true
        
        log "Testing directory traversal..."
        curl -s "http://localhost/../../etc/passwd" > /dev/null 2>&1 || true
        
        log "Generating multiple 404 errors (scanning simulation)..."
        for i in {1..12}; do
            curl -s "http://localhost/nonexistent_$i.php" > /dev/null 2>&1 || true
        done
        
        log "✓ Web attack tests complete"
        echo "Expected: Rules 100301, 100302, 100303"
        echo "Check: Dashboard → Security Events → Filter: rule.id:(100301 OR 100302 OR 100303)"
    else
        echo -e "${YELLOW}Web server not running, skipping web attack tests${NC}"
    fi
else
    echo -e "${YELLOW}curl not available, skipping web attack tests${NC}"
fi

# Summary
echo ""
echo "=========================================="
echo -e "${GREEN}✓ All Tests Complete!${NC}"
echo "=========================================="
echo ""
echo "Tests Performed:"
echo "  ✓ File Integrity Monitoring"
echo "  ✓ SSH Brute Force Detection"
echo "  ✓ Critical File Modification"
echo "  ✓ Ransomware Pattern Detection"
if command -v curl &> /dev/null && (systemctl is-active --quiet apache2 || systemctl is-active --quiet nginx); then
    echo "  ✓ Web Attack Detection"
fi
echo ""
echo "Verification Steps:"
echo "  1. Open Wazuh Dashboard"
echo "  2. Go to Security Events"
echo "  3. Check for the following rule IDs:"
echo "     - 550: File modified"
echo "     - 100101: SSH brute force"
echo "     - 100201: Critical file modified"
echo "     - 100205: Ransomware pattern"
echo "     - 100301-100303: Web attacks"
echo ""
echo "View Alerts:"
echo "  sudo tail -f /var/ossec/logs/alerts/alerts.log"
echo ""
echo "Gate Check:"
echo "  All alerts should appear within 5 seconds of event"
echo "  MITRE ATT&CK tags should be present"
echo "  Alert severity levels should be correct"
echo ""
echo "=========================================="
