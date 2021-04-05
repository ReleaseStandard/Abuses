#!/bin/bash
#
#
# This script must be run as root.
# It will cause a small network disconnection to user (ex: 1-2s).
# This disconnect could show as a desktop notification (ex: under ubuntu).
# The connexion will not be reported by wireshark, opensnitch, netstat.
# The targeted kernel must support network namespaces (ex: 3.x+ kernels)
#

if ! [ "$(whoami)" = "root" ] ; then echo "must be root"; exit 1 ; fi

n="test${RANDOM}"
i=$(ip r |grep "default" |head -n 1 |sed 's/^.*dev \([^ ]\+\) .*$/\1/')

start="$(date +%s)"
> /var/run/netns/default
mount --bind /proc/1/ns/net /var/run/netns/default
ip netns add $n
ip link set $i netns $n
ip netns exec $n dhclient $i

echo "=================";
echo "";
echo "Device ready !";
echo "";
echo "=================";
echo "";
ip netns exec $n ifconfig -a
ip netns exec $n ip link show
echo "";
ip netns exec $n cp /etc/resolv.conf /tmp/
ip netns exec $n bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
echo "";
echo "Network ready !";
echo "";
ip netns exec $n wget -O - https://github.com/
ip netns exec $n ping -c 1 8.8.8.8;
echo "";
echo "Network clean up";
echo "";
ip netns exec $n mv /tmp/resolv.conf /etc/
ip netns exec $n ip link set $i netns default
ip netns del $n
dhclient $i
ip netns del default

stop="$(date +%s)"
let diff=stop-start;


echo "";
echo "";
echo "User has experienced a disconnect of $diff secs...";
echo "";
echo "";

