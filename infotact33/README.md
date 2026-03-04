ha# Sentient Shield - Enterprise EDR & Threat Hunting Grid

## Overview
Enterprise-grade Endpoint Detection and Response (EDR) system for Security Operations Center (SOC). Built for Infotact Solutions' Cyber Defense Operations Center (CDOC).

## Product Features

### 1. File Integrity Monitoring (FIM)
- Real-time monitoring of critical system files
- Instant alerting on unauthorized modifications
- Tracks changes to `/etc/passwd`, Windows System32, and other critical paths

### 2. Active Response (IPS)
- Automated remediation actions
- Firewall-based IP blocking after failed login attempts
- Configurable response scripts for various threat scenarios

### 3. MITRE ATT&CK Mapping
- Correlates security alerts to adversary tactics and techniques
- Enriches raw alerts with MITRE framework context
- Identifies patterns like T1055 (Process Injection), T1003 (Credential Dumping)

### 4. Threat Simulation
- Atomic Red Team integration for testing
- Ransomware attack pattern simulation
- Kill chain visualization

## Architecture
```
┌─────────────────┐
│  Wazuh Manager  │ ← Central Management & Analysis
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│ Linux │ │Windows│ ← Agents on Endpoints
│ Agent │ │ Agent │
└───────┘ └───────┘
         │
    ┌────▼────┐
    │ Sysmon  │ ← Deep Process/Network Visibility
    └─────────┘
```

## Tech Stack
- **Wazuh**: Open-source EDR platform
- **Sysmon**: Windows system monitoring
- **Elasticsearch**: Log storage and analysis
- **Kibana/OpenSearch**: Visualization and dashboards
- **Python**: Custom scripts and automation
- **Atomic Red Team**: Threat simulation framework

## Project Timeline

### Week 1: Infrastructure & Agent Deployment
- Deploy Wazuh Manager on dedicated Linux server
- Deploy agents on test Windows/Linux servers
- Install Sysmon for deep visibility

### Week 2: Detection Rules (The Logic)
- Configure FIM for sensitive directories
- Write custom XML decoders and rules
- Enable Vulnerability Detector module

### Week 3: Active Response (IPS)
- Configure active-response scripts
- Implement SSH brute force → firewall-drop automation
- Test automated blocking mechanisms

### Week 4: Threat Simulation
- Use Atomic Red Team for ransomware simulation
- Visualize kill chain in Kibana/OpenSearch
- Validate detection and response capabilities

## Getting Started

### 🚀 Quick Start (30 Minutes)

Follow the [Week 1 Quick Start Guide](docs/week1-quick-start.md) for rapid deployment.

**TL;DR:**
```bash
# 1. Install Wazuh Manager
sudo bash scripts/week1-infrastructure-setup.sh

# 2. Deploy Linux Agent
sudo bash scripts/week1-deploy-linux-agent.sh <manager-ip>

# 3. Deploy Windows Agent (PowerShell)
msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER="<manager-ip>"

# 4. Install Sysmon (PowerShell)
.\scripts\week1-install-sysmon-windows.ps1

# 5. Verify
sudo bash scripts/week1-verify-agents.sh
```

### 📚 Detailed Guides

- **Week 1**: [Infrastructure & Agent Deployment](docs/week1-infrastructure-deployment.md) | [Quick Start](docs/week1-quick-start.md)
- **Week 2**: [Detection Rules (The Logic)](docs/week2-detection-rules.md) | [Quick Start](docs/week2-quick-start.md)
- **Week 3**: Active Response (Coming Soon)
- **Week 4**: Threat Simulation (Coming Soon)

### Prerequisites
- Linux server (Ubuntu 20.04+ or CentOS 7+)
- Windows Server for testing
- Python 3.8+
- Minimum 4GB RAM, 2 CPU cores, 50GB disk

## Directory Structure
```
sentient-shield/
├── agents/              # Agent configurations
├── rules/               # Custom detection rules
├── decoders/            # Log parsing decoders
├── active-response/     # Automated response scripts
├── dashboards/          # Kibana/OpenSearch dashboards
├── threat-simulation/   # Atomic Red Team scenarios
├── scripts/             # Automation scripts
├── docs/                # Documentation
└── tests/               # Testing framework
```

## Documentation
- [Installation Guide](docs/installation.md)
- [FIM Configuration](docs/fim-setup.md)
- [Active Response Guide](docs/active-response.md)
- [MITRE ATT&CK Mapping](docs/mitre-mapping.md)
- [Threat Simulation](docs/threat-simulation.md)

## License
Proprietary - Infotact Solutions

## Contact
Infotact Solutions - Cyber Defense Operations Center (CDOC)
