#!/system/bin/busybox sh

source /etc/patchblocked.sh

sleep 3
# Patch VXWORKS and unlock SIMLOCK, by ValdikSS <iam@valdikss.org.ru>
# For Goranet E5577s-932 FIRMWARE - 21.333.63.01.1384
ecall __arm_ioremap $((0x50D10000)) $((0x38F0000)) 2     # map VXWORKS address space into Linux
REMAPPED=$(dmesg | tail -n4 | awk '/Call __arm_ioremap return, value/{print $7}')     # Get the mapped address
if [[ "$REMAPPED" ]];
then
    wr_m $(($REMAPPED + 0x12AFC40)) 00     # set customer_locked_flag = 0 (MMA_IsCustomerLocked) in VXWORKS
    ecall __arm_iounmap $(($REMAPPED))     # Unmap VXWORKS address space from Linux
    atc 'at^sethwlock="SIMLOCK",00000000'
    # Trigger cardlock unlock functionality
    atc 'at^simlock=1'
    atc 'at^cardlock="00000000"'
    echo "Cardlock patched"
    # Unlocked :)
else
    echo "Cardlock patch failed, can't read remapped address"
fi
