#!/system/bin/busybox sh

source /etc/patchblocked.sh

# Patch 'finger' Android USB gadget to use 'ecm' instead
# Needed for ECM USB autoswitch
# See drivers/usb/mbb_usb_unitary/hw_pnp_adapt.{c,h} to learn more
# HACK: hardcoded offset for E5573Cs 21.328.62.00.1456
wr_m 0xC06C3C28 65 63 6D 00
