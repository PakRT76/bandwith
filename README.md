# OpenWRT Bandwidth Monitor

A comprehensive bandwidth monitoring and management tool for OpenWRT routers.

## Features

- Real-time bandwidth monitoring
- User blocking
- Speed limiting
- Web-based user interface
- Alerts and notifications
- Logging and reporting

## Installation

1.  **Clone the repository:**
    ```
    git clone https://github.com/PakRT76/bandwith.git
    ```
2.  **Copy the project to your router:**
    ```
    scp -r openwrt-bandwidth-monitor root@<router-ip>:/root/
    ```
3.  **Connect to your router and run the installation script:**
    ```
    ssh root@<router-ip>
    cd /root/openwrt-bandwidth-monitor
    sh install.sh
    ```

## Configuration

-   **Alerts:** The alert threshold can be configured by editing the `THRESHOLD` variable in the `/usr/bin/check_alerts.sh` script. The default threshold is 1GB.
-   **Web Interface:** The web interface can be accessed by navigating to `http://<router-ip>/` in your web browser.
-   **Speed Limits:** Speed limits are stored in `/tmp/speed_limits` and are **not persistent** across reboots. This is by design to prevent excessive wear on the router's flash storage.

## Security

-   **Change the default router password:** It is highly recommended to change the default password for your OpenWRT router.
-   **Restrict access to the web interface:** You can use the OpenWRT firewall to restrict access to the web interface. For example, you can create a rule that only allows access from a specific IP address or a local network.
-   **Secure the cgi-bin scripts:** The cgi-bin scripts are a potential security risk. It is recommended to configure uhttpd to only allow access to the cgi-bin scripts from a specific IP address or a local network.
