#!/system/bin/busybox sh

# OpenVPN DNS redirection code
# Intended to be called from OpenVPN client.up/down script

# Currently supports only IPv4 as there's no IPv6 NAT support in Huawei kernel.

PATH=/bin:/sbin:/app/bin:/system/sbin:/system/bin:/system/xbin

function dnsredir_disable {
    xtables-multi iptables -t nat -D PREROUTING -i br0 -j OVPN_DNS
    xtables-multi iptables -t nat -F OVPN_DNS
    pkill dnsmasq
}

function dnsredir_enable {
    xtables-multi iptables -t nat -C PREROUTING -i br0 -j OVPN_DNS &> /dev/null
    if [[ "$?" == "0" ]];
    then
        echo "OpenVPN DNS redirection already running!"
        exit 1
    fi

    dnsmasq "--server=/#/$1" -i br0 -2 br0 --port=5353 --cache-size=3000 -C /dev/null
    xtables-multi iptables -t nat -N OVPN_DNS
    xtables-multi iptables -t nat -F OVPN_DNS
    xtables-multi iptables -t nat -I OVPN_DNS -p udp --dport 53 -m u32 --u32 '0x1C&0xFA00=0 && 0x22=0' -j REDIRECT --to 5353
    xtables-multi iptables -t nat -I OVPN_DNS -p tcp --dport 53 -j REDIRECT --to 5353

    xtables-multi iptables -t nat -I PREROUTING -i br0 -j OVPN_DNS
}

if [[ "$1" == "" ]];
then
    exit 1
fi

if [[ "$1" == "0" ]];
# Force-off
then
    dnsredir_disable
else
    dnsredir_enable "$1"
fi
