# 🛡️ Sentient Shield - Project Kya Hai? (Simple Explanation)

## 📖 **Is Project Mein Kya Ho Raha Hai?**

Yeh ek **Enterprise Security System** hai jo aapke servers aur computers ko hackers se bachata hai.

---

## 🎯 **Simple Mein Samjho**

### **Analogy: Security Guard System**

Socho aapke office mein ek security system hai:

1. **CCTV Cameras** = Wazuh Agents (har computer par)
2. **Control Room** = Wazuh Manager (central monitoring)
3. **Monitor Screen** = Wazuh Dashboard (web interface)
4. **Alert System** = Detection Rules (suspicious activity detect kare)
5. **Security Guards** = Active Response (automatic action le)

---

## 🏢 **Real World Example**

### **Problem:**
Infotact Solutions company ke servers par:
- Hackers password guess kar rahe hain (brute force)
- Important files change ho rahi hain
- Malware install ho raha hai
- Koi pata nahi chal raha

### **Solution: Sentient Shield**
Yeh system automatically:
- ✅ Har file change ko detect kare (5 seconds mein)
- ✅ Failed login attempts count kare
- ✅ Suspicious activity par alert bheje
- ✅ Hacker ka IP block kar de
- ✅ Sab kuch dashboard par dikhe

---

## 🔍 **Project Ke Main Components**

### **1. Wazuh Manager (दिमाग)**
```
Kya Karta Hai:
• Sab agents se data collect kare
• Rules apply kare
• Alerts generate kare
• Logs store kare

Example:
Agent: "Boss, kisi ne /etc/passwd file change ki!"
Manager: "Alert! Critical file modified!"
```

### **2. Wazuh Agents (आँखें)**
```
Kya Karte Hain:
• Har server/computer par install hote hain
• File changes monitor karte hain
• Login attempts track karte hain
• Logs manager ko bhejte hain

Example:
Agent Linux server par: "File /etc/passwd modified"
Agent Windows server par: "5 failed login attempts"
```

### **3. Wazuh Dashboard (स्क्रीन)**
```
Kya Karta Hai:
• Web browser mein khulta hai
• Real-time alerts dikhata hai
• Graphs aur charts dikhata hai
• Search aur filter karne deta hai

Example:
Browser mein: https://localhost
Login karke sab kuch visual dekho
```

### **4. Detection Rules (नियम)**
```
Kya Karte Hain:
• Define karte hain ki suspicious kya hai
• Alerts generate karte hain
• Severity level set karte hain

Example:
Rule: "Agar 5 failed login attempts in 5 minutes"
Action: "High severity alert generate karo"
```

### **5. Active Response (एक्शन)**
```
Kya Karta Hai:
• Automatic action leta hai
• IP block karta hai
• Account disable karta hai
• Services restart karta hai

Example:
Alert: "5 failed SSH login attempts from 192.168.1.100"
Response: "IP 192.168.1.100 ko 1 hour ke liye block karo"
```

---

## 📊 **Project Ka Flow - Step by Step**

### **Scenario: Hacker Attack**

```
Step 1: Hacker tries to login
├─ Hacker: ssh admin@server (wrong password)
├─ Hacker: ssh admin@server (wrong password)
├─ Hacker: ssh admin@server (wrong password)
├─ Hacker: ssh admin@server (wrong password)
└─ Hacker: ssh admin@server (wrong password) [5th attempt]

Step 2: Agent detects
├─ Agent: "5 failed login attempts detected"
└─ Agent: Sends log to Manager

Step 3: Manager processes
├─ Manager: Receives log
├─ Manager: Applies Rule #100101 (Brute Force Detection)
├─ Manager: Generates HIGH severity alert
└─ Manager: Triggers Active Response

Step 4: Active Response
├─ Response: Executes firewall-drop.sh
├─ Response: Blocks IP 192.168.1.100
└─ Response: Sends notification

Step 5: Dashboard shows
├─ Dashboard: Shows alert in real-time
├─ Dashboard: Shows MITRE ATT&CK tag: T1110.001
├─ Dashboard: Shows source IP, time, severity
└─ Dashboard: Shows response action taken

Step 6: Security Team
├─ Team: Sees alert on dashboard
├─ Team: Investigates source IP
├─ Team: Takes further action if needed
└─ Team: Documents incident
```

---

## 🎨 **Visual Representation**

```
┌─────────────────────────────────────────────────────────────┐
│                    SENTIENT SHIELD SYSTEM                   │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   Linux      │      │   Windows    │      │   Web        │
│   Server     │      │   Server     │      │   Server     │
│              │      │              │      │              │
│  [Agent 001] │      │  [Agent 002] │      │  [Agent 003] │
└──────┬───────┘      └──────┬───────┘      └──────┬───────┘
       │                     │                     │
       │ Logs                │ Logs                │ Logs
       │                     │                     │
       └─────────────────────┼─────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │ WAZUH MANAGER  │
                    │                │
                    │ • Collects     │
                    │ • Analyzes     │
                    │ • Alerts       │
                    │ • Responds     │
                    └────────┬───────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
                ▼            ▼            ▼
         ┌──────────┐ ┌──────────┐ ┌──────────┐
         │Dashboard │ │ Active   │ │  Logs    │
         │(Browser) │ │ Response │ │ Storage  │
         └──────────┘ └──────────┘ └──────────┘
              │
              ▼
      ┌───────────────┐
      │ Security Team │
      │  Monitoring   │
      └───────────────┘
```

---

## 🔐 **Real Examples - Kya Detect Hota Hai**

### **Example 1: File Integrity Monitoring (FIM)**

```
Scenario: Hacker ne important file change ki

Before:
/etc/passwd: "root:x:0:0:root:/root:/bin/bash"

Hacker Action:
echo "hacker:x:0:0:hacker:/root:/bin/bash" >> /etc/passwd

Detection:
⚠️  ALERT: Critical file /etc/passwd modified
    Time: 2026-02-12 14:30:45
    User: root
    Process: echo
    Severity: HIGH
    MITRE: T1098 (Account Manipulation)

Response:
✅ Alert sent to dashboard
✅ Email notification sent
✅ File change logged
✅ Backup created
```

### **Example 2: Brute Force Attack**

```
Scenario: Hacker password guess kar raha hai

Hacker Actions:
14:30:01 - ssh admin@server (password: admin123) ❌
14:30:05 - ssh admin@server (password: password) ❌
14:30:10 - ssh admin@server (password: 123456) ❌
14:30:15 - ssh admin@server (password: admin) ❌
14:30:20 - ssh admin@server (password: root) ❌

Detection:
⚠️  ALERT: SSH Brute Force Attack Detected
    Source IP: 192.168.1.100
    Failed Attempts: 5 in 5 minutes
    Target User: admin
    Severity: HIGH
    MITRE: T1110.001 (Password Guessing)

Response:
✅ IP 192.168.1.100 blocked for 1 hour
✅ Alert sent to dashboard
✅ Email notification sent
✅ Incident logged
```

### **Example 3: Ransomware Detection**

```
Scenario: Ransomware files encrypt kar raha hai

Ransomware Actions:
14:30:00 - document1.pdf → document1.pdf.encrypted
14:30:01 - document2.docx → document2.docx.encrypted
14:30:02 - photo1.jpg → photo1.jpg.encrypted
14:30:03 - video1.mp4 → video1.mp4.encrypted
[100+ files in 10 seconds]

Detection:
⚠️  ALERT: Ransomware Activity Detected
    Pattern: Multiple file extensions changed
    Files Affected: 100+
    Time Window: 10 seconds
    Process: unknown.exe
    Severity: CRITICAL
    MITRE: T1486 (Data Encrypted for Impact)

Response:
✅ Process killed immediately
✅ Network isolated
✅ Critical alert sent
✅ Backup restoration initiated
✅ Incident response team notified
```

---

## 📅 **Project Timeline - 4 Weeks**

### **Week 1: Infrastructure Setup (✅ COMPLETE)**
```
Kya Kiya:
• Wazuh Manager install kiya
• Wazuh Dashboard setup kiya
• Linux agents deploy kiye
• Windows agents deploy kiye
• Sysmon install kiya

Result:
✅ Central monitoring system ready
✅ Agents reporting to manager
✅ Dashboard accessible
✅ Basic monitoring active
```

### **Week 2: Detection Rules (✅ COMPLETE)**
```
Kya Kiya:
• File Integrity Monitoring (FIM) configure kiya
• 13 custom detection rules banaye
• Brute force detection setup kiya
• MITRE ATT&CK mapping kiya
• Vulnerability detector enable kiya

Result:
✅ Real-time file monitoring
✅ Brute force attacks detect ho rahe
✅ Web attacks detect ho rahe
✅ Vulnerability scanning active
✅ Alerts dashboard mein dikh rahe
```

### **Week 3: Active Response (🔜 PENDING)**
```
Kya Karna Hai:
• Automatic IP blocking setup
• Account disable on compromise
• Service restart on anomaly
• Custom response scripts
• 1-hour ban with auto-unblock

Expected Result:
✅ Automatic threat mitigation
✅ Reduced response time
✅ Less manual intervention
✅ Faster incident handling
```

### **Week 4: Threat Simulation (⏳ PENDING)**
```
Kya Karna Hai:
• Atomic Red Team integration
• Ransomware simulation
• Brute force testing
• Credential dumping test
• Kill chain visualization

Expected Result:
✅ Detection validation
✅ Response testing
✅ Performance metrics
✅ Final report
```

---

## 🎯 **Key Features - Kya Kya Kar Sakta Hai**

### **1. File Integrity Monitoring (FIM)**
```
Kya Hai:
Important files ko monitor karta hai

Kaise Kaam Karta Hai:
• Har 5 seconds mein files check kare
• Koi change ho to alert bheje
• Before/after comparison dikhe

Example:
Monitor: /etc/passwd, /etc/shadow, /var/www/html/
Alert: "File /etc/passwd modified by user root"
```

### **2. Brute Force Detection**
```
Kya Hai:
Password guessing attacks detect kare

Kaise Kaam Karta Hai:
• Failed login attempts count kare
• 5 attempts in 5 minutes = Alert
• Source IP track kare

Example:
5 failed SSH logins from 192.168.1.100
→ HIGH severity alert
→ IP blocked for 1 hour
```

### **3. MITRE ATT&CK Mapping**
```
Kya Hai:
Har attack ko standard framework se map kare

Kaise Kaam Karta Hai:
• Attack technique identify kare
• MITRE ID assign kare
• Kill chain visualize kare

Example:
Brute Force → T1110.001 (Password Guessing)
Ransomware → T1486 (Data Encrypted for Impact)
File Change → T1098 (Account Manipulation)
```

### **4. Vulnerability Detection**
```
Kya Hai:
System mein security holes find kare

Kaise Kaam Karta Hai:
• Installed packages scan kare
• CVE database se match kare
• Patch recommendations de

Example:
Found: OpenSSL 1.0.1 (vulnerable)
CVE: CVE-2014-0160 (Heartbleed)
Severity: CRITICAL
Fix: Update to OpenSSL 1.0.1g
```

### **5. Real-time Alerting**
```
Kya Hai:
Instant notifications bheje

Kaise Kaam Karta Hai:
• Event detect hote hi alert
• Dashboard mein real-time update
• Email/SMS notifications
• Severity-based prioritization

Example:
Event: Critical file modified
Alert: Instant (< 5 seconds)
Notification: Dashboard + Email
Priority: HIGH
```

---

## 💼 **Use Cases - Kahan Use Hota Hai**

### **Use Case 1: Banking Sector**
```
Problem:
• Customer data theft
• Unauthorized access
• Compliance requirements

Solution:
✅ Monitor all database access
✅ Detect unauthorized queries
✅ Alert on data exfiltration
✅ Compliance reporting
```

### **Use Case 2: E-commerce**
```
Problem:
• Website defacement
• Payment data theft
• DDoS attacks

Solution:
✅ Monitor web files
✅ Detect SQL injection
✅ Track failed logins
✅ Alert on suspicious traffic
```

### **Use Case 3: Healthcare**
```
Problem:
• Patient data breach
• HIPAA compliance
• Ransomware attacks

Solution:
✅ Monitor patient records
✅ Detect unauthorized access
✅ Alert on file encryption
✅ Compliance auditing
```

### **Use Case 4: Government**
```
Problem:
• Classified data leak
• Insider threats
• APT attacks

Solution:
✅ Monitor all file access
✅ Detect privilege escalation
✅ Track user activities
✅ Incident forensics
```

---

## 🔧 **Technical Architecture**

### **System Components:**

```
1. Data Collection Layer
   ├─ Wazuh Agents (on monitored systems)
   ├─ Syslog collectors
   ├─ API integrations
   └─ Custom log sources

2. Processing Layer
   ├─ Wazuh Manager (analysis engine)
   ├─ Rule engine
   ├─ Decoder engine
   └─ Correlation engine

3. Storage Layer
   ├─ Wazuh Indexer (Elasticsearch)
   ├─ Alert database
   ├─ Archive storage
   └─ Backup system

4. Presentation Layer
   ├─ Wazuh Dashboard (Kibana)
   ├─ REST API
   ├─ Mobile app
   └─ Email notifications

5. Response Layer
   ├─ Active response scripts
   ├─ Firewall integration
   ├─ SIEM integration
   └─ Ticketing system
```

---

## 📈 **Benefits - Kya Faida Hai**

### **Security Benefits:**
```
✅ 24/7 monitoring
✅ Real-time threat detection
✅ Automatic response
✅ Reduced attack surface
✅ Compliance adherence
```

### **Operational Benefits:**
```
✅ Centralized management
✅ Reduced manual work
✅ Faster incident response
✅ Better visibility
✅ Cost effective
```

### **Business Benefits:**
```
✅ Reduced downtime
✅ Protected reputation
✅ Customer trust
✅ Regulatory compliance
✅ Insurance benefits
```

---

## 📊 **Metrics - Kaise Measure Karein**

### **Detection Metrics:**
```
• Detection Rate: 95%+ (kitne attacks detect hue)
• False Positive Rate: <5% (galat alerts)
• Response Time: <5 seconds (alert kitni jaldi)
• Coverage: 100% (kitne systems monitor)
```

### **Performance Metrics:**
```
• Agent CPU Usage: <5%
• Agent Memory: <100MB
• Network Bandwidth: <1Mbps per agent
• Dashboard Load Time: <3 seconds
```

### **Business Metrics:**
```
• Incidents Prevented: Count
• Downtime Reduced: Hours saved
• Cost Savings: Money saved
• Compliance Score: Percentage
```

---

## 🎓 **Learning Path - Kaise Seekhein**

### **Beginner Level:**
```
1. Read START_HERE.md
2. Understand basic concepts
3. Install on test system
4. Explore dashboard
5. Create simple rules
```

### **Intermediate Level:**
```
1. Deploy in production
2. Configure custom rules
3. Set up active response
4. Integrate with SIEM
5. Tune for performance
```

### **Advanced Level:**
```
1. Develop custom decoders
2. Create complex correlations
3. Build custom integrations
4. Optimize at scale
5. Train security team
```

---

## 🚀 **Quick Start - Abhi Shuru Karo**

### **Option 1: Local Testing (Your Laptop)**
```bash
# Already installed hai!
# Dashboard access karo:
firefox https://localhost

# Login:
Username: admin
Password: Admin.123
```

### **Option 2: Production Server**
```bash
# Server par install karo:
1. Upload project to server
2. Run: sudo bash server-complete-setup.sh
3. Wait 30 minutes
4. Access: https://server-ip
```

---

## 📚 **Documentation Structure**

```
Essential Files:
├─ START_HERE.md              ← Start here!
├─ PROJECT_EXPLANATION_HINDI.md ← This file
├─ IMPLEMENTATION_GUIDE.md    ← Complete guide
├─ QUICK_REFERENCE.md         ← Quick commands
├─ PROJECT_STATUS.md          ← Current progress
├─ CHECKLIST.md               ← Task tracking
└─ README.md                  ← Project overview

Detailed Docs:
├─ docs/week1-quick-start.md
├─ docs/week2-quick-start.md
├─ docs/week1-infrastructure-deployment.md
└─ docs/week2-detection-rules.md

Scripts:
├─ scripts/week1-infrastructure-setup.sh
├─ scripts/week2-deploy-custom-rules.sh
├─ scripts/week2-configure-fim.sh
└─ scripts/week2-test-detection.sh
```

---

## 🎯 **Summary - Ek Line Mein**

**Sentient Shield ek automated security system hai jo aapke servers ko 24/7 monitor karta hai, hackers ko detect karta hai, aur automatically unhe block kar deta hai - sab kuch real-time dashboard mein dikhta hai!**

---

## 💡 **Key Takeaways**

```
1. Yeh ek Security Monitoring System hai
2. Real-time mein threats detect karta hai
3. Automatic response leta hai
4. Dashboard mein sab visual dikhta hai
5. MITRE ATT&CK framework use karta hai
6. Production-ready hai
7. Scalable hai (100s of servers)
8. Open source hai (free!)
```

---

## 🎉 **Conclusion**

Sentient Shield aapke organization ko cyber attacks se bachane ke liye ek complete solution hai. Yeh:

- ✅ **Detect** karta hai threats ko
- ✅ **Alert** karta hai security team ko
- ✅ **Respond** karta hai automatically
- ✅ **Report** karta hai compliance ke liye
- ✅ **Protect** karta hai 24/7

**Ab aap samajh gaye ho ki yeh project kya hai aur kaise kaam karta hai!** 🚀

---

**Questions? Padho:**
- START_HERE.md - Getting started
- IMPLEMENTATION_GUIDE.md - Detailed guide
- QUICK_REFERENCE.md - Quick commands

**Ready to use? Run:**
```bash
firefox https://localhost
# Login: admin / Admin.123
```

