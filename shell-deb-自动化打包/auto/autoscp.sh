#!/bin/bash

SCRIPT=`readlink -f $0`
CWD=`dirname $SCRIPT`
LOG_FILE="$CWD/log/autoscp.log"
[ -d $CWD/log ] || mkdir $CWD/log
cd $CWD
usage() {
    echo "Usage: $(basename $0) <node> <src> <dst>"
    echo "   Ex: $(basename $0) webserver0 /etc/hosts /etc"
}
if [ $# -lt 3 ]; then
    echo "Error: invalid parameters"
    usage
    exit 1
fi
user=`cat $CWD/conf/user`
port=`cat $CWD/conf/port`
NODE_DIR=$CWD/node
if [ -d $NODE_DIR ]; then
    if [ -f $NODE_DIR/${1} ];then
        . $NODE_DIR/${1}
    else
        nodes=("${1}")
    fi
else
    echo "Error: $NODE_DIR not exist!!!"
    exit 1
fi
src=$2
dst=$3
log() {
    msg=$1
    DATE=`date +'%F %R'`
    echo "$DATE $msg" >> $LOG_FILE
}
confirm()
{
    msg=$1
    # response="y"
    # call with a prompt string or use a default
    while [ 1 -eq 1 ]
    do
        read -r -p "${1:-msg} click 'y' to continue, 'n' to ignore " response
        case $response in
            [yY][eE][sS]|[yY])
                echo 0
                return
                ;;
            [nN][oO]|[nN])
                echo 1
                return
                ;;
        esac
    done
}
nodes_list=$(IFS=, ; echo ${nodes[*]})
log "Execing scp $src to ${node_}:${dst}.."
var=`confirm "Are you sure scp [${src}] to [${nodes_list}] : [${dst}]?"`
if [ $var -eq 0 ];then 
    for i in "${!nodes[@]}"; do
        node_="${nodes[$i]}"
        echo -en "Execing scp $src to ${node_}:${dst}..\n"
        scp -r -p -o ConnectTimeout=3 -o ConnectionAttempts=1 $src $node_:$dst
        echo
    done
fi

echo "Done"
exit 0
