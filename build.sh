#!/bin/bash

set -e
set -x

WORKDIR="workdir"
BASEDIR="base"
DEVICEDIR="device_overlay"

FAMILY="$1"
DEVICEOVERLAY="$2"
ORIGFW="$3"

echo "Huawei Balong custom firmware builder"
echo "https://github.com/Huawei-LTE-routers-mods/"
echo

if [[ ! "$3" ]];
then
    echo "$0 <balong family> <device overlay> <firmware directory>"
    echo "Example: $0 v7r11 e8372h-153_zong_21.333.64.00.1456"
    exit 1
fi

if [[ ! -d "$BASEDIR/$FAMILY" || ! -d "$DEVICEDIR/$DEVICEOVERLAY" ]];
then
    echo "Base directory or device directory not found!"
    exit 2
fi

rm -rf "$WORKDIR/"
mkdir "$WORKDIR/"

[[ ! -d "$ORIGFW/system/" ]] && echo "Firmware directory does not contain system!" && exit 3

for fwdirname in "system" "app" "webui";
do
    if [[ -d "$ORIGFW/$fwdirname/" ]];
    then
        # Copy files from original firmware to workdir
        cp -a "$ORIGFW/$fwdirname/" "$WORKDIR/$fwdirname/"
    fi
done

# Run base family before_copy.sh file
[[ -f "$BASEDIR/$FAMILY/before_copy.sh" ]] && source "$BASEDIR/$FAMILY/before_copy.sh"
for fwdirname in "system" "app" "webui";
do
    if [[ -d "$ORIGFW/$fwdirname/" && -d "$BASEDIR/$FAMILY/root/$fwdirname/" ]];
    then
        # Copy base family contents over original firmware in the workdir
        cp -a "$BASEDIR/$FAMILY/root/$fwdirname/" "$WORKDIR/"
    fi
done
# Run base family before_copy.sh file
[[ -f "$BASEDIR/$FAMILY/after_copy.sh" ]] && source "$BASEDIR/$FAMILY/after_copy.sh"

[[ -f "$DEVICEDIR/$DEVICEOVERLAY/before_copy.sh" ]] && source "$DEVICEDIR/$DEVICEOVERLAY/before_copy.sh"
for fwdirname in "system" "app" "webui";
do
    if [[ -d "$ORIGFW/$fwdirname/" && -d "$DEVICEDIR/$DEVICEOVERLAY/root/$fwdirname/" ]];
    then
        # Copy device overlay contents over original firmware + base family in the workdir
        cp -a "$DEVICEDIR/$DEVICEOVERLAY/root/$fwdirname/" "$WORKDIR/"
    fi
done
[[ -f "$DEVICEDIR/$DEVICEOVERLAY/after_copy.sh" ]] && source "$DEVICEDIR/$DEVICEOVERLAY/after_copy.sh"

# Run output script if exists. The script produces final .cpio file.
if [[ -f "$DEVICEDIR/$DEVICEOVERLAY/output.sh" ]];
then
    source "$DEVICEDIR/$DEVICEOVERLAY/output.sh"
elif [[ -f "$BASEDIR/$FAMILY/output.sh" ]];
then
    source "$BASEDIR/$FAMILY/output.sh"
fi
