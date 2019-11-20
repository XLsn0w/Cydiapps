#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Fri 08 Mar 2019 08:54:01 AM CST
#File Name: whoisonline.sh
#Description: 判断网络里，当前在线用户的IP有哪些
#######################################################################

read -p "检查的网段是: <10.1.1.0>" network

head=`echo $network|awk -F'/' '{print $1}'|cut -d'.' -f 1-3`
netmask=`echo $network|awk -F'/' '{print $2}'`

echo $head
