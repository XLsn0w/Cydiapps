#!/bin/sh

#  alloc8.sh
#  checkm8
#
#  Created by Colby Lamothe on 10/2/19.
#  Copyright © 2019 tie1r. All rights reserved.

clear
echo "loading"
read -p "." -t 1
echo ""
ls
cd /Applications/checkm8.app/Contents/Resources/ipwndfu
./ipwndfu -x
clear
exit
exit
