#!/bin/sh

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <interface> <ip_address> <download_speed_mbps> <upload_speed_mbps>"
    exit 1
fi

INTERFACE=$1
IP_ADDRESS=$2
DOWNLOAD_SPEED=$3
UPLOAD_SPEED=$4
CONFIG_FILE="/tmp/speed_limits" # Moved from /etc/config

# --- Input Validation ---
# Interface name should be a simple string (e.g., br-lan, eth0)
if ! echo "$INTERFACE" | grep -q -E '^[a-zA-Z0-9\.\-\_]+$'; then
    echo "Error: Invalid interface name format."
    exit 1
fi
# IP address must be a valid IPv4 address
if ! echo "$IP_ADDRESS" | grep -q -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
    echo "Error: Invalid IP address format."
    exit 1
fi
# Download and upload speeds must be integers
if ! echo "$DOWNLOAD_SPEED" | grep -q -E '^[0-9]+$'; then
    echo "Error: Invalid download speed. Must be an integer."
    exit 1
fi
if ! echo "$UPLOAD_SPEED" | grep -q -E '^[0-9]+$'; then
    echo "Error: Invalid upload speed. Must be an integer."
    exit 1
fi
# --- End Validation ---

# First, remove any existing limit for this IP to prevent conflicts
/usr/bin/unlimit_speed.sh "$INTERFACE" "$IP_ADDRESS"

# Determine the next available class ID for traffic shaping
if [ -f "$CONFIG_FILE" ]; then
    LAST_CLASSID=$(awk '{print $5}' "$CONFIG_FILE" | sort -n | tail -n 1)
    if [ -z "$LAST_CLASSID" ]; then
        CLASSID=10
    else
        CLASSID=$((LAST_CLASSID + 1))
    fi
else
    CLASSID=10
fi

# Set up the root HTB qdisc if it doesn't exist
if ! tc qdisc show dev "$INTERFACE" | grep -q "htb 1:"; then
    tc qdisc add dev "$INTERFACE" root handle 1: htb default 10
    tc class add dev "$INTERFACE" parent 1: classid 1:1 htb rate 1000mbit
fi

# Add the new class and filter for the specified IP address (Download)
tc class add dev "$INTERFACE" parent 1:1 classid "1:$CLASSID" htb rate "${DOWNLOAD_SPEED}mbit"
tc filter add dev "$INTERFACE" protocol ip parent 1:0 prio 1 u32 match ip dst "$IP_ADDRESS/32" flowid "1:$CLASSID"

# Set up the ingress qdisc if it doesn't exist
if ! tc qdisc show dev "$INTERFACE" | grep -q "ingress ffff:"; then
    tc qdisc add dev "$INTERFACE" handle ffff: ingress
fi

# Add the ingress filter for the specified IP address (Upload)
tc filter add dev "$INTERFACE" parent ffff: protocol ip prio 50 u32 match ip src "$IP_ADDRESS/32" police rate "${UPLOAD_SPEED}mbit" burst 1m drop flowid :1

# Save the settings to the volatile configuration file
echo "$INTERFACE $IP_ADDRESS $DOWNLOAD_SPEED $UPLOAD_SPEED $CLASSID" >> "$CONFIG_FILE"

echo "Success: Speed limit applied for $IP_ADDRESS."
