#!/bin/bash
#######################################################################
#Author: kellanfan
#Created Time : Wed 06 Sep 2017 05:53:29 PM CST
#File Name: debmaker.sh
#Description:
#######################################################################

logger() {
    Msg=$*
    DATE=`date +'%Y-%m-%d %H:%M:%S'`
    echo "$DATE $Msg" >> $LOGFILE
}

usage() {
	echo "Usage:"
    echo "	Note: package must be found in $PKGDIR"
    echo "	$0 <package> --all "
	echo "		--all all packages in $PKGDIR will be build and scan them.."
    echo "example: "
	echo "	$0 mydeb "
    echo "	$0 --all"
}

safeBuild() {
    local cmd=$*
    echo -n "Building [$package] ... "
	log_file="/var/log/debmaker/$package.log"
    logger "Building [$package] ..."
    ${cmd} >>${log_file} 2>&1
    if [ $? -eq 0 ]; then
        echo -n "OK." && echo ""
        logger "Build [$package] OK."
    else
        echo -n "Error!" && echo ""
        logger "Build [$package] Error!"
        exit 1
    fi
}

check_packages() {
	package=$1
	logger "check $package.."
	count=$(find $PKGDIR -name "$package" |wc -l)
	if [ $count -eq 0 ];then
		echo "Error: The package [$package] is invalid, can not find it in $PKGDIR"
		exit 1
	fi
}

scanPackages() {
	echo "Scaning [$DEBHOME] ..."
	logger "Scaning [$DEBHOME] ..."
	cd $DEBHOME
	dpkg-scanpackages . /dev/null 2>>${LOGFILE} | gzip -9c > Packages.gz
	if [ $? -eq 0 ]; then
    	echo -n "OK." && echo ""
    	logger "Scan [$DEBHOME] OK."
    else
        echo -n "Error!" && echo ""
        logger "Scan [$DEBHOME] Error!"
        exit 1
    fi
}
######## main #######
echo "debmaker version: 0.1"
######## variable #######
SCRIPT=$(readlink -f $0)
CWD=$(dirname ${SCRIPT})
LOGFILE="/var/log/debmaker/common.log"
PKGDIR=$CWD/packages
DEBHOME=$CWD/deb
parm=$1

if [ ! -d /var/log/debmaker ]; then
	mkdir /var/log/debmaker
fi

if [ ! -d $DEBHOME ];then
    mkdir $DEBHOME
fi

if [[ "x$parm" == "x" ]] || [ $# -eq 0 ];then
	usage
	exit 1
fi

##### build ######

if [[ "x$parm" == "x--all" ]];then
	packages=$(ls -1 $PKGDIR)
	for package in $packages;do
		check_packages $package
	done
	
	for package in $packages;do
		safeBuild $CWD/build_package.sh $package
	done
    scanPackages
else
    check_packages $parm
    safeBuild $CWD/build_package.sh $parm
    scanPackages
fi
