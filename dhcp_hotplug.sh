#!/bin/sh

# This hotplug script is triggered when a DHCP lease is assigned.
# $1 = action (add, old, del)
# $2 = MAC address
# $3 = IP address
# $4 = Hostname

# We only care about new leases ('add' or 'old' actions)
if [ "$1" = "add" ] || [ "$1" = "old" ]; then
    IP_ADDRESS=$3
    
    # Check if the bandwidth monitoring chains exist
    iptables -L BW_IN >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        # Chains don't exist, maybe setup.sh hasn't run. Exit gracefully.
        exit 0
    fi

    # Add iptables rules for the new IP address if they don't already exist
    # This ensures devices that connect after boot are monitored.
    iptables -C BW_IN -s "$IP_ADDRESS" -j RETURN 2>/dev/null || iptables -A BW_IN -s "$IP_ADDRESS" -j RETURN
    iptables -C BW_OUT -d "$IP_ADDRESS" -j RETURN 2>/dev/null || iptables -A BW_OUT -d "$IP_ADDRESS" -j RETURN
fi

exit 0
