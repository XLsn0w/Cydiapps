#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Sun 18 Jun 2017 05:51:24 PM CST
#File Name: mysqlinit.sh
#Description:
#######################################################################

DEFAULT_FILE="/data/3306/my.cnf"
USER=root
PW=123456
SOCKFILE=/data/3306/mysql.sock

Usage() {
    echo "Usage $0 {start|stop|restart|status}"
    exit 1
}

loger() {
         LOG_INFO=$1
         /usr/bin/logger ${LOG_INFO}
}

if [ $# -gt 1 ];then
    Usage
fi

start_process() {
    [ -f ${DEFAULT_FILE} ] || echo "${DEFAULT_FILE} is not exist!";exit 1
    echo "Starting mysql..."
    mysqld_safe --defaults-file=${DEFAULT_FILE} &
    if [ $? -eq 0 ];then
        echo "mysql Started..."
        loger "started mysql on PID $mysql_id"
    else
        echo -e "\033[31m mysql Start Failed... \033[0m"
    fi
    mysql_id=$(cat ${SOCKFILE})
}

stop_process() {
    echo "Stopping mysql..."
    mysqladmin -u ${USER} -p ${PW} -S ${SOCKFILE} shutdown
    if [ $? -eq 0 ];then
        echo "mysql Stoped..."
        loger "stoped mysql"
    else
        echo -e "\033[31m mysql Stop Failed... \033[0m"
    fi
}
restart_process() {
    echo "restarting mysql...."
    stop_process
    start_process
    echo "mysql restarted..."
}
status_process() {
    ps aux |grep mysql > /dev/null
    if [ $? -eq 0 ]; then
        mysql_id=$(cat ${SOCKFILE})
        echo "mysql running on ${mysql_id}..."
    else
        echo "mysql is stoped..."
    fi
}

case "$1" in 
    start)
        start_process;;
    stop)
        stop_process;;
    restart)
        restart_process;;
    status)
        status_process;;
    *)
        Usage;;
esac    
    
