#!/bin/bash
#
cd $(dirname $0) 
server_ip="192.168.8.11"   #server_ip="10.17.80.12"
server_mac="ec:0d:9a:d9:ba:ce" #server_mac="18:c5:8a:10:ad:53"
gw=$( python -c "print '.'.join('${server_ip}'.split('.')[:-1])" ) 
ip_line=$( ip route show |grep " src $gw" )
##########################################################################
ip=$( python -c "print '${ip_line}'.split()[-1]" )
dev=$( python -c "dev='${ip_line}'.split()[2];print dev.split('@')[0]" ) # fix vlan 
cmd="modprobe netconsole netconsole=6666@${ip}/${dev},6666@${server_ip}/${server_mac}"

##########################################################################
set_console(){
    rc_file='/etc/rc.local.tail' 
    if [ ! -e $rc_file ] ; then 
        rc_file='/etc/rc.local' 
    fi
      
    if [ -e $rc_file ] ; then 
        sed -i  '/modprobe netconsole /d' $rc_file 
        echo "lsmod  |grep netconsole && rmmod netconsole && $cmd"
        echo $cmd >>$rc_file
        echo m  >>/proc/sysrq-trigger  # send massage  
        echo "$cmd"
        ssh $server_ip  "ls /var/log/netconsole/${ip}-netconsole.log && echo __success__"
    fi
}

set_console
