#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Wed 27 Sep 2017 01:40:04 PM CST
#File Name: calendar.sh
#Description:
#######################################################################
#! /bin/bash
#date=$1
tiffcolor="\033[0;35m"
menucolor="\033[0;33m"
todaycolor="\033[0;35;44m"
start="\033[0m"

usage() {
    echo "Usage:"
    echo "  $0 [date]"
    echo "  Note: If no parameter, it will print Today's Date"
}

if [ $# -eq 1 ];then
    date=$1
elif [ $# -eq 0 ];then
    date=`date +%F`
else
    usage
fi
count=`echo $date |grep -o '-'|wc -l`
if [ $count -ne 2 ];then
    echo "plz input correct date"
    exit 1
fi
year=`echo $date|cut -d "-" -f 1`
month=`echo $date|cut -d "-" -f 2`
day=`echo $date|cut -d "-" -f 3`
expr $year + $month + $day + 0 &>/dev/null
if [ $? -ne 0 ];then
    echo "plz input a correct date"
    exit 1
elif [ $month -gt 12 -o $month -eq 0 ];then
    echo "plz input the month between 1 and 12"
    exit 1
elif [ $day -gt 31 -o $day -eq 0 ];then
    echo "plz input the day between 1 and 31"
    exit 1
fi

weekday=`date -d "$year-$month-01" +%w`
if [ $month -eq 12 ];then
    newmonth=1
    newyear=`expr $year + 1`
else
    newyear=$year
    newmonth=`expr $month + 1`
fi
days=$(( ($(date -d "${newyear}-${newmonth}-01" +%s) - $(date -d "$year-$month-01" +%s))/(24*60*60) )) 
#echo $days
echo -en "${menucolor}"
echo -en "\t   $year  $month\n"
echo "SUN  MON  TUE  WEN  THU  FRI  SAT"
echo -en "${start}"

if [ $weekday -ne 0 ];then
    for((i=1;i<=$weekday;i++))
    do
        echo -n "   "
        echo -n "  "
    done
fi


for((i=1;i<=$days;i++))
do
    printf  "%s" " "
    echo -en "${tiffcolor}"
    if [ $day -eq $i ];then
        echo -en "${todaycolor}"
    fi
    printf "%2d" $i
    echo -en "${start}"
    echo -en "  "
    if [ $((($weekday+$i)%7)) == 0 ];then
    echo ""
    fi
#   printf "%3d  " $i
done
echo ""
