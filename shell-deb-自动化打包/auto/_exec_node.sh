#!/bin/bash
# set -x

SCRIPT=`readlink -f $0`
CWD=`dirname $SCRIPT`

function usage()
{
    echo "Usage:"
    echo "    exec_one_node.sh <node> <cmd>"
    echo "Example:"
    echo "    exec_one_node.sh test \"apt-get update\""
}

if [[ "x$1" == "x-h" ]] || [[ "x$1" == "x--help" ]]; then
    usage
    exit 1
fi

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

node=$1
shift
cmd=$@

ping -c 1 -w 1 $node > /dev/null 2>&1
if [ $? -ne 0 ];then
    echo "Error: The node [$node] is unreachable. Please check the network!"
    exit 1
fi

mkdir -p /var/log/exec_nodes
log_file="/var/log/exec_nodes/exec_${node}.log"
if [ -f ${log_file} ]; then
    echo "" >> ${log_file}
fi

function log()
{
   msg=$*
   DATE=`date +'%Y-%m-%d %H:%M:%S'`
   echo "$DATE $msg" >> ${log_file}
}

echo "Execing [$node] with [$cmd] ..."
log "Execing [$node] with [$cmd] ..."
ssh -o ConnectTimeout=3 -o ConnectionAttempts=1 $node $cmd 2>&1 | tee -a ${log_file}
if [ $? -eq 0 ]; then
    echo ""
    log "Exec [$node] with [$cmd] OK."
    exit 0
else
    echo ""
    log "Exec [$node] with [$cmd] Error!"
    exit 1
fi
