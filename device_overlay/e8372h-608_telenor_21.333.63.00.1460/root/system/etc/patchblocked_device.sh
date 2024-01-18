#!/system/bin/busybox sh

source /etc/patchblocked.sh

# Patch 'finger' Android USB gadget to use 'ecm' instead
# Needed for ECM USB autoswitch
# See drivers/usb/mbb_usb_unitary/hw_pnp_adapt.{c,h} to learn more
# HACK: hardcoded offset for E8372h 21.333.64.00.1456
#wr_m 0xC06EA21C 65 63 6D 00
