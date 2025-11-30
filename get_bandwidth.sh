#!/bin/sh

# Get the list of connected devices
devices=$(cat /tmp/dhcp.leases | awk '{print $3}')

echo "["

first=true
# Get the bandwidth usage for each device
for ip in $devices
do
  if [ "$first" = true ]; then
    first=false
  else
    echo ","
  fi

  # Get the incoming and outgoing bytes for the device
  bytes_in=$(iptables -L BW_IN -v -n -x | grep $ip | awk '{print $2}')
  bytes_out=$(iptables -L BW_OUT -v -n -x | grep $ip | awk '{print $2}')

  if [ -z "$bytes_in" ]; then
    bytes_in=0
  fi

  if [ -z "$bytes_out" ]; then
    bytes_out=0
  fi

  mac_address=$(cat /tmp/dhcp.leases | grep $ip | awk '{print $2}')

  echo "{"
  echo "\"ip_address\": \"$ip\","
  echo "\"mac_address\": \"$mac_address\","
  echo "\"bytes_in\": $bytes_in,"
  echo "\"bytes_out\": $bytes_out"
  echo "}"
done

echo "]"
