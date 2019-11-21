#!/bin/bash

png=$1
out=$2

steps=()

src=${out}.src.png
dst=${out}.dst.png

copy=("${src}" "${dst}")

function step() {
    "$@"
    mv -f "${dst}" "${src}"
    steps+=($(stat -f "%z" "${src}"))
}

pngcrush=$(xcode-select --print-path)/Platforms/iPhoneOS.platform/Developer/usr/bin/pngcrush

if grep CgBI "${png}" &>/dev/null; then
    if [[ ${png} != ${out} ]]; then
        cp -a "${png}" "${out}"
    fi

    exit 0
fi

step cp -fa "${png}" "${dst}"

#step "${pngcrush}" -q -rem alla -reduce -brute -iphone "${copy[@]}"

#step "${pngcrush}" -q -rem alla -reduce -brute "${copy[@]}"
#step pincrush "${copy[@]}"

step "${pngcrush}" -q -rem alla -reduce -iphone "${copy[@]}"

#"${pngcrush}" -q -rem alla -reduce -brute -iphone "${png}" 1.png
#"${pngcrush}" -q -iphone _.png 2.png
#ls -la 1.png 2.png

mv -f "${src}" "${out}"

echo -n "${png##*/} "
for ((i = 0; i != ${#steps[@]}; ++i)); do
    if [[ $i != 0 ]]; then
        echo -n " "
    fi

    echo -n "${steps[i]}"
done

printf $' %.0f%%\n' "$((steps[${#steps[@]}-1] * 100 / steps[0]))"
