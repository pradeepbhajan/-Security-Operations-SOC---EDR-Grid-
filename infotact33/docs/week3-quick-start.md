# Week 3: Active Response - Quick Start Guide

## ⚡ Quick Setup (30 minutes)

### Prerequisites
- ✅ Week 1 & 2 completed
- ✅ Wazuh Manager running
- ✅ At least one agent active
- ✅ Custom rules deployed

---

## Step 1: Configure Active Response (5 minutes)

```bash
# Run automated configuration script
sudo bash scripts/week3-configure-active-response.sh

# This script will:
# - Add active response configuration to ossec.conf
# - Deploy response scripts to agents
# - Set correct permissions
# - Restart services
```

---

## Step 2: Verify Configuration (2 minutes)

```bash
# Check configuration
sudo grep -A 10 "active-response" /var/ossec/etc/ossec.conf

# Verify scripts
ls -la /var/ossec/active-response/bin/ | grep -E "firewall|disable"

# Check services
sudo systemctl status wazuh-manager
sudo systemctl status wazuh-agent
```

---

## Step 3: Test with Brute Force (10 minutes)

### On Testing Machine:

```bash
# Install Hydra
sudo apt-get install -y hydra

# Create password list
cat > /tmp/passwords.txt << EOF
password
123456
admin
wrong1
wrong2
wrong3
wrong4
wrong5
EOF

# Launch attack (replace <target-ip> with your monitored server)
hydra -l testuser -P /tmp/passwords.txt ssh://<target-ip> -t 4 -V
```

### On Wazuh Manager:

```bash
# Watch real-time alerts
sudo tail -f /var/ossec/logs/alerts/alerts.log

# Watch active response
sudo tail -f /var/ossec/logs/active-responses.log
```

---

## Step 4: Verify IP Block (3 minutes)

```bash
# Check if attacker IP is blocked
sudo iptables -L INPUT -n | grep <attacker-ip>

# View active response log
sudo grep "Successfully blocked" /var/ossec/logs/active-responses.log

# Check recent alerts
sudo grep "100101" /var/ossec/logs/alerts/alerts.log | tail -5
```

---

## Step 5: Gate Check (5 minutes)

```bash
# Run automated gate check
sudo bash scripts/week3-gate-check.sh

# Expected output:
# ✅ Active response configured
# ✅ Scripts deployed
# ✅ IP blocking working
# ✅ Auto-unblock scheduled
# ✅ Logs complete
```

---

## Quick Commands Reference

### Monitor Active Response
```bash
# Real-time monitoring
sudo tail -f /var/ossec/logs/active-responses.log

# View all blocks today
sudo grep "blocked IP" /var/ossec/logs/active-responses.log | grep "$(date +%Y-%m-%d)"

# Count total blocks
sudo grep -c "Successfully blocked" /var/ossec/logs/active-responses.log
```

### Manual IP Management
```bash
# Block IP manually
sudo /var/ossec/active-response/bin/firewall-drop.sh add - 192.168.1.100 - 100101

# Unblock IP manually
sudo /var/ossec/active-response/bin/firewall-drop.sh delete - 192.168.1.100 - -

# View all blocked IPs
sudo iptables -L INPUT -n -v | grep DROP
```

### Troubleshooting
```bash
# Check for errors
sudo grep "ERROR" /var/ossec/logs/ossec.log | tail -20

# Restart services
sudo systemctl restart wazuh-manager
sudo systemctl restart wazuh-agent

# Test script manually
sudo /var/ossec/active-response/bin/firewall-drop.sh add - 1.2.3.4 - 100101
```

---

## Expected Results

### After Brute Force Attack:

1. **Alert Generated** (Rule 100101)
   ```
   Rule: 100101 (level 10) -> 'SSH Brute Force Attack Detected'
   Src IP: <attacker-ip>
   ```

2. **Active Response Triggered**
   ```
   Successfully blocked IP: <attacker-ip> (Rule ID: 100101)
   ```

3. **IP Blocked in iptables**
   ```bash
   $ sudo iptables -L INPUT -n
   Chain INPUT (policy ACCEPT)
   DROP       all  --  <attacker-ip>  0.0.0.0/0
   ```

4. **Auto-unblock Scheduled**
   ```
   IP will be unblocked after 3600 seconds (1 hour)
   ```

---

## Gate Check Criteria

- ✅ Active response configured in ossec.conf
- ✅ Response scripts deployed with correct permissions
- ✅ Brute force attack triggers rule 100101
- ✅ IP automatically blocked within 10 seconds
- ✅ Block visible in iptables
- ✅ Active response log shows successful block
- ✅ Auto-unblock scheduled for 1 hour

---

## Common Issues & Quick Fixes

### Issue: Active Response Not Triggering
```bash
# Check configuration
sudo grep "active-response" /var/ossec/etc/ossec.conf

# Restart services
sudo systemctl restart wazuh-manager
```

### Issue: Script Permission Denied
```bash
# Fix permissions
sudo chmod 750 /var/ossec/active-response/bin/firewall-drop.sh
sudo chown root:wazuh /var/ossec/active-response/bin/firewall-drop.sh
```

### Issue: IP Not Blocking
```bash
# Test manually
sudo /var/ossec/active-response/bin/firewall-drop.sh add - 1.2.3.4 - 100101

# Check iptables
sudo iptables -L INPUT -n
```

---

## Next Steps

After completing Week 3:

1. ✅ Run gate check: `sudo bash scripts/week3-gate-check.sh`
2. 📊 Review logs and metrics
3. 🎯 Proceed to Week 4: Threat Simulation

---

## Time Breakdown

- Configuration: 5 minutes
- Verification: 2 minutes
- Testing: 10 minutes
- Validation: 3 minutes
- Gate Check: 5 minutes
- Buffer: 5 minutes

**Total: 30 minutes**

---

## Success Indicators

✅ Brute force attack detected  
✅ IP automatically blocked  
✅ Block appears in iptables  
✅ Response logged correctly  
✅ Auto-unblock scheduled  
✅ No false positives  
✅ All gate checks passed  

---

**Week 3 Complete!** 🎉

Your EDR now has automated threat response capabilities!

