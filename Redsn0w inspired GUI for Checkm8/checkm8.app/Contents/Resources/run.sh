#!/bin/sh

#  run.sh
#  checkm8
#
#  Created by Tyler on 9/27/19.
#  Copyright © 2019 tie1r. All rights reserved.


clear
echo "loading"
read -p "." -t 1
echo ""
ls
cd /Applications/checkm8.app/Contents/Resources/ipwndfu
./ipwndfu -p
clear
exit
exit
