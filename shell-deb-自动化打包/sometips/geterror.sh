#!/bin/bash

###################################################
# ShellName:geterror.sh
# Version: 0.1
# Function: Sorting error logs
# Author: Kellan Fan
# Organization: Qingcloud
# Date: 2016.12.05
# Description: none
####################################################

SHELL_NAME=`basename $0`
SHELL_LOG="/var/log/${SHELL_NAME}.log"
LOCK_FILE="/tmp/${SHELL_NAME}.lock"
NOTIFY_DIR="/notifier"
FILES=`find /notifier -path "/notifier/sort" -prune -o -type f -mtime -1 -not -name "*.sign"`


shell_log() {
     LOG_INFO=$1
     echo "$(date +%F) $(date +%R:%S) : ${SHELL_NAME} : ${LOG_INFO}" >> ${SHELL_LOG}
}

shell_lock() {
     touch ${LOCK_FILE}
}

shell_unlock() {
     rm -f ${LOCK_FILE}
}

del_timeoutfile() {
	find /notifier -mtime +1 -type f -print |xargs rm -rf &> /dev/null
	if [ $? == 0 ];then
		shell_log "clean up done"
	else
		shell_log "clean fail"
	fi
	rm /notifier/sort/*
}


checkfile() {
	FILES=`find /notifier -path "/notifier/sort/" -prune -o -type f -mtime -1 -not -name "*.sign"`
	declare -a array
	for file in $FILES; do
		NUM=`nl $file |egrep '<h3>'|wc -l`
		LIST=`nl $file |egrep '<h3>'|awk '{print $1}'|xargs echo`
		re_file=`basename ${file}`
		if [ "${NUM}" -gt 1 ]; then
			i=0
			for list in $LIST;do
				array[$i]=$list
				let "i += 1"
			done
			j=0
			while (( j < $NUM )); do
				sed -n "${array[$j]},${array[$j+1]}p" $file > $NOTIFY_DIR/sort/$re_file-$j
				let "j += 1"
			done
		else
			cp $file $NOTIFY_DIR/sort/
		fi
	
	done
}

awklog() {
	DATE=`date +%F`
	HOST_NAME=''
	KEY=''
	if [[ -f ${LOCK_FILE} ]];then
		AWK_FILES=`find $NOTIFY_DIR/sort -type f`	
		for awk_file in $AWK_FILES; do
			HOST_NAME=`basename ${awk_file} | awk -F"_" '{print $3}'`
			KEY=`awk '/\<h3\>/{print $2}' $awk_file|awk -F"[" '{print $1}'`
			for key in $KEY
			do
				if [[ $key = kern.log ]];then
					awk '/\<p\>/{for(i=7;i<=NF;i++) printf $i" ";printf "\n"}' $awk_file |sort|uniq >> /root/result-$HOST_NAME-$DATE
				elif [[ $key =~ wf ]];then
					awk '/\<p\>/{for(i=5;i<=NF;i++) printf $i" ";printf "\n"}' $awk_file |sort|uniq >> /root/result-$HOST_NAME-$DATE
				elif [[ $key = supervisord.log ]];then
					awk '/\<p\>/{for(i=3;i<=NF;i++) printf $i" ";printf "\n"}' $awk_file |sort|uniq >> /root/result-$HOST_NAME-$DATE
				else
					awk '/\<p\>/{print $0}' $awk_file|sort| uniq >> /root/result-$HOST_NAME-$DATE
				fi
			done
		done
	fi
}

makeup()
{
	FILE_RESULT=`ls /root/result-*`
	DATE=`date +%F`
	for i in $FILE_RESULT
	do
		cat $i | sort >> /root/$DATE-result-tmp
	done
	cat /root/$DATE-result-tmp |sort | uniq > /root/$DATE-result
	rm /root/$DATE-result-tmp
	rm /root/result-*
}
shell_lock
del_timeoutfile
if [ ! -d $NOTIFY_DIR/sort ];then
	mkdir $NOTIFY_DIR/sort
fi
checkfile
awklog
makeup
shell_unlock
