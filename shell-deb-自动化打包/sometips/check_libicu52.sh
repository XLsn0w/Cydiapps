#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Fri 15 Mar 2019 09:52:59 AM CST
#File Name: check_libicu52.sh
#Description:
#######################################################################

#!/bin/bash
system_version=$(cat /etc/issue | awk '{print $2}' |head -n 1)
libvirt_verssion=$(dpkg -l |grep libvirt|grep -v python |awk '{print $3}')
if [[ $system_version == "14.04.3" ]] || [[ $system_version == "14.04.5" ]] && [[ $libvirt_verssion == "4.0.1" ]];then
	dpkg -l |grep libicu52 > /dev/null && echo "libicu52 had installed" || echo "ERROR: libicu52 donot install"
else
	echo "ignore.."
fi
