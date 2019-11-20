#!/bin/bash

#set -x
DISK=$1
MOUNTPOINT=$2
DISK_UUID=`blkid $DISK |awk '{print $2}'|cut -d"\"" -f 2`
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
    ls -l $DISK >> /dev/null
    if [ $? -gt 0 ];then
        exit 2
    fi
}
#check_exist
check
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

cat $FSTAB_FILE
