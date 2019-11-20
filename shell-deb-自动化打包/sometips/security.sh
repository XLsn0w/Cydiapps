#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Tue 24 Aug 2017 04:38:17 PM CST
#File Name: security.sh
#Description: 更新防火墙
#######################################################################
SCRIPT=$(readlink -f $0)
CWD=$(dirname ${SCRIPT})
sglist=$(cat $CWD/sglist)

if [ ! -d "${CWD}/actionlog" ];then
	mkdir ${CWD}/actionlog
fi

if [ ! -d "${CWD}/joblog" ];then
	mkdir ${CWD}/joblog
fi

check_job() {
	sg=$1
	jobId=$(grep job_id ${CWD}/actionlog/apply-${sg}.log|awk -F":" '{print $2}'|awk -F"\"" '{print $2}')
	cd /pitrix/cli/
	jobStatus=$(./describe-jobs -j ${jobId} |grep status|egrep -v 'time|]'|awk -F":" '{print $2}'|awk -F"\"" '{print $2}')
	if [ $jobStatus == "successful" ];then
		return 0
	else
		return 1
	fi
}

check_action() {
	sg=$1
	actionRet=$(grep ret_code ${CWD}/actionlog/addRule-${sg}.log|awk -F":" '{print $2}'|sort |uniq |tail -n 1)
	if [ $actionRet == 0 ];then
		echo "${sg} addRule is successful..."
	else
		echo "${sg} addRule is failed..."
		exit 1
	fi
}

cd /pitrix/cli/
for sg in ${sglist};do
	./add-security-group-rules -s ${sg} -r '[{"protocol":"tcp","priority":"1","direction":"0","action":"accept","val1":"1","val2":"20000","val3":"100.126.0.0/16"}]' >> ${CWD}/actionlog/addRule-${sg}.log
	check_action ${sg}
	sleep 1
	./add-security-group-rules -s ${sg} -r '[{"protocol":"tcp","priority":"1","direction":"1","action":"accept","val1":"1","val2":"20000","val3":"100.126.0.0/16"}]' >> ${CWD}/actionlog/addRule-${sg}.log
	check_action ${sg}
	sleep 1
	./apply-security-group -s ${sg} >> ${CWD}/actionlog/apply-${sg}.log
	for((i=0;i<120;i++)); do
		sleep 1
		check_job ${sg}
		if [ $? == 0 ];then
			echo "${sg} job is successful..." >> ${CWD}/joblog/job-${sg}.log
			break
		else
			continue
		fi
	done
	if [ $i -ge 120 ];  then
		echo "${sg} timeout...please check..." >> ${CWD}/joblog/job-${sg}.log
	fi
done
