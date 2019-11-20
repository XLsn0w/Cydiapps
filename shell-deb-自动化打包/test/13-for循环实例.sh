#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Fri 08 Mar 2019 10:23:28 AM CST
#File Name: 13-for循环实例.sh
#Description: bash for循环打印下面这句话中字母数不大于6的单词
#I am oldboy teacher welcome to oldboy training class.
#######################################################################

str='I am oldboy teacher welcome to oldboy training class.'
for i in $str;do
    count=${#i}
    if [ $count -lt 6 ];then
        echo "[$i] has $count character.."
    fi
done

