#!/bin/sh

#  verbose122.sh
#  checkm8
#
#  Created by Colby Lamothe on 10/14/19.
#  Copyright © 2019 tie1r. All rights reserved.

clear
echo "loading"
read -p "." -t 1
echo ""
ls
cd /Applications/checkm8.app/Contents/Resources/ipwndfu
./ipwndfu -p --boot122
clear
exit
exit
