#!/bin/bash

set -e -x

sudo xcode-select --switch /Applications/Xcode-4.6.3.app
cycc -i2.0 -oldid.arm -- -c -std=c++11 ldid.cpp -I.
cycc -i2.0 -oldid.arm -- ldid.arm -x c sha1.c lookup2.c -I .

rm -rf _
mkdir -p _/usr/bin
cp -a ldid.arm _/usr/bin/ldid
mkdir -p _/DEBIAN
./control.sh _ >_/DEBIAN/control
mkdir -p debs
ln -sf debs/ldid_$(./version.sh)_iphoneos-arm.deb ldid.deb
dpkg-deb -b _ ldid.deb
readlink ldid.deb
