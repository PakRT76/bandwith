#!/bin/sh

# Source the configuration file
if [ -f "/etc/config/bandwidth_monitor" ]; then
    . "/etc/config/bandwidth_monitor"
else
    # Set a default threshold if the config file doesn't exist
    THRESHOLD=1073741824
fi

# Log file for alerts
ALERT_LOG="/var/log/bandwidth_alerts.log"

# Get the bandwidth usage for each device
/usr/bin/get_bandwidth.sh | while read -r line; do
    ip=$(echo $line | grep -o '"ip_address": "[^"]*' | grep -o '[^"]*$')
    bytes_in=$(echo $line | grep -o '"bytes_in": [^,]*' | grep -o '[^,]*$')

    if [ -n "$ip" ] && [ "$bytes_in" -gt "$THRESHOLD" ]; then
        echo "$(date): User with IP $ip has exceeded the bandwidth threshold of $THRESHOLD bytes. Current usage: $bytes_in bytes." >> $ALERT_LOG
    fi
done
