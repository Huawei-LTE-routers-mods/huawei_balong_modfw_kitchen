#!/bin/bash

# Include v7r11 base.
if [[ -f "$BASEDIR/v7r11/before_copy.sh" ]];
then
    REENABLE_E=
    # Temporary disable errexit as v7r11 base
    # mv may fail due to missing led binary.
    [ -o errexit ] && set +e && REENABLE_E=1
    source "$BASEDIR/v7r11/before_copy.sh"
    [[ "$REENABLE_E" ]] && set -e
fi

if [[ -d "$WORKDIR/app/" ]];
then
    # Rename some binaries in /app/bin/
    mv "$WORKDIR/app/bin/device" "$WORKDIR/app/bin/device.orig"
    mv "$WORKDIR/app/bin/oled" "$WORKDIR/app/bin/oled.orig"
    mv "$WORKDIR/app/bin/router" "$WORKDIR/app/bin/router.orig"
fi

# Copy system contents from v7r11 base
if [[ -d "$BASEDIR/v7r11/root/system/" ]];
then
    cp -a "$BASEDIR/v7r11/root/system/" "$WORKDIR/"
fi
