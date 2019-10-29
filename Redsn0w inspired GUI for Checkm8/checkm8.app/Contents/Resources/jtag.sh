#!/bin/sh

#  jtag.sh
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
cd /Applications/checkm8.app/Contents/Resources/ipwndfu
./ipwndfu --demote
clear
exit
exit
