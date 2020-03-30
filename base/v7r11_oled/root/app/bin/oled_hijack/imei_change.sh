#!/system/bin/busybox sh

IMEI_SET_COMMAND='AT^PHYNUM=IMEI'

IMEI_GENERATOR="/app/bin/oled_hijack/imei_generator"

CURRENT_IMEI_FILE="/var/current_imei"
BACKUP_IMEI_FILE="/online/imei_backup"

# IMEI caching to prevent menu slowdowns
if [[ ! -f "$CURRENT_IMEI_FILE" ]]
then
    CURRENT_IMEI=$(atc 'AT+CGSN' | grep -o '[0-9]\{15\}')
    echo $CURRENT_IMEI > $CURRENT_IMEI_FILE
else
    CURRENT_IMEI=$(cat $CURRENT_IMEI_FILE)
fi

if [[ "$CURRENT_IMEI" == "" ]]
then
    CURRENT_IMEI=$(atc 'AT+CGSN' | grep -o '[0-9]\{15\}')
    echo $CURRENT_IMEI > $CURRENT_IMEI_FILE
fi

if [[ "$CURRENT_IMEI" == "" ]]
then
    exit 255
fi

CURRENT_IMEI_CUT="$(echo $CURRENT_IMEI | cut -c 1-8)"

echo $CURRENT_IMEI

if [[ "$1" == "get" ]]
then
    [[ "$CURRENT_IMEI_CUT" == "35428207" ]] && exit 1
    [[ "$CURRENT_IMEI_CUT" == "35365206" ]] && exit 2

    # special case for factory imei
    echo $CURRENT_IMEI > $BACKUP_IMEI_FILE
    exit 0
fi

if [[ "$1" == "set_next" ]]
then
    IMEI_ANDROID="$($IMEI_GENERATOR -m 35428207)"
    IMEI_WINPHONE="$($IMEI_GENERATOR -m 35365206)"
    IMEI_BACKUP="$(cat $BACKUP_IMEI_FILE)"
    if [[ "$IMEI_BACKUP" == "" ]]
    then
        exit 253
    fi

    [[ "$CURRENT_IMEI_CUT" == "35428207" ]] && atc "$IMEI_SET_COMMAND,$IMEI_WINPHONE" && echo $IMEI_WINPHONE > $CURRENT_IMEI_FILE && exit 0
    [[ "$CURRENT_IMEI_CUT" == "35365206" ]] && atc "$IMEI_SET_COMMAND,$IMEI_BACKUP" && echo $IMEI_BACKUP > $CURRENT_IMEI_FILE && exit 0

    # special case for factory imei
    atc "$IMEI_SET_COMMAND,$IMEI_ANDROID" && echo $IMEI_ANDROID > $CURRENT_IMEI_FILE

fi
