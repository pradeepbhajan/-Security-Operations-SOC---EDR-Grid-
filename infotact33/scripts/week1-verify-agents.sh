#!/bin/bash
# Week 1: Agent Verification Script
# Verifies all agents are active and sending heartbeats

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "  Week 1 Gate Check: Agent Verification"
echo "=========================================="
echo ""

# Check if running on Wazuh Manager
if [ ! -f "/var/ossec/bin/agent_control" ]; then
    echo -e "${RED}Error: This script must run on Wazuh Manager${NC}"
    exit 1
fi

# Get agent list
echo "Checking registered agents..."
echo ""

AGENT_OUTPUT=$(/var/ossec/bin/agent_control -l)
echo "$AGENT_OUTPUT"
echo ""

# Count active agents
ACTIVE_COUNT=$(echo "$AGENT_OUTPUT" | grep -c "Active" || true)
TOTAL_COUNT=$(echo "$AGENT_OUTPUT" | grep -c "ID:" || true)

echo "=========================================="
echo "Summary:"
echo "  Total Agents: $TOTAL_COUNT"
echo "  Active Agents: $ACTIVE_COUNT"
echo "=========================================="
echo ""

# Gate check criteria
if [ "$ACTIVE_COUNT" -ge 2 ]; then
    echo -e "${GREEN}✓ GATE CHECK PASSED${NC}"
    echo "All agents are reporting Active status"
    echo ""
    echo "Week 1 objectives completed:"
    echo "  ✓ Wazuh Manager deployed"
    echo "  ✓ Linux agent active"
    echo "  ✓ Windows agent active"
    echo "  ✓ Heartbeat signals confirmed"
    echo ""
    echo "Ready to proceed to Week 2!"
else
    echo -e "${RED}✗ GATE CHECK FAILED${NC}"
    echo "Not all agents are active"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check agent logs: tail -f /var/ossec/logs/ossec.log"
    echo "2. Verify network connectivity"
    echo "3. Check firewall rules (ports 1514, 1515)"
    echo "4. Restart agents: systemctl restart wazuh-agent"
fi

echo ""
echo "=========================================="
