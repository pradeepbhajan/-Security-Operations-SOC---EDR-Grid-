# Week 2 Quick Start Guide

## 🚀 Fast Track Setup (45 Minutes)

### Prerequisites
- ✅ Week 1 completed (all agents active)
- ✅ SSH access to Wazuh Manager
- ✅ SSH access to Linux agents

## Step-by-Step Execution

### Step 1: Deploy Custom Rules & Decoders (5 minutes)

**On Wazuh Manager:**
```bash
cd /path/to/sentient-shield
sudo bash scripts/week2-deploy-custom-rules.sh
```

This deploys:
- SSH brute force detection rules
- FIM detection rules
- Web attack detection rules
- Custom decoders for log parsing

### Step 2: Configure FIM on Linux Agents (10 minutes)

**On each Linux agent:**
```bash
cd /path/to/sentient-shield
sudo bash scripts/week2-configure-fim.sh
```

This configures monitoring for:
- `/etc` (critical system files)
- `/usr/bin`, `/usr/sbin` (binaries)
- `/var/www` (web applications)
- `/etc/ssh` (SSH configuration)
- Cron jobs and scheduled tasks

### Step 3: Configure FIM on Windows Agents (10 minutes)

**On Windows Server (PowerShell as Administrator):**
```powershell
# Edit Wazuh config
notepad "C:\Program Files (x86)\ossec-agent\ossec.conf"
```

**Add this configuration:**
```xml
<syscheck>
  <disabled>no</disabled>
  <frequency>300</frequency>
  <scan_on_start>yes</scan_on_start>
  
  <directories check_all="yes" realtime="yes">C:\Windows\System32</directories>
  <directories check_all="yes">C:\Program Files</directories>
  
  <windows_registry check_all="yes" realtime="yes">HKEY_LOCAL_MACHINE\Software</windows_registry>
  <windows_registry check_all="yes" realtime="yes">HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services</windows_registry>
  
  <alert_new_files>yes</alert_new_files>
</syscheck>
```

**Restart agent:**
```powershell
Restart-Service WazuhSvc
```

### Step 4: Enable Vulnerability Detector (5 minutes)

**On Wazuh Manager:**
```bash
sudo bash scripts/week2-enable-vulnerability-detector.sh
```

Wait 5-10 minutes for first scan to complete.

### Step 5: Test Detection Rules (10 minutes)

**On Linux agent:**
```bash
sudo bash scripts/week2-test-detection.sh
```

This generates test events for:
- File modifications
- SSH brute force attempts
- Critical file changes
- Ransomware patterns
- Web attacks (if web server available)

### Step 6: Verify in Dashboard (5 minutes)

1. Open Wazuh Dashboard: `https://your-manager-ip`
2. Go to **Security Events**
3. Look for these rule IDs:
   - **550**: File modified
   - **100101**: SSH brute force detected
   - **100201**: Critical system file modified
   - **100205**: Ransomware pattern
   - **100301-100303**: Web attacks

4. Check **Vulnerabilities** section for CVE detections

## 🎯 Gate Check (5 minutes)

### Manual FIM Test

**Linux:**
```bash
echo "Gate check test - $(date)" | sudo tee -a /var/www/test/gate_check.txt
```

**Windows:**
```powershell
Add-Content -Path "C:\Windows\System32\gate_check.txt" -Value "Test - $(Get-Date)"
```

**Verify:**
- Alert appears in dashboard within **5 seconds**
- Rule 550 or 100201/100202 triggered
- File path visible in alert
- MITRE ATT&CK tags present

### Expected Results

✅ **FIM Alerts**: < 5 seconds response time  
✅ **Brute Force Detection**: After 5 failed attempts  
✅ **Vulnerability Scan**: CVEs detected and displayed  
✅ **MITRE Mapping**: Technique IDs visible in alerts  
✅ **Alert Severity**: Correct levels (7-14)

## 🔧 Quick Troubleshooting

### FIM Not Working
```bash
# Force syscheck scan
sudo /var/ossec/bin/agent_control -r -u 001

# Check agent logs
sudo tail -f /var/ossec/logs/ossec.log | grep syscheck
```

### Rules Not Triggering
```bash
# Test rule with sample log
echo 'Failed password for admin from 192.168.1.100 port 22' | sudo /var/ossec/bin/wazuh-logtest

# Check if rules loaded
sudo grep "rule id=\"100101\"" /var/ossec/etc/rules/*.xml
```

### Vulnerability Detector Not Running
```bash
# Check logs
sudo tail -f /var/ossec/logs/ossec.log | grep vulnerability

# Restart manager
sudo systemctl restart wazuh-manager
```

## 📊 What You Should See

### Dashboard - Security Events
- Multiple alerts with different severity levels
- MITRE ATT&CK technique IDs (T1110, T1486, etc.)
- Source IPs, usernames, file paths
- Timestamps within seconds of events

### Dashboard - Vulnerabilities
- List of detected CVEs
- Severity ratings (Critical, High, Medium, Low)
- Affected packages
- Available patches

### Alert Examples

**SSH Brute Force:**
```
Rule: 100101 (level 10)
Description: SSH brute force attack detected from 192.168.1.100
MITRE: T1110.001 (Password Guessing)
```

**FIM Alert:**
```
Rule: 100201 (level 12)
Description: Critical system file /etc/passwd modified
MITRE: T1078 (Valid Accounts), T1548 (Abuse Elevation Control)
File: /etc/passwd
```

## 📝 Completion Checklist

- [ ] Custom rules deployed on manager
- [ ] FIM configured on all Linux agents
- [ ] FIM configured on all Windows agents
- [ ] Vulnerability detector enabled
- [ ] Test script executed successfully
- [ ] FIM alerts appearing < 5 seconds
- [ ] Brute force detection working
- [ ] Vulnerabilities detected
- [ ] MITRE tags visible in alerts
- [ ] Gate check passed

## 🎓 Key Concepts Learned

- **FIM**: Real-time file monitoring with < 5 second alerts
- **Decoders**: Extract fields from logs (IP, user, action)
- **Rules**: Logic for detection (frequency, correlation)
- **MITRE ATT&CK**: Standardized adversary tactics
- **Vulnerability Detection**: Automated CVE scanning

## ⏭️ Next Steps

Once Week 2 is complete:
1. Review [Week 3 Documentation](week3-active-response.md)
2. Prepare for active response configuration
3. Plan automated remediation actions

---

**Estimated Time**: 45-60 minutes total  
**Difficulty**: Intermediate  
**Gate Check**: FIM alert within 5 seconds required to proceed
