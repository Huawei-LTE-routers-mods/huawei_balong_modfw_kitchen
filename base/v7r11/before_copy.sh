#!/bin/bash
# Rename iptables and ip6tables
mv "$WORKDIR/system/bin/iptables" "$WORKDIR/system/bin/iptables.orig"
mv "$WORKDIR/system/bin/ip6tables" "$WORKDIR/system/bin/ip6tables.orig"

if [[ -d "$WORKDIR/app/" ]];
then
    # Remove /app/config/mlog/mlogcfg.cfg to disable logging
    [[ -f "$WORKDIR/app/config/mlog/mlogcfg.cfg" ]] && rm "$WORKDIR/app/config/mlog/mlogcfg.cfg"

    # Rename /app/bin/led for net_updown.so network UP/DOWN hook
    mv "$WORKDIR/app/bin/led" "$WORKDIR/app/bin/led.orig"
fi
