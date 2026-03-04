#!/bin/bash
# Sentient Shield - Firewall Drop Active Response
# Automatically blocks source IP after brute force detection

# Get parameters from Wazuh
ACTION=$1
USER=$2
IP=$3
ALERT_ID=$4
RULE_ID=$5

# Log file
LOG_FILE="/var/ossec/logs/active-responses.log"

# Ban duration (1 hour = 3600 seconds)
BAN_DURATION=3600

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to block IP using iptables
block_ip() {
    local ip=$1
    
    # Check if IP is already blocked
    if iptables -L INPUT -n | grep -q "$ip"; then
        log_message "IP $ip is already blocked"
        return 0
    fi
    
    # Block the IP
    iptables -I INPUT -s "$ip" -j DROP
    
    if [ $? -eq 0 ]; then
        log_message "Successfully blocked IP: $ip (Rule ID: $RULE_ID, Alert ID: $ALERT_ID)"
        
        # Send notification
        echo "BLOCKED: $ip at $(date)" | mail -s "Sentient Shield: IP Blocked" soc@infotact.com
        
        # Schedule unblock after BAN_DURATION
        (sleep $BAN_DURATION && /var/ossec/active-response/bin/firewall-drop.sh delete - "$ip" - -) &
        
        return 0
    else
        log_message "Failed to block IP: $ip"
        return 1
    fi
}

# Function to unblock IP
unblock_ip() {
    local ip=$1
    
    # Remove the block rule
    iptables -D INPUT -s "$ip" -j DROP 2>/dev/null
    
    if [ $? -eq 0 ]; then
        log_message "Successfully unblocked IP: $ip"
        return 0
    else
        log_message "Failed to unblock IP: $ip (may not be blocked)"
        return 1
    fi
}

# Main logic
case "$ACTION" in
    add)
        log_message "Received block request for IP: $IP (User: $USER, Rule: $RULE_ID)"
        block_ip "$IP"
        ;;
    delete)
        log_message "Received unblock request for IP: $IP"
        unblock_ip "$IP"
        ;;
    *)
        log_message "Invalid action: $ACTION"
        exit 1
        ;;
esac

exit 0
