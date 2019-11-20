#!/bin/bash
#set -x
#set -e

SCRIPT=$(readlink -f $0)
CWD=$(dirname $SCRIPT)
LOG_DIR="${CWD}/vxnet_log"
TIMEOUT=30

function wait_job() {
    job_id=$1
    cd /pitrix/cli || exit
    ./describe-jobs -j ${job_id} |grep successful > /dev/null
    if [ $? -eq 0 ];then
        return 0
    else
        return 1
    fi
}

if [ -f "${CWD}/vxnet_list" ];then
    vxnets=`cat ${CWD}/vxnet_list`
else
    echo "can not find [vxnet_list] file.."
    exit
fi
if [ -f "${CWD}/hyper_list" ];then
    hypers=`cat ${CWD}/hyper_list`
else
    echo "can not find [hyper_list] file.."
    exit
fi

if [ ! -d "${CWD}/${LOG_DIR}" ];then
    mkdir ${CWD}/${LOG_DIR}
fi

cd /pitrix/cli || exit

for vxnet in $vxnets;do
    for hyper in $hypers;do
        ./rebuild_vxnet -l 2 -t $hyper -v $vxnet >> ${CWD}/${LOG_DIR}/vxnet-${vxnet}.log
        
        job_id=$(grep job_id ${CWD}/${LOG_DIR}/vxnet-${vxnet}.log | awk -F':' '{print $2}'|awk -F'"' '{print $2}')
        timer=0
        while true;do
            sleep 5
            if wait_job "${job_id}";then
                break
            else
                timer=$(($timer+5))
                if [ ${timer} -ge ${TIMEOUT} ];then
                    echo "${job_id} is timeout, please check.." | tee >> "${CWD}"/"${LOG_DIR}"/error.log
                    break
                fi
                continue
            fi 
        done
    done
done
