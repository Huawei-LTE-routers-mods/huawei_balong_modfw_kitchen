#!/bin/bash

# Include v7r1 base.
if [[ -f "$BASEDIR/v7r1/before_copy.sh" ]];
then
    source "$BASEDIR/v7r1/before_copy.sh"
fi

# Copy contents from v7r1 base
for fwdirname in "system" "app" "webui";
do
    if [[ -d "$BASEDIR/v7r1/root/$fwdirname/" ]];
    then
        cp -a "$BASEDIR/v7r1/root/$fwdirname/" "$WORKDIR/"
    fi
done
