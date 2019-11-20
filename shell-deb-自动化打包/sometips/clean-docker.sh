#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Thu 25 Oct 2018 09:21:50 AM CST
#File Name: clean-docker.sh
#Description:
#######################################################################

echo "清除容器..."
cn_list=`docker ps -qa`
for i in $cn_list;do
    docker rm $i
done

echo "清除dangling image..."
dl_image=`docker images -q -f dangling=true`
for j in $dl_image;do
    docker rmi $j
done

echo "清除虚悬volume..."
dl_volume=`docker volume ls -qf dangling=true`
for g in $dl_volume;do
    docker volume rm $g
done
echo "Done."
