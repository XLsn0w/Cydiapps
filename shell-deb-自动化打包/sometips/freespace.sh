#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Sun 09 Sep 2018 09:24:35 PM CST
#File Name: freespace.sh
#Description:
#######################################################################

dirs=('/var/log' '/tmp');
current_precent=`df |grep ^/|awk '{print $5}'|awk -F'%' '{print $1}'`
if [ $current_precent -gt 10 ];then
    for dir in ${dirs[*]};do
        filelist=`find $dir -size +10M -name *.log`
        for file in $filelist;do
            echo "" > $file && echo "clean ok.."
        done
    done
fi
