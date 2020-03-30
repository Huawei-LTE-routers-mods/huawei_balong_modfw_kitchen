#!/system/bin/busybox sh

source /etc/patchblocked.sh

# Patch 'finger' Android USB gadget to use 'ecm' instead
# Needed for ECM USB autoswitch
# See drivers/usb/mbb_usb_unitary/hw_pnp_adapt.{c,h} to learn more
# HACK: hardcoded offset for E5770 21.329.01.00.00
wr_m 0xC070FA28 65 63 6D 00

# Patch USB MAC address
/etc/patch_usbmac.sh
