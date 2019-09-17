#!/bin/bash

export LANG=C
export LC_CTYPE=C
export LC_ALL=C

make clean && make && mv .theos/obj/debug/TweakInject.dylib ../../bootstrap/dylibs/TweakInject.dylib && rm -rf .theos && rm -rf obj #&& sed -i "" 's/\/Library\//\/var\/LIB\//g' ../../bootstrap/dylibs/TweakInject.dylib && sed -i "" 's/\/System\/var\/LIB\//\/System\/Library\//g' ../../bootstrap/dylibs/TweakInject.dylib && ldid -S ../../bootstrap/dylibs/TweakInject.dylib
