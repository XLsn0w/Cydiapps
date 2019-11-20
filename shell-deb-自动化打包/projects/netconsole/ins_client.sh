#!/bin/bash
#
if [ -e ./nodes/all ] ; then 
    source ./nodes/all  
else
    exit 1
fi

for node in ${nodes[*]} ; do 
    log=$( scp netconsole.sh ${node}:/tmp/ && ssh $node bash -x /tmp/netconsole.sh 2>&1 ) 
    if echo $log |grep '__success__' >/dev/null ; then
        echo -e "$node netconsole fix done..."
    else
        echo -e "$node netconsole fix failed..."
    fi

done
