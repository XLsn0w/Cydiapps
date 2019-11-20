#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Jul 4 2017 11:37:27 AM CST
#File Name: scpkey.sh
#Description:
#######################################################################

SCRIPT=$(readlink -f $0)
CWD=$(dirname $SCRIPT)

[ -f ${CWD}/node/scpkey ] && nodes=$(cat ${CWD}/node/scpkey)
[ -f ${CWD}/conf/node.conf ] && . ${CWD}/conf/node.conf

checkalived() {
    node=$1
    ping -c 1 -w 1 $node > /dev/null
    if [ $? -eq 0 ];then
        echo "$node is alived..."
    else
        echo "$node is not alived..."
        exit 1
    fi
}


scpkey() {
    /usr/bin/expect << EOF
    set timeout 60
    spawn scp -r /root/.ssh ${USER}@${node}:~
    expect "*password*"
    send "${PASS}\r"
    expect eof
    exit
EOF
}

sudocpkey() {
    /usr/bin/expect << EOF
    set timeout 60
    spwan ssh -p ${PORT} -t ${USER}@${node} "sudo cp -r /home/${USER}/.ssh/ /root/"
    expect "*password*"
    send "${PASS}\r"
    expect eof
    exit
EOF
}


confirm() {
    msg=$1
    read -r -p "${1:-msg}" decision
    case $decision in
        [yY])
            echo 0
            ;;
        *)
            echo 1
            ;;
    esac
}

for node in $nodes; do
    checkalived $node
done

if [ "${USER}" == "root" ]; then
    var=`confirm "are you sure do this with ${USER}?[y/N]"`
    if [[ ${var} -eq 0 ]];then
        for node in $nodes; do
            scpkey
        done
    else
        echo "do not do this...."
        exit 1
    fi
else
    for node in $nodes; do
        scpkey
        sudocpkey
    done
fi

