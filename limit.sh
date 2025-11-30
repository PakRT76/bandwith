#!/bin/sh

echo "Content-Type: text/plain"
echo ""

# Safely parse query string parameters
ip=$(echo "$QUERY_STRING" | sed -n 's/.*ip=\([^&]*\).*/\1/p')
download=$(echo "$QUERY_STRING" | sed -n 's/.*download=\([^&]*\).*/\1/p')
upload=$(echo "$QUERY_STRING" | sed -n 's/.*upload=\([^&]*\).*/\1/p')

# Basic validation
if [ -z "$ip" ] || [ -z "$download" ] || [ -z "$upload" ]; then
    echo "Error: Missing ip, download, or upload parameter."
    exit 1
fi

# Further validation
# IP address should be a valid IP address
if ! echo "$ip" | grep -q -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
    echo "Error: Invalid IP address format."
    exit 1
fi

# Download and upload should be numbers
if ! echo "$download" | grep -q -E '^[0-9]+$'; then
    echo "Error: Invalid download speed."
    exit 1
fi

if ! echo "$upload" | grep -q -E '^[0-9]+$'; then
    echo "Error: Invalid upload speed."
    exit 1
fi

# Get the LAN interface
interface=$(/usr/bin/get_lan_interface.sh)

# Execute the script and output its response directly
# Use absolute path
/usr/bin/limit_speed.sh "$interface" "$ip" "$download" "$upload"
