#!/system/bin/busybox sh
source /system/etc/patchblocked.sh

function ord() {
    printf '%x' "'$1"
}

CFILE="/data/userdata/usb_mac"
# HACK: hardcoded offset for E5770 21.329.01.00.00
# See drivers/usb/mbb_usb_unitary/u_ether.c to learn more
USBMAC_BASE=$(( 0xC0719F10 ))

if [[ ! -f "$CFILE" ]];
then
    exit 1
fi

USB_MACADDR="$(cat $CFILE)"
echo "$USB_MACADDR" | grep -E -q '^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$' || { echo "Wrong value!"; exit 2; }

cnt=0
for i in $(echo "$USB_MACADDR" | fold -w1);
do
    wr_m $(( $USBMAC_BASE + $cnt )) "$(ord "$i")"
    cnt=$cnt+1
done
