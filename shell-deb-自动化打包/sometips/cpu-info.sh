#!/bin/bash


this script only works in a Linux OS which has one or more identical physical CPUs.

echo -n "logical CPU numbers in total: "
cat /proc/cpuinfo | grep "processor"|wc -l

cat /proc/cpuinfo | grep -qi "core id"
if [ $? -ne 0 ]; then
    echo "Warning，NO multi-core or hyper-threading is enabled."
    exit 0
fi

echo -n "physical CPU numbers in total: "
cat /proc/cpuinfo | grep "physical id" |sort |uniq |wc -l

echo -n "core number in a physical CPU: "
core_per_phy_cpu=$(cat /proc/cpuinfo |grep "core id" |sort |uniq |wc -l)
echo $core_per_phy_cpu

logical_cpu_per_phy_cpu=$(cat /proc/cpuinfo |grep "siblings" |sort |uniq |wc -l |awk -F: '{print $2}')
echo $logical_cpu_per_phy_cpu

if [[ $logical_cpu_per_phy_cpu -gt $core_per_phy_cpu ]]; then
    echo "Hyper threading is enabled."
elif [[ $logical_cpu_per_phy_cpu -eq $core_per_phy_cpu ]]; then
    echo "Hyper threading is NOT enabled."
else
    echo "Someting is Wrong."
fi

