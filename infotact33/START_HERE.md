# 🛡️ Sentient Shield - START HERE

## Welcome to Sentient Shield EDR Project!

This is your **complete guide** to implementing an Enterprise EDR & Threat Hunting Grid for Infotact Solutions.

---

## 📖 Read These Files First

### 1️⃣ **START_HERE.md** ← You are here!
Quick orientation and navigation guide

### 2️⃣ **IMPLEMENTATION_GUIDE.md** 📘
**MOST IMPORTANT FILE** - Complete master guide with:
- Full project structure
- Week-by-week implementation
- All commands and configurations
- Troubleshooting guide
- 60+ pages of detailed documentation

### 3️⃣ **QUICK_REFERENCE.md** ⚡
Fast command reference for daily use:
- One-line commands
- Quick tests
- Essential file locations
- Emergency procedures

### 4️⃣ **PROJECT_STATUS.md** 📊
Current project status:
- Progress tracking (50% complete)
- Week-by-week completion status
- File inventory
- Next steps

### 5️⃣ **README.md** 📄
Project overview and introduction

---

## 🚀 Quick Start (Choose Your Path)

### Path A: Complete Implementation (Recommended)
**Time**: 2-3 hours total

1. **Week 1** (30 min): Infrastructure Setup
   ```bash
   # Read this first
   cat docs/week1-quick-start.md
   
   # Then run
   sudo bash scripts/week1-infrastructure-setup.sh
   ```

2. **Week 2** (45 min): Detection Rules
   ```bash
   # Read this first
   cat docs/week2-quick-start.md
   
   # Then run
   sudo bash scripts/week2-deploy-custom-rules.sh
   ```

3. **Week 3** (30 min): Active Response - Coming Soon
4. **Week 4** (60 min): Threat Simulation - Coming Soon

### Path B: Just Exploring
1. Read `IMPLEMENTATION_GUIDE.md` for full understanding
2. Browse `docs/` folder for detailed guides
3. Check `scripts/` folder for automation

### Path C: Quick Demo
```bash
# See what's available
ls -la scripts/week*.sh

# Check project structure
tree -L 2

# Read quick reference
cat QUICK_REFERENCE.md
```

---

## 📁 Project Structure Overview

```
sentient-shield/
│
├── 📘 START_HERE.md                    ← You are here
├── 📘 IMPLEMENTATION_GUIDE.md          ← Master guide (READ THIS!)
├── ⚡ QUICK_REFERENCE.md               ← Command cheatsheet
├── 📊 PROJECT_STATUS.md                ← Progress tracking
├── 📄 README.md                        ← Project overview
│
├── 📁 docs/                            ← Detailed Documentation
│   ├── week1-infrastructure-deployment.md
│   ├── week1-quick-start.md
│   ├── week2-detection-rules.md
│   ├── week2-quick-start.md
│   └── ... (9 more files)
│
├── 📁 scripts/                         ← Automation Scripts
│   ├── week1-infrastructure-setup.sh
│   ├── week1-deploy-linux-agent.sh
│   ├── week1-install-sysmon-windows.ps1
│   ├── week1-verify-agents.sh
│   ├── week2-deploy-custom-rules.sh
│   ├── week2-configure-fim.sh
│   ├── week2-enable-vulnerability-detector.sh
│   ├── week2-test-detection.sh
│   └── week2-gate-check.sh
│
├── 📁 rules/                           ← Detection Rules
│   ├── custom_brute_force_rules.xml
│   └── custom_fim_rules.xml
│
├── 📁 decoders/                        ← Log Parsers
│   └── custom_decoders.xml
│
├── 📁 active-response/                 ← Automated Actions
│   ├── firewall-drop.sh
│   └── disable-account.sh
│
├── 📁 agents/                          ← Agent Configs
├── 📁 config/                          ← Manager Config
├── 📁 src/                             ← Python Modules
├── 📁 tests/                           ← Test Cases
└── ... (more folders)
```

---

## 🎯 What This Project Does

### Core Features

1. **File Integrity Monitoring (FIM)**
   - Real-time monitoring of critical files
   - Alert within 5 seconds of changes
   - Tracks `/etc/passwd`, Windows System32, etc.

2. **Brute Force Detection**
   - Detects 5 failed login attempts in 5 minutes
   - SSH, RDP, Web application protection
   - MITRE ATT&CK T1110 mapping

3. **Active Response** (Week 3)
   - Automatic IP blocking
   - Account disable on compromise
   - 1-hour ban with auto-unblock

4. **MITRE ATT&CK Mapping**
   - 13 custom detection rules
   - Technique IDs: T1110, T1486, T1055, etc.
   - Kill chain visualization

5. **Vulnerability Detection**
   - Automated CVE scanning
   - Ubuntu, Windows, Red Hat support
   - Patch recommendations

---

## ✅ Current Status

```
✅ Week 1: Infrastructure & Agents     - COMPLETE
✅ Week 2: Detection Rules             - COMPLETE
🔜 Week 3: Active Response             - READY TO START
⏳ Week 4: Threat Simulation           - PENDING

Overall Progress: 50% ████████████░░░░░░░░░░
```

---

## 🎓 Learning Path

### Beginner
1. Start with `README.md`
2. Read `docs/week1-quick-start.md`
3. Follow Week 1 implementation
4. Explore dashboard

### Intermediate
1. Read `IMPLEMENTATION_GUIDE.md`
2. Complete Week 1 & 2
3. Customize detection rules
4. Test with real scenarios

### Advanced
1. Review all documentation
2. Complete all 4 weeks
3. Develop custom rules
4. Integrate with SIEM

---

## 🔧 Prerequisites

### Hardware
- Linux server (Ubuntu 20.04+)
- 4GB RAM minimum (8GB recommended)
- 2 CPU cores (4 recommended)
- 50GB disk space

### Software
- Ubuntu/CentOS for manager
- Windows Server for testing
- Python 3.8+
- Basic Linux/Windows admin skills

### Network
- Static IP for manager
- Ports: 1514, 1515, 55000, 443, 9200
- Internet access for updates

---

## 📞 Getting Help

### Documentation
1. **IMPLEMENTATION_GUIDE.md** - Complete reference
2. **QUICK_REFERENCE.md** - Quick commands
3. **docs/** folder - Detailed guides

### Troubleshooting
- Check `IMPLEMENTATION_GUIDE.md` → Troubleshooting section
- Review logs: `/var/ossec/logs/ossec.log`
- Run verification scripts

### External Resources
- [Wazuh Documentation](https://documentation.wazuh.com/)
- [MITRE ATT&CK](https://attack.mitre.org/)
- [Sysmon Guide](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)

---

## 🎯 Next Steps

### If You're Just Starting
```bash
# 1. Read the master guide
cat IMPLEMENTATION_GUIDE.md

# 2. Check prerequisites
# - Linux server ready?
# - Root access?
# - Network configured?

# 3. Start Week 1
cat docs/week1-quick-start.md
sudo bash scripts/week1-infrastructure-setup.sh
```

### If You Completed Week 1
```bash
# 1. Verify Week 1
sudo bash scripts/week1-verify-agents.sh

# 2. Start Week 2
cat docs/week2-quick-start.md
sudo bash scripts/week2-deploy-custom-rules.sh
```

### If You Completed Week 2
```bash
# 1. Verify Week 2
sudo bash scripts/week2-gate-check.sh

# 2. Wait for Week 3 implementation
# (Active Response - Coming Soon)
```

---

## 📊 Project Metrics

- **Total Files**: 46+
- **Scripts**: 11 automation scripts
- **Rules**: 13 custom detection rules
- **Documentation**: 13 comprehensive guides
- **Setup Time**: 2-3 hours total
- **Completion**: 50% (Week 1 & 2 done)

---

## 🏆 What You'll Learn

### Technical Skills
- ✅ Wazuh EDR deployment
- ✅ Linux/Windows administration
- ✅ Bash/PowerShell scripting
- ✅ XML rule development
- ✅ Log analysis
- ✅ MITRE ATT&CK framework
- ✅ Security monitoring
- ✅ Incident detection

### Security Concepts
- ✅ File Integrity Monitoring
- ✅ Brute force detection
- ✅ Active response mechanisms
- ✅ Threat hunting
- ✅ Kill chain analysis
- ✅ Vulnerability management

---

## 🎬 Ready to Start?

### Option 1: Quick Start (Recommended)
```bash
# Read this first (5 minutes)
cat IMPLEMENTATION_GUIDE.md | less

# Then start Week 1 (30 minutes)
sudo bash scripts/week1-infrastructure-setup.sh
```

### Option 2: Detailed Study
```bash
# Read all documentation first
ls docs/*.md

# Then proceed with implementation
```

### Option 3: Explore First
```bash
# Browse the project
tree -L 2

# Check what's available
ls -la scripts/
ls -la rules/
ls -la docs/
```

---

## 📝 Important Notes

1. **Always read documentation before running scripts**
2. **Backup configurations before making changes**
3. **Test in non-production environment first**
4. **Follow gate checks before proceeding to next week**
5. **Keep credentials secure** (`/root/wazuh-credentials.txt`)

---

## 🚀 Let's Begin!

**Your journey starts here:**

1. ✅ You've read START_HERE.md
2. 📘 Next: Read IMPLEMENTATION_GUIDE.md
3. ⚡ Keep: QUICK_REFERENCE.md handy
4. 🎯 Start: Week 1 implementation

```bash
# Open the master guide
cat IMPLEMENTATION_GUIDE.md

# Or start immediately
sudo bash scripts/week1-infrastructure-setup.sh
```

---

**Good luck with your Sentient Shield implementation! 🛡️**

---

**Project**: Sentient Shield  
**Organization**: Infotact Solutions - CDOC  
**Status**: Week 2 Complete (50%)  
**Last Updated**: $(date)
