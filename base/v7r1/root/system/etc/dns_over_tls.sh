#!/system/bin/busybox sh

# Currently supports only IPv4 as there's no IPv6 NAT support in Huawei kernel.
# Outgoing IPv6 DNS queries are dropped if performed by the device itself (i.e. if the user uses on-device DNS).
# IPv6 DNS queries to other IPv6 addresses from users still work, as well as IPv6 queries to the device' IPv6 DNS.

CFILE="/data/userdata/dns_over_tls"
CPORT="5353"

if [[ -f "$CFILE" ]];
then
    AB_ENABLED="$(cat $CFILE)"
else
    AB_ENABLED="0"
fi

function ab_start_dnstls {
    stubby -C /etc/stubby/stubby.yml -g
    dnsmasq -C /etc/dnsmasq.conf
}

function ab_start_dnstls_with_adblock {
    stubby -C /etc/stubby/stubby.yml -g
    dnsmasq -C /etc/dnsmasq-adblock.conf
}

function ab_disable {
    pkill stubby
    pkill dnsmasq
    xtables-multi iptables -t nat -D PREROUTING -i br0 -p udp --dport 53 -j DNSTLS_DNS
    xtables-multi iptables -t nat -D PREROUTING -i br0 -p tcp --dport 53 -j DNSTLS_DNS
    xtables-multi ip6tables -D OUTPUT -o wan0 -j DNSTLS_DNS
}

function ab_enable {
    xtables-multi iptables -t nat -C PREROUTING -i br0 -p udp --dport 53 -j DNSTLS_DNS &> /dev/null
    if [[ "$?" == "0" ]];
    then
        echo "DNS over TLS is already running!"
        exit 1
    fi

    xtables-multi iptables -t nat -N DNSTLS_DNS
    xtables-multi iptables -t nat -F DNSTLS_DNS
    xtables-multi iptables -t nat -I DNSTLS_DNS -p udp --dport 53 -m u32 --u32 '0x1C&0xFA00=0 && 0x22=0' -j REDIRECT --to "$CPORT"
    # WARNING: u32 for TCP is entirely broken on Balong V7R1 (probably because of CTF, 
    # but I tried to disable it), redirect all TCP port 53 queries.
    xtables-multi iptables -t nat -I DNSTLS_DNS -p tcp --dport 53 -j REDIRECT --to "$CPORT"
    xtables-multi iptables -t nat -I PREROUTING -i br0 -p udp --dport 53 -j DNSTLS_DNS
    xtables-multi iptables -t nat -I PREROUTING -i br0 -p tcp --dport 53 -j DNSTLS_DNS
    # Block IPv6 DNS queries to force IPv4-only DNS
    xtables-multi ip6tables -N DNSTLS_DNS
    xtables-multi ip6tables -F DNSTLS_DNS
    xtables-multi ip6tables -I DNSTLS_DNS -p udp --dport 53 -m u32 --u32 '0x30&0xFA00=0 && 0x36=0' -j DROP
    xtables-multi ip6tables -I DNSTLS_DNS -p tcp --dport 53 -j REJECT
    xtables-multi ip6tables -I OUTPUT -o wan0 -j DNSTLS_DNS
}

if [[ "$1" == "0" ]];
# Force-off
then
    ab_disable
elif [[ "$1" == "1" ]] || [[ "$AB_ENABLED" == "1" ]];
then
    ab_disable
    ab_start_dnstls
    ab_enable
elif [[ "$1" == "2" ]] || [[ "$AB_ENABLED" == "2" ]];
then
    ab_disable
    ab_start_dnstls_with_adblock
    ab_enable
fi
