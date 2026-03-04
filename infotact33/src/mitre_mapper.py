"""
Sentient Shield - MITRE ATT&CK Mapper
Maps Wazuh alerts to MITRE ATT&CK framework
"""

import json
from typing import Dict, List
from mitreattack.stix20 import MitreAttackData

class MitreMapper:
    def __init__(self):
        self.mitre_data = MitreAttackData("enterprise-attack.json")
        
    def get_technique_details(self, technique_id: str) -> Dict:
        """Get detailed information about a MITRE technique"""
        technique = self.mitre_data.get_object_by_attack_id(technique_id, "attack-pattern")
        
        if not technique:
            return None
            
        return {
            "id": technique_id,
            "name": technique.get("name"),
            "description": technique.get("description"),
            "tactics": [phase["phase_name"] for phase in technique.get("kill_chain_phases", [])],
            "detection": technique.get("x_mitre_detection", ""),
            "platforms": technique.get("x_mitre_platforms", [])
        }
    
    def enrich_alert(self, alert: Dict) -> Dict:
        """Enrich Wazuh alert with MITRE ATT&CK context"""
        mitre_ids = alert.get("rule", {}).get("mitre", {}).get("id", [])
        
        if not mitre_ids:
            return alert
            
        mitre_details = []
        for technique_id in mitre_ids:
            details = self.get_technique_details(technique_id)
            if details:
                mitre_details.append(details)
        
        alert["mitre_enrichment"] = mitre_details
        return alert
