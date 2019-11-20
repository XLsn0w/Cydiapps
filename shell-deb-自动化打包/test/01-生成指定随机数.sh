#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Fri 09 Mar 2018 03:33:34 PM CST
#File Name: 01-生成指定随机数.sh
#Description:
#######################################################################

#获取50范围【1-50】的随机数
echo $((RANDOM%50+1))

#shell脚本生成[4,9]范围内的随机整数，包含边界值4和9，并将随机数序列存放在一个数组中。
#功能要求：要求不能有重复的随机数.　参考:shell不重复随机数生成方法(模拟彩票随机抽奖)
declare -a arr #声明arr为数组
arr=(`seq 4 9 | awk 'BEGIN{srand();ORS=" "} {b[rand()]=$0} END{for(x in b) print b[x]}'`)
echo ${arr[*]} #打印数组array的所有元素

#说明：
#生成[4,9]范围内不重复的随机整数，并保存到数组arr中。
#seq 4 9 用于生成4~9的整数序列（包含边界值4和9）。
#awk中的rand() 函数用于随机产生一个0到1之间的小数值（保留小数点后6位）。
#由于rand()只生成一次随机数，要使用srand() 函数使随机数滚动生成（括号里留空即默认采用当前时间作为随机计数器的种子）。这样以秒为间隔，随机数就能滚动随机生成了。

#限制：
#由于以秒为间隔，所以如果快速连续运行两次脚本（1s内），你会发现生成的随机数还是一样的。


#生成400000~500000的随机数
function rand(){ 
    min=$1
    max=$(($2-$min+1)) 
    num=$(($RANDOM+1000000000)) #增加一个10位的数再求余 
    echo $(($num%$max+$min)) 
} 

rnd=$(rand 400000 500000) 
echo $rnd 


#使用date +%s%N
function rand1(){ 
    min=$1 
    max=$(($2-$min+1)) 
    num=$(date +%s%N) 
    echo $(($num%$max+$min)) 
} 

rnd=$(rand1 1 50) 
echo $rnd


#使用/dev/random 和 /dev/urandom

#/dev/random 存储着系统当前运行环境的实时数据，是阻塞的随机数发生器，读取有时需要等待。
#/dev/urandom 非阻塞随机数发生器，读取操作不会产生阻塞。
function rand2(){ 
    min=$1 
    max=$(($2-$min+1)) 
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}') 
    echo $(($num%$max+$min)) 
} 

rnd=$(rand2 100 500) 
echo $rnd 

#使用linux uuid
#uuid 全称是通用唯一识别码，格式包含32个16进制数字，以'-'连接号分为5段。形式为8-4-4-4-12 的32个字符。

function rand3(){ 
    min=$1 
    max=$(($2-$min+1)) 
    num=$(cat /proc/sys/kernel/random/uuid | cksum | awk -F ' ' '{print $1}') 
    echo $(($num%$max+$min)) 
} 

rnd=$(rand3 100 500) 
echo $rnd 


#使用date 生成随机字符串 
date +%s%N | md5sum | head -c 10

#使用 /dev/urandom 生成随机字符串 
cat /dev/urandom | head -n 10 | md5sum | head -c 10
