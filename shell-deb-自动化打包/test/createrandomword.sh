#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Sun 18 Jun 2017 05:08:34 PM CST
#File Name: createrandomworld.sh
#Description:
#######################################################################
word_list=(a b c d e f g h i j k l m n o p q r s t u v w x y z)
for ((i=0;i<10;i++))
do
    echo -n "${word_list[$RANDOM%10]}"
done
