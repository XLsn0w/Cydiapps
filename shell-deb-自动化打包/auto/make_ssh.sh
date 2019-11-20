#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Sun 21 Oct 2018 08:56:27 PM CST
#File Name: make_ssh.sh
#Description:
#######################################################################

SCRIPT=`readlink -f $0`
CWD=`dirname $SCRIPT`

function usage()
{
    echo "Usage:"
    echo "    make_ssh.sh <ip>/<ip_list> [<ssh_port> <user> <password>]"
    echo "      <ip> is the ip you want to establish ssh connection"
    echo "      <ip_list> is the ip list file including ips, one ip one line"
    echo "      <ssh_port> is the ssh port of the node, 22 is default"
    echo "      <user> is the user of the node, yop is default"
    echo "      <password> is the password of the node, 123456 is default"
    echo "Example:"
    echo "    make_ssh.sh 10.16.10.10"
    echo "    make_ssh.sh /root/ip_list"
    echo "    make_ssh.sh 10.16.10.10 22"
    echo "    make_ssh.sh /root/ip_list 22 testuser 123456"
}

if [[ "x$1" == "x-h" ]] || [[ "x$1" == "x--help" ]]; then
    usage
    exit 1
fi

if [ $# -eq 0 ] || [ $# -gt 4 ]; then
    usage
    exit 1
fi

IPS=$1
ssh_port=$2
user=$3
password=$4

num=`echo $IPS | tr '.' '\n' | wc -l`
if [ $num -eq 4 ]; then
    ips=$IPS
elif [ -f $IPS ]; then
    ips=`cat $IPS`
else
    echo "The ip or ip list [${IPS}] is invalid!"
    exit 1
fi

if [[ "x${ssh_port}" == "x" ]]; then
    ssh_port='22'
fi

if [[ "x$user" == "x" ]]; then
    user='ubuntu'
fi

if [[ "x$password" == "x" ]]; then
    password='123456'
fi

# the node ssh port will be used
SSH_PORT=`cat /etc/ssh/sshd_config | grep 'Port' | grep -v '^#' | awk '{print $2}'`

function establish_ssh()
{
    local ip=$1

    # refresh the known_hosts file
    ssh-keygen -f "/root/.ssh/known_hosts" -R $ip

    if [[ x"$user" == x"root" ]]; then
        home_dir="/root"
    else
        home_dir="/home/$user"
    fi
    /usr/bin/expect << EOF
set timeout 60
spawn scp -P ${ssh_port} -r /root/.ssh/ $user@$ip:$home_dir/
expect {
    "*password*" {
        send "$password\r";
        exp_continue;
    }
    eof
}
exit
EOF
    /usr/bin/expect << EOF
set timeout 60
spawn ssh -p ${ssh_port} -t $user:$password@$ip "sudo cp -r $home_dir/.ssh/ /root/"
expect {
    "*password*" {
        send "$password\r";
        exp_continue;
    }
    eof
}
exit
EOF
    scp -P ${ssh_port} /etc/ssh/ssh_config ${ip}:/etc/ssh/
    scp -P ${ssh_port} /etc/ssh/sshd_config ${ip}:/etc/ssh/
    ssh -p ${ssh_port} ${ip} "service ssh restart"

    # refresh the known_hosts file for new ssh port
    hostname=$(ssh ${ip} "hostname")
    ssh-keygen -f "/root/.ssh/known_hosts" -R ${ip}
    ssh-keygen -f "/root/.ssh/known_hosts" -R ${hostname}
    return 0
}

mkdir -p /var/log/node
log_file=/var/log/node/establish_ssh.log
if [ -f ${log_file} ]; then
    echo "" >> ${log_file}
fi

function log()
{
    msg=$*
    date=`date +'%Y-%m-%d %H:%M:%S'`
    echo "$date $msg" >> ${log_file}
}

function SafeEstablish()
{
    local ip=$1
    date=`date +'%Y-%m-%d %H:%M:%S'`
    echo -n "$date Establishing [$ip] ssh connection ... "
    log "Establishing [$ip] ssh connection ..."
    establish_ssh $ip >>${log_file} 2>&1
    if [ $? -eq 0 ]; then
        echo -n "OK." && echo ""
        log "Establish [$ip] ssh connection OK."
    else
        echo -n "Error!" && echo ""
        log "Establish [$ip] ssh connection Error!"
        exit 1
    fi
}

for ip in $ips
do
    # start establish
    SafeEstablish $ip
done

