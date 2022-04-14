#!/system/bin/busybox sh

source /etc/patchblocked.sh

# Patch VXWORKS and unlock SIMLOCK
# For E8372 21.328.62.02.1460 (ZONG BOLT+)
ecall __arm_ioremap $((0x50D10000)) $((0x38F0000)) 2     # map VXWORKS address space into Linux
REMAPPED=$(dmesg | tail -n4 | awk '/Call __arm_ioremap return, value/{print $7}')     # Get the mapped address
if [[ "$REMAPPED" ]];
then
    wr_m $(($REMAPPED + 0x12B4F54)) 00     # set customer_locked_flag = 0 (MMA_IsCustomerLocked) in VXWORKS
    ecall __arm_iounmap $(($REMAPPED))     # Unmap VXWORKS address space from Linux
    echo -ne 'at^sethwlock="SIMLOCK",00000000\r' > /dev/appvcom1
    sleep 0.3
    # Trigger cardlock unlock functionality
    echo -ne 'at^simlock=1\r' > /dev/appvcom1
    sleep 0.3
    echo -ne 'at^cardlock="00000000"\r' > /dev/appvcom1
    echo "Cardlock patched"
    # Unlocked :)
else
    echo "Cardlock patch failed, can't read remapped address"
fi
