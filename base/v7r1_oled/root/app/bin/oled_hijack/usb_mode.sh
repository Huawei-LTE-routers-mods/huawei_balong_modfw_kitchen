#!/system/bin/busybox sh

# USB mode OLED handler.
# By ValdikSS, iam@valdikss.org.ru

CONF_FILE="/var/usb_mode"

MODE_0="01 00 00 00 A1 A2 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 12 16 A1 A2 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
MODE_1="01 00 00 00 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 12 16 A2 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
MODE_2="01 00 00 00 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 12 16 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
MODE_3="01 00 00 00 FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 12 16 A1 A2 05 0A 13 14 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"

status_from_mode() {
    [[ "$1" == "$MODE_0" ]] && echo 0
    [[ "$1" == "$MODE_1" ]] && echo 1
    [[ "$1" == "$MODE_2" ]] && echo 2
    [[ "$1" == "$MODE_3" ]] && echo 3
}

# usb mode caching to prevent menu slowdowns
if [[ ! -f "$CONF_FILE" ]]
then
    CURRENT_USB_MODE="$(atc 'AT^NVRD=50091' | grep 'NVRD' | grep -o ',[0-9A-F ]\{179\}' | cut -b 2-999)"
    CURRENT_USB_MODE="$(status_from_mode "$CURRENT_USB_MODE")"
    if [[ "$CURRENT_USB_MODE" == "" ]]
    then
        # error
        exit 255
    fi
    echo $CURRENT_USB_MODE > $CONF_FILE
else
    CURRENT_USB_MODE="$(cat $CONF_FILE)"
fi

if [[ "$CURRENT_USB_MODE" == "" ]]
then
    exit 254
fi

echo $CURRENT_USB_MODE

if [[ "$1" == "get" ]]
then
    [[ "$CURRENT_USB_MODE" == "0" ]] && exit 0
    [[ "$CURRENT_USB_MODE" == "1" ]] && exit 1
    [[ "$CURRENT_USB_MODE" == "2" ]] && exit 2
    [[ "$CURRENT_USB_MODE" == "3" ]] && exit 3

    exit 253
fi

if [[ "$1" == "set_next" ]]
then
    [[ "$CURRENT_USB_MODE" == "0" ]] && atc "AT^NVWR=50091,60,$MODE_1" && echo 1 > $CONF_FILE && exit 0
    [[ "$CURRENT_USB_MODE" == "1" ]] && atc "AT^NVWR=50091,60,$MODE_2" && echo 2 > $CONF_FILE && exit 0
    [[ "$CURRENT_USB_MODE" == "2" ]] && atc "AT^NVWR=50091,60,$MODE_3" && atc "AT^NVWR=33,4,2,0,0,0" && echo 3 > $CONF_FILE && exit 0
    [[ "$CURRENT_USB_MODE" == "3" ]] && atc "AT^NVWR=50091,60,$MODE_0" && atc "AT^NVWR=33,4,0,0,0,0" && echo 0 > $CONF_FILE && exit 0

    exit 253
fi
