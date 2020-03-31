#!/system/bin/busybox sh

mkdir bin
ln -s /system/lib /lib
ln -s /system/bin/sh /bin/sh
ln -s /system/bin/busybox /bin/ash
ln -s /system/xbin/atc.sh /sbin/atc
# For OpenVPN
ln -s /system/bin/busybox /bin/ip
mkdir /var /opt /tmp /online/opt
# For Entware
mount --bind /online/opt /opt
# For TUN/TAP
mkdir /dev/net
mknod /dev/net/tun c 10 200

/system/sbin/NwInquire &

busybox echo 0 > /proc/sys/net/netfilter/nf_conntrack_checksum

#根据产线NV项，如果是产线版本，则只起wifi，否则起全应用，forgive me pls, no better method thought
ecall bsp_get_factory_mode
dmesg | grep "+=+=+==factory_mode+=+=+=="
if [ $? -eq 0 ]
then 
	#BEGIN DTS2013092201594 yaozhanwei 2013-05-25 added for wifi factory mode
	/system/bin/wifi_brcm/exe/wifi_poweron_factory_43241.sh
	#END DTS2013092201594 yaozhanwei 2013-05-25 added for wifi factory mode
	/system/bin/bcm43236/exe/wifi_poweron_switch_43236.sh

	# g122020 DTS2014070401173 2014.07.24 add begin
	if [ -e "/etc/bluetooth/BCM4354.hcd" ]; then 
		/etc/bluetooth/bt_poweron_mmi.sh &
	fi 
	# g122020 DTS2014070401173 2014.07.24 add end
	exit 0
fi

# Start everything only if we're not in offline charging mode.
# Any AT command boots the device from offline mode, so
# we shouldn't skip this check.
# See init/main.c kernel source code for more information.
#if [[ "$(cat /proc/power_on)" == "#StartupMode:1!" ]];
if [[ 1 ]];
then
    # Set time closer to a real time for time-sensitive software.
    # Needed for everything TLS/HTTPS-related, like DNS over TLS stubby,
    # to work before the time is synced over the internet.
    date -u -s '2020-03-01 00:00:00'

    # Load kernel modules
    for kofile in /system/bin/kmod/*.ko;
    do
        insmod "$kofile"
    done

    # Unlock DATALOCK and blocked (sensitive) NVRAM items
    [ -f /etc/patchblocked.sh ] && /etc/patchblocked.sh
    # Additional device-specific patch file
    [ -f /etc/patchblocked_device.sh ] && /etc/patchblocked_device.sh

    # Wi-Fi Cut-Thru forwarding (software NAT offloading) with TTL awareness
    [ -f /system/bin/insmod_ctf_ko.sh ] && /system/bin/insmod_ctf_ko.sh

    # See /system/bin/iptables-fixttl-wrapper.sh
    /system/etc/fix_ttl.sh 0
    /system/bin/busybox sysctl -p /system/etc/sysctl.conf

    if [ -f /app/bin/oled_hijack/autorun.sh ];
    then
        # Run oled hijack autorun: unlock DATALOCK and cache some data
        /app/bin/oled_hijack/autorun.sh
        # Start adb if oled_hijack is present by default.
        # Adb access would be blocked by default via remote_access oled_hijack script.
        [ ! -f /data/userdata/adb_disable ] && adb
    else
        # Non-OLED device. Uncomment to enable adb by default.
        # Adb could still be launched via telnet 'adb' command.
        #[ ! -f /data/userdata/adb_disable ] && adb
        true
    fi

    [ ! -f /data/userdata/passwd ] && cp /system/usr/default_files/passwd_def /data/userdata/passwd
    [ ! -f /data/userdata/telnet_disable ] && telnetd -l login -b 0.0.0.0

    # Entware autorun is performed only if was enabled manually
    [ -f /data/userdata/entware_autorun ] && /opt/etc/init.d/rc.unslung start

    # Custom web interface autorun
    [ -f /app/webroot/webui_init.sh ] && /app/webroot/webui_init.sh

    # fix_ttl.sh 2, anticensorship.sh and dns_over_tls.sh are called from iptables wrapper.

fi

/app/appautorun.sh
