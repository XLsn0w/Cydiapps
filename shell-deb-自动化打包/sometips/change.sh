#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Wed 28 Mar 2018 09:04:33 AM CST
#File Name: change.sh
#Description:
#######################################################################

Usage() {
    echo "Usage:"
    echo "    $0 ip"
}


if [ $# -ne 1 ];then
    Usage
    exit 1
fi
hostname=`hostname`
ip=$1
echo " hostname is $hostname, ip is $ip"
#sed -i 's/INSTHOSTNAME/${hostname}/' /etc/hosts
#sed -i 's/INSTHOSTNAME/${hostname}/' /etc/hostname
ip_head=`echo $ip |tr '.' ' '|awk '{print $1}'`
if [[ ${ip_head} -eq 172 ]];then
    cp interfaces-172 /etc/network/interfaces
    chmod 644 /etc/network/interfaces
    sed -i '/address/s/172.10.24.10/${ip}/' /etc/network/interfaces
elif [[ ${ip_head} -eq 10 ]];then
    cp interfaces-10 /etc/network/interfaces
    chmod 644 /etc/network/interfaces
    sed -i '/address/s/10.130.254.10/${ip}/' /etc/network/interfaces
else
    echo "WTF!!!!"
    exit 1
fi
