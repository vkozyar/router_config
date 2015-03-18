#!/bin/bash
# Load balancing script by Vasyl Koziar
#
# #eth0 - 192.168.1.2 ukrtel1 - default
# #eth1 - 192.168.0.2 ukrtel2
# #eth2 - 192.168.165.52 local_provider
# #eth3 - 102.168.2.0 local net
# Gateways
# ukrtel1="192.168.1.1"
# ukrtel2="192.168.0.1"
# local_provider="192.168.165.1"
#
# VRRP="no"
# VRRPNET="192.168.1.254 netmask 255.255.255.0"
# DHCPD="no"
# DEADROUTECHK="no"
#
# LOCALNET="192.168.2.0/24"
# WAN interface 1
IF1="eth0"
# WAN interface 2
IF2="eth1"
# WAN interface 3
IF3="eth2"
# LAN interface
IF4="eth3"
 
gw_isp1_ukrtel1="192.168.1.1"
gw_isp2_ukrtel2="192.168.0.1"
gw_isp3_local_provider="192.168.165.1"

IP1="192.168.1.2"
IP2="192.168.0.2"
#IP3="192.168.165.51"
IP3="`ifconfig $IF3 | grep 192 | awk -F":" '{print $2}' | awk -F" "  {'print $1'}`"
echo "IP3=$IP3"
IP4="192.168.2.4"
#IP3="`ip addr show $IF2 | grep inet | awk '{print $2}'`"
 
# WAN1 netmask
P1_NET="192.168.1.0/24"
# WAN2 netmask
P2_NET="192.168.0.0/24"
# WAN3 netmask
P3_NET="192.168.165.0/24"

# LAN 
P4_NET="192.168.2.0/24"

TBL1="isp1_ukrtel1"
TBL2="isp2_ukrtel2"
TBL3="isp3_local_provider"

echo "1" > /proc/sys/net/ipv4/ip_forward

# Add out route tables
#echo '103 isp1_ukrtel1' >> /etc/iproute2/rt_tables
#echo '102 isp2_ukrtel2' >> /etc/iproute2/rt_tables
#echo '101 isp3_local_provider' >> /etc/iproute2/rt_tables

ip route flush table isp1_ukrtel1
ip rule del table isp1_ukrtel1
ip route flush table isp2_ukrtel2
ip rule del table isp2_ukrtel2
ip route flush table isp3_local_provider
ip rule del table isp3_local_provider
ip route flush cache

ip route delete default

#ip route replace default scope global \

ip route add $P1_NET dev $IF1 src $IP1 table $TBL1
ip route add default via $gw_isp1_ukrtel1 table $TBL1
ip route add $P1_NET dev $IF1 src $IP1
ip route add default via $gw_isp1_ukrtel1

ip route add $P2_NET dev $IF2 src $IP2 table $TBL2 
ip route add default via $gw_isp2_ukrtel2 table $TBL2
ip route add $P2_NET dev $IF2 src $IP2
ip route add default via $gw_isp2_ukrtel2

ip route add $P3_NET dev $IF3 src $IP3 table $TBL3
ip route add default via $gw_isp3_local_provider table $TBL3
ip route add $P3_NET dev $IF3 src $IP3
ip route add default via $gw_isp3_local_provider 

ip rule add from $IP1 table $TBL1
ip rule add from $IP2 table $TBL2
ip rule add from $IP3 table $TBL3

# Routing for local LAN
ip route add $P4_NET dev $IF4 table $TBL1
ip route add $P1_NET dev $IF1 table $TBL1
ip route add $P2_NET dev $IF2 table $TBL1
ip route add $P3_NET dev $IF3 table $TBL1
ip route add 127.0.0.0/8 dev lo table $TBL1

ip route add $P4_NET dev $IF4 table $TBL2
ip route add $P1_NET dev $IF1 table $TBL2
ip route add $P2_NET dev $IF2 table $TBL2
ip route add $P3_NET dev $IF3 table $TBL2
ip route add 127.0.0.0/8 dev lo table $TBL2

ip route add $P4_NET dev $IF4 table $TBL3
ip route add $P1_NET dev $IF1 table $TBL3
ip route add $P2_NET dev $IF2 table $TBL3
ip route add $P3_NET dev $IF3 table $TBL3
ip route add 127.0.0.0/8 dev lo table $TBL3


##ip route add $P3_NET dev $IF3 table $TBL2
##ip route add 127.0.0.0/8 dev lo table $TBL2
##ip route add $P1_NET dev $IF1 table $TBL3
##ip route add $P2_NET dev $IF2 table $TBL3
##ip route add $P3_NET dev $IF3 table $TBL3
#ip route add 127.0.0.0/8 dev lo table $TBL3

##ip route add default via $gw_isp1_ukrtel1 dev eth0 table isp1_ukrtel1

ip route add default scope global nexthop via $gw_isp1_ukrtel1 dev $IF1 weight 4 \
nexthop via $gw_isp3_local_provider dev $IF3 weight 1
#nexthop via $gw_isp2_ukrtel2 dev $IF2 weight 4
#ip route add default scope global nexthop via $gw_isp2_ukrtel2

#nexthop via $gw_isp3_local_provider dev $IF3 weight 1

##ip route add default via $gw_isp1_ukrtel1 dev eth0 table isp1_ukrtel1
##ip route add default via $gw_isp2_ukrtel2 dev eth1 table isp2_ukrtel2
##ip route add default via $gw_isp3_local_provider dev eth2 table isp3_local_provider
#
ip rule add priority 103 fwmark 0x4/0x4 lookup isp1_ukrtel1
ip rule add priority 102 fwmark 0x2/0x2 lookup isp2_ukrtel2
ip rule add priority 101 fwmark 0x1/0x1 lookup isp3_local_provider

##ip route add default equalize nexthop via $gw_isp1_ukrtel1 \
##nexthop via $gw_isp1_ukrtel2 \
###nexthop via $gw_isp3_local_provider

##ip route replace default scope global \
##    nexthop via $gw_isp1_ukrtel1 dev eth0 weight 4 \
##    nexthop via $gw_isp2_ukrtel2 dev eth1 weight 4 \
##    nexthop via $gw_isp3_local_provider eth2 weight 1

ip route flush cache

# Marks packets
#ip rule add fwmark 3 table 103
#ip rule add fwmark 2 table 102
#ip rule add fwmark 1 table 101

# Default Firewall rules
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#iptables -P DROP
# Allow connections from localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
#iptables -A FORWARD -i lo -j ACCEPT
#iptables -A FORWARD -o lo -j ACCEPT

#Allow Ping from Inside to Outside
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

# Allow traceroute from Inside to Outside
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -m udp -p udp --sport 33434:33524 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m udp -p udp --dport 33434:33524 -m state --state NEW -j ACCEPT

#Allow all OUTPUT
#iptables -A OUTPUT -j ACCEPT # use it for testing only
iptables -A OUTPUT -o $IF1 -j ACCEPT
iptables -A OUTPUT -o $IF2 -j ACCEPT
iptables -A OUTPUT -o $IF3 -j ACCEPT
iptables -A OUTPUT -o $IF4 -j ACCEPT

# Allow incoming SSH from internal network
iptables -A INPUT -i $IF4 -p tcp --dport 22 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

# Allo dns for established package
iptables -A INPUT -p udp --source-port 53 --dport 1024:65535 -m state --state RELATED,ESTABLISHED -j ACCEPT

iptables -A INPUT -i $IF1 -p tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $IF2 -p tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $IF3 -p tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $IF4 -p tcp -m state --state RELATED,ESTABLISHED -j ACCEPT

#iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

iptables -t mangle -A POSTROUTING -o $IF1 -j MARK --set-mark 0x4/0x4
iptables -t mangle -A POSTROUTING -o $IF2 -j MARK --set-mark 0x2/0x2
iptables -t mangle -A POSTROUTING -o $IF3 -j MARK --set-mark 0x1/0x1
iptables -t mangle -A POSTROUTING -j CONNMARK --save-mark
iptables -t mangle -A PREROUTING -j CONNMARK --restore-mark


#iptables -t mangle -A INPUT -i $IF1 -j CONNMARK --set-mark 0x1
#iptables -t mangle -A INPUT -i $IF2 -j CONNMARK --set-mark 0x2
#iptables -t mangle -A INPUT -i $IF3 -j CONNMARK --set-mark 0x4
#iptables -t mangle -A INPUT -i $IF4 -j CONNMARK --set-mark 0x8

#iptables -t mangle -A OUTPUT -j CONNMARK --restore-mark

#iptables -t mangle -A OUTPUT -m mark ! --mark 0x0 -j ACCEPT



# Masquerading for all users
iptables -t nat -F POSTROUTING

iptables -t nat -A POSTROUTING -s $P1_NET -o $IF1 -j MASQUERADE
iptables -t nat -A POSTROUTING -s $P4_NET -o $IF1 -j MASQUERADE
iptables -t nat -A POSTROUTING -s $P2_NET -o $IF2 -j MASQUERADE
iptables -t nat -A POSTROUTING -s $P4_NET -o $IF2 -j MASQUERADE
iptables -t nat -A POSTROUTING -s $P3_NET -o $IF3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s $P4_NET -o $IF3 -j MASQUERADE

iptables -F FORWARD
#iptables -A FORWARD -j ACCEPT  # use it for testing only
iptables -A FORWARD -i $IF1 -o $IF4 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $IF2 -o $IF4 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $IF3 -o $IF4 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $IF4 -o $IF1 -j ACCEPT
iptables -A FORWARD -i $IF4 -o $IF2 -j ACCEPT
iptables -A FORWARD -i $IF4 -o $IF3 -j ACCEPT

#iptables -t nat -A POSTROUTING -s $P0_NET -o $IF2 -j MASQUERADE
