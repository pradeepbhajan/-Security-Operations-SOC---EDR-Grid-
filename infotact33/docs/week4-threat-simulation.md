# Week 4: Threat Simulation - Detailed Guide

## Overview
Week 4 focuses on validating your EDR implementation by simulating real-world attacks using the Atomic Red Team framework. You'll test detection capabilities, visualize the kill chain, and generate a comprehensive report.

## Learning Objectives
- Install and configure Atomic Red Team
- Simulate ransomware attacks (T1486)
- Test brute force detection with Hydra
- Visualize kill chain in Kibana/OpenSearch
- Validate detection and response effectiveness
- Generate final assessment report

## Architecture

```
┌─────────────────────────────────────────────────┐
│         Atomic Red Team Framework               │
│  ┌──────────────────────────────────────────┐  │
│  │  T1486: Ransomware                       │  │
│  │  T1110: Brute Force                      │  │
│  │  T1003: Credential Dumping               │  │
│  │  T1055: Process Injection                │  │
│  └──────────────┬───────────────────────────┘  │
└─────────────────┼───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│           Wazuh EDR System                      │
│  ┌──────────────────────────────────────────┐  │
│  │  Detection Engine                        │  │
│  │  - Custom Rules                          │  │
│  │  - MITRE ATT&CK Mapping                  │  │
│  └──────────────┬───────────────────────────┘  │
│                 │                                │
│                 ▼                                │
│  ┌──────────────────────────────────────────┐  │
│  │  Active Response                         │  │
│  │  - IP Blocking                           │  │
│  │  - Account Lockout                       │  │
│  └──────────────┬───────────────────────────┘  │
└─────────────────┼───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│         Kibana/OpenSearch Dashboard             │
│  - Kill Chain Visualization                     │
│  - Alert Timeline                               │
│  - Detection Coverage Matrix                    │
└─────────────────────────────────────────────────┘
```

## Day 1: Atomic Red Team Setup (20 minutes)

### Step 1: Install Atomic Red Team

On Windows (PowerShell as Administrator):

```powershell
# Install Invoke-AtomicRedTeam module
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);
Install-AtomicRedTeam -getAtomics

# Verify installation
Get-Command Invoke-AtomicTest
```

On Linux:

```bash
# Clone Atomic Red Team repository
cd /opt
sudo git clone https://github.com/redcanaryco/atomic-red-team.git

# Install dependencies
sudo apt-get install -y curl jq

# Verify installation
ls -la /opt/atomic-red-team/atomics/
```

### Step 2: Review Available Tests

```bash
# List all available techniques
ls /opt/atomic-red-team/atomics/

# View specific technique
cat /opt/atomic-red-team/atomics/T1486/T1486.yaml
```

### Step 3: Configure Test Environment

```bash
# Create test directory
sudo mkdir -p /tmp/atomic-test-files
sudo chmod 777 /tmp/atomic-test-files

# Create test files for ransomware simulation
for i in {1..10}; do
    echo "Test file $i" > /tmp/atomic-test-files/testfile$i.txt
done
```

## Day 2: Ransomware Simulation (T1486) (20 minutes)

### Step 1: Prepare Ransomware Test

Create ransomware simulation script:

```bash
cat > /tmp/simulate-ransomware.sh << 'EOF'
#!/bin/bash
# Simulates ransomware file encryption behavior

TARGET_DIR="/tmp/atomic-test-files"
EXTENSION=".encrypted"

echo "[*] Starting ransomware simulation..."
echo "[*] Target directory: $TARGET_DIR"

# Simulate file encryption
for file in $TARGET_DIR/*.txt; do
    if [ -f "$file" ]; then
        echo "[*] Encrypting: $file"
        # Simulate encryption by renaming and modifying
        mv "$file" "${file}${EXTENSION}"
        echo "ENCRYPTED" >> "${file}${EXTENSION}"
        sleep 0.5
    fi
done

# Create ransom note
cat > $TARGET_DIR/RANSOM_NOTE.txt << 'RANSOM'
Your files have been encrypted!
To decrypt your files, send 1 BTC to: [address]
This is a SIMULATION for testing purposes only.
RANSOM

echo "[*] Ransomware simulation complete"
echo "[*] Files encrypted: $(ls $TARGET_DIR/*.encrypted 2>/dev/null | wc -l)"
EOF

chmod +x /tmp/simulate-ransomware.sh
```

### Step 2: Execute Ransomware Test

```bash
# Run simulation
sudo /tmp/simulate-ransomware.sh

# Verify files were "encrypted"
ls -la /tmp/atomic-test-files/
```

### Step 3: Verify Detection

```bash
# Check Wazuh alerts for ransomware detection
sudo grep "100205" /var/ossec/logs/alerts/alerts.log | tail -5

# Check FIM alerts
sudo grep "ransomware\|RANSOM_NOTE" /var/ossec/logs/alerts/alerts.log

# View in dashboard
# Navigate to: https://<wazuh-dashboard>:443
# Filter by: rule.id:100205
```

## Day 3: Brute Force Testing (T1110) (15 minutes)

### Step 1: Install Hydra

```bash
# Ubuntu/Debian
sudo apt-get install -y hydra

# CentOS/RHEL
sudo yum install -y hydra
```

### Step 2: Create Password List

```bash
cat > /tmp/passwords.txt << EOF
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
```

### Step 3: Execute Brute Force Attack

```bash
# Get target IP
TARGET_IP=$(hostname -I | awk '{print $1}')

# Launch SSH brute force
hydra -l testuser -P /tmp/passwords.txt ssh://$TARGET_IP -t 4 -V

# Expected: IP should be blocked after 5 attempts
```

### Step 4: Verify Detection and Response

```bash
# Check brute force alerts
sudo grep "100101" /var/ossec/logs/alerts/alerts.log | tail -5

# Verify IP was blocked
sudo iptables -L INPUT -n | grep $TARGET_IP

# Check active response log
sudo grep "Successfully blocked" /var/ossec/logs/active-responses.log | tail -5
```

## Day 4: Kill Chain Visualization (20 minutes)

### Step 1: Access Wazuh Dashboard

```bash
# Get dashboard URL
echo "Dashboard URL: https://$(hostname -I | awk '{print $1}'):443"

# Get credentials
sudo cat /root/wazuh-credentials.txt
```

### Step 2: Create Kill Chain Dashboard

Navigate to Dashboard → Create New Dashboard

Add visualizations:

1. **Attack Timeline**
   - Visualization: Line chart
   - X-axis: @timestamp
   - Y-axis: Count of alerts
   - Filter: rule.mitre.technique

2. **MITRE ATT&CK Heatmap**
   - Visualization: Heat map
   - Rows: rule.mitre.tactic
   - Columns: rule.mitre.technique
   - Metrics: Count

3. **Top Attacked Assets**
   - Visualization: Pie chart
   - Slice by: agent.name
   - Metrics: Count of alerts

4. **Detection Coverage**
   - Visualization: Data table
   - Columns: rule.mitre.id, rule.description, count
   - Sort by: count (descending)

### Step 3: Export Dashboard

```bash
# Export dashboard configuration
# Dashboard → Saved Objects → Export

# Save to project
cp ~/Downloads/dashboard-export.ndjson dashboards/kill-chain-dashboard.json
```

## Day 5: Final Validation & Report (25 minutes)

### Step 1: Run Comprehensive Test Suite

```bash
# Run all Week 4 tests
sudo bash scripts/week4-run-simulations.sh

# This will:
# - Execute ransomware simulation
# - Run brute force test
# - Test credential dumping (if applicable)
# - Validate all detections
```

### Step 2: Generate Detection Report

```bash
# Run report generation script
sudo bash scripts/week4-generate-report.sh

# Report will be saved to: reports/week4-final-report.html
```

### Step 3: Validate Detection Coverage

```bash
# Check detection rate
sudo bash scripts/week4-validate-detection.sh

# Expected output:
# ✓ T1486 (Ransomware): DETECTED
# ✓ T1110 (Brute Force): DETECTED
# ✓ T1078 (Valid Accounts): DETECTED
# ✓ Active Response: WORKING
# 
# Detection Rate: 100%
# False Positive Rate: 0%
```

## Gate Check Criteria

### ✅ Checklist

- [ ] Atomic Red Team installed and configured
- [ ] Ransomware simulation executed successfully
- [ ] Ransomware detected by rule 100205
- [ ] Brute force attack executed with Hydra
- [ ] Brute force detected by rule 100101
- [ ] IP automatically blocked by active response
- [ ] Kill chain visualized in dashboard
- [ ] All MITRE techniques mapped correctly
- [ ] Detection rate > 95%
- [ ] False positive rate < 5%
- [ ] Final report generated

### Verification Commands

```bash
# 1. Check all simulated attacks
sudo grep -E "100101|100102|100103|100205" /var/ossec/logs/alerts/alerts.log | wc -l

# 2. Verify MITRE mapping
sudo grep "mitre" /var/ossec/logs/alerts/alerts.json | jq '.rule.mitre'

# 3. Check active response effectiveness
sudo grep "Successfully blocked" /var/ossec/logs/active-responses.log | wc -l

# 4. View detection coverage
sudo bash scripts/week4-validate-detection.sh

# 5. Generate final report
sudo bash scripts/week4-generate-report.sh
```

### Success Metrics

| Metric | Target | Status |
|--------|--------|--------|
| Detection Rate | > 95% | 📊 |
| False Positive Rate | < 5% | ✅ |
| Response Time | < 10 sec | ⏱️ |
| MITRE Coverage | 5+ techniques | 🎯 |
| Kill Chain Visibility | Complete | 📈 |

## Troubleshooting

### Issue 1: Atomic Red Team Installation Fails

**Solutions**:
```bash
# Linux: Check git installation
sudo apt-get install -y git

# Windows: Run PowerShell as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force

# Verify installation
ls /opt/atomic-red-team/atomics/  # Linux
Get-Command Invoke-AtomicTest     # Windows
```

### Issue 2: Ransomware Not Detected

**Solutions**:
```bash
# Check FIM configuration
sudo grep -A 10 "syscheck" /var/ossec/etc/ossec.conf

# Verify rule exists
sudo grep "100205" /var/ossec/etc/rules/local_rules.xml

# Check if directory is monitored
sudo grep "/tmp/atomic-test-files" /var/ossec/etc/ossec.conf

# Restart agent
sudo systemctl restart wazuh-agent
```

### Issue 3: Dashboard Not Showing Data

**Solutions**:
```bash
# Check Elasticsearch/OpenSearch
curl -k -u admin:admin https://localhost:9200/_cluster/health

# Verify index exists
curl -k -u admin:admin https://localhost:9200/_cat/indices | grep wazuh

# Refresh dashboard
# Dashboard → Management → Index Patterns → Refresh

# Check time range
# Dashboard → Time filter → Last 24 hours
```

### Issue 4: Low Detection Rate

**Solutions**:
```bash
# Verify all rules are active
sudo grep -c "rule id" /var/ossec/etc/rules/local_rules.xml

# Check rule levels
sudo grep "level" /var/ossec/etc/rules/local_rules.xml

# Increase log verbosity
# Edit /var/ossec/etc/ossec.conf
# <logging><log_alert_level>1</log_alert_level></logging>

# Restart manager
sudo systemctl restart wazuh-manager
```

## MITRE ATT&CK Coverage

| Tactic | Technique | ID | Rule | Status |
|--------|-----------|-----|------|--------|
| Credential Access | Brute Force | T1110.001 | 100101 | ✅ |
| Credential Access | Password Spraying | T1110.003 | 100103 | ✅ |
| Defense Evasion | Valid Accounts | T1078 | 100102 | ✅ |
| Impact | Data Encrypted for Impact | T1486 | 100205 | ✅ |
| Persistence | Boot or Logon Autostart | T1547 | 100206 | ✅ |

## Best Practices

### 1. Safe Testing
- Always test in isolated environment
- Use dedicated test accounts
- Document all test activities
- Clean up after tests

### 2. Detection Tuning
- Review false positives
- Adjust rule thresholds
- Update MITRE mappings
- Document exceptions

### 3. Reporting
- Generate reports regularly
- Track detection trends
- Document improvements
- Share with stakeholders

### 4. Continuous Improvement
- Add new techniques quarterly
- Update Atomic Red Team
- Review MITRE ATT&CK updates
- Train SOC team

## Final Report Template

The final report should include:

1. **Executive Summary**
   - Project overview
   - Key achievements
   - Detection coverage

2. **Technical Details**
   - Infrastructure deployed
   - Rules implemented
   - Active response configured

3. **Test Results**
   - Simulated attacks
   - Detection rate
   - Response effectiveness

4. **MITRE ATT&CK Coverage**
   - Techniques covered
   - Detection gaps
   - Recommendations

5. **Metrics & KPIs**
   - Alert volume
   - Response time
   - False positive rate

6. **Next Steps**
   - Production deployment
   - Additional techniques
   - Training requirements

## Next Steps

After completing Week 4:

1. ✅ Review final report
2. 📊 Analyze detection coverage
3. 🎯 Plan production deployment
4. 📚 Document lessons learned
5. 🎓 Train SOC team

## Additional Resources

- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)
- [MITRE ATT&CK](https://attack.mitre.org/)
- [Wazuh Threat Hunting](https://documentation.wazuh.com/current/user-manual/capabilities/threat-hunting.html)
- [Kill Chain Analysis](https://www.lockheedmartin.com/en-us/capabilities/cyber/cyber-kill-chain.html)

---

**Week 4 Complete!** 🎉

You now have a fully validated EDR system with proven detection and response capabilities!

**Project Complete!** 🏆

Congratulations on completing the Sentient Shield EDR implementation!

