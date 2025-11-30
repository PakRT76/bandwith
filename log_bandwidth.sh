#!/bin/sh

LOG_FILE="/var/log/bandwidth.log"

# Get the current timestamp
timestamp=$(date +%s)

# Get the bandwidth usage for each device
/usr/bin/get_bandwidth.sh | while read -r line; do
    ip=$(echo $line | grep -o '"ip_address": "[^"]*' | grep -o '[^"]*$')
    bytes_in=$(echo $line | grep -o '"bytes_in": [^,]*' | grep -o '[^,]*$')
    bytes_out=$(echo $line | grep -o '"bytes_out": [^,]*' | grep -o '[^,]*$')

    if [ -n "$ip" ]; then
        echo "$timestamp,$ip,$bytes_in,$bytes_out" >> $LOG_FILE
    fi
done
