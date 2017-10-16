#!/bin/bash

# Purpose: finds kernel_task and realhost


if [ $# -eq 0 ]
    then
    echo "Usage: kernel_offsets_finder.sh [kernel_file]"
    exit 0
fi

echo "g_offsets.kernel_task = 0x$(nm -P "$1" | egrep '^_kernel_task S [0-9a-f]{16} 0$' | sed -E 's#^_kernel_task S ([0-9a-f]{16}) 0$#\1#') - g_offsets.kernel_base;";

host_priv_self="$(nm -P "$1" | egrep '^_host_priv_self S [0-9a-f]{16} 0$' | sed -E 's#^_host_priv_self S ([0-9a-f]{16}) 0$#\1#')";
if [ "${#host_priv_self}" -eq 16 ]; then
    asm="$(r2 -e 'scr.color=false' -qc "pd 2 @0x$host_priv_self" "$1" 2>/dev/null)";
    adrp="$(echo "$asm" | egrep 'adrp x0, 0x[0-9a-f]{13}000')";
    add="$(echo "$asm" | egrep 'add x0, x0, 0x[0-9a-f]{1,3}')";
    if [ "${#adrp}" -gt 0 ] && [ "${#add}" -gt 0 ]; then
        adrp="$(echo "$adrp" | sed -E 's#^.*adrp x0, 0x([0-9a-f]{13})000$#\1#')";
        add="$(echo "$add" | sed -E 's#^.*add x0, x0, 0x([0-9a-f]{1,3})$#\1#')";
        while [ "${#add}" -lt 3 ]; do
            add="0$add";
        done
        echo "g_offsets.realhost = 0x$adrp$add - g_offsets.kernel_base;";
    fi;
fi;