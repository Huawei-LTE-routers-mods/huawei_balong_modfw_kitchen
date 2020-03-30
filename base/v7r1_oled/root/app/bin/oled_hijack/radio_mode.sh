#!/system/bin/busybox sh

# Radio mode OLED handler.
# By ValdikSS, iam@valdikss.org.ru

HOOK_CLIENT="/app/bin/oled_hijack/net_hook_client"
NETWORK_REQ_PRE='<?xml version="1.0" encoding="UTF-8"?><request><NetworkMode>'
NETWORK_REQ_POST='</NetworkMode><NetworkBand>3FFFFFFF</NetworkBand><LTEBand>7fffffffffffffff</LTEBand></request>'

function get_state() {
    OUT="$(timeout -t 5 $HOOK_CLIENT net net-mode 1 1)"
    CURRENT_MODE="$(echo "$OUT" | grep 'NetworkMode' | sed -E 's~.+>(.+)</.+~\1~')"
    echo $CURRENT_MODE
}

function set_state() {
    timeout -t 15 $HOOK_CLIENT net net-mode 2 "${NETWORK_REQ_PRE}$1${NETWORK_REQ_POST}"
}

if [[ "$1" == "get" ]]
then
    get_state

    [[ "$CURRENT_MODE" == "00" ]]   && exit 0
    [[ "$CURRENT_MODE" == "01" ]]   && exit 1
    [[ "$CURRENT_MODE" == "02" ]]   && exit 2
    [[ "$CURRENT_MODE" == "03" ]]   && exit 3
    [[ "$CURRENT_MODE" == "0302" ]] && exit 4
    [[ "$CURRENT_MODE" == "0301" ]] && exit 5
    [[ "$CURRENT_MODE" == "0201" ]] && exit 6

    # error
    exit 255
fi

if [[ "$1" == "set_next" ]]
then
    get_state

    [[ "$CURRENT_MODE" == "00" ]]   && set_state "01"
    [[ "$CURRENT_MODE" == "01" ]]   && set_state "02"
    [[ "$CURRENT_MODE" == "02" ]]   && set_state "03"
    [[ "$CURRENT_MODE" == "03" ]]   && set_state "0302"
    [[ "$CURRENT_MODE" == "0302" ]] && set_state "0301"
    [[ "$CURRENT_MODE" == "0301" ]] && set_state "0201"
    [[ "$CURRENT_MODE" == "0201" ]] && set_state "00"
fi
