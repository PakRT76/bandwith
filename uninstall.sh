#!/bin/sh

echo "This script will remove the OpenWRT Bandwidth Monitor."
read -p "Are you sure you want to continue? [y/N] " confirm
if [ "$confirm" != "y" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Remove web files
rm -rf /www/cgi-bin/bandwidth.sh
rm -rf /www/cgi-bin/block.sh
rm -rf /www/cgi-bin/limit.sh
rm -rf /www/cgi-bin/reports.sh
rm -rf /www/cgi-bin/unlimit.sh
rm -rf /www/index.html
rm -rf /www/style.css
rm -rf /www/app.js
rm -rf /www/echarts.min.js

# Remove scripts
rm -rf /usr/bin/get_bandwidth.sh
rm -rf /usr/bin/block_user.sh
rm -rf /usr/bin/limit_speed.sh
rm -rf /usr/bin/setup.sh
rm -rf /usr/bin/check_alerts.sh
rm -rf /usr/bin/log_bandwidth.sh
rm -rf /usr/bin/unlimit_speed.sh
rm -rf /usr/bin/get_lan_interface.sh
rm -rf /usr/bin/dhcp_hotplug.sh

# Remove hotplug script
rm -f /etc/hotplug.d/dhcp/90-bw-monitor

# Remove configuration and log files
rm -f /tmp/speed_limits
rm -f /etc/config/bandwidth_monitor
rm -f /var/log/bandwidth.log
rm -f /var/log/bandwidth_alerts.log

# Remove from startup
sed -i '/\/usr\/bin\/setup.sh/d' /etc/rc.local

# Remove cron jobs
sed -i '/\/usr\/bin\/check_alerts.sh/d' /etc/crontabs/root
sed -i '/\/usr\/bin\/log_bandwidth.sh/d' /etc/crontabs/root

# Remove uhttpd authentication settings using UCI
uci -q delete uhttpd.main.realm
uci -q delete uhttpd.main.basic_user
uci commit uhttpd

# Restart uhttpd
/etc/init.d/uhttpd restart

echo "Uninstallation complete."
