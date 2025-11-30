#!/bin/sh

echo "Content-Type: text/plain"
echo ""

# Safely parse query string parameters
ip=$(echo "$QUERY_STRING" | sed -n 's/.*ip=\([^&]*\).*/\1/p')

# Basic validation
if [ -z "$ip" ]; then
    echo "Error: Missing ip parameter."
    exit 1
fi

# Further validation
# IP address should be a valid IP address
if ! echo "$ip" | grep -q -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
    echo "Error: Invalid IP address format."
    exit 1
fi

# Get the LAN interface
interface=$(/usr/bin/get_lan_interface.sh)

# Execute the script and output its response directly
# Use absolute path
/usr/bin/unlimit_speed.sh "$interface" "$ip"
