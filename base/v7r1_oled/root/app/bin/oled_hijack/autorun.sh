#!/system/bin/busybox sh

# Some scripts are called from /system/bin/iptables-wrapper.sh
# force "get" to cache some values
/app/bin/oled_hijack/imei_change.sh dataunlock
/app/bin/oled_hijack/imei_change.sh get
/app/bin/oled_hijack/no_battery.sh get
/app/bin/oled_hijack/usb_mode.sh get
