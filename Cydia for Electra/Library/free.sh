#!/bin/bash

# /usr/bin \

for dir in \
    /Applications \
    /Library/Wallpaper \
    /Library/Ringtones \
    /usr/include \
    /usr/share \
; do
    . /usr/libexec/cydia/move.sh "$@" "${dir}"
done

sync
