#!/bin/bash
# set -x

SCRIPT=`readlink -f $0`
CWD=`dirname $SCRIPT`

function usage()
{
    echo "Usage:"
    echo "    exec_nodes.sh [-f/--force-yes] <nodes> <cmd>"
    echo "      -f/--force-yes means force yes"
    echo "Example:"
    echo "    exec_nodes.sh -f testr01n01 \"apt-get update\""
    echo "    exec_nodes.sh hyper \"grep pitrix /etc/fstab\""
    echo "    exec_nodes.sh testr01n01,testr01n02 \"apt-get update\""
    echo "    exec_nodes.sh testr01n01,hyper \"grep pitrix /etc/fstab\""
}

if [[ "x$1" == "x-h" ]] || [[ "x$1" == "x--help" ]]; then
    usage
    exit 1
fi

if [ $# -lt 2 ]; then
    usage
    exit 1
fi

if [[ "x$1" == "x-f" ]] || [[ "x$1" == "x--force-yes" ]]; then
    option="--force-yes"
    shift
else
    option=""
fi
NODES=$1
shift
cmd=$@


echo $NODES | grep -q ','
if [ $? -eq 0 ]; then
    NODES=`echo $NODES | tr ',' ' '`
fi

new_nodes=()
for NODE in $NODES
do
    if [[ -z "$NODE" ]]; then
        continue
    fi
    if [ -f $CWD/nodes/$NODE ]; then
        . $CWD/nodes/$NODE
    else
        nodes=($NODE)
    fi
    new_nodes=(${new_nodes[@]} ${nodes[@]})
done
nodes=(${new_nodes[@]})

if [ ${#nodes[@]} -eq 0 ]; then
    echo "Error: the argument <nodes> is empty, please input a valid one."
    exit 1
fi

# nodes is array

nodes_str=$(IFS=, ; echo "${nodes[*]}")
cmd_str="$cmd"
echo "------------------------------------------------"
echo -e "TARGET NODES:\n    ${nodes_str}"
echo "------------------------------------------------"
echo -e "TARGET COMMAND:\n    $cmd"
echo "------------------------------------------------"

function confirm()
{
    msg=$*
    while [ 1 -eq 1 ]
    do
        read -r -p "${msg}" response
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

if [[ "x$option" != "x--force-yes" ]]; then
    val=`confirm "Are you sure to exec the command on the above nodes [y/N]?"`
    if [ $val -ne 0 ]; then
        exit 0
    fi
fi

mkdir -p /var/log/exec_nodes
log_file="/var/log/exec_nodes/exec_nodes.log"
if [ -f ${log_file} ]; then
    echo "" >> ${log_file}
fi

function log()
{
   msg=$*
   DATE=`date +'%Y-%m-%d %H:%M:%S'`
   echo "$DATE $msg" >> ${log_file}
}

conf_file="/tmp/exec_nodes_${NODE}_$$"
rm -f ${conf_file}
for node in ${nodes[@]}
do
    echo "$node#$cmd" >> ${conf_file}
done

job_log="/tmp/exec_nodes_job_log_$$"
rm -f ${job_log}

log "Execing [${nodes[@]}] with [$cmd] ..."
cat ${conf_file} | parallel -j 10 --colsep '#' --joblog ${job_log} $CWD/_exec_node.sh {1} {2} 2>&1 | tee -a ${log_file}
log "Exec [${nodes[@]}] with [$cmd] Finish."
echo "Done."

# get the exit codes from the job log file and check them
cat ${job_log} | awk '{print $7}' | grep -v 'Exitval' | sort | uniq | grep -qw '1'
if [ $? -eq 0 ]; then
    rm -f ${conf_file}
    rm -f ${job_log}
    exit 1
else
    rm -f ${conf_file}
    rm -f ${job_log}
    exit 0
fi
