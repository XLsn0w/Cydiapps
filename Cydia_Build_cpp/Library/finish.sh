#!/bin/bash

declare -a cydia
cydia=($CYDIA)

if [[ ${CYDIA+@} ]]; then
    eval "echo 'finish:$1' >&${cydia[0]}"
fi
