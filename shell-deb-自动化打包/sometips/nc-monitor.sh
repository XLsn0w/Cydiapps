#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Thu 20 Jul 2017 02:41:56 PM CST
#File Name: nc-monitor.sh
#Description:
#######################################################################

SCRIPT=$(readlink -f $0)
CWD=$(dirname $SCRIPT)
LOGFILE=${CWD}/nc-monitor.log
while true;do
    for i in ${!nodes[@]};do
        node="${nodes[$i]}"
        nc -z ${node} 11211 > /dev/null
        if [ $? -eq 0 ]; then
            echo "$(date +%F) $(date +%R:%S) : ${node} port 11211 is ok..." >> ${LOGFILE}
        else
            echo "$(date +%F) $(date +%R:%S) : ${node} port 11211 is ERROR!!!!" >> ${LOGFILE}
        fi
    done
    /bin/sleep 1
    echo "============" >> ${LOGFILE}
done
