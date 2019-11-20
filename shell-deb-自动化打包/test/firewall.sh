#!/bin/bash

PATH=/sbin:/bin:/usr/sbin:/usr/bin; export PATH


#1 clean tables

iptables -F
iptables -X
iptables -Z

#2 policy

iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

#3 policy....

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -s 192.168.180.0/24 -j ACCEPT

#4 save

