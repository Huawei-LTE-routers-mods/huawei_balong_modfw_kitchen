#!/system/bin/busybox sh

fix_ttl="$(cat /system/etc/fix_ttl)"

if [[ "$fix_ttl" == "0" ]] || [[ "$fix_ttl" == "" ]]; then
    /system/bin/insmod /system/bin/kmod_ctf/ctf.ko

elif [[ "$fix_ttl" == "1" ]] || [[ "$fix_ttl" == "64" ]]; then
    /system/bin/insmod /system/bin/kmod_ctf/ctf_ttl_set_64.ko

elif [[ "$fix_ttl" == "65" ]]; then
    /system/bin/insmod /system/bin/kmod_ctf/ctf_ttl_set_65.ko

elif [[ "$fix_ttl" == "128" ]]; then
    /system/bin/insmod /system/bin/kmod_ctf/ctf_ttl_set_128.ko

else
    # Disable CTF (Cut-through forwarding, FastNAT) if TTL
    # is not 64, 65 or 128.
    echo 1 > /proc/ctf_stop
fi
