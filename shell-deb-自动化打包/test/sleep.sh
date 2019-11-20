#!/bin/bash
#set -x
tput setb 2
tput setf 3
echo -n Count:
tput sc

count=0;
while true
    do
    if [ $count -lt 40 ]
    then
        let count++
        sleep 1
        tput rc
        tput ed
        echo -n $count
    else
        exit 0
    fi
done
