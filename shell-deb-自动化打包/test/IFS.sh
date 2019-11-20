#!/bin/bash

line="root:x:0:0:root:/root:/bin/bash"
oldIFS=$IFS
echo $oldIFS
IFS=":"
count=0
for item in $line
do
    [ $count -eq 0 ] && name=$item
    [ $count -eq 6 ] && shell=$item
    let count++
done
IFS=$oldIFS
echo $name\'s bash is $shell
