#!/bin/sh

#  dump.sh
#  checkm8
#
#  Created by Tyler on 9/27/19.
#  Copyright © 2019 tie1r. All rights reserved.


clear
echo "loading"
read -p "." -t 1
echo ""
dir=`pwd`
ls
cd /Applications/checkm8.app/Contents/Resources/ipwndfu-master
./ipwndfu --dump-rom
read -p "." -t 1
read -p "." -t 1
read -p "." -t 1
cp /Applications/checkm8.app/Contents/Resources/ipwndfu/dumps ~/Desktop
clear
exit
exit
