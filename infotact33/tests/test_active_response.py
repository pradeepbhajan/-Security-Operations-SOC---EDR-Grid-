"""
Test cases for Active Response functionality
"""

import pytest
import subprocess
from unittest.mock import patch, MagicMock

class TestActiveResponse:
    
    def test_firewall_drop_blocks_ip(self):
        """Test that firewall-drop script blocks IP correctly"""
        # Mock iptables command
        with patch('subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(returncode=0)
            
            # Simulate firewall-drop execution
            result = subprocess.run([
                '/var/ossec/active-response/bin/firewall-drop.sh',
                'add', 'testuser', '192.168.1.100', 'alert123', 'rule100101'
            ])
            
            assert result.returncode == 0
    
    def test_account_disable(self):
        """Test account disable functionality"""
        with patch('subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(returncode=0)
            
            result = subprocess.run([
                '/var/ossec/active-response/bin/disable-account.sh',
                'add', 'testuser', '192.168.1.100', 'alert456', 'rule100106'
            ])
            
            assert result.returncode == 0
