#!/system/bin/busybox sh

HUAWEICALC="/system/bin/huaweicalc"
DATAUNLOCK_FLAG="/var/dataunlocked"

dataunlock () {
    if [[ ! -f "$DATAUNLOCK_FLAG" ]]
        then
        CURRENT_IMEI=$(atc 'AT+CGSN' | grep -o '[0-9]\{15\}')
        DATALOCK_CODE="$($HUAWEICALC -3 $CURRENT_IMEI)"
        if [[ "$DATALOCK_CODE" != "" ]]
        then
            atc "AT^DATALOCK=\"$DATALOCK_CODE\""
            echo "Datalock:" "AT^DATALOCK=\"$DATALOCK_CODE\""
            echo > $DATAUNLOCK_FLAG
        else
            exit 254
        fi
    fi
}

if [[ "$1" == "boot" ]];
then
    dataunlock
fi
