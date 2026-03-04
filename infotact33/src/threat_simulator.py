"""
Sentient Shield - Threat Simulator
Simulates various attack scenarios for testing
"""

import subprocess
import time
from loguru import logger

class ThreatSimulator:
    
    @staticmethod
    def simulate_brute_force(target_ip: str, username: str = "admin", attempts: int = 10):
        """Simulate SSH brute force attack"""
        logger.info(f"Simulating brute force attack on {target_ip}")
        
        for i in range(attempts):
            try:
                cmd = f"sshpass -p 'wrongpassword{i}' ssh -o StrictHostKeyChecking=no {username}@{target_ip}"
                subprocess.run(cmd, shell=True, timeout=5, capture_output=True)
                time.sleep(1)
            except Exception as e:
                logger.debug(f"Attempt {i+1} failed: {e}")
        
        logger.info("Brute force simulation complete")
    
    @staticmethod
    def simulate_file_modification(file_path: str = "/tmp/test_fim.txt"):
        """Simulate file modification for FIM testing"""
        logger.info(f"Simulating file modification: {file_path}")
        
        with open(file_path, "w") as f:
            f.write("Test content for FIM detection\n")
        
        time.sleep(2)
        
        with open(file_path, "a") as f:
            f.write("Modified content - should trigger FIM alert\n")
        
        logger.info("File modification simulation complete")
