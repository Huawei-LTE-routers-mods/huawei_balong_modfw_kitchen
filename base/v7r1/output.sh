#!/bin/bash
for fwdirname in "system" "app";
do
    if [[ -d "$WORKDIR/$fwdirname/" ]];
    then
        (cd "$WORKDIR/" && mkyaffs2 -s 16 --yaffs-ecclayout "$fwdirname" "$fwdirname.bin" -v)
    fi
done
