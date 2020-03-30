#!/system/bin/busybox sh

# This wrapper calls "fix_ttl.sh 2" to permit FORWARDed traffic
# when "ip[6]tables -t mangle -F" flushing rule is called by /app/bin/npdaemon.
# Calling "fix_ttl.sh 2" or other scripts in autorun causes race condition, so we
# "monitor" when the rules are flushed and call handlers which modify iptables
# rules again to add or re-add them.

/system/bin/${0##*/}.orig "$@"
RETCODE="$?"

if [[ "$1" == "-t" ]] && [[ "$3" == "-F" ]];
then
    if [[ "$2" == "filter" ]];
    then
        [ -f /app/bin/oled_hijack/remote_access.sh ] && /app/bin/oled_hijack/remote_access.sh boot
    elif [[ "$2" == "mangle" ]];
    then
        /etc/fix_ttl.sh 2
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
