#!/bin/sh

# Copy the web files to the uhttpd document root
cp -r www/* /www/

# Copy the scripts to a system-wide location
cp -r scripts/* /usr/bin/

# Make the scripts executable
chmod +x /usr/bin/get_bandwidth.sh
chmod +x /usr/bin/block_user.sh
chmod +x /usr/bin/limit_speed.sh
chmod +x /usr/bin/setup.sh
chmod +x /usr/bin/unlimit_speed.sh
chmod +x /usr/bin/get_lan_interface.sh
chmod +x /usr/bin/check_alerts.sh
chmod +x /usr/bin/log_bandwidth.sh

# Install the hotplug script
cp scripts/dhcp_hotplug.sh /etc/hotplug.d/dhcp/90-bw-monitor
chmod +x /etc/hotplug.d/dhcp/90-bw-monitor

# Make the cgi scripts executable
chmod +x /www/cgi-bin/bandwidth.sh
chmod +x /www/cgi-bin/block.sh
chmod +x /www/cgi-bin/limit.sh

# Run the setup script to initialize the iptables rules
/usr/bin/setup.sh

# Add the setup script to the system startup
echo "/usr/bin/setup.sh" >> /etc/rc.local

# Add a cron job to check for alerts
echo "*/10 * * * * /usr/bin/check_alerts.sh" >> /etc/crontabs/root

# Add a cron job to log bandwidth usage
echo "*/5 * * * * /usr/bin/log_bandwidth.sh" >> /etc/crontabs/root

# Copy the bandwidth_monitor configuration file
cp config/bandwidth_monitor /etc/config/bandwidth_monitor

# Configure uhttpd for basic authentication using UCI
uci -q delete uhttpd.main.realm
uci set uhttpd.main.realm='OpenWRT Bandwidth Monitor'

# Check if htpasswd is installed
if ! command -v htpasswd >/dev/null 2>&1; then
    echo "Error: htpasswd is not installed. Please install it by running 'opkg update && opkg install apache2-utils' and then run this script again."
    exit 1
fi

# Prompt the user to set a password
echo "Please set a username and password for the web interface."
read -p "Username: " username
read -s -p "Password: " password
echo ""
password_hash=$(htpasswd -n -b "$username" "$password" | cut -d ':' -f 2)

# Use UCI to add the user. This is idempotent and safe.
uci -q delete uhttpd.main.basic_user
uci add_list uhttpd.main.basic_user="$username:$password_hash"

# Commit the changes to the uhttpd configuration
uci commit uhttpd

# Restart uhttpd to apply the new configuration
/etc/init.d/uhttpd restart

echo "Installation complete. Open your browser and navigate to http://<router-ip>/"
