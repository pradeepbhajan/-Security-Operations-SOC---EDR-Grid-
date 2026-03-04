# Week 2: Detection Rules (The Logic)

## 🎯 Objectives
- Configure File Integrity Monitoring (FIM) for sensitive directories
- Write custom XML decoders for application-specific log formats
- Create custom detection rules for brute force, FIM alerts, and suspicious activity
- Enable Vulnerability Detector module
- Test rules with real-world scenarios

## 📋 Prerequisites
- ✅ Week 1 completed (all agents active)
- ✅ Access to Wazuh Manager
- ✅ Basic understanding of XML
- ✅ Sample application logs (optional)

## 🚀 Day-by-Day Implementation

### Day 1: Configure File Integrity Monitoring (FIM)

#### Understanding FIM
FIM monitors files and directories for:
- Modifications (content changes)
- Additions (new files)
- Deletions (removed files)
- Permission changes
- Ownership changes

#### Step 1: Configure FIM on Linux Agent

**Edit agent configuration:**
```bash
# On Linux agent
sudo nano /var/ossec/etc/ossec.conf
```

**Add FIM configuration:**
```xml
<syscheck>
  <disabled>no</disabled>
  <frequency>300</frequency>
  <scan_on_start>yes</scan_on_start>
  
  <!-- Critical System Files -->
  <directories check_all="yes" realtime="yes" report_changes="yes">/etc</directories>
  <directories check_all="yes" realtime="yes">/usr/bin</directories>
  <directories check_all="yes" realtime="yes">/usr/sbin</directories>
  <directories check_all="yes" realtime="yes">/bin</directories>
  <directories check_all="yes" realtime="yes">/sbin</directories>
  
  <!-- Web Application Directory -->
  <directories check_all="yes" realtime="yes" report_changes="yes">/var/www</directories>
  
  <!-- SSH Configuration -->
  <directories check_all="yes" realtime="yes" report_changes="yes">/etc/ssh</directories>
  
  <!-- Ignore temporary files -->
  <ignore>/etc/mtab</ignore>
  <ignore>/etc/hosts.deny</ignore>
  <ignore>/etc/mail/statistics</ignore>
  <ignore>/etc/random-seed</ignore>
  <ignore>/etc/adjtime</ignore>
  
  <!-- Alert on specific files -->
  <alert_new_files>yes</alert_new_files>
</syscheck>
```

**Restart agent:**
```bash
sudo systemctl restart wazuh-agent
```

#### Step 2: Configure FIM on Windows Agent

**Edit Windows agent configuration:**
```powershell
# On Windows Server
notepad "C:\Program Files (x86)\ossec-agent\ossec.conf"
```

**Add FIM configuration:**
```xml
<syscheck>
  <disabled>no</disabled>
  <frequency>300</frequency>
  <scan_on_start>yes</scan_on_start>
  
  <!-- Windows System Directories -->
  <directories check_all="yes" realtime="yes">C:\Windows\System32</directories>
  <directories check_all="yes">C:\Program Files</directories>
  <directories check_all="yes">C:\Program Files (x86)</directories>
  
  <!-- Windows Registry Keys -->
  <windows_registry check_all="yes" realtime="yes">HKEY_LOCAL_MACHINE\Software</windows_registry>
  <windows_registry check_all="yes" realtime="yes">HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services</windows_registry>
  <windows_registry check_all="yes">HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\KnownDLLs</windows_registry>
  
  <!-- Startup Locations -->
  <directories check_all="yes" realtime="yes">C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup</directories>
  
  <alert_new_files>yes</alert_new_files>
</syscheck>
```

**Restart agent:**
```powershell
Restart-Service WazuhSvc
```

#### Step 3: Test FIM Configuration

**Linux Test:**
```bash
# Create test directory
sudo mkdir -p /var/www/test

# Create test file
echo "Original content" | sudo tee /var/www/test/test_fim.txt

# Wait 10 seconds for initial scan
sleep 10

# Modify file (should trigger alert)
echo "Modified content" | sudo tee /var/www/test/test_fim.txt

# Check alerts
sudo tail -f /var/ossec/logs/alerts/alerts.log | grep syscheck
```

**Windows Test:**
```powershell
# Create test file in System32
New-Item -Path "C:\Windows\System32\test_fim.txt" -ItemType File -Value "Test content"

# Wait 10 seconds
Start-Sleep -Seconds 10

# Modify file
Add-Content -Path "C:\Windows\System32\test_fim.txt" -Value "Modified"
```

**Expected Alert in Dashboard:**
- Rule ID: 550 (File modified)
- Severity: 7
- File path shown
- Changes reported

### Day 2: Write Custom Decoders

#### Understanding Decoders
Decoders parse log messages and extract fields like:
- Source IP
- Username
- Action
- Timestamp

#### Step 1: Create Custom Decoder File

**On Wazuh Manager:**
```bash
sudo nano /var/ossec/etc/decoders/local_decoder.xml
```

#### Step 2: SSH Brute Force Decoder

```xml
<!-- Custom SSH Authentication Decoder -->
<decoder name="custom-sshd">
  <parent>sshd</parent>
  <prematch>^Failed password for</prematch>
  <regex offset="after_prematch">^ (\S+) from (\S+) port (\d+)</regex>
  <order>user, srcip, srcport</order>
</decoder>

<decoder name="custom-sshd-invalid">
  <parent>sshd</parent>
  <prematch>^Invalid user</prematch>
  <regex offset="after_prematch">^ (\S+) from (\S+)</regex>
  <order>user, srcip</order>
</decoder>

<decoder name="custom-sshd-accepted">
  <parent>sshd</parent>
  <prematch>^Accepted password for</prematch>
  <regex offset="after_prematch">^ (\S+) from (\S+) port (\d+)</regex>
  <order>user, srcip, srcport</order>
</decoder>
```

#### Step 3: Apache/Nginx Web Server Decoder

```xml
<!-- Custom Apache Access Log Decoder -->
<decoder name="custom-apache-access">
  <parent>apache-access</parent>
  <type>web-log</type>
  <prematch>^\S+ \S+ \S+ \[\S+ \S+\] "\w+ \S+ HTTP/\d.\d" \d+</prematch>
  <regex>^(\S+) \S+ \S+ \[\S+ \S+\] "(\w+) (\S+) HTTP/\d.\d" (\d+)</regex>
  <order>srcip, method, url, status_code</order>
</decoder>

<!-- Custom Apache Error Log Decoder -->
<decoder name="custom-apache-error">
  <parent>apache-errorlog</parent>
  <prematch>authentication failure</prematch>
  <regex>user (\S+): authentication failure</regex>
  <order>user</order>
</decoder>
```

#### Step 4: Custom Application Decoder (Example)

```xml
<!-- Custom Application Log Decoder -->
<decoder name="custom-app-login">
  <program_name>myapp</program_name>
  <prematch>^LOGIN_ATTEMPT</prematch>
  <regex>^LOGIN_ATTEMPT user=(\S+) ip=(\S+) status=(\w+)</regex>
  <order>user, srcip, status</order>
</decoder>

<decoder name="custom-app-error">
  <program_name>myapp</program_name>
  <prematch>^ERROR</prematch>
  <regex>^ERROR code=(\d+) message=(.+)$</regex>
  <order>error_code, error_message</order>
</decoder>
```

#### Step 5: Test Decoders

```bash
# Restart Wazuh Manager to load decoders
sudo systemctl restart wazuh-manager

# Test decoder with sample log
echo 'Failed password for admin from 192.168.1.100 port 22 ssh2' | sudo /var/ossec/bin/wazuh-logtest

# Expected output should show extracted fields:
# user: admin
# srcip: 192.168.1.100
# srcport: 22
```

### Day 3: Create Custom Detection Rules

#### Step 1: Create Custom Rules File

```bash
sudo nano /var/ossec/etc/rules/local_rules.xml
```

#### Step 2: SSH Brute Force Detection Rules

```xml
<group name="authentication,brute_force,sentient_shield">

  <!-- SSH Brute Force: 5 failed attempts in 5 minutes -->
  <rule id="100101" level="10" frequency="5" timeframe="300">
    <if_matched_sid>5710</if_matched_sid>
    <same_source_ip />
    <description>SSH brute force attack detected from $(srcip) - 5 failed attempts in 5 minutes</description>
    <mitre>
      <id>T1110.001</id>
    </mitre>
  </rule>

  <!-- Successful login after brute force -->
  <rule id="100102" level="12">
    <if_sid>5715</if_sid>
    <if_matched_sid>100101</if_matched_sid>
    <same_source_ip />
    <description>CRITICAL: Successful SSH login from $(srcip) after brute force attempts</description>
    <mitre>
      <id>T1110.001</id>
      <id>T1078</id>
    </mitre>
  </rule>

  <!-- Password spray: Multiple users from same IP -->
  <rule id="100103" level="11" frequency="20" timeframe="600">
    <if_matched_sid>5710</if_matched_sid>
    <different_user />
    <same_source_ip />
    <description>Password spray attack from $(srcip) - Multiple users targeted</description>
    <mitre>
      <id>T1110.003</id>
    </mitre>
  </rule>

  <!-- Invalid user attempts -->
  <rule id="100104" level="9" frequency="5" timeframe="300">
    <if_matched_sid>5710</if_matched_sid>
    <match>Invalid user</match>
    <same_source_ip />
    <description>Multiple invalid user login attempts from $(srcip)</description>
    <mitre>
      <id>T1110.001</id>
    </mitre>
  </rule>

</group>
```

#### Step 3: File Integrity Monitoring Rules

```xml
<group name="syscheck,fim,sentient_shield">

  <!-- Critical system file modified -->
  <rule id="100201" level="12">
    <if_sid>550</if_sid>
    <field name="file">/etc/passwd|/etc/shadow|/etc/sudoers</field>
    <description>CRITICAL: System file $(file) was modified - Potential privilege escalation</description>
    <mitre>
      <id>T1078</id>
      <id>T1548</id>
    </mitre>
  </rule>

  <!-- Windows System32 modification -->
  <rule id="100202" level="12">
    <if_sid>550</if_sid>
    <field name="file">\\Windows\\System32</field>
    <description>CRITICAL: Windows System32 file $(file) modified - Potential malware</description>
    <mitre>
      <id>T1055</id>
      <id>T1574</id>
    </mitre>
  </rule>

  <!-- Web shell detection -->
  <rule id="100203" level="13">
    <if_sid>554</if_sid>
    <field name="file">/var/www|/usr/share/nginx</field>
    <match>.php|.jsp|.asp</match>
    <description>CRITICAL: Potential web shell uploaded to $(file)</description>
    <mitre>
      <id>T1505.003</id>
    </mitre>
  </rule>

  <!-- SSH config modification -->
  <rule id="100204" level="10">
    <if_sid>550</if_sid>
    <field name="file">/etc/ssh/sshd_config</field>
    <description>SSH configuration modified - Review changes immediately</description>
    <mitre>
      <id>T1098</id>
    </mitre>
  </rule>

  <!-- Multiple file modifications (Ransomware indicator) -->
  <rule id="100205" level="14" frequency="10" timeframe="60">
    <if_matched_sid>550</if_matched_sid>
    <description>CRITICAL: Ransomware activity detected - Multiple files modified rapidly</description>
    <mitre>
      <id>T1486</id>
    </mitre>
  </rule>

  <!-- Startup persistence -->
  <rule id="100206" level="9">
    <if_sid>554</if_sid>
    <field name="file">\\Startup|/etc/cron|/var/spool/cron</field>
    <description>File added to startup location - Potential persistence mechanism</description>
    <mitre>
      <id>T1547.001</id>
      <id>T1053.003</id>
    </mitre>
  </rule>

</group>
```

#### Step 4: Web Application Attack Rules

```xml
<group name="web,attack,sentient_shield">

  <!-- SQL Injection attempt -->
  <rule id="100301" level="10">
    <if_sid>31100</if_sid>
    <url>select|union|insert|update|delete|drop|exec|script</url>
    <description>SQL Injection attempt detected from $(srcip)</description>
    <mitre>
      <id>T1190</id>
    </mitre>
  </rule>

  <!-- Directory traversal -->
  <rule id="100302" level="10">
    <if_sid>31100</if_sid>
    <url>\.\.\/|\.\.\\</url>
    <description>Directory traversal attempt from $(srcip)</description>
    <mitre>
      <id>T1083</id>
    </mitre>
  </rule>

  <!-- Multiple 404 errors (scanning) -->
  <rule id="100303" level="8" frequency="10" timeframe="120">
    <if_sid>31101</if_sid>
    <same_source_ip />
    <description>Web scanning detected from $(srcip) - Multiple 404 errors</description>
    <mitre>
      <id>T1595.002</id>
    </mitre>
  </rule>

</group>
```

#### Step 5: Restart and Test Rules

```bash
# Test rules syntax
sudo /var/ossec/bin/wazuh-logtest

# Restart manager
sudo systemctl restart wazuh-manager

# Check if rules loaded
sudo grep "100101" /var/ossec/logs/ossec.log
```

### Day 4: Enable Vulnerability Detector

#### Step 1: Configure Vulnerability Detector

```bash
sudo nano /var/ossec/etc/ossec.conf
```

**Add configuration:**
```xml
<vulnerability-detector>
  <enabled>yes</enabled>
  <interval>5m</interval>
  <min_full_scan_interval>6h</min_full_scan_interval>
  <run_on_start>yes</run_on_start>

  <!-- Ubuntu/Debian -->
  <provider name="canonical">
    <enabled>yes</enabled>
    <os>trusty</os>
    <os>xenial</os>
    <os>bionic</os>
    <os>focal</os>
    <os>jammy</os>
    <update_interval>1h</update_interval>
  </provider>

  <!-- Red Hat/CentOS -->
  <provider name="redhat">
    <enabled>yes</enabled>
    <update_interval>1h</update_interval>
  </provider>

  <!-- Windows -->
  <provider name="msu">
    <enabled>yes</enabled>
    <update_interval>1h</update_interval>
  </provider>

  <!-- National Vulnerability Database -->
  <provider name="nvd">
    <enabled>yes</enabled>
    <update_interval>1h</update_interval>
  </provider>

</vulnerability-detector>
```

#### Step 2: Restart and Verify

```bash
# Restart manager
sudo systemctl restart wazuh-manager

# Check vulnerability detector logs
sudo tail -f /var/ossec/logs/ossec.log | grep vulnerability

# Wait 5-10 minutes for first scan
```

#### Step 3: View Vulnerabilities in Dashboard

1. Go to Dashboard → Vulnerabilities
2. Filter by agent
3. View CVE details
4. Check severity levels

### Day 5: Testing and Validation

#### Test 1: FIM Alert Test

**Linux:**
```bash
# Manually modify watched file
echo "test" | sudo tee -a /var/www/test/test_fim.txt

# Check dashboard within 5 seconds
# Expected: Rule 550, Level 7, File modified
```

**Windows:**
```powershell
# Modify System32 file
Add-Content -Path "C:\Windows\System32\test_fim.txt" -Value "Modified at $(Get-Date)"

# Check dashboard
# Expected: Rule 100202, Level 12, Critical alert
```

#### Test 2: Brute Force Detection

```bash
# Generate 6 failed SSH attempts
for i in {1..6}; do
  ssh wronguser@localhost
  sleep 2
done

# Expected alerts:
# 1. 5x Rule 5710 (Failed password)
# 2. 1x Rule 100101 (Brute force detected)
```

#### Test 3: Web Attack Simulation

```bash
# SQL Injection attempt
curl "http://your-web-server/index.php?id=1' OR '1'='1"

# Directory traversal
curl "http://your-web-server/../../etc/passwd"

# Expected: Rules 100301, 100302
```

#### Test 4: Vulnerability Scan Verification

```bash
# Check if vulnerabilities detected
sudo /var/ossec/bin/agent_control -i 001

# View vulnerability count in dashboard
```

### Day 6-7: Gate Check & Documentation

#### Gate Check Tasks

##### 1. Manually Modify FIM File
```bash
# On Linux agent
echo "Gate check test" | sudo tee -a /etc/test_gate_check.txt

# Verify alert appears in dashboard within 5 seconds
# Required: High-severity alert visible
```

##### 2. Verify Custom Rules Working
```bash
# Check rule statistics
sudo /var/ossec/bin/wazuh-logtest -v

# Verify rules loaded
sudo grep "100101\|100201\|100301" /var/ossec/ruleset/rules/*.xml
```

##### 3. Test Vulnerability Detector
- Dashboard shows vulnerability count
- At least one CVE detected
- Severity levels displayed

##### 4. Review Alert Dashboard
- FIM alerts visible
- Brute force alerts working
- MITRE ATT&CK tags present
- Alert levels correct

## 📊 Week 2 Deliverables

### Configuration Files
- ✅ FIM configured on all agents
- ✅ Custom decoders created
- ✅ Custom rules deployed
- ✅ Vulnerability detector enabled

### Testing Results
- ✅ FIM alerts triggering within 5 seconds
- ✅ Brute force detection working
- ✅ Web attack rules functional
- ✅ Vulnerability scans running

### Documentation
- ✅ List of monitored directories
- ✅ Custom rule IDs and descriptions
- ✅ Decoder mappings
- ✅ Test results

## 🔧 Troubleshooting

### FIM Not Triggering
```bash
# Check syscheck status
sudo /var/ossec/bin/agent_control -i 001 -s

# Force syscheck scan
sudo /var/ossec/bin/agent_control -r -u 001

# Check agent logs
sudo tail -f /var/ossec/logs/ossec.log | grep syscheck
```

### Rules Not Matching
```bash
# Test rule with sample log
echo 'Your log message' | sudo /var/ossec/bin/wazuh-logtest

# Check rule syntax
sudo /var/ossec/bin/wazuh-logtest -v

# Verify rule loaded
sudo grep "rule id=\"100101\"" /var/ossec/etc/rules/local_rules.xml
```

### Vulnerability Detector Not Running
```bash
# Check configuration
sudo grep -A 20 "vulnerability-detector" /var/ossec/etc/ossec.conf

# Check logs
sudo tail -f /var/ossec/logs/ossec.log | grep vulnerability

# Restart manager
sudo systemctl restart wazuh-manager
```

## 📝 Week 2 Completion Checklist

- [ ] FIM configured on Linux agents
- [ ] FIM configured on Windows agents
- [ ] Custom decoders created and tested
- [ ] SSH brute force rules working
- [ ] FIM detection rules working
- [ ] Web attack rules functional
- [ ] Vulnerability detector enabled
- [ ] Manual FIM test passed (< 5 seconds)
- [ ] Brute force simulation successful
- [ ] All alerts visible in dashboard
- [ ] MITRE ATT&CK tags present
- [ ] Documentation completed

## 🎓 Key Learnings

By end of Week 2, you should understand:
- How FIM works and what to monitor
- XML decoder structure and field extraction
- Rule logic (frequency, timeframe, correlation)
- MITRE ATT&CK framework integration
- Vulnerability detection capabilities

## ⏭️ Next Week Preview

Week 3 will focus on:
- Active Response configuration
- Automated IP blocking scripts
- SSH brute force → firewall-drop automation
- Testing with Hydra tool
- Response verification

---

**Gate Check Criteria**: FIM alert must appear within 5 seconds of file modification before proceeding to Week 3.
