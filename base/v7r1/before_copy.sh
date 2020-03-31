#!/bin/bash
# Rename iptables and ip6tables
mv "$WORKDIR/system/bin/iptables" "$WORKDIR/system/bin/iptables.orig"
mv "$WORKDIR/system/bin/ip6tables" "$WORKDIR/system/bin/ip6tables.orig"

# If reboot is a symlink to toolbox, the toolbox binary would be rewritten.
# Remove the symlink.
rm "$WORKDIR/system/bin/reboot" || true
