# Week 3: Active Response (IPS) - Detailed Guide

## Overview
Week 3 focuses on implementing automated response mechanisms that act as an Intrusion Prevention System (IPS). When threats are detected, the system automatically takes action to block or mitigate them.

## Learning Objectives
- Configure active response in Wazuh
- Implement automated IP blocking
- Set up account lockout mechanisms
- Test with real brute force attacks
- Validate response effectiveness

## Architecture

```
┌─────────────────────────────────────────────────┐
│           Wazuh Manager                         │
│  ┌──────────────────────────────────────────┐  │
│  │  Detection Engine                        │  │
│  │  (Rules from Week 2)                     │  │
│  └──────────────┬───────────────────────────┘  │
│                 │                                │
│                 ▼                                │
│  ┌──────────────────────────────────────────┐  │
│  │  Active Response Module                  │  │
│  │  - Trigger conditions                    │  │
│  │  - Response scripts                      │  │
│  │  - Timeout management                    │  │
│  └──────────────┬───────────────────────────┘  │
└─────────────────┼───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│           Target Agent                          │
│  ┌──────────────────────────────────────────┐  │
│  │  firewall-drop.sh                        │  │
│  │  - Block IP with iptables                │  │
│  │  - Auto-unblock after timeout            │  │
│  └──────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────┐  │
│  │  disable-account.sh                      │  │
│  │  - Lock user account                     │  │
│  │  - Kill active sessions                  │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

## Day 1: Active Response Configuration (15 minutes)

### Step 1: Configure Active Response on Manager

Edit `/var/ossec/etc/ossec.conf` on the Wazuh Manager:

```xml
<ossec_config>
  <!-- Active Response Configuration -->
  <command>
    <name>firewall-drop</name>
    <executable>firewall-drop.sh</executable>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <command>
    <name>disable-account</name>
    <executable>disable-account.sh</executable>
    <timeout_allowed>yes</timeout_allowed>
  </command>

  <!-- Response for SSH Brute Force -->
  <active-response>
    <command>firewall-drop</command>
    <location>local</location>
    <rules_id>100101</rules_id>
    <timeout>3600</timeout>
  </active-response>

  <!-- Response for Successful Login After Brute Force -->
  <active-response>
    <command>disable-account</command>
    <location>local</location>
    <rules_id>100102</rules_id>
    <timeout>7200</timeout>
  </active-response>

  <!-- Response for Password Spray Attack -->
  <active-response>
    <command>firewall-drop</command>
    <location>local</location>
    <rules_id>100103</rules_id>
    <timeout>3600</timeout>
  </active-response>
</ossec_config>
```

### Step 2: Deploy Response Scripts to Agents

```bash
# Copy scripts to Wazuh active-response directory
sudo cp active-response/firewall-drop.sh /var/ossec/active-response/bin/
sudo cp active-response/disable-account.sh /var/ossec/active-response/bin/

# Set permissions
sudo chmod 750 /var/ossec/active-response/bin/firewall-drop.sh
sudo chmod 750 /var/ossec/active-response/bin/disable-account.sh
sudo chown root:wazuh /var/ossec/active-response/bin/firewall-drop.sh
sudo chown root:wazuh /var/ossec/active-response/bin/disable-account.sh
```

### Step 3: Restart Wazuh Services

```bash
# Restart manager
sudo systemctl restart wazuh-manager

# Restart agent (on each monitored system)
sudo systemctl restart wazuh-agent
```

### Verification

```bash
# Check if active response is enabled
sudo grep -A 10 "active-response" /var/ossec/etc/ossec.conf

# Verify scripts are in place
ls -la /var/ossec/active-response/bin/ | grep -E "firewall-drop|disable-account"

# Check logs
sudo tail -f /var/ossec/logs/active-responses.log
```

## Day 2: Testing with Hydra (15 minutes)

### Step 1: Install Hydra (Attack Tool)

On a separate testing machine:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y hydra

# CentOS/RHEL
sudo yum install -y hydra
```

### Step 2: Create Test User on Target

On the monitored Linux server:

```bash
# Create test user
sudo useradd -m testuser
echo "testuser:ComplexPassword123!" | sudo chpasswd

# Verify user exists
id testuser
```

### Step 3: Launch Brute Force Attack

From the testing machine:

```bash
# Create password list
cat > passwords.txt << EOF
password
123456
admin
testuser
wrongpass1
wrongpass2
wrongpass3
wrongpass4
wrongpass5
EOF

# Launch SSH brute force attack
hydra -l testuser -P passwords.txt ssh://<target-ip> -t 4 -V

# This will trigger 5+ failed attempts within 5 minutes
```

### Step 4: Monitor Active Response

On the Wazuh Manager:

```bash
# Watch alerts in real-time
sudo tail -f /var/ossec/logs/alerts/alerts.log

# Watch active response log
sudo tail -f /var/ossec/logs/active-responses.log

# Check if IP is blocked
sudo iptables -L INPUT -n | grep <attacker-ip>
```

### Expected Behavior

1. **After 5 failed attempts**: Rule 100101 triggers
2. **Active response executes**: `firewall-drop.sh` blocks attacker IP
3. **Verification**:
   ```bash
   # IP should be in iptables
   sudo iptables -L INPUT -n -v
   
   # Log entry should show block
   sudo grep "Successfully blocked" /var/ossec/logs/active-responses.log
   ```

4. **After 1 hour**: IP automatically unblocked

## Day 3: Advanced Scenarios (15 minutes)

### Scenario 1: Account Lockout Test

```bash
# Simulate successful login after brute force
# This triggers rule 100102

# 1. First, trigger brute force (5 failed attempts)
# 2. Then login successfully
ssh testuser@<target-ip>

# Expected: Account gets locked automatically
```

### Scenario 2: Manual IP Block/Unblock

```bash
# Manual block
sudo /var/ossec/active-response/bin/firewall-drop.sh add - 192.168.1.100 - 100101

# Verify block
sudo iptables -L INPUT -n | grep 192.168.1.100

# Manual unblock
sudo /var/ossec/active-response/bin/firewall-drop.sh delete - 192.168.1.100 - -

# Verify unblock
sudo iptables -L INPUT -n | grep 192.168.1.100
```

### Scenario 3: Whitelist Configuration

Add to `/var/ossec/etc/ossec.conf`:

```xml
<ossec_config>
  <active-response>
    <disabled>no</disabled>
    <ca_store>/var/ossec/etc/lists/whitelist</ca_store>
  </active-response>
</ossec_config>
```

Create whitelist file:

```bash
# Create whitelist
sudo mkdir -p /var/ossec/etc/lists
sudo cat > /var/ossec/etc/lists/whitelist << EOF
192.168.1.10
10.0.0.5
172.16.0.100
EOF

# Restart manager
sudo systemctl restart wazuh-manager
```

## Gate Check Criteria

### ✅ Checklist

- [ ] Active response configured in `ossec.conf`
- [ ] Response scripts deployed to agents
- [ ] Hydra brute force test successful
- [ ] IP automatically blocked after 5 failed attempts
- [ ] Block appears in iptables within 10 seconds
- [ ] Active response log shows successful block
- [ ] IP automatically unblocked after timeout
- [ ] Account lockout working (optional)
- [ ] Whitelist configuration tested (optional)

### Verification Commands

```bash
# 1. Check active response configuration
sudo grep -A 5 "active-response" /var/ossec/etc/ossec.conf

# 2. Verify scripts exist
ls -la /var/ossec/active-response/bin/ | grep -E "firewall|disable"

# 3. Check recent blocks
sudo tail -20 /var/ossec/logs/active-responses.log

# 4. View current iptables rules
sudo iptables -L INPUT -n -v --line-numbers

# 5. Check alert correlation
sudo grep "100101" /var/ossec/logs/alerts/alerts.log | tail -5
```

### Success Metrics

| Metric | Target | Status |
|--------|--------|--------|
| Response Time | < 10 seconds | ⏱️ |
| Block Success Rate | 100% | 📊 |
| Auto-unblock | After 1 hour | ⏰ |
| False Positives | 0 | ✅ |
| Log Entries | Complete | 📝 |

## Troubleshooting

### Issue 1: Active Response Not Triggering

**Symptoms**: Brute force detected but no IP block

**Solutions**:
```bash
# Check if active response is enabled
sudo grep "active-response" /var/ossec/etc/ossec.conf

# Verify script permissions
ls -la /var/ossec/active-response/bin/firewall-drop.sh

# Check for errors
sudo grep "ERROR" /var/ossec/logs/ossec.log

# Restart services
sudo systemctl restart wazuh-manager
sudo systemctl restart wazuh-agent
```

### Issue 2: Script Execution Fails

**Symptoms**: Log shows "Failed to block IP"

**Solutions**:
```bash
# Test script manually
sudo /var/ossec/active-response/bin/firewall-drop.sh add - 1.2.3.4 - 100101

# Check iptables
sudo iptables -L INPUT -n

# Verify root permissions
sudo -l

# Check SELinux (if applicable)
sudo getenforce
sudo setenforce 0  # Temporary disable for testing
```

### Issue 3: IP Not Unblocking

**Symptoms**: IP remains blocked after timeout

**Solutions**:
```bash
# Check background processes
ps aux | grep firewall-drop

# Manual unblock
sudo /var/ossec/active-response/bin/firewall-drop.sh delete - <ip> - -

# Clear all blocks
sudo iptables -F INPUT

# Restart iptables
sudo systemctl restart iptables
```

### Issue 4: Hydra Test Not Working

**Symptoms**: Hydra fails to connect

**Solutions**:
```bash
# Verify SSH is running
sudo systemctl status sshd

# Check firewall rules
sudo iptables -L INPUT -n

# Test SSH manually
ssh testuser@<target-ip>

# Check SSH logs
sudo tail -f /var/log/auth.log  # Ubuntu
sudo tail -f /var/log/secure    # CentOS
```

## MITRE ATT&CK Mapping

| Technique | ID | Detection | Response |
|-----------|-----|-----------|----------|
| Brute Force | T1110.001 | Rule 100101 | firewall-drop |
| Valid Accounts | T1078 | Rule 100102 | disable-account |
| Password Spraying | T1110.003 | Rule 100103 | firewall-drop |

## Best Practices

### 1. Response Tuning
- Start with longer timeouts (1 hour)
- Monitor false positives
- Adjust thresholds based on environment

### 2. Whitelist Management
- Always whitelist admin IPs
- Document all whitelist entries
- Review whitelist monthly

### 3. Logging
- Enable detailed logging
- Rotate logs regularly
- Archive for compliance

### 4. Testing
- Test in non-production first
- Use dedicated test accounts
- Document all test results

### 5. Incident Response
- Create runbook for manual intervention
- Define escalation procedures
- Train SOC team on override process

## Next Steps

After completing Week 3:

1. ✅ Verify all gate check criteria
2. 📊 Review active response logs
3. 📈 Analyze false positive rate
4. 🎯 Proceed to Week 4: Threat Simulation

## Additional Resources

- [Wazuh Active Response Documentation](https://documentation.wazuh.com/current/user-manual/capabilities/active-response/)
- [iptables Tutorial](https://www.netfilter.org/documentation/)
- [Hydra Documentation](https://github.com/vanhauser-thc/thc-hydra)

---

**Week 3 Complete!** 🎉

You now have a fully functional IPS that automatically responds to threats.

