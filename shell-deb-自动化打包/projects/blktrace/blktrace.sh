#!/bin/bash
SCRIPT=`readlink -f $0`
CWD=`dirname $SCRIPT`
cd $CWD
usage() {
    echo "Usage: $(basename $0) <DEV> <end_time>"
    echo "   Ex: $(basename $0) /dev/sdc1 360"
}
if [ $# -lt 1 ]; then
    echo "Error: invalid parameters"
    usage
    exit 1
fi

DEV=$1
DEV_A=`echo $1 | awk -F"/" '{print $3}'`
TIME=$2
D_TIME=30
DATA_DIR=$CWD/data
if [ ! -d $DATA_DIR ]; then
    mkdir $DATA_DIR
fi

check_root()
{
    if [ $UID != 0 ];then
        echo "Please use user root to play it!"
        exit 1
    fi
}

command_check()
{
    if ! which blktrace > /dev/null;then
        echo "blktrace command not found,please install"
    fi
}

clean()
{
    if [ -d $DATA_DIR ]; then
        rm -rf $DATA_DIR/*
    fi
    if [ -f $CWD/blktrace ]; then
        rm $CWD/blktrace
    fi
    if [ -f $CWD/result ]; then
        rm $CWD/result
    fi
    if [ -f $CWD/tmp ]; then
        rm $CWD/tmp
    fi
}

blktrace()
{
    cd $DATA_DIR
    
    if [ "x$TIME" = "x" ]; then
        echo "blktrace $D_TIME ..."
        /usr/sbin/blktrace -d $DEV -w $D_TIME
    else
        echo "blktrace $TIME ..."
        /usr/sbin/blktrace -d $DEV -w $TIME
    fi
    blkparse -i ${DEV_A}.blktrace.0 -o ../blktrace
}

make()
{
    cd $CWD
    bash blktrace_awk.sh blktrace 4
}

which_pro()
{
    cd $CWD
    ROOT_DIR=`df -h | grep $DEV |awk '{print $6}'`
    S=`awk '{print $2}' result`
    for i in $S; do
        BLOCK=`echo "$i/8" | bc`
        INODE=`debugfs -R "icheck $BLOCK" $DEV |grep $BLOCK | awk '{print $2}'`
        if [ "$INODE" -gt 0 ] 2>/dev/null ;then
            debugfs -R "ncheck $INODE" $DEV > file_tmp
            FILE=`tail -n 1 file_tmp| awk '{print $2}'`
            echo "the file is $ROOT_DIR$FILE"
            break
        fi
    done
    rm file_tmp
    lsof $ROOT_DIR$FILE
}
clean
command_check
blktrace
make
which_pro
