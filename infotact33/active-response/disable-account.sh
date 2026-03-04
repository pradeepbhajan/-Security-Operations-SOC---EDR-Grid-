#!/bin/bash
# Sentient Shield - Disable Account Active Response
# Disables user account after suspicious activity

ACTION=$1
USER=$2
IP=$3
ALERT_ID=$4
RULE_ID=$5

LOG_FILE="/var/ossec/logs/active-responses.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

disable_account() {
    local username=$1
    
    # Disable the account
    usermod -L "$username"
    
    if [ $? -eq 0 ]; then
        log_message "Successfully disabled account: $username (Rule ID: $RULE_ID)"
        
        # Kill all user sessions
        pkill -u "$username"
        
        # Send alert
        echo "Account $username has been disabled due to suspicious activity. Alert ID: $ALERT_ID" | \
            mail -s "Sentient Shield: Account Disabled" soc@infotact.com
        
        return 0
    else
        log_message "Failed to disable account: $username"
        return 1
    fi
}

enable_account() {
    local username=$1
    
    usermod -U "$username"
    
    if [ $? -eq 0 ]; then
        log_message "Successfully enabled account: $username"
        return 0
    else
        log_message "Failed to enable account: $username"
        return 1
    fi
}

case "$ACTION" in
    add)
        log_message "Disabling account: $USER (IP: $IP, Rule: $RULE_ID)"
        disable_account "$USER"
        ;;
    delete)
        log_message "Enabling account: $USER"
        enable_account "$USER"
        ;;
    *)
        log_message "Invalid action: $ACTION"
        exit 1
        ;;
esac

exit 0
