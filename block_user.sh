#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <block|unblock> <mac_address>"
    exit 1
fi

ACTION=$1
MAC_ADDRESS=$2

# --- Input Validation ---
# Action must be 'block' or 'unblock'
if [ "$ACTION" != "block" ] && [ "$ACTION" != "unblock" ]; then
    echo "Error: Invalid action specified."
    exit 1
fi

# MAC address must be in the correct format to prevent injection
if ! echo "$MAC_ADDRESS" | grep -q -E '^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$'; then
    echo "Error: Invalid MAC address format."
    exit 1
fi
# --- End Validation ---

if [ "$ACTION" = "block" ]; then
    # Use -C to check if rule exists before adding to prevent duplicates
    iptables -C FORWARD -m mac --mac-source "$MAC_ADDRESS" -j DROP 2>/dev/null || iptables -I FORWARD -m mac --mac-source "$MAC_ADDRESS" -j DROP
    echo "Success: Blocked user with MAC address $MAC_ADDRESS"
elif [ "$ACTION" = "unblock" ]; then
    # Use -C to check if rule exists before deleting to prevent errors
    iptables -C FORWARD -m mac --mac-source "$MAC_ADDRESS" -j DROP 2>/dev/null && iptables -D FORWARD -m mac --mac-source "$MAC_ADDRESS" -j DROP
    echo "Success: Unblocked user with MAC address $MAC_ADDRESS"
fi
