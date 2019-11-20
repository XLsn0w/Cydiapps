#!/usr/bin/env bash
#######################################################################
#Author: kellanfan
#Created Time : Fri 30 Nov 2018 03:46:05 PM CST
#File Name: build_package.sh
#Description:
#######################################################################

SCRIPT=$(readlink -f $0)
CWD=$(dirname ${SCRIPT})
package=$1
DEBHOME="$CWD/deb"
PKGHOME="$CWD/packages/$package"

PKGNAME=$(grep Package $PKGHOME/DEBIAN/control |awk -F':' '{print $2}'|awk '{print $1}')
PKGVERSION=$(grep Version $PKGHOME/DEBIAN/control |awk -F':' '{print $2}'|awk '{print $1}')

rm -f $DEBHOME/$PKGNAME-*.deb
dpkg -b $PKGHOME $DEBHOME/"$PKGNAME-$PKGVERSION.deb"
if [ $? -ne 0 ]; then
    echo "build package [$PKGNAME] failed"
    exit 1
else
    echo "build package [$PKGNAME] successful"
fi

