#!/system/bin/busybox sh

ttl="$(cat /system/etc/fix_ttl)"

if [[ "$ttl" == "0" ]] || [[ "$ttl" == "" ]]; then
  exit
fi

if [[ "$ttl" == "1" ]]; then
  ttl=64
fi

if [[ "$1" == "0" ]]; then
  echo $ttl > /proc/sys/net/ipv4/ip_default_ttl
  echo $ttl > /proc/sys/net/ipv6/conf/wan0/hop_limit

  xtables-multi iptables -P FORWARD DROP
  xtables-multi ip6tables -P FORWARD DROP
else
  xtables-multi iptables -t mangle -A POSTROUTING -o wan0 -j TTL --ttl-set $ttl
  xtables-multi iptables -P FORWARD ACCEPT
  xtables-multi ip6tables -t mangle -A POSTROUTING -o wan0 -j HL --hl-set $ttl
  xtables-multi ip6tables -P FORWARD ACCEPT
fi
