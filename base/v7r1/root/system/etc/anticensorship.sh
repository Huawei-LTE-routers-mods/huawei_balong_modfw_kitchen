#!/system/bin/busybox sh

# Currently supports only IPv4 as there's no IPv6 NAT support in Huawei kernel.

CFILE="/data/userdata/anticensorship"
CPORT="12831"

if [[ -f "$CFILE" ]];
then
    AC_ENABLED="$(cat $CFILE)"
else
    AC_ENABLED="0"
fi

function ac_disable {
    killall tpws
    xtables-multi iptables -t nat -D PREROUTING -i br0 -p tcp --dport 80 -j ANTICENSORSHIP
    xtables-multi iptables -t nat -D PREROUTING -i br0 -p tcp --dport 443 -j ANTICENSORSHIP
}

function ac_enable {
    iptables -t nat -C PREROUTING -i br0 -p tcp --dport 80 -j REDIRECT --to "$CPORT" &> /dev/null
    if [[ "$?" == "0" ]];
    then
        echo "Anticensorship is already running!"
        exit 1
    fi
    
    iptables -t nat -nL ANTICENSORSHIP &> /dev/null
    if [[ "$?" != "0" ]]
    then
        xtables-multi iptables -t nat -N ANTICENSORSHIP
        xtables-multi iptables -t nat -A ANTICENSORSHIP -d 0.0.0.0/8 -j RETURN
        xtables-multi iptables -t nat -A ANTICENSORSHIP -d 10.0.0.0/8 -j RETURN
        xtables-multi iptables -t nat -A ANTICENSORSHIP -d 127.0.0.0/8 -j RETURN
        xtables-multi iptables -t nat -A ANTICENSORSHIP -d 169.254.0.0/16 -j RETURN
        xtables-multi iptables -t nat -A ANTICENSORSHIP -d 172.16.0.0/12 -j RETURN
        xtables-multi iptables -t nat -A ANTICENSORSHIP -d 192.168.0.0/16 -j RETURN
        xtables-multi iptables -t nat -A ANTICENSORSHIP -d 224.0.0.0/4 -j RETURN
        xtables-multi iptables -t nat -A ANTICENSORSHIP -d 240.0.0.0/4 -j RETURN
        xtables-multi iptables -t nat -A ANTICENSORSHIP -p tcp -j REDIRECT --to-ports "$CPORT"
    fi

    ulimit -n 4096
    tpws --daemon --port "$CPORT" --split-pos 2 --hostcase --hostspell hoSt --hostnospace
    # Redirect HTTP and HTTPS traffic to transparent anticensorship proxy.
    xtables-multi iptables -t nat -I PREROUTING -i br0 -p tcp --dport 80 -j ANTICENSORSHIP
    xtables-multi iptables -t nat -I PREROUTING -i br0 -p tcp --dport 443 -j ANTICENSORSHIP
}

if [[ "$1" == "0" ]];
# Force-off
then
    ac_disable

elif [[ "$1" == "1" ]] || [[ "$AC_ENABLED" == "1" ]];
then
    ac_disable
    ac_enable
fi
