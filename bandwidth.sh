#!/bin/sh

echo "Content-Type: application/json"
echo ""

# Use absolute path to the backend script
/usr/bin/get_bandwidth.sh
