#!/system/bin/busybox sh

# This wrapper calls "fix_ttl.sh 2" to permit FORWARDed traffic
# when "ip[6]tables -t mangle -F" is called by /app/bin/npdaemon.
# Calling "fix_ttl.sh 2" and other iptables scripts in autorun
# cause race condition.

/system/bin/${0##*/}.orig "$@"
RETCODE="$?"

if [[ "$1" == "-t" ]] && [[ "$3" == "-F" ]];
then
    if [[ "$2" == "mangle" ]];
    then
        /etc/fix_ttl.sh 2
        [ -f /app/bin/oled_hijack/remote_access.sh ] && /app/bin/oled_hijack/remote_access.sh boot
    elif [[ "$2" == "nat" ]];
    then
        /etc/anticensorship.sh
        /etc/dns_over_tls.sh
    fi
fi

if [[ "$1" == "-t" ]] && [[ "$2" == "filter" ]] \
   && [[ "$3" == "-N" ]] && [[ "$4" == "SERVICE_INPUT" ]];
then
    [ -f /app/bin/oled_hijack/remote_access.sh ] && /app/bin/oled_hijack/remote_access.sh boot
fi

exit "$RETCODE"
