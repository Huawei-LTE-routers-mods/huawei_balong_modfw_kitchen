These scripts setup TUN/TAP Masquerading (NAT), disable access FROM VPN TO LAN and FROM VPN TO ROUTER SERVICES, and handle OpenVPN pushed DNS servers.
Use them from OpenVPN client configuration file with --up and --down directives.

Proper setup is as follows:

script-security 2
up /system/bin/openvpn_scripts/client.up
down /system/bin/openvpn_scripts/client.down
up-restart

NOTE!: Do not use persist-tun option in your configuration file!

If you want to add OpenVPN into /etc/autorun.sh startup script, run it as follows:
LD_LIBRARY_PATH=/app/lib:/system/lib:/system/lib/glibc /system/bin/openvpn

See also: /app/bin/[o]led_hijack/net.{down,up}, to trigger OpenVPN reconnection on network change.

NOTE!: Do not delete "ip" symlink in this folder, it's required for OpenVPN.
