#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Sun 18 Jun 2017 02:51:51 PM CST
#File Name: mysqlcheck.sh
#Description: Monitoring whether MySQL master slave synchronization is 
#             abnormal
#             And you can crontab
#             */30 * * * * nohub $SCRIPT >/dev/null &
#######################################################################

SCRIPT=$(readlink -f $0)
CWD=$(dirname ${SCRIPT})
INFO_FILE=${CWD}/mysqlstatus.txt

MASTER_HOST=$(grep Master_Host ${INFO_FILE} |awk -F':' '{print $2}')
SLAVE_HOST=$(ifconfig eth0|grep inet|head -1|awk '{print $2}'|awk -F":" '{print $2}')
SLAVE_IO_RUNNING=$(grep Slave_IO_Running ${INFO_FILE} | awk '{print $2}')
SLAVE_SQL_RUNNING=$(grep Slave_SQL_Running ${INFO_FILE} | awk '{print $2}')
SECONDS_BEHIND_MASTER=$(grep Seconds_Behind_Master ${INFO_FILE} | awk '{print $2}')
error_code=$(grep Last_Errno ${INFO_FILE}| awk '{print $2}')

mailto() {
    to_address="icyfk1989@163.com"
    email_title="WARNING! The Mysql Master Slave cluster has Error!"
    content=$1
    echo ${content} | mail -s ${email_title} ${to_address} 
}

ignore_error() {
    ignore_code=( 158 1159 1008 1007 1062 )
    for i in "${ignore_code[@]}";do
        if [ $i -eq ${error_code} ];then
            /usr/bin/logger "error_code is ${error_code}, but ignore it!"
            exit 1
        fi
    done
}

MS_sync_check() {
    ignore_error
    declare -A a
    if [ "${SLAVE_IO_RUNNING}" == "Yes" -a "${SLAVE_SQL_RUNNING}" == "Yes" -a ${SECONDS_BEHIND_MASTER} -lt 60 ]; then
        /usr/bin/logger "MySQL master slave synchronization is normal"
    else
        if [ "${SLAVE_IO_RUNNING}" == "No" ];then
            a['Slave_IO_Running']=${SLAVE_IO_RUNNING}
            a['error_code']=${error_code}
            mailto "the synchronization has error, slave ${SLAVE_HOST} TO master ${MASTER_HOST} , Slave_IO_Running is No and Error_code is ${error_code}"
        elif [ "${SLAVE_SQL_RUNNING}" == 'No' ];then
            a['Slave_Sql_Running']=${SLAVE_IO_RUNNING}
            a['error_code']=${error_code}
            mailto "the synchronization has error, slave ${SLAVE_HOST} TO master ${MASTER_HOST} , Slave_Sql_Running is No and Error_code is ${error_code}"
        elif [ "${SECONDS_BEHIND_MASTER}" -gt 60 ];then
            mailto "the synchronization has error, slave ${SLAVE_HOST} TO master ${MASTER_HOST} , Seconds_Behind_Master is logger 60, plaese check the network!"
        fi
    fi
}


if [ $UID -ne 0 ];then
    echo "you are not root user,Please run as root"
    exit 1
else
    MS_sync_check
fi 
