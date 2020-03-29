#!/system/bin/busybox sh

CFILE="/data/userdata/fix_ttl"

if [[ ! -f "$CFILE" ]];
then
    exit 1
fi

TTL="$(cat $CFILE)"
if [[ "$TTL" == "0" ]] || [[ "$TTL" == "" ]];
then
    exit 2
fi

if [[ "$TTL" == "1" ]];
then
    TTL="64"
fi

if [[ "$1" == "0" ]];
then
    source /etc/patchblocked.sh

    xtables-multi iptables -P FORWARD DROP
    xtables-multi ip6tables -P FORWARD DROP
    echo $TTL > /proc/sys/net/ipv4/ip_default_ttl
    echo $TTL > /proc/sys/net/ipv6/conf/wan0/hop_limit

    # Patch fastip_forward
    FASTIP_FORWARD_ADDR="$(awk '/ _fastip_forward/ {print "0x"$1;exit}' /proc/kallsyms)"
    if [[ "$FASTIP_FORWARD_ADDR" ]];
    then
        FASTIP_FORWARD_PATCH_OFFSET_1=$(($FASTIP_FORWARD_ADDR + 0x7C0))
        FASTIP_FORWARD_PATCH_OFFSET_2=$(($FASTIP_FORWARD_ADDR + 0x7F0))
        FASTIP_FORWARD_PATCH_OFFSET_3=$(($FASTIP_FORWARD_ADDR + 0x930))
        FASTIP_FORWARD_PATCH_OFFSET_4=$(($FASTIP_FORWARD_ADDR + 0x960))
        TTL_HEX="$(printf "%02x" "$TTL")"
        # change SUB R3, R3, #1 to MOV R3, #64 for CTF_ACTION_SNAT
        wr_m $FASTIP_FORWARD_PATCH_OFFSET_1 $TTL_HEX 30 A0 E3
        wr_m $FASTIP_FORWARD_PATCH_OFFSET_2 $TTL_HEX 30 A0 E3
        # change SUB R3, R3, #1 to MOV R3, #64 for CTF_ACTION_DNAT
        # NOTE: COMMENT IF CTF_ACTION_DNAT PATCH IS NOT DESIRED
        wr_m $FASTIP_FORWARD_PATCH_OFFSET_3 $TTL_HEX 30 A0 E3
        wr_m $FASTIP_FORWARD_PATCH_OFFSET_4 $TTL_HEX 30 A0 E3
        echo "FastIP patched"
    else
        echo "ERROR: can't find FastIP address."
        xtables-multi iptables -P FORWARD ACCEPT
        xtables-multi ip6tables -P FORWARD ACCEPT
        exit 3
    fi

elif [[ "$1" == "2" ]];
then
    # Add iptables rules
    xtables-multi iptables -t mangle -A POSTROUTING -o wan0 -j TTL --ttl-set $TTL
    xtables-multi ip6tables -t mangle -A POSTROUTING -o wan0 -j HL --hl-set $TTL
    # NOTE: COMMENT IF CTF_ACTION_DNAT PATCH IS NOT DESIRED
    xtables-multi iptables -t mangle -A PREROUTING -i wan0 -j TTL --ttl-set $TTL
    xtables-multi ip6tables -t mangle -A PREROUTING -i wan0 -j HL --hl-set $TTL

    xtables-multi iptables -P FORWARD ACCEPT
    xtables-multi ip6tables -P FORWARD ACCEPT
fi
