#!/bin/bash
echo "$(git describe --tags --dirty="+" --match="v*" | sed -e 's@-\([^-]*\)-\([^-]*\)$@+\1.\2@;s@^v@1:@')"
