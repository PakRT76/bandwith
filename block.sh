#!/bin/sh

echo "Content-Type: text/plain"
echo ""

# Safely parse query string parameters
action=$(echo "$QUERY_STRING" | sed -n 's/.*action=\([^&]*\).*/\1/p')
mac=$(echo "$QUERY_STRING" | sed -n 's/.*mac=\([^&]*\).*/\1/p')

# Basic validation
if [ -z "$mac" ] || [ -z "$action" ]; then
    echo "Error: Missing mac or action parameter."
    exit 1
fi

# Further validation to prevent command injection
# Action should be either 'block' or 'unblock'
if [ "$action" != "block" ] && [ "$action" != "unblock" ]; then
    echo "Error: Invalid action."
    exit 1
fi

# MAC address should look like a MAC address
if ! echo "$mac" | grep -q -E '^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$'; then
    echo "Error: Invalid MAC address format."
    exit 1
fi

# Execute the script and output its response directly to the user
# Use absolute path
/usr/bin/block_user.sh "$action" "$mac"
