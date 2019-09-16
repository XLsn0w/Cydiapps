# export packagePath=

#!/var/containers/Bundle/iosbinpack64/bin/bash

export LANG=C
export LC_CTYPE=C
export LC_ALL=C

export v1=${packagePath}/Library/MobileSubstrate/DynamicLibraries/*dylib
export v2=${packagePath}/Library/PreferenceBundles/*/*

for i in $v1
do
echo "Patching $i"
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/\/Library\//\/var\/LIB\//g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/\/System\/var\/LIB\//\/System\/Library\//g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/%@\/var\/LIB\//%@\/Library\//g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/mobile\/var\/LIB\//mobile\/Library\//g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/\/usr\/lib\/libsubstrate/\/var\/ulb\/libsubstrate/g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/\/usr\/lib\/libsubstitute/\/var\/ulb\/libsubstitute/g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/\/usr\/lib\/libprefs/\/var\/ulb\/libprefs/g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/bin/ldid2 -S $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/inject $i # 2> /dev/null
done

for i in $v2
do
echo "Patching $i"
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/\/Library\//\/var\/LIB\//g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/\/System\/var\/LIB\//\/System\/Library\//g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/%@\/var\/LIB\//%@\/Library\//g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/mobile\/var\/LIB\//mobile\/Library\//g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/\/usr\/lib\/libsubstrate/\/var\/ulb\/libsubstrate/g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/\/usr\/lib\/libsubstitute/\/var\/ulb\/libsubstitute/g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/sed -i "" 's/\/usr\/lib\/libprefs/\/var\/ulb\/libprefs/g' $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/bin/ldid2 -S $i # 2> /dev/null
/var/containers/Bundle/iosbinpack64/usr/bin/inject $i # 2> /dev/null
done
