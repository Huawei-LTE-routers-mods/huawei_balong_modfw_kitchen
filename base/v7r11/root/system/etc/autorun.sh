#!/system/bin/busybox sh

mkdir bin
ln -s /system/bin/sh /bin/sh
ln -s /system/bin/busybox /bin/ash
ln -s /system/xbin/atc.sh /sbin/atc
mkdir /var /opt /tmp /online/opt
# For Entware
mount --bind /online/opt /opt
# For TUN/TAP
mkdir /dev/net
mknod /dev/net/tun c 10 200

busybox echo 0 > /proc/sys/net/netfilter/nf_conntrack_checksum

# NV restore flag, load patches only when normal boot.
if [[ "$(cat /proc/dload_nark)" == "nv_restore_start" ]];
then
    /system/sbin/NwInquire &

    /etc/huawei_process_start
    exit 0
fi

/etc/fix_ttl.sh 0
/etc/huawei_process_start

# Unlock DATALOCK and blocked (sensitive) NVRAM items
# to be readable/writable using AT^NVRD/AT^NVWR.
/etc/patchblocked.sh boot
# Additional device-specific patch file
[ -f /etc/patchblocked_device.sh ] && /etc/patchblocked_device.sh
# Unlock SIM if the file is present.
[ -f /etc/simunlock.sh ] && /etc/simunlock.sh

# Load kernel modules
for kofile in /system/bin/kmod/*.ko;
do
    insmod "$kofile"
done

# Set time closer to a real time for time-sensitive software.
# Needed for everything TLS/HTTPS-related, like DNS over TLS stubby,
# to work before the time is synced over the internet.
date -u -s '2020-03-01 00:00:00'

# Load custom sysctl settings
busybox sysctl -p /system/etc/sysctl.conf

# Remove /online/mobilelog/mlogcfg.cfg if /app/config/mlog/mlogcfg.cfg does NOT exist
# Disables mobile logger and saves flash rewrite cycles
[ ! -f /app/config/mlog/mlogcfg.cfg ] && rm /online/mobilelog/mlogcfg.cfg

[ ! -f /data/userdata/passwd ] && cp /system/usr/default_files/passwd_def /data/userdata/passwd
[ ! -f /data/userdata/telnet_disable ] && telnetd -l login -b 0.0.0.0

if [ -f /app/bin/oled_hijack/autorun.sh ];
then
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

# Entware autorun
[ -f /data/userdata/entware_autorun ] && /opt/etc/init.d/rc.unslung start

# Custom web interface autorun
[ -f /app/webroot/webui_init.sh ] && /app/webroot/webui_init.sh

# fix_ttl.sh 2, dns_over_tls.sh and anticenshorship.sh are called
# from /system/bin/iptables-fixttl-wrapper.sh by /app/bin/npdaemon.
