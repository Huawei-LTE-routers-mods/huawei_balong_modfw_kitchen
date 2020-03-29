#!/system/bin/busybox sh
# suspend ats daemon to prevent intervention
killall -STOP ats
timeout -t 3 /system/xbin/atc "$@"
killall -CONT ats
