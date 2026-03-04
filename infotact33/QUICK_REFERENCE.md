# Sentient Shield - Quick Reference Guide

## 🚀 One-Command Setup

### Week 1: Infrastructure (30 min)
```bash
# Manager
sudo bash scripts/week1-infrastructure-setup.sh

# Linux Agent
sudo bash scripts/week1-deploy-linux-agent.sh <manager-ip>

# Windows Agent (PowerShell)
msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER="<manager-ip>"
.\scripts\week1-install-sysmon-windows.ps1

# Verify
sudo bash scripts/week1-verify-agents.sh
```

### Week 2: Detection Rules (45 min)
```bash
# Manager
sudo bash scripts/week2-deploy-custom-rules.sh
sudo bash scripts/week2-enable-vulnerability-detector.sh

# Linux Agent
sudo bash scripts/week2-configure-fim.sh

# Test & Verify
sudo bash scripts/week2-test-detection.sh
sudo bash scripts/week2-gate-check.sh
```

---

## 📋 Essential Commands

### Wazuh Manager
```bash
# Service control
sudo systemctl start|stop|restart|status wazuh-manager

# List agents
sudo /var/ossec/bin/agent_control -l

# Agent details
sudo /var/ossec/bin/agent_control -i 001

# Force syscheck scan
sudo /var/ossec/bin/agent_control -r -u 001

# Test rules
echo 'log message' | sudo /var/ossec/bin/wazuh-logtest

# View alerts
sudo tail -f /var/ossec/logs/alerts/alerts.log

# View all logs
sudo tail -f /var/ossec/logs/archives/archives.log
```

### Wazuh Agent (Linux)
```bash
# Service control
sudo systemctl start|stop|restart|status wazuh-agent

# View logs
sudo tail -f /var/ossec/logs/ossec.log

# Check configuration
sudo cat /var/ossec/etc/ossec.conf

# Manual syscheck scan
sudo /var/ossec/bin/agent_control -r -a
```

### Wazuh Agent (Windows PowerShell)
```powershell
# Service control
Start-Service WazuhSvc
Stop-Service WazuhSvc
Restart-Service WazuhSvc
Get-Service WazuhSvc

# View logs
Get-Content "C:\Program Files (x86)\ossec-agent\ossec.log" -Tail 50 -Wait

# Check configuration
notepad "C:\Program Files (x86)\ossec-agent\ossec.conf"
```

---

## 🧪 Quick Tests

### Test FIM
```bash
# Linux
echo "test-$(date)" | sudo tee -a /var/www/test/test.txt

# Windows (PowerShell)
Add-Content -Path "C:\Windows\System32\test.txt" -Value "Test-$(Get-Date)"
```

### Test SSH Brute Force
```bash
for i in {1..6}; do ssh wronguser@localhost; sleep 2; done
```

### Test Web Attacks
```bash
curl "http://localhost/index.php?id=1' OR '1'='1"
curl "http://localhost/../../etc/passwd"
```

---

## 🎯 Important Rule IDs

| Rule ID | Description | Severity |
|---------|-------------|----------|
| 550 | File modified | 7 |
| 554 | File added | 7 |
| 553 | File deleted | 7 |
| 5710 | SSH failed login | 5 |
| 5715 | SSH successful login | 3 |
| 100101 | SSH brute force | 10 |
| 100102 | Login after brute force | 12 |
| 100201 | Critical file modified | 12 |
| 100202 | Windows System32 modified | 12 |
| 100205 | Ransomware pattern | 14 |
| 100301 | SQL Injection | 10 |

---

## 🔍 Dashboard Filters

```bash
# SSH brute force
rule.id:100101

# FIM alerts
rule.groups:syscheck

# Critical alerts
rule.level:>=12

# Specific agent
agent.name:"web-server-01"

# MITRE technique
rule.mitre.id:T1110.001

# Time range
timestamp:[now-1h TO now]
```

---

## 📁 Important File Locations

### Wazuh Manager
```
/var/ossec/etc/ossec.conf              # Main config
/var/ossec/etc/rules/                  # Rules directory
/var/ossec/etc/decoders/               # Decoders directory
/var/ossec/logs/alerts/alerts.log      # Alerts
/var/ossec/logs/ossec.log              # Manager logs
/var/ossec/bin/agent_control           # Agent management
/var/ossec/bin/wazuh-logtest           # Rule testing
```

### Linux Agent
```
/var/ossec/etc/ossec.conf              # Agent config
/var/ossec/logs/ossec.log              # Agent logs
/var/ossec/bin/wazuh-control           # Agent control
```

### Windows Agent
```
C:\Program Files (x86)\ossec-agent\ossec.conf    # Config
C:\Program Files (x86)\ossec-agent\ossec.log     # Logs
```

---

## 🔧 Quick Fixes

### Agent Not Connecting
```bash
# Check manager IP
grep MANAGER_IP /var/ossec/etc/ossec.conf

# Fix and restart
sudo sed -i "s/MANAGER_IP/actual-ip/g" /var/ossec/etc/ossec.conf
sudo systemctl restart wazuh-agent
```

### FIM Not Working
```bash
# Force scan
sudo /var/ossec/bin/agent_control -r -u 001

# Check config
grep -A 20 "<syscheck>" /var/ossec/etc/ossec.conf
```

### Dashboard Not Accessible
```bash
# Restart services
sudo systemctl restart wazuh-dashboard
sudo systemctl restart wazuh-indexer

# Check firewall
sudo ufw allow 443/tcp
```

---

## 📊 Monitoring Directories

### Linux
- `/etc` - System configuration
- `/usr/bin`, `/usr/sbin` - Binaries
- `/var/www` - Web applications
- `/etc/ssh` - SSH config
- `/etc/cron.d` - Scheduled tasks

### Windows
- `C:\Windows\System32` - System files
- `C:\Program Files` - Applications
- `HKLM\Software` - Registry
- `%APPDATA%\...\Startup` - Startup items

---

## 🎯 MITRE ATT&CK Mapping

| Technique | Name | Rule IDs |
|-----------|------|----------|
| T1110.001 | Password Guessing | 100101, 100104 |
| T1110.003 | Password Spraying | 100103 |
| T1078 | Valid Accounts | 100102, 100201 |
| T1486 | Data Encrypted (Ransomware) | 100205 |
| T1055 | Process Injection | 100202 |
| T1505.003 | Web Shell | 100203 |
| T1190 | Exploit Public-Facing App | 100301 |

---

## 📞 Access Information

**Dashboard**: `https://<manager-ip>`  
**API**: `https://<manager-ip>:55000`  
**Credentials**: `/root/wazuh-credentials.txt`

**Ports**:
- 1514 - Agent communication
- 1515 - Agent enrollment
- 55000 - API
- 9200 - Indexer
- 443 - Dashboard

---

## ✅ Gate Check Commands

### Week 1
```bash
sudo bash scripts/week1-verify-agents.sh
# Expected: All agents "Active"
```

### Week 2
```bash
sudo bash scripts/week2-gate-check.sh
# Expected: FIM < 5s, all checks pass
```

---

## 🚨 Emergency Commands

### Stop All Services
```bash
sudo systemctl stop wazuh-manager
sudo systemctl stop wazuh-indexer
sudo systemctl stop wazuh-dashboard
```

### Backup Configuration
```bash
sudo cp /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.backup.$(date +%Y%m%d)
```

### Restore Configuration
```bash
sudo cp /var/ossec/etc/ossec.conf.backup.YYYYMMDD /var/ossec/etc/ossec.conf
sudo systemctl restart wazuh-manager
```

### View Last 100 Alerts
```bash
sudo tail -n 100 /var/ossec/logs/alerts/alerts.log
```

### Clear Old Logs (Careful!)
```bash
sudo truncate -s 0 /var/ossec/logs/alerts/alerts.log
sudo truncate -s 0 /var/ossec/logs/archives/archives.log
```

---

## 📚 Documentation Links

- **Main Guide**: `IMPLEMENTATION_GUIDE.md`
- **Week 1**: `docs/week1-quick-start.md`
- **Week 2**: `docs/week2-quick-start.md`
- **README**: `README.md`

---

**Quick Help**: For detailed information, see `IMPLEMENTATION_GUIDE.md`
