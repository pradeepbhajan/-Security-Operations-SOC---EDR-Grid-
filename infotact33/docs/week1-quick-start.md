# Week 1 Quick Start Guide

## 🚀 Fast Track Installation (30 Minutes)

### Prerequisites
- Ubuntu 20.04/22.04 server with root access
- Minimum 4GB RAM, 2 CPU cores, 50GB disk
- Static IP address

### Step 1: Install Wazuh Manager (10 minutes)

```bash
# SSH into your server
ssh root@your-server-ip

# Run automated setup
cd /path/to/sentient-shield
sudo bash scripts/week1-infrastructure-setup.sh
```

This script will:
- ✅ Check system requirements
- ✅ Install Wazuh Manager, Indexer, and Dashboard
- ✅ Configure firewall rules
- ✅ Generate completion report

**Save the credentials displayed at the end!**

### Step 2: Access Dashboard (2 minutes)

1. Open browser: `https://your-server-ip`
2. Accept SSL warning (self-signed certificate)
3. Login with credentials from installation
4. You should see the Wazuh Dashboard

### Step 3: Deploy Linux Agent (5 minutes)

On your Linux web server:

```bash
# Download and run agent deployment script
curl -O https://your-repo/scripts/week1-deploy-linux-agent.sh
sudo bash week1-deploy-linux-agent.sh <wazuh-manager-ip>
```

Verify in Dashboard:
- Go to **Agents** section
- Should see your Linux agent with "Active" status

### Step 4: Deploy Windows Agent (5 minutes)

On your Windows Server (PowerShell as Administrator):

```powershell
# Download agent
$url = "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.0-1.msi"
Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\wazuh-agent.msi"

# Install
msiexec.exe /i "$env:TEMP\wazuh-agent.msi" /q WAZUH_MANAGER="<manager-ip>"

# Start service
NET START WazuhSvc
```

### Step 5: Install Sysmon (5 minutes)

On Windows Server (PowerShell as Administrator):

```powershell
# Download and run Sysmon installation script
$url = "https://your-repo/scripts/week1-install-sysmon-windows.ps1"
Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\install-sysmon.ps1"
& "$env:TEMP\install-sysmon.ps1"
```

### Step 6: Verify Everything (3 minutes)

On Wazuh Manager:

```bash
# Run verification script
sudo bash scripts/week1-verify-agents.sh
```

Expected output:
```
✓ GATE CHECK PASSED
All agents are reporting Active status

Week 1 objectives completed:
  ✓ Wazuh Manager deployed
  ✓ Linux agent active
  ✓ Windows agent active
  ✓ Heartbeat signals confirmed

Ready to proceed to Week 2!
```

## 🎯 Gate Check Criteria

Before moving to Week 2, verify:

- [ ] Dashboard accessible at `https://your-server-ip`
- [ ] At least 2 agents showing "Active" status
- [ ] Last keep alive < 1 minute for all agents
- [ ] Sysmon events visible in dashboard
- [ ] Can generate test alerts

## 🧪 Quick Test

Generate a test alert:

**Linux:**
```bash
# Failed SSH login
ssh wronguser@localhost
```

**Windows:**
```powershell
# Failed login attempt
runas /user:wronguser cmd
```

Check Dashboard → Security Events within 5 seconds.

## 📊 What You Should See

### Dashboard Overview
- Total agents: 2+
- Active agents: 2+
- Recent alerts: Multiple
- System status: All green

### Agent Details
Each agent should show:
- Status: Active (green)
- Last keep alive: < 1 minute ago
- OS: Linux/Windows
- Version: 4.7.0

### Sysmon Events
Filter: `data.win.system.channel: Microsoft-Windows-Sysmon/Operational`

Should see:
- Event ID 1: Process Creation
- Event ID 3: Network Connection
- Event ID 11: File Creation

## 🔧 Common Issues

### Issue: Dashboard not accessible
```bash
# Check service
sudo systemctl status wazuh-dashboard

# Restart
sudo systemctl restart wazuh-dashboard

# Check firewall
sudo ufw allow 443/tcp
```

### Issue: Agent not connecting
```bash
# Check agent logs
sudo tail -f /var/ossec/logs/ossec.log

# Verify manager IP in config
grep MANAGER_IP /var/ossec/etc/ossec.conf

# Restart agent
sudo systemctl restart wazuh-agent
```

### Issue: Sysmon not logging
```powershell
# Check service
Get-Service Sysmon64

# Check events
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5

# Restart Wazuh agent
Restart-Service WazuhSvc
```

## 📝 Completion Checklist

- [ ] Wazuh Manager installed
- [ ] Dashboard accessible
- [ ] Linux agent deployed and active
- [ ] Windows agent deployed and active
- [ ] Sysmon installed on Windows
- [ ] All agents sending heartbeats
- [ ] Test alerts generated successfully
- [ ] Credentials saved securely
- [ ] Verification script passed

## ⏭️ Next Steps

Once Week 1 is complete:
1. Review [Week 2 Documentation](week2-detection-rules.md)
2. Prepare for FIM configuration
3. Plan custom rule development

---

**Estimated Time**: 30-45 minutes total
**Difficulty**: Beginner
**Support**: See [Troubleshooting Guide](week1-infrastructure-deployment.md#troubleshooting)
