#!/bin/bash
#set -x
DATE=`date +%Y%m%d`
DIR=/root/getresource/assembly/result
R_DIR=/root/getresource
ZONE_ID=`grep zone_id /pitrix/conf/global/server.yaml |head -1|awk -F"'" '{print $2}'`
source /root/getresource/user
n=${#users[@]}
i=0
while(( $i<$n ))
do
	sed -i "s/${users[i]}/${users[i+1]}/" $DIR/*
	let "i+=2"
done
cd $R_DIR/assembly
tar czf $R_DIR/result-$ZONE_ID-$DATE.tgz result/
