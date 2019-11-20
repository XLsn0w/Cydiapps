#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Fri 08 Mar 2019 10:42:50 AM CST
#File Name: 12-脚本传参.sh
#Description: 以脚本传参以及read读入的方式比较2个整数大小
#######################################################################

isNum() {
    tmp=$1
    expr $tmp + 1 &> /dev/null
    return $?
}


if [ $# -ne 2 ];then
    echo "请输入2个参数"
    exit
fi

num1=$1
num2=$2

isNum $num1
flag1=$?
isNum $num2
flag2=$?
if [ $flag1 -ne 0 -o $flag2 -ne 0 ];then
    echo "请输入数字类型!"
    exit
fi


if [ $num1 -eq $num2 ];then
    echo "$num1 和 $num2 相等"
elif [ $num1 -gt $num2 ];then
    echo "$num1 大于 $num2"
else
    echo "$num1 小于 $num2"
fi
