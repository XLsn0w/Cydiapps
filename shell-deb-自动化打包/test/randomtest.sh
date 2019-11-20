#!/bin/bash
for i in `seq 1 $1`
do
    for j in `seq 1 $2`
    do 
        s=$(($RANDOM%100))
            echo -e "$i,$j\t$s" >>M_$1_$2
    done
done
