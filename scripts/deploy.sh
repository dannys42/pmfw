#!/bin/bash
# This script will implement the firewall rules you declare
# This script is considered a template and should be adjusted for your specific network requirements.

iface_internet="eth0"
allow_ping=1
allow_http=0
allow_https=0
allow_ntp=1
allow_webknock=1
allow_cron=0
default_logging=1

PMFW_DIR=/etc/pmfw

if [ -r ${PMFW_DIR}/pmfw.conf ]; then
    . ${PMFW_DIR}/pmfw.conf
fi

dry_run=0
while [ $# -gt 0 ]; do
    case "$1" in 
        --cron)
            if [ "$allow_cron" -ne 1 ]; then
                exit
            fi
            ;;
        -n|--dry-run)
            dry_run=1
            ;;
        -h|--help)
            cat <<EOF

Usage: $0 [options]

Options:
 -n, --dry-run      Show results, but don't actually do anything
 -h, --help         This help message.

EOF
            exit 1
            ;;
    esac
    shift
done

IPTABLES_RESTORE=/sbin/iptables-restore

TMPFILE=/tmp/temp.pmfw.$$
umask 066

cat << EOF > "${TMPFILE}"
# This script generated by WebKnock by Danny Sung <danny@dannysung.com>
*filter
:INPUT DROP 
:FORWARD DROP 
:OUTPUT ACCEPT 
:in_pub - 
:in_pub_icmp - 
:in_pub_tcp - 
:in_pub_udp - 
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i ${iface_internet} -p tcp -j in_pub_tcp
-A INPUT -i ${iface_internet} -p udp -j in_pub_udp
-A INPUT -i ${iface_internet} -p icmp -j in_pub_icmp
EOF

if [ "$allow_ping" -eq 1 ]; then
cat << EOF >> "${TMPFILE}"
-A in_pub_icmp -p icmp -m icmp --icmp-type 3 -j ACCEPT
-A in_pub_icmp -p icmp -m icmp --icmp-type 8 -j ACCEPT
-A in_pub_icmp -p icmp -m icmp --icmp-type 11 -j ACCEPT
EOF
fi

if [ "$allow_http" -eq 1 ]; then
cat << EOF >> "${TMPFILE}"
-A in_pub_tcp -p tcp -m tcp --dport 80 -j ACCEPT
EOF
fi

if [ "$allow_https" -eq 1 ]; then
cat << EOF >> "${TMPFILE}"
-A in_pub_tcp -p tcp -m tcp --dport 443 -j ACCEPT
EOF
fi

# Hard-coded addresses to allow
if [ -f ${PMFW_DIR}/hosts.allow ]; then
    while read allow_name; do
    allow_name=$(echo "$allow_name" | sed 's/#.*//g')
    if [ ! -z "$allow_name" ]; then
        allow_ip=$(host -t A "${allow_name}" | cut -d' ' -f 4)
cat << EOF >> "${TMPFILE}"
-A in_pub_tcp -p tcp -m tcp --dport 22 -s "$allow_ip" -j ACCEPT
EOF
    fi
    unset allow_ip
    done < ${PMFW_DIR}/hosts.allow
fi


# Check our poorman's webknock
if [ "$allow_webknock" -eq 1 -a -x ${PMFW_DIR}/webknock.rules ]; then
shopt -s nullglob
for file_ip in /var/spool/webknock/*; do
    ip=$(basename $file_ip)
    if [ ! -z "$ip" ]; then
        export ip
        export iface_internet
        ${PMFW_DIR}/webknock.rules >> "${TMPFILE}"
    fi
done
fi

if [ "$allow_ntp" -eq 1 ]; then
cat << EOF >> "${TMPFILE}"
-A in_pub_udp -p udp -m udp --sport 123 --dport 123 -j ACCEPT
EOF
fi

if [ "$default_logging" -eq 1 ]; then
# Now add all the drop rules
cat << EOF >> "${TMPFILE}"
-A INPUT -m limit --limit 3/min --limit-burst 3 -j LOG --log-prefix "IPT INPUT died: " --log-level 7
-A INPUT -j DROP

-A in_pub_tcp -m limit --limit 3/min --limit-burst 3 -j LOG --log-prefix "IPT drop New: " --log-level 7
-A in_pub_tcp -p tcp -m state --state NEW -j DROP

-A in_pub_udp -p udp -j DROP
-A in_pub_udp -p udp -m limit --limit 3/min --limit-burst 3 -j LOG --log-prefix "IPT drop UDP: " --log-level 7

-A in_pub_icmp -p icmp -m limit --limit 3/min --limit-burst 3 -j LOG --log-prefix "IPT drop ICMP: " --log-level 7
-A in_pub_icmp -p icmp -j DROP
EOF
fi

if [ -r ${PMFW_DIR}/custom.rules ]; then
    cat ${PMFW_DIR}/custom.rules | sed '/^#/d' >> "${TMPFILE}"
fi

cat << EOF >> "${TMPFILE}"
COMMIT
EOF

if [ "$dry_run" -eq 1 ]; then
    cat "${TMPFILE}"
else
    cat "${TMPFILE}" | ${IPTABLES_RESTORE}
fi
rm -f "${TMPFILE}"

