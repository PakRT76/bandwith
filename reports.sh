#!/bin/sh

echo "Content-Type: application/json"
echo ""

LOG_FILE="/var/log/bandwidth.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "[]"
    exit 0
fi

echo "["

first=true
while IFS=, read -r timestamp ip bytes_in bytes_out; do
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi

    echo "{"
    echo "\"timestamp\": $timestamp,"
    echo "\"ip_address\": \"$ip\","
    echo "\"bytes_in\": $bytes_in,"
    echo "\"bytes_out\": $bytes_out"
    echo "}"
done < "$LOG_FILE"

echo "]"
