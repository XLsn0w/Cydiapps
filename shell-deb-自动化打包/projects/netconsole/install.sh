#!/bin/bash
#source get_server.sh 
cd $(dirname $0)
######################
server_ip="$1"
server_mac="$2"
if [ -n "$server_ip" -a -n "$server_mac" ] ; then 
    echo
    read -p "netconsole server ip is $server_ip , mac is $server_mac [y/n]: " stat 
    echo
    [ "$stat" != 'y' ] && exit -1
    echo server_ip > ./conf/netconsole_server
    echo server_ip=$server_ip   |tee server_ip
    echo server_mac=$server_mac |tee server_mac
else
    echo -e "\n./install.sh <netcosole_server_ip> <netconsole_server_mac>\n"
    exit -1
fi
#################################
if [ "$stat" == "y" ] ; then 
    cp netconsole.sh.example  netconsole.sh
    sed -i "s/{{server_ip}}/$server_ip/g"   netconsole.sh 
    sed -i "s/{{server_mac}}/$server_mac/g" netconsole.sh 
    scp ins_server.sh ${server_ip}:/tmp/ && ssh ${server_ip}  bash /tmp/ins_server.sh
    bash ins_client.sh  |tee -a fix.log 
fi

