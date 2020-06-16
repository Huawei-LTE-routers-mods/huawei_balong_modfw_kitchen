#!/system/bin/busybox sh

source /etc/patchblocked.sh

# Patch 'finger' Android USB gadget to use 'ecm' instead
# Needed for ECM USB autoswitch
# See drivers/usb/mbb_usb_unitary/hw_pnp_adapt.{c,h} to learn more
# HACK: hardcoded offset for E8372h 21.328.62.02.1460
wr_m 0xC06DBFE4 65 63 6D 00
