#!/bin/bash
dir=$1
dir=${dir:=_}
sed -e "s@^\(Version:.*\)@\1$(./version.sh)@" control
echo "Installed-Size: $(du -s "${dir}" | cut -f 1)"
