# Sentient Shield — Project Presentation

## 1. सारांश
Sentient Shield एक Enterprise EDR और Threat Hunting समाधान है, जिसे Infotact Solutions के Cyber Defense Operations Center (CDOC) के लिए बनाया गया है। यह सिस्टम फ़ाइल इंटीग्रिटी मॉनिटरिंग (FIM), सक्रिय प्रतिक्रिया (Active Response), MITRE ATT&CK मैपिंग और Threat Simulation (Atomic Red Team) प्रदान करता है।

## 2. उद्देश्य
- Endpoint पर तेज़ और सटीक डिटेक्शन।
- अनधिकृत फ़ाइल परिवर्तनों पर त्वरित अलर्ट और स्वचालित रिलेएस।
- SOC टीम के लिए MITRE ATT&CK-आधारित समृद्ध संदर्भ।

## 3. प्रमुख विशेषताएँ
- File Integrity Monitoring (FIM)
- Active Response (firewall blocking, remediation scripts)
- MITRE ATT&CK mapping और enrichment
- Threat Simulation (Atomic Red Team integration)

## 4. आर्किटेक्चर (संक्षेप)
- Central: Wazuh Manager — लॉग कलेक्शन और विश्लेषण
- Endpoints: Linux / Windows Agents
- Visibility: Sysmon (Windows)
- Storage & Visualization: Elasticsearch + Kibana/OpenSearch

## 5. मुख्य मॉड्यूल और फायली
- Python मॉड्यूल: `src/mitre_mapper.py`, `src/threat_simulator.py`, `src/wazuh_api_client.py`
- Active response स्क्रिप्ट्स: `active-response/` (उदा. `firewall-drop.sh`)
- डैशबोर्ड: `dashboards/kibana-dashboard.json`
- Custom rules & decoders: `rules/`, `decoders/custom_decoders.xml`
- Deployment स्क्रिप्ट्स: `scripts/` (week1-* and अन्य)

## 6. तैनाती और प्रारम्भिक सेटअप (Quick start)
1) Dependencies इंस्टॉल:

```bash
python3 -m pip install -r requirements.txt
```

2) इनफ्रास्ट्रक्चर सेटअप (तेज़ तैनाती):

```bash
sudo bash scripts/week1-infrastructure-setup.sh
sudo bash scripts/week1-deploy-linux-agent.sh <MANAGER_IP>
# Windows agent के लिए PowerShell/Installer निर्देश README में मौजूद हैं
```

3) वेरिफाई एजेंट्स:

```bash
sudo bash scripts/week1-verify-agents.sh
```

## 7. डेमो स्टेप्स (प्रस्तुति के लिए)
1. Wazuh Manager UI खोलें और लाइव अलर्ट दिखाएँ।
2. FIM अलर्ट जेनरेट करें: किसी सुरक्षित फ़ाइल में छोटे परिवर्तन करके अलर्ट ट्रिगर दिखाएँ।
3. Brute-force simulation चलाएँ और `active-response/firewall-drop.sh` के द्वारा ऑटो ब्लॉक दिखाएँ।
4. MITRE मैपिंग: किसी अलर्ट को `src/mitre_mapper.py` के साथ enrich करके दिखाएँ।
5. Threat Simulation: `threat-simulation/atomic-red-team-tests.yml` से एक सीनारियो चलाएँ और डिटेक्शन दिखाएँ।

## 8. परीक्षण
- यूनिट/इंटीग्रेशन टेस्ट चलाएँ:

```bash
python3 -m pytest -q
```

## 9. प्रस्तुति स्लाइड (सुझाव)
- स्लाइड 1: Project Title + Short Tagline
- स्लाइड 2: Problem Statement (Why EDR needed)
- स्लाइड 3: Architecture Diagram (high-level)
- स्लाइड 4: Key Capabilities (FIM, Active Response, MITRE)
- स्लाइड 5: Live Demo steps (short bullets)
- स्लाइड 6: Results / Next Steps / Roadmap

## 10. उपयोगी संदर्भ (डॉक्स)
- Quick start और week-wise गाइड: `docs/week1-quick-start.md`, `docs/week2-quick-start.md`
- Detection rules: `rules/` और `decoders/custom_decoders.xml`

## 11. संपर्क
Project Lead: Infotact Solutions - CDOC

---

यदि आप चाहें तो मैं इस `PRESENTATION.md` को स्लाइड्स (PowerPoint/Google Slides) के लिए एक छोटा नोट या English संस्करण भी बना दूँ।