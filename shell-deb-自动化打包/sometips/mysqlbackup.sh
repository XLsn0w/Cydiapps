#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Sun 07 Oct 2018 10:45:21 PM CST
#File Name: mysqlbackup.sh
#Description:
#######################################################################

SCRIPT=`readlink -f $0`
CWD=`dirname $SCRIPT`
LOG_FILE="/var/log/mysql/mysqlbackup.log"
CONF_FILE="$CWD/mysql.conf"
BACKUP_DIR="/root/data/mysqlbackup"
max_dump_num=12

log() {
    msg=$1
    DATE=`date +'%F %R'`
    echo "$DATE $msg" >> $LOG_FILE
}

backup() {
    log "开始备份..."
    /usr/bin/mysqldump -u$USER -p$PASSWORD -h$HOST --flush-logs --databases $DATABASE > $BACKUP_DIR/$(date +%Y%m%d)_full_backup.sql
    if [ $? == 0 ];then
        log "备份完成..."
    else
        log "备份失败..."
    fi
}

cleanup() {
    count=`ls -1 $BACKUP_DIR |wc -l`
	if [ $count -gt $max_dump_num ]; then
		delnum=`expr $count - $max_dump_num`
		cd $BACKUP_DIR
		ls -1t $BACKUP_DIR | tail -$delnum | xargs rm -f
	fi
}
if [ -f $CONF_FILE ];then
    . $CONF_FILE
else
    echo "no configure file..."
    exit
fi


if [ $UID != 0 ];then
    echo "please run by uesr root..."
    exit
fi

if [ ! -d $BACKUP_DIR ];then
    mkdir -p $BACKUP_DIR
fi
backup
cleanup
