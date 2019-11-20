#!/bin/bash


function DEBUG() {
[ "$_DEBUG" == "on" ] && $@ || :
}
for i in {1..6}
do
#    set -x
    DEBUG echo $i
#    set +x
done
echo aaaa
