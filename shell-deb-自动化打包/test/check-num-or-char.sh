#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Sun 18 Jun 2017 06:34:47 PM CST
#File Name: check-num-or-char.sh
#Description:
#######################################################################
b=$((${RANDOM}%10))
check() {
    echo $1|grep -E "^[[:digit:]]+(\.[[:digit:]]+)?$" > /dev/null
    if [ $? -ne 0 ];then
        echo "please input a num!"
            exit 1
    else
        if [ ${a} -ge 10 ];then
            echo "plese input in 10"
            exit 1
        fi
     fi
}
while [ 1 -eq 1 ];do
    read -p "input you want " a
    check ${a}
    if [ ${a} -eq ${b} ]; then
        echo "Yeah!"
        exit 0
    elif [ ${a} -gt ${b} ]; then
        echo "bigger!"
    elif [ ${a} -lt ${b} ]; then
        echo "smaller!"
    fi
done
