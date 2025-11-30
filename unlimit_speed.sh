#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <interface> <ip_address>"
    exit 1
fi

INTERFACE=$1
IP_ADDRESS=$2
CONFIG_FILE="/tmp/speed_limits" # Moved from /etc/config

# --- Input Validation ---
if ! echo "$INTERFACE" | grep -q -E '^[a-zA-Z0-9\.\-\_]+$'; then
    echo "Error: Invalid interface name format."
    exit 1
fi
if ! echo "$IP_ADDRESS" | grep -q -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
    echo "Error: Invalid IP address format."
    exit 1
fi
# --- End Validation ---

# Find the classid associated with the IP address
if [ -f "$CONFIG_FILE" ]; then
    CLASSID=$(grep "$IP_ADDRESS" "$CONFIG_FILE" | awk '{print $5}')
fi

if [ -n "$CLASSID" ]; then
    # Remove tc rules for download and upload
    tc filter del dev "$INTERFACE" protocol ip parent 1:0 prio 1 u32 match ip dst "$IP_ADDRESS/32" 2>/dev/null
    tc class del dev "$INTERFACE" parent 1:1 classid "1:$CLASSID" 2>/dev/null
    tc filter del dev "$INTERFACE" parent ffff: protocol ip prio 50 u32 match ip src "$IP_ADDRESS/32" 2>/dev/null

    # Remove the entry from the configuration file
    sed -i "/$IP_ADDRESS/d" "$CONFIG_FILE"
    echo "Success: Removed speed limit for $IP_ADDRESS"
else
    echo "Info: No speed limit found for $IP_ADDRESS"
fi
