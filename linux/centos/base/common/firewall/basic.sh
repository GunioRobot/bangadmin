#!/bin/sh

#  Copyright (c) 2010, Sudheera Satyanarayana.
#  All rights reserved.
# 
#    Redistribution and use in source and binary forms, with or without modification,
#    are permitted provided that the following conditions are met:
# 
#    * Redistributions of source code must retain the above copyright notice,
#      this list of conditions and the following disclaimer.
# 
#    * Redistributions in binary form must reproduce the above copyright notice,
#      this list of conditions and the following disclaimer in the documentation
#      and/or other materials provided with the distribution.
# 
#    * Neither the names of Sudheera Satyanarayana nor the names of the project
#      contributors may be used to endorse or promote products derived from this
#      software without specific prior written permission.
# 
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
#  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#  
# 


# Contact - http://techchorus.net

# chkconfig: 345 26 27
# description: custom firewall
# processname: firewall



# iptables firewall rules to protect your server
# Server profile
# eth0 is the internet interface
# eth1 is the local network interface
# What you sould know to use this script
#   your ISP DNS server 1 IP
#   your ISP DNS server 2 IP
#




# What is allowed?
# By default INPUT and FORWARD chains DROP connection
# eth0 is allowed to listen on port 80
# eth0 is allowed to listen on port 3690 - SVN, Subversion
# Connection tracking is enabled using the ip_conntrack_ftp kernel model
# On recent versions of kernel, ip_conntrack_ftp is renamed to nf_conntrack_ftp
# So are all ip_* to nf_*
# Server is allowed to respond to ping requests
# The script takes care of basic IP address spoofing attacks
# It also checks whether the TCP/UDP packets look like they should be


# How to use this script?
# Set correct values of IPADDR, IPADDRLOCAL, ISPDNSSERVER1, ISPDNSSERVER2
# Stop iptables. Remove iptables from startup. Use ntsysv
# Copy this script contents to /etc/init.d/firewall
# To stop the firewall use `/etc/init.d/firewall stop`
# chmod 775 /etc/init.d/firewall
# chkconfig --add firewall

IPADDR="my.internet.ip.address"     
IPADDRLOCAL="my.lan.ip.address"
ISPDNSSERVER1="my.isp.dns.server1"
ISPDNSSERVER2="my.isp.dns.server1"

# Configuration ends here


# Enable the kernel module
/sbin/modprobe ip_conntrack_ftp
/sbin/modprobe nf_conntrack_ftp


###############################################################
# Variables

IPT="/sbin/iptables"                 # Location of iptables on your system
INTERNET="eth0"                      # Internet connected interface
LOOPBACK_INTERFACE="lo"              # however your system names it

CONNECTION_TRACKING="1"              # track connections?

ACCEPT_AUTH="1"
SSH_SERVER="1"
FTP_SERVER="0"
WEB_SERVER="1"
SSL_SERVER="0"
DHCP_CLIENT="1"


NAMESERVER="8.8.8.8"

LOOPBACK="127.0.0.0/8"               # Reserved loopback address range
CLASS_A="10.0.0.0/8"                 # Class A private networks
CLASS_B="172.16.0.0/12"              # Class B private networks
CLASS_C="192.168.0.0/16"             # Class C private networks
CLASS_D_MULTICAST="224.0.0.0/4"      # Class D multicast addresses
CLASS_E_RESERVED_NET="240.0.0.0/5"   # Class E reserved addresses
BROADCAST_SRC="0.0.0.0"              # Broadcast source address
BROADCAST_DEST="255.255.255.255"     # Broadcast destination address

PRIVPORTS="0:1023"                   # Well known privileged port range
UNPRIVPORTS="1024:65535"             # Unprivileged port range

SSH_PORTS="1024:65535"

NFS_PORT="2049"
LOCKD_PORT="4045"
SOCKS_PORT="1080"
OPENWINDOWS_PORT="2000"
XWINDOW_PORTS="6000:6063"
SQUID_PORT="3128"


###############################################################

# Enable broadcast echo Protection
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Disable Source Routed Packets
for f in /proc/sys/net/ipv4/conf/*/accept_source_route; do
    echo 0 > $f
done

# Enable TCP SYN Cookie Protection
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# Disable ICMP Redirect Acceptance
for f in /proc/sys/net/ipv4/conf/*/accept_redirects; do
    echo 0 > $f
done

# Don.t send Redirect Messages
for f in /proc/sys/net/ipv4/conf/*/send_redirects; do
    echo 0 > $f
done

# Drop Spoofed Packets coming in on an interface, which if replied to, 
# would result in the reply going out a different interface.
for f in /proc/sys/net/ipv4/conf/*/rp_filter; do
    echo 1 > $f
done

# Log packets with impossible addresses.
for f in /proc/sys/net/ipv4/conf/*/log_martians; do
    echo 1 > $f
done

###############################################################

# Remove any existing rules from all chains
$IPT --flush
$IPT -t nat --flush
$IPT -t mangle --flush
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X
$IPT --policy INPUT   ACCEPT
$IPT --policy OUTPUT  ACCEPT
$IPT --policy FORWARD ACCEPT
$IPT -t nat --policy PREROUTING  ACCEPT
$IPT -t nat --policy OUTPUT ACCEPT
$IPT -t nat --policy POSTROUTING ACCEPT
$IPT -t mangle --policy PREROUTING ACCEPT
$IPT -t mangle --policy OUTPUT ACCEPT

if [ "$1" = "stop" ]
then
echo "Firewall completely stopped!  WARNING: THIS HOST HAS NO FIREWALL RUNNING."
exit 0
fi


# Unlimited traffic on the loopback interface
$IPT -A INPUT  -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# Set the default policy to drop
$IPT --policy INPUT   DROP
$IPT --policy OUTPUT  ACCEPT
$IPT --policy FORWARD DROP

###############################################################

# Stealth Scans and TCP State Flags
# All of the bits are cleared
$IPT -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
# SYN and FIN are both set
$IPT -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
# SYN and RST are both set
$IPT -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
# FIN and RST are both set
$IPT -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
# FIN is the only bit set, without the expected accompanying ACK
$IPT -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j DROP
# PSH is the only bit set, without the expected accompanying ACK
$IPT -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP
# URG is the only bit set, without the expected accompanying ACK
$IPT -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP


# All of the bits are cleared

###############################################################
# Using Connection State to By-pass Rule Checking
if [ "$CONNECTION_TRACKING" = "1" ]; then
    $IPT -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
    $IPT -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # Using the state module alone, INVALID will break protocols that use
    # bi-directional connections or multiple connections or exchanges,
    # unless an ALG is provided for the protocol. At this time, FTP and is 
    # IRC are the only protocols with ALG support.

    $IPT -A INPUT -m state --state INVALID -j LOG \
             --log-prefix "INVALID input: "
    $IPT -A INPUT -m state --state INVALID -j DROP

    $IPT -A OUTPUT -m state --state INVALID -j LOG \
             --log-prefix "INVALID output: "
    $IPT -A OUTPUT -m state --state INVALID -j DROP
fi

###############################################################
# Refuse Class D multicast addresses
# illegal as a source address
$IPT -A INPUT -i $INTERNET -s $CLASS_D_MULTICAST -j DROP

$IPT -A INPUT -i $INTERNET -p ! udp -d $CLASS_D_MULTICAST -j DROP

$IPT -A INPUT  -i $INTERNET -p udp -d $CLASS_D_MULTICAST -j ACCEPT

# Refuse Class E reserved IP addresses
$IPT -A INPUT  -i $INTERNET -s $CLASS_E_RESERVED_NET -j DROP

# refuse addresses defined as reserved by the IANA
# 0.*.*.*          - Can.t be blocked unilaterally with DHCP
# 169.254.0.0/16   - Link Local Networks
# 192.0.2.0/24     - TEST-NET

$IPT -A INPUT -i $INTERNET -s 0.0.0.0/8 -j DROP
$IPT -A INPUT -i $INTERNET -s 169.254.0.0/16 -j DROP
$IPT -A INPUT -i $INTERNET -s 192.0.2.0/24 -j DROP


###############################################################
# Source Address Spoofing and Other Bad Addresses
# Incoming Remote Client Requests to Local Servers

# Allow DNS lookups
$IPT -A INPUT -p udp -s $ISPDNSSERVER1/32 --source-port 53 -d 0/0 --destination-port 1024:65535 -j ACCEPT
$IPT -A INPUT -p udp -s $ISPDNSSERVER2/32 --source-port 53 -d 0/0 --destination-port 1024:65535 -j ACCEPT

# Allow ssh connections
if [ "$SSH_SERVER" = "1" ]; then
$IPT -A INPUT -p tcp --dport 22 -j ACCEPT
$IPT -A OUTPUT -p tcp --sport 22 -j ACCEPT
fi

# Allow HTTP requests
if [ "$WEB_SERVER" = "1" ]; then
$IPT -A INPUT -p tcp --dport 80 -j ACCEPT
$IPT -A OUTPUT -p tcp --sport 80 -j ACCEPT
fi

# Allow pinging
$IPT -A INPUT -p icmp --icmp-type 8 -s 0/0 -d $IPADDR -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

$IPT -A OUTPUT -p icmp --icmp-type 0 -s $IPADDR -d 0/0 -m state --state ESTABLISHED,RELATED -j ACCEPT


# Allow SVN
$IPT -A INPUT -p tcp --dport 3690 -j ACCEPT
$IPT -A OUTPUT -p tcp --sport 3690 -j ACCEPT

##############################################################
# Logging Dropped Packets

# Don't log dropped incoming echo requests
$IPT -A INPUT -i $INTERNET -p icmp \
         --icmp-type ! 8 -d $IPADDR -j LOG

$IPT -A INPUT -i $INTERNET -p tcp \
         -d $IPADDR -j LOG

$IPT -A OUTPUT -o $INTERNET -j LOG

exit 0
