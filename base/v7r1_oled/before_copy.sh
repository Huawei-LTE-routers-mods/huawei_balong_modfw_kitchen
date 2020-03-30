#!/bin/bash

# Include v7r1 base.
if [[ -f "$BASEDIR/v7r1/before_copy.sh" ]];
then
    source "$BASEDIR/v7r1/before_copy.sh"
fi

if [[ -d "$WORKDIR/app/" ]];
then
    # Rename some binaries in /app/bin/
    mv "$WORKDIR/app/bin/device" "$WORKDIR/app/bin/device.orig"
    mv "$WORKDIR/app/bin/oled" "$WORKDIR/app/bin/oled.orig"
fi

# Copy system contents from v7r1 base
if [[ -d "$BASEDIR/v7r1/root/system/" ]];
then
    cp -a "$BASEDIR/v7r1/root/system/" "$WORKDIR/"
fi
