# Sentient Shield - Complete Implementation Guide

## 📋 Project Overview

**Product**: Sentient Shield - Enterprise EDR & Threat Hunting Grid  
**Organization**: Infotact Solutions - Cyber Defense Operations Center (CDOC)  
**Timeline**: 4 Weeks  
**Status**: Week 1 & 2 Complete

---

## 🗂️ Project Structure

```
sentient-shield/
├── 📄 IMPLEMENTATION_GUIDE.md          ← YOU ARE HERE (Master Guide)
├── 📄 QUICK_REFERENCE.md               ← Quick commands & cheatsheet
├── 📄 README.md                        ← Project overview
│
├── 📁 docs/                            ← Complete Documentation
│   ├── week1-infrastructure-deployment.md    (Day-by-day guide)
│   ├── week1-quick-start.md                  (30-min setup)
│   ├── week2-detection-rules.md              (Day-by-day guide)
│   ├── week2-quick-start.md                  (45-min setup)
│   ├── installation.md
│   ├── fim-setup.md
│   ├── active-response.md
│   ├── mitre-mapping.md
│   └── threat-simulation.md
│
├── 📁 scripts/                         ← Automation Scripts
│   ├── 🔵 WEEK 1 SCRIPTS
│   │   ├── week1-infrastructure-setup.sh      (Main installer)
│   │   ├── week1-deploy-linux-agent.sh        (Linux agent)
│   │   ├── week1-install-sysmon-windows.ps1   (Windows Sysmon)
│   │   └── week1-verify-agents.sh             (Gate check)
│   │
│   ├── 🟢 WEEK 2 SCRIPTS
│   │   ├── week2-deploy-custom-rules.sh       (Rules & decoders)
│   │   ├── week2-configure-fim.sh             (FIM setup)
│   │   ├── week2-enable-vulnerability-detector.sh
│   │   ├── week2-test-detection.sh            (Testing)
│   │   └── week2-gate-check.sh                (Verification)
│   │
│   ├── setup.sh                        (General setup)
│   └── deploy-agent.sh                 (Remote deployment)
│
├── 📁 rules/                           ← Detection Rules
│   ├── custom_brute_force_rules.xml    (SSH, RDP, Web brute force)
│   └── custom_fim_rules.xml            (File integrity alerts)
│
├── 📁 decoders/                        ← Log Parsers
│   └── custom_decoders.xml             (SSH, Apache, custom apps)
│
├── 📁 active-response/                 ← Automated Actions
│   ├── firewall-drop.sh                (IP blocking)
│   └── disable-account.sh              (Account lockout)
│
├── 📁 agents/                          ← Agent Configurations
│   ├── linux-agent-config.conf
│   └── windows-agent-config.conf
│
├── 📁 config/                          ← Manager Configuration
│   └── wazuh-manager.yml
│
├── 📁 src/                             ← Python Modules
│   ├── wazuh_api_client.py
│   ├── mitre_mapper.py
│   └── threat_simulator.py
│
├── 📁 tests/                           ← Test Cases
│   ├── test_active_response.py
│   └── test_mitre_mapper.py
│
├── 📁 dashboards/                      ← Kibana Dashboards
│   └── kibana-dashboard.json
│
├── 📁 threat-simulation/               ← Attack Scenarios
│   └── atomic-red-team-tests.yml
│
├── 📄 requirements.txt                 ← Python dependencies
├── 📄 docker-compose.yml               ← Container deployment
├── 📄 Makefile                         ← Build commands
└── 📄 .env.example                     ← Configuration template
```

---

## 🚀 Quick Start Commands

### Week 1: Infrastructure Setup (30 minutes)

```bash
# 1. Install Wazuh Manager (Ubuntu server)
sudo bash scripts/week1-infrastructure-setup.sh

# 2. Deploy Linux Agent
sudo bash scripts/week1-deploy-linux-agent.sh <manager-ip>

# 3. Deploy Windows Agent (PowerShell)
msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER="<manager-ip>"

# 4. Install Sysmon (PowerShell)
.\scripts\week1-install-sysmon-windows.ps1

# 5. Verify Everything
sudo bash scripts/week1-verify-agents.sh
```

### Week 2: Detection Rules (45 minutes)

```bash
# 1. Deploy Custom Rules (on Manager)
sudo bash scripts/week2-deploy-custom-rules.sh

# 2. Configure FIM (on Linux agents)
sudo bash scripts/week2-configure-fim.sh

# 3. Enable Vulnerability Detector (on Manager)
sudo bash scripts/week2-enable-vulnerability-detector.sh

# 4. Test Detection
sudo bash scripts/week2-test-detection.sh

# 5. Gate Check
sudo bash scripts/week2-gate-check.sh
```

---

## 📅 Week-by-Week Implementation

### ✅ Week 1: Infrastructure & Agent Deployment

**Objective**: Deploy Wazuh Manager and agents on all endpoints

**Key Files**:
- 📄 `docs/week1-infrastructure-deployment.md` - Complete guide
- 📄 `docs/week1-quick-start.md` - Fast track
- 🔧 `scripts/week1-infrastructure-setup.sh` - Main installer
- 🔧 `scripts/week1-verify-agents.sh` - Verification

**Deliverables**:
- ✅ Wazuh Manager running on dedicated server
- ✅ Dashboard accessible at `https://<server-ip>`
- ✅ Linux agent deployed and active
- ✅ Windows agent deployed and active
- ✅ Sysmon installed on Windows
- ✅ All agents sending heartbeats (< 1 minute)

**Gate Check**: All agents must show "Active" status

**Time**: 30-45 minutes

---

### ✅ Week 2: Detection Rules (The Logic)

**Objective**: Configure FIM, create custom rules, enable vulnerability scanning

**Key Files**:
- 📄 `docs/week2-detection-rules.md` - Complete guide
- 📄 `docs/week2-quick-start.md` - Fast track
- 🔧 `scripts/week2-deploy-custom-rules.sh` - Rules deployment
- 🔧 `scripts/week2-configure-fim.sh` - FIM setup
- 🔧 `scripts/week2-gate-check.sh` - Verification
- 📋 `rules/custom_brute_force_rules.xml` - Brute force detection
- 📋 `rules/custom_fim_rules.xml` - File integrity rules
- 📋 `decoders/custom_decoders.xml` - Log parsers

**Deliverables**:
- ✅ FIM configured on all agents
- ✅ Custom detection rules deployed
- ✅ SSH brute force detection (5 attempts in 5 min)
- ✅ Critical file modification alerts
- ✅ Ransomware pattern detection
- ✅ Web attack detection (SQLi, traversal)
- ✅ Vulnerability detector enabled
- ✅ MITRE ATT&CK mapping active

**Gate Check**: FIM alert must appear within 5 seconds

**Time**: 45-60 minutes

---

### 🔜 Week 3: Active Response (IPS)

**Objective**: Implement automated remediation actions

**Key Files** (Ready to use):
- 📄 `docs/active-response.md` - Configuration guide
- 🔧 `active-response/firewall-drop.sh` - IP blocking
- 🔧 `active-response/disable-account.sh` - Account lockout

**Planned Deliverables**:
- ⏳ Automated IP blocking after 5 failed SSH attempts
- ⏳ 1-hour ban duration with auto-unblock
- ⏳ Account disable on compromise
- ⏳ Custom response scripts
- ⏳ Testing with Hydra tool

**Gate Check**: IP automatically blocked after brute force

**Time**: 30-45 minutes

---

### 🔜 Week 4: Threat Simulation

**Objective**: Test detection capabilities with real attack scenarios

**Key Files** (Ready to use):
- 📄 `docs/threat-simulation.md` - Testing guide
- 📋 `threat-simulation/atomic-red-team-tests.yml` - Attack scenarios
- 🐍 `src/threat_simulator.py` - Simulation tools

**Planned Deliverables**:
- ⏳ Ransomware simulation (T1486)
- ⏳ SSH brute force testing
- ⏳ Credential dumping simulation
- ⏳ Kill chain visualization
- ⏳ Detection validation

**Gate Check**: All simulated attacks detected and visualized

**Time**: 60-90 minutes

---

## 🎯 Custom Detection Rules

### SSH Brute Force Detection

**Rule ID**: 100101  
**Severity**: 10 (High)  
**Logic**: 5 failed attempts in 5 minutes from same IP  
**MITRE**: T1110.001 (Password Guessing)  
**File**: `rules/custom_brute_force_rules.xml`

```xml
<rule id="100101" level="10" frequency="5" timeframe="300">
  <if_matched_sid>5710</if_matched_sid>
  <same_source_ip />
  <description>SSH brute force attack detected from $(srcip)</description>
  <mitre>
    <id>T1110.001</id>
  </mitre>
</rule>
```

### Critical File Modification

**Rule ID**: 100201  
**Severity**: 12 (Critical)  
**Logic**: Modification of /etc/passwd, /etc/shadow, /etc/sudoers  
**MITRE**: T1078, T1548  
**File**: `rules/custom_fim_rules.xml`

```xml
<rule id="100201" level="12">
  <if_sid>550</if_sid>
  <field name="file">/etc/passwd|/etc/shadow|/etc/sudoers</field>
  <description>CRITICAL: System file $(file) modified</description>
  <mitre>
    <id>T1078</id>
    <id>T1548</id>
  </mitre>
</rule>
```

### Ransomware Pattern

**Rule ID**: 100205  
**Severity**: 14 (Critical)  
**Logic**: 10+ file modifications in 60 seconds  
**MITRE**: T1486 (Data Encrypted for Impact)  
**File**: `rules/custom_fim_rules.xml`

```xml
<rule id="100205" level="14" frequency="10" timeframe="60">
  <if_matched_sid>550</if_matched_sid>
  <description>CRITICAL: Ransomware activity detected</description>
  <mitre>
    <id>T1486</id>
  </mitre>
</rule>
```

### Complete Rule List

| Rule ID | Description | Severity | MITRE Technique |
|---------|-------------|----------|-----------------|
| 100101 | SSH Brute Force | 10 | T1110.001 |
| 100102 | Login After Brute Force | 12 | T1110.001, T1078 |
| 100103 | Password Spray | 11 | T1110.003 |
| 100104 | Invalid User Attempts | 9 | T1110.001 |
| 100201 | Critical File Modified | 12 | T1078, T1548 |
| 100202 | Windows System32 Modified | 12 | T1055, T1574 |
| 100203 | Web Shell Detected | 13 | T1505.003 |
| 100204 | SSH Config Modified | 10 | T1098 |
| 100205 | Ransomware Pattern | 14 | T1486 |
| 100206 | Startup Persistence | 9 | T1547.001, T1053.003 |
| 100301 | SQL Injection | 10 | T1190 |
| 100302 | Directory Traversal | 10 | T1083 |
| 100303 | Web Scanning | 8 | T1595.002 |

---

## 🔧 Important Configuration Files

### 1. Wazuh Manager Configuration
**File**: `config/wazuh-manager.yml`

Key settings:
- Manager host: 0.0.0.0
- Agent port: 1514
- API port: 55000
- Email alerts: soc@infotact.com
- FIM frequency: 300 seconds
- Vulnerability detector: Enabled

### 2. Linux Agent Configuration
**File**: `agents/linux-agent-config.conf`

Monitored directories:
- `/etc` - System configuration
- `/usr/bin`, `/usr/sbin` - Binaries
- `/var/www` - Web applications
- `/etc/ssh` - SSH configuration

### 3. Windows Agent Configuration
**File**: `agents/windows-agent-config.conf`

Monitored locations:
- `C:\Windows\System32` - System files
- `C:\Program Files` - Applications
- Registry: `HKLM\Software`, `HKLM\System`
- Startup folders

### 4. Active Response Scripts
**Files**: `active-response/firewall-drop.sh`, `disable-account.sh`

Actions:
- IP blocking (1 hour duration)
- Account disable
- Service restart
- Custom remediation

---

## 📊 Dashboard Access & Monitoring

### Access Information
- **URL**: `https://<wazuh-manager-ip>`
- **Default User**: admin
- **Password**: Check `/root/wazuh-credentials.txt`

### Key Dashboard Sections

1. **Security Events**
   - Real-time alerts
   - Filter by rule ID, severity, agent
   - MITRE ATT&CK mapping

2. **Vulnerabilities**
   - CVE list with severity
   - Affected packages
   - Available patches

3. **File Integrity Monitoring**
   - File modifications
   - New files added
   - Deleted files
   - Permission changes

4. **Agents**
   - Agent status (Active/Disconnected)
   - Last keep alive
   - OS information
   - Agent version

### Useful Filters

```
# SSH brute force alerts
rule.id:100101

# FIM alerts
rule.groups:syscheck

# Critical alerts only
rule.level:>=12

# Specific agent
agent.name:"web-server-01"

# MITRE technique
rule.mitre.id:T1110.001
```

---

## 🧪 Testing Commands

### Test FIM
```bash
# Linux
echo "test" | sudo tee -a /var/www/test/test_fim.txt

# Windows (PowerShell)
Add-Content -Path "C:\Windows\System32\test.txt" -Value "Test"
```

### Test SSH Brute Force
```bash
for i in {1..6}; do
  ssh wronguser@localhost
  sleep 2
done
```

### Test Web Attacks
```bash
# SQL Injection
curl "http://localhost/index.php?id=1' OR '1'='1"

# Directory Traversal
curl "http://localhost/../../etc/passwd"
```

### View Alerts
```bash
# Real-time alerts
sudo tail -f /var/ossec/logs/alerts/alerts.log

# All logs
sudo tail -f /var/ossec/logs/archives/archives.log

# Specific rule
sudo grep "100101" /var/ossec/logs/alerts/alerts.log
```

---

## 🔍 Troubleshooting

### Agent Not Connecting
```bash
# Check agent status
sudo systemctl status wazuh-agent

# Check logs
sudo tail -f /var/ossec/logs/ossec.log

# Verify manager IP
grep MANAGER_IP /var/ossec/etc/ossec.conf

# Restart agent
sudo systemctl restart wazuh-agent
```

### FIM Not Triggering
```bash
# Force syscheck scan
sudo /var/ossec/bin/agent_control -r -u 001

# Check syscheck status
sudo /var/ossec/bin/agent_control -i 001 -s

# Verify configuration
grep -A 20 "<syscheck>" /var/ossec/etc/ossec.conf
```

### Rules Not Matching
```bash
# Test rule with sample log
echo 'Your log message' | sudo /var/ossec/bin/wazuh-logtest

# Check rule syntax
sudo /var/ossec/bin/wazuh-logtest -v

# Verify rule loaded
sudo grep "rule id=\"100101\"" /var/ossec/etc/rules/*.xml
```

### Dashboard Not Accessible
```bash
# Check dashboard status
sudo systemctl status wazuh-dashboard

# Restart dashboard
sudo systemctl restart wazuh-dashboard

# Check firewall
sudo ufw allow 443/tcp
```

---

## 📚 Additional Resources

### Documentation
- [Wazuh Official Docs](https://documentation.wazuh.com/)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [Sysmon Documentation](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)

### Project Files
- `README.md` - Project overview
- `QUICK_REFERENCE.md` - Command cheatsheet
- `requirements.txt` - Python dependencies
- `.env.example` - Configuration template

---

## ✅ Completion Checklist

### Week 1
- [ ] Wazuh Manager installed
- [ ] Dashboard accessible
- [ ] Linux agent active
- [ ] Windows agent active
- [ ] Sysmon installed
- [ ] All agents sending heartbeats
- [ ] Verification script passed

### Week 2
- [ ] Custom rules deployed
- [ ] FIM configured on all agents
- [ ] Vulnerability detector enabled
- [ ] FIM response < 5 seconds
- [ ] Brute force detection working
- [ ] MITRE tags present
- [ ] Gate check passed

### Week 3 (Upcoming)
- [ ] Active response configured
- [ ] IP blocking working
- [ ] Account disable functional
- [ ] Response scripts tested
- [ ] Hydra testing complete

### Week 4 (Upcoming)
- [ ] Ransomware simulation
- [ ] Attack scenarios tested
- [ ] Kill chain visualized
- [ ] Detection validated
- [ ] Final report generated

---

## 🎓 Key Learnings

### Week 1
- Wazuh architecture (Manager, Agent, Indexer, Dashboard)
- Agent enrollment and communication
- Sysmon event types and visibility
- Basic dashboard navigation

### Week 2
- FIM configuration and real-time monitoring
- XML decoder structure and field extraction
- Rule logic (frequency, timeframe, correlation)
- MITRE ATT&CK framework integration
- Vulnerability detection capabilities

### Week 3 (Upcoming)
- Active response mechanisms
- Automated remediation strategies
- Script development for custom actions
- Testing and validation methods

### Week 4 (Upcoming)
- Attack simulation techniques
- Detection validation
- Kill chain analysis
- Reporting and documentation

---

## 📞 Support & Contact

**Organization**: Infotact Solutions  
**Project**: Cyber Defense Operations Center (CDOC)  
**Product**: Sentient Shield  
**Email**: soc@infotact.com

---

**Last Updated**: Week 2 Complete  
**Next Milestone**: Week 3 - Active Response Configuration  
**Status**: ✅ On Track
