#!/system/bin/busybox sh
ln -s /dev/appvcom /dev/appvcom1 2> /dev/null
# suspend ats daemon to prevent intervention
killall -STOP ats
timeout -t 3 /system/xbin/atc "$@"
killall -CONT ats
