#!/bin/bash

# Move dnsmasq to /app due to low space on /system
mv "$WORKDIR/system/bin/dnsmasq" "$WORKDIR/app/bin/dnsmasq"
ln -s /app/bin/dnsmasq "$WORKDIR/system/bin/dnsmasq"
