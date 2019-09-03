#!/usr/bin/env python3

import os
import platform
import subprocess
import sys

if __name__ == '__main__':
    bin_dir = os.path.dirname(os.path.realpath(__file__))

    os_name = platform.system().lower()
    if os_name == 'darwin':
        os_name = 'macos'

    arch = platform.machine()
    if arch.startswith('i') and arch.endswith('86'):
        arch = 'x86'

    if os_name == 'windows':
        bison_executable = "bison.exe"
    else:
        bison_executable = "bison-{0}-{1}".format(os_name, arch)

    bison = os.path.join(bin_dir, bison_executable)
    bison_datadir = os.path.join(os.path.dirname(bin_dir), "share", "bison")

    os.environ['BISON_PKGDATADIR'] = bison_datadir

    exit_code = subprocess.call([bison] + sys.argv[1:])

    sys.exit(exit_code)
