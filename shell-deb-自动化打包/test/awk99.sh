#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Wed 07 Jun 2017 01:23:19 PM CST
#File Name: awk99.sh
#Description:
#######################################################################

awk 'BEGIN{
        for(i=1;i<=9;i++){ 
                for(j=1;j<=9;j++){ 
                        tarr[i,j]=i*j; 
                }
        } 
        for(m in tarr){ 
                split(m,tarr2,SUBSEP); 
                print tarr2[1],"*",tarr2[2],"=",tarr[m]; 
        } 
}'

