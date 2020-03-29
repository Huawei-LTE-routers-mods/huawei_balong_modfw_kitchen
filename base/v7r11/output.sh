#!/bin/bash
for fwdirname in "system" "app" "webui";
do
    if [[ -d "$WORKDIR/$fwdirname/" ]];
    then
        (cd "$WORKDIR/$fwdirname/" && find . | cpio -o -H newc > "../$fwdirname.cpio")
    fi
done
