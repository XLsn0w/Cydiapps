#!/bin/bash

#for check os
#author: Kellan Fan
#version: 1.0

SCRIPT=`readlink -f $0`
CWD=`dirname $SCRIPT`
DATE=`date +%F`
LOG_DIR='/var/log/'
SafeExec()
{
    local cmd=$*
    ${cmd} >> $LOG_DIR/oscheck.log 2>&1
    if [ $? -ne 0 ]; then
        echo "Exec ${cmd} FAILED."
        exit 1
    fi
}

check_root()
{
    if [ $UID != 0 ];then
        echo "Please use user root to play it!"
        exit 1
    fi
}

os_version()
{
    if [ -f /etc/issue ];then
        DEBIAN=$(awk '{print $1}' /etc/issue)
    else
        REDHAT=$(awk '{print $1}' /etc/readhat-release)
    fi
}

packet_install_mode()
{
    os_version
    if [ "$DEBIAN" == "Ubuntu" -o "$DEBIAN" == "ubuntu" ];then
        P_M=apt-get
    elif [ "$REDHAT" == "Centos" -o "$REDHAT" == "Red" ];then
        P_M=yum
    fi
}

command_check()
{
    packet_install_mode
    if ! which vmstat > /dev/null;then
        echo "vmstat command not found,now the install"
        $P_M -y install procps
        echo "------------------------------"
    fi
    if ! which iostat > /dev/null;then
        echo "iostat command not found,now the install"
        $P_M -y install sysstat
        echo "------------------------------"
    fi
}

cpu_load()
{
    echo "------------------------------"
    i=1
    while [[ $i -le 3 ]];do
        echo -e "\033[33m参考值\033[0m"
        UTIL=$(vmstat | awk '{if(NR==3)print 100-$15"%"}')
        USER=$(vmstat | awk '{if(NR==3)print $13"%"}')
        SYS=$(vmstat | awk '{if(NR==3)print $14"%"}')
        IOWAIT=$(vmstat | awk '{if(NR==3)print $16"%"}')
        echo "Util: $UTIL"
        echo "User Use: $USER"
        echo "Sys Use: $SYS"
        echo "Iowait: $IOWAIT"
        i=$(($i+1))
        sleep 1
    done
    echo "------------------------------"
}

disk_load()
{
    echo "------------------------------"
    i=1
    while [[ $i -le 3 ]];do
        echo -e "\033[32m参考值\033[0m"
        UTIL=$(iostat -x -k|awk '/^[v|s]/{OFS=": ";print $1,$NF"%"}')
        READ=$(iostat -x -k|awk '/^[v|s]/{OFS=": ";print $1,$6"KB"}')
        WRITE=$(iostat -x -k|awk '/^[v|s]/{OFS=": ";print $1,$7"KB"}')
        IOWAIT=$(iostat -x -k|awk '/^[v|s]/{OFS=": ";print $1,$10"%"}')
        echo "Disk Util: $UTIL"
        echo "Disk Read: $READ"
        echo "Disk Write: $WRITE"
        echo "Disk IoWait: $IOWAIT"
        i=$(($i+1))
        sleep 1
    done   
    echo "------------------------------"
}

disk_use()
{
    echo "------------------------------"
    DISK_LOG="$CWD/disk.log"
    TOTAL_DISK=$(parted -l|grep -i disk|egrep 'TB|GB'|awk '{print $2" "$3}')
    USE_RATE=$(df -h|awk '/^\/dev/{print int($5)}')
    echo -e "Disk Total:\n$TOTAL_DISK"
    for i in $USE_RATE;do
        PART=$(df -h |awk -v part=$i '{if(int($5)==part)print $6}') #暂时有个bug，当使用量一样的情况，没办法判断
        if [[ $i -gt 90 ]];then
            echo -e "\033[32mDisk Usage: $PART ${i}%\033[0m"
        else
            echo -e "Disk Usage: $PART ${i}"%""
        fi
    done
    echo "------------------------------"
}

disk_inode()
{
    echo "------------------------------"
    INODE=$(df -i|awk '/^\/dev/{print int($5)}')
    for i in $INODE;do
        PART=$(df -i |awk -v part=$i  '{if(int($5)==part)print $6}') #暂时有个bug，当使用量一样的情况，没办法判断
        if [[ $i -gt 90 ]];then
            echo -e "\033[32mInode Usage:\n $PART ${i}%\033[0m"
        else
            echo -e "Inode Usage:\n $PART ${i}%"
        fi
    done
    echo "------------------------------"
}

mem_use()
{
    echo "------------------------------"
    TOTAL=$(free -h|awk '{if(NR==2)print $2}')
    USE=$(free -m|awk '{if(NR==2)printf "%.1f",$3/1024}END{print "G"}')
    CACHE=$(free -m |awk '{if(NR==2)printf "%.1f",($6+$7)/1024}END{print "G"}')
    FREE=$(free -m |awk '{if(NR==2)printf "%.1f",$4/1024}END{print "G"}')
    echo "Mem Total: $TOTAL"
    echo "Mem USAGE: $USE"
    echo "MEm Cache: $CACHE"
    echo "Mem Free: $FREE"
    echo "------------------------------"
}

tcp_stat()
{
    echo "------------------------------"
    COUNT=$(netstat -anlpt|awk '{status[$6]++}END{for(i in status) print i,status[i]}')
    echo -e "TCP connection status:\n$COUNT"
    echo "------------------------------"
}

cpu_top10()
{
    echo "------------------------------"
    CPU_LOG="$CWD/cpu.log"
    i=1
    while [[ $i -lt 3 ]];do
        ps aux|awk '{if($3>0.1){{printf "PID: "$2" CPU: "$3"% --> "}for(i=11;i<=NF;i++)if($i==NF)print $i;else print $i}}'| sort -k4 -nr| head -10 > $CPU_LOG
        if [[ -n `cat $CPU_LOG` ]];then
            echo -e "\033[33m参考值\033[0m"
            cat $CPU_LOG
            > $CPU_LOG
        else
            echo "No process using the CPU"
            break
        fi
        i=$(($i+1))
        sleep 1
    done
    echo "------------------------------"
}

mem_top10()
{
    echo "------------------------------"
    MEM_LOG="$CWD/mem.log"
    i=1
    while [[ $i -lt 3 ]];do
        ps aux|awk '{if($4>0.1){{printf "PID: "$2" MEM: "$4"% --> "}for(i=11;i<=NF;i++)if($i==NF)print $i;else print $i}}'| sort -k4 -nr| head -10 > $MEM_LOG
        if [[ -n `cat $MEM_LOG` ]];then
            echo -e "\033[33m参考值\033[0m"
            cat $MEM_LOG
            > $MEM_LOG
        else
            echo "No process using the MEM"
            break
        fi
        i=$(($i+1))
        sleep 1
    done
    echo "------------------------------"
}

traffic()
{
    echo "------------------------------"
    DEV=$(ifconfig |grep HWaddr|awk '{print $1}')
    for dev in $DEV;do
        i=1
        while [[ $i -lt 3 ]];do
            OLD_IN=$(ifconfig $dev| awk -F'[: ]+' '/bytes/{if(NR==8)print $4;else if(NR==7)print $4}')
            OLD_OUT=$(ifconfig $dev| awk -F'[: ]+' '/bytes/{if(NR==8)print $9;else if(NR==7)print $4}')
            sleep 1
            NEW_IN=$(ifconfig $dev| awk -F'[: ]+' '/bytes/{if(NR==8)print $4;else if(NR==7)print $4}')
            NEW_OUT=$(ifconfig $dev| awk -F'[: ]+' '/bytes/{if(NR==8)print $9;else if(NR==7)print $4}')
            IN=`awk 'BEGIN{printf "%.1f\n",'$((NEW_IN-OLD_IN))'/1024/128}'`
            OUT=$(awk 'BEGIN{printf "%.1f\n",'$((NEW_OUT-OLD_OUT))'/1024/128}')
            echo -e "${dev}:\nIN: ${IN}MB/s\nOUT: ${OUT}MB/s"
            i=$(($i+1))
            sleep 1
        done
    done
    echo "------------------------------"
}
check_stat()
{
    while true;do
        select input in cpu_load disk_load disk_use disk_inode mem_use tcp_stat cpu_top10 mem_top10 traffic quit;do
            case $input in 
                cpu_load)
                    SafeExec cpu_load
                    break
                    ;;
                disk_load)
                    disk_load
                    break
                    ;;
                disk_use)
                    disk_use
                    break
                    ;;
                disk_inode)
                    disk_inode
                    break
                    ;;
                mem_use)
                    mem_use
                    break
                    ;;
                tcp_stat)
                    tcp_stat
                    break
                    ;;
                cpu_top10)
                    cpu_top10
                    break
                    ;;
                mem_top10)
                    mem_top10
                    break
                    ;;
                traffic)
                    traffic
                    break
                    ;;
                quit)
                    exit 0
                    break
                    ;;
                *)
                    echo "------------------------------"
                    echo -e "\e[35m Please Input number $(tput sgr0)"
                    echo "------------------------------"
                    break
                    ;;
            esac
        done
    done
}
check_root
command_check
check_stat
