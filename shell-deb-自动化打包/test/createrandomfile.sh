#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Sun 18 Jun 2017 05:09:24 PM CST
#File Name: createrandomfile.sh
#Description:
#######################################################################
i=0
while [ $i -lt 5 ];do
    a=`bash createrandomword.sh`
    touch haha-${a}.txt
    let i++
done
