#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Fri 23 Jun 2017 06:37:27 PM CST
#File Name: write-fstab.sh
#Description:
#######################################################################

#!/bin/bash

#set -x
DISK=$1
MOUNTPOINT=$2
DISK_UUID=`blkid $DISK |awk '{print $2}'|cut -d"\"" -f 2`
echo $DISK_UUID
FSTAB_FILE="/etc/fstab"

usage() {
    echo "Usage: $(basename $0) <disk> <mount_point>"
    echo "       $(basename $0) <file.iso> <mount_point>"
    echo "   Ex: $(basename $0) /dev/sdc1 /data"
    echo "   Ex: $(basename $0) /root/file.iso /data"
}

if [ $# -lt 2 ]; then
    echo "Error: invalid parameters"
    usage
    exit 1
fi
check() {
    if [ -f $DISK ];then
        grep $DISK $FSTAB_FILE >> /dev/null && mount -a >> /dev/null
    elif [ -b $DISK ];then
        grep $DISK_UUID $FSTAB_FILE >> /dev/null && mount -a
    else
        echo "$DISK not exist!!!"
        exit 1
    fi
    if [ $? == 0 ]
    then
        echo "You had do it"
        exit 0
    else
        echo "this is no config,I will do it"
    fi
}
check_exist() {
    if ls -l $DISK >> /dev/null ; then
        exit 2
    fi
}
#check_exist
check
cp ${FSTAB_FILE} ${FSTAB_FILE}.`date +'%Y%m%d%H%M%S'`
if [[ -f ${DISK} && -d ${MOUNTPOINT} && -f ${FSTAB_FILE} ]];then
    echo "$DISK $MOUNTPOINT iso9660 loop,nosuid 0 0" >> $FSTAB_FILE
    check
elif [[ -b ${DISK} && -d ${MOUNTPOINT} && -f ${FSTAB_FILE} ]];then
    echo "UUID=$DISK_UUID $MOUNTPOINT ext4 defaults 0 0" >> $FSTAB_FILE
    check
else
    mkdir -p $MOUNTPOINT
    [[ -d ${MOUNTPOINT} && -b ${DISK} ]] && echo "UUID=$DISK_UUDI $MOUNTPOINT ext4 defaults 0 0" >> $FSTAB_FILE
    [[ -d ${MOUNTPOINT} && -f ${DISK} ]] && echo "$DISK $MOUNTPOINT iso9660 loop,nosuid 0 0" >> $FSTAB_FILE
    check
fi

