#!/bin/bash

#######参数#######
DENYIPLIST="/usr/local/sbin/denyiplist"
SSH_PORT=2222
IPLIST=`grep "Invalid user" /var/log/auth.log |awk '{print $10}'|sort|uniq`

#根据ip加防火墙规则
Iptables() {
    ip=$1
    grep $ip $DENYIPLIST > /dev/null
    if [ $? -ne 0 ]; then
        iptables -A INPUT -s $ip -p tcp --dport $SSH_PORT -j DROP
        echo $ip >> $DENYIPLIST
        /usr/bin/logger "${ip} had been denyed by iptables..."
    fi
}

#检查这个ip是否还在连着主机，如果连着，就kill掉进程
check() {
    ip=$1
    netstat -an|grep $SSH_PORT|grep $ip > /dev/null
    if [ $? -eq 0 ];then
       ssh_pid=`ss  -p -o state established "( sport = :$SSH_PORT )"|grep $ip |awk -F',' '{print $2}'|awk -F'=' '{print $2}'`
       kill -9 $ssh_pid
       /usr/bin/logger "${ip} connecting, Pid is $ssh_pid, killed.."
    fi
}

####main#####
for ip in $IPLIST; do
    Iptables $ip
    check $ip
done
