"""
Test cases for MITRE ATT&CK Mapper
"""

import pytest
from src.mitre_mapper import MitreMapper

class TestMitreMapper:
    
    def setup_method(self):
        self.mapper = MitreMapper()
    
    def test_get_technique_details(self):
        """Test retrieving MITRE technique details"""
        details = self.mapper.get_technique_details("T1110.001")
        
        assert details is not None
        assert details["id"] == "T1110.001"
        assert "name" in details
        assert "tactics" in details
    
    def test_enrich_alert(self):
        """Test alert enrichment with MITRE data"""
        alert = {
            "rule": {
                "mitre": {
                    "id": ["T1110.001", "T1078"]
                }
            }
        }
        
        enriched = self.mapper.enrich_alert(alert)
        
        assert "mitre_enrichment" in enriched
        assert len(enriched["mitre_enrichment"]) == 2
