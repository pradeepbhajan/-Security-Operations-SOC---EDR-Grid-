"""
Sentient Shield - Wazuh API Client
Interacts with Wazuh Manager API
"""

import requests
from typing import Dict, List
import os
from dotenv import load_dotenv

load_dotenv()

class WazuhAPIClient:
    def __init__(self):
        self.host = os.getenv("WAZUH_MANAGER_HOST", "localhost")
        self.port = os.getenv("WAZUH_MANAGER_PORT", "55000")
        self.user = os.getenv("WAZUH_API_USER", "admin")
        self.password = os.getenv("WAZUH_API_PASSWORD")
        self.protocol = os.getenv("WAZUH_API_PROTOCOL", "https")
        self.base_url = f"{self.protocol}://{self.host}:{self.port}"
        self.token = None
        
    def authenticate(self):
        """Authenticate and get JWT token"""
        url = f"{self.base_url}/security/user/authenticate"
        response = requests.post(
            url,
            auth=(self.user, self.password),
            verify=False
        )
        self.token = response.json()["data"]["token"]
        return self.token
    
    def get_agents(self) -> List[Dict]:
        """Get all registered agents"""
        if not self.token:
            self.authenticate()
            
        url = f"{self.base_url}/agents"
        headers = {"Authorization": f"Bearer {self.token}"}
        response = requests.get(url, headers=headers, verify=False)
        return response.json()["data"]["affected_items"]
    
    def get_alerts(self, limit: int = 100) -> List[Dict]:
        """Get recent alerts"""
        if not self.token:
            self.authenticate()
            
        url = f"{self.base_url}/alerts"
        headers = {"Authorization": f"Bearer {self.token}"}
        params = {"limit": limit, "sort": "-timestamp"}
        response = requests.get(url, headers=headers, params=params, verify=False)
        return response.json()["data"]["affected_items"]
