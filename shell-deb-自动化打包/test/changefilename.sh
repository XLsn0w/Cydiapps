#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Sun 18 Jun 2017 05:28:21 PM CST
#File Name: changefilename.sh
#Description:
#######################################################################
SCRIPT=$(readlink -f $0)
CWD=$(dirname ${SCRIPT})
cd $CWD
file_list=$(ls -1 .| grep haha)
for file in ${file_list};do
    random=$(echo $file|awk -F"-" '{print $2}'|awk -F'.' '{print $1}')
    echo $random
    mv $file heihei-${random}.TXT
done

