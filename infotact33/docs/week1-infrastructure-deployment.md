# Week 1: Infrastructure & Agent Deployment

## 🎯 Objectives
- Deploy Wazuh Manager on dedicated Linux server
- Deploy agents on test Windows Server and Linux Web Server
- Install Sysmon on Windows for deep process/network visibility
- Verify all agents are reporting "Active" status
- Send reliable heartbeat signals and initial logs

## 📋 Prerequisites Checklist

### Hardware Requirements
- [ ] Linux Server (Ubuntu 20.04/22.04 or CentOS 7+)
  - 4GB RAM minimum (8GB recommended)
  - 2 CPU cores (4 cores recommended)
  - 50GB disk space
  - Static IP address

- [ ] Test Windows Server (Windows Server 2016/2019/2022)
  - 2GB RAM minimum
  - Network connectivity to Wazuh Manager

- [ ] Test Linux Web Server (Ubuntu/CentOS)
  - 1GB RAM minimum
  - Apache/Nginx installed (for web server monitoring)

### Network Requirements
- [ ] Open ports on Wazuh Manager:
  - 1514 (TCP/UDP) - Agent communication
  - 1515 (TCP) - Agent enrollment
  - 55000 (TCP) - Wazuh API
  - 9200 (TCP) - Elasticsearch/OpenSearch
  - 443 (TCP) - Dashboard access

## 🚀 Day-by-Day Implementation

### Day 1-2: Wazuh Manager Installation

#### Step 1: Prepare Linux Server
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install curl apt-transport-https lsb-release gnupg -y

# Check system resources
free -h
df -h
```

#### Step 2: Install Wazuh All-in-One
```bash
# Download installation script
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh

# Run installation (installs Manager + Indexer + Dashboard)
sudo bash wazuh-install.sh -a

# Save the credentials displayed at the end!
# Example output:
# INFO: --- Summary ---
# INFO: You can access the web interface https://<wazuh-dashboard-ip>
#       User: admin
#       Password: <generated-password>
```

#### Step 3: Verify Installation
```bash
# Check Wazuh Manager status
sudo systemctl status wazuh-manager

# Check Wazuh Indexer
sudo systemctl status wazuh-indexer

# Check Dashboard
sudo systemctl status wazuh-dashboard

# View manager logs
sudo tail -f /var/ossec/logs/ossec.log
```

#### Step 4: Access Dashboard
1. Open browser: `https://<server-ip>`
2. Login with credentials from installation
3. Navigate to "Agents" section
4. Verify dashboard is accessible

### Day 3: Deploy Linux Agent (Web Server)

#### Step 1: Add Agent from Dashboard
1. Go to Dashboard → Agents → Deploy new agent
2. Select: Linux
3. Server address: `<wazuh-manager-ip>`
4. Copy the generated commands

#### Step 2: Install on Linux Web Server
```bash
# Add Wazuh repository
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

# Update and install
sudo apt update
sudo apt install wazuh-agent -y

# Configure manager IP
sudo sed -i "s/MANAGER_IP/<your-manager-ip>/g" /var/ossec/etc/ossec.conf

# Enable and start agent
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

# Check agent status
sudo systemctl status wazuh-agent
```

#### Step 3: Verify Agent Connection
```bash
# On Wazuh Manager
sudo /var/ossec/bin/agent_control -l

# Expected output:
# Wazuh agent_control. List of available agents:
#    ID: 001, Name: web-server-01, IP: 192.168.1.100, Active
```

### Day 4: Deploy Windows Agent

#### Step 1: Download Windows Agent
1. From Dashboard → Agents → Deploy new agent
2. Select: Windows
3. Download MSI installer

#### Step 2: Install on Windows Server
```powershell
# Run as Administrator
# Install agent
msiexec.exe /i wazuh-agent-4.7.0-1.msi /q WAZUH_MANAGER="<manager-ip>" WAZUH_REGISTRATION_SERVER="<manager-ip>"

# Start service
NET START WazuhSvc

# Check service status
Get-Service WazuhSvc
```

#### Step 3: Verify in Dashboard
- Go to Agents section
- Should see Windows agent with "Active" status
- Check "Last keep alive" timestamp

### Day 5: Install Sysmon on Windows

#### Step 1: Download Sysmon
```powershell
# Download Sysmon
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "$env:TEMP\Sysmon.zip"

# Extract
Expand-Archive -Path "$env:TEMP\Sysmon.zip" -DestinationPath "$env:TEMP\Sysmon" -Force
```

#### Step 2: Download Sysmon Config
```powershell
# Download SwiftOnSecurity config (industry standard)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "$env:TEMP\Sysmon\sysmonconfig.xml"
```

#### Step 3: Install Sysmon
```powershell
# Navigate to Sysmon directory
cd $env:TEMP\Sysmon

# Install with config
.\Sysmon64.exe -accepteula -i sysmonconfig.xml

# Verify installation
Get-Service Sysmon64
```

#### Step 4: Configure Wazuh to Read Sysmon Logs
```xml
<!-- Add to C:\Program Files (x86)\ossec-agent\ossec.conf -->
<localfile>
  <location>Microsoft-Windows-Sysmon/Operational</location>
  <log_format>eventchannel</log_format>
</localfile>
```

#### Step 5: Restart Wazuh Agent
```powershell
Restart-Service WazuhSvc
```

### Day 6-7: Verification & Testing

#### Gate Check Tasks

##### 1. Verify All Agents Active
```bash
# On Wazuh Manager
sudo /var/ossec/bin/agent_control -l

# Expected output:
# ID: 001, Name: web-server-01, IP: 192.168.1.100, Active
# ID: 002, Name: windows-server-01, IP: 192.168.1.101, Active
```

##### 2. Check Heartbeat Signals
- Dashboard → Agents
- Verify "Last keep alive" is recent (< 1 minute)
- Check "Status" shows green "Active"

##### 3. Verify Initial Logs
```bash
# Check alerts
sudo tail -f /var/ossec/logs/alerts/alerts.log

# Check archives (all logs)
sudo tail -f /var/ossec/logs/archives/archives.log
```

##### 4. Test Sysmon Visibility
On Windows, run:
```powershell
# Generate process creation event
notepad.exe

# Check Event Viewer
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5
```

In Wazuh Dashboard:
- Go to Security Events
- Filter: `data.win.system.channel: Microsoft-Windows-Sysmon/Operational`
- Should see process creation events (Event ID 1)

##### 5. Generate Test Alert
```bash
# On Linux agent - trigger SSH failed login
ssh wronguser@localhost

# On Windows - failed login attempt
# Try wrong password on RDP or local login
```

Check Dashboard for alerts within 5 seconds.

## 📊 Week 1 Deliverables

### Completed Infrastructure
- ✅ Wazuh Manager running and accessible
- ✅ Wazuh Dashboard accessible via HTTPS
- ✅ Linux agent deployed and active
- ✅ Windows agent deployed and active
- ✅ Sysmon installed and logging

### Documentation
- ✅ Server IP addresses and credentials (secure storage)
- ✅ Agent IDs and names
- ✅ Network diagram
- ✅ Installation logs

### Verification Screenshots
- [ ] Dashboard showing all agents active
- [ ] Sysmon events in dashboard
- [ ] Sample security alerts
- [ ] Agent status output

## 🔧 Troubleshooting

### Agent Not Connecting
```bash
# Check firewall
sudo ufw status
sudo ufw allow 1514/tcp
sudo ufw allow 1515/tcp

# Check agent logs
sudo tail -f /var/ossec/logs/ossec.log

# Restart agent
sudo systemctl restart wazuh-agent
```

### Sysmon Not Logging
```powershell
# Check Sysmon service
Get-Service Sysmon64

# Check Event Viewer
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 1

# Restart Wazuh agent
Restart-Service WazuhSvc
```

### Dashboard Not Accessible
```bash
# Check dashboard status
sudo systemctl status wazuh-dashboard

# Check logs
sudo tail -f /var/ossec/logs/wazuh-dashboard.log

# Restart dashboard
sudo systemctl restart wazuh-dashboard
```

## 📝 Week 1 Completion Checklist

- [ ] Wazuh Manager installed and running
- [ ] Dashboard accessible and credentials saved
- [ ] Linux agent deployed on web server
- [ ] Windows agent deployed on test server
- [ ] Sysmon installed on Windows
- [ ] All agents showing "Active" status
- [ ] Heartbeat signals confirmed (< 1 min)
- [ ] Initial logs visible in dashboard
- [ ] Sysmon events appearing in dashboard
- [ ] Test alerts generated successfully
- [ ] Documentation completed
- [ ] Screenshots captured

## 🎓 Key Learnings

By end of Week 1, you should understand:
- Wazuh architecture (Manager, Agent, Indexer, Dashboard)
- Agent enrollment process
- Log collection flow
- Sysmon event types
- Basic dashboard navigation

## 📚 Additional Resources

- [Wazuh Documentation](https://documentation.wazuh.com/)
- [Sysmon Documentation](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- [SwiftOnSecurity Sysmon Config](https://github.com/SwiftOnSecurity/sysmon-config)

## ⏭️ Next Week Preview

Week 2 will focus on:
- Writing custom detection rules
- Configuring FIM for sensitive directories
- Creating custom decoders for application logs
- Enabling Vulnerability Detector module

---

**Gate Check Criteria**: All agents must show "Active" status and send heartbeat signals before proceeding to Week 2.
