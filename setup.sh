#!/bin/sh

# This script initializes the bandwidth monitoring firewall rules and re-applies speed limits.

# Create the necessary iptables chains for bandwidth monitoring if they don't exist
iptables -N BW_IN 2>/dev/null
iptables -N BW_OUT 2>/dev/null

# Clear any previous rules from the chains to ensure a clean state
iptables -F BW_IN
iptables -F BW_OUT

# Add our custom chains to the main FORWARD chain if they aren't already there
iptables -C FORWARD -j BW_IN 2>/dev/null || iptables -I FORWARD -j BW_IN
iptables -C FORWARD -j BW_OUT 2>/dev/null || iptables -I FORWARD -j BW_OUT

# Note: Individual device rules are now added dynamically by the hotplug script.
# This script no longer needs to iterate through DHCP leases at boot.

# Re-apply any persistent speed limits from the volatile config file
# This is for limits set before a reboot.
CONFIG_FILE="/tmp/speed_limits"
if [ -f "$CONFIG_FILE" ]; then
    # Create a temporary copy to avoid issues with modifying the file while reading it
    TMP_CONFIG=$(mktemp)
    cp "$CONFIG_FILE" "$TMP_CONFIG"
    
    # Clear the original file before re-populating it
    > "$CONFIG_FILE"

    while read -r interface ip download upload; do
        # Re-apply the limit. The limit_speed script will re-create the entry in the config file.
        /usr/bin/limit_speed.sh "$interface" "$ip" "$download" "$upload"
    done < "$TMP_CONFIG"
    
    rm -f "$TMP_CONFIG"
fi
