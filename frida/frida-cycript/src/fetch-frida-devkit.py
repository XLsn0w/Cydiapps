#!/usr/bin/env python3
from __future__ import print_function

import os
import platform
import subprocess
import sys

params = {
    'version': sys.argv[1],
    'os': sys.argv[2],
    'arch': sys.argv[3],
}
output_dir = sys.argv[4]

if platform.system() == 'Windows':
    print("FIXME: not yet implemented on Windows")
    exit_code = 1
else:
    url_template = "https://github.com/frida/frida/releases/download/%(version)s/frida-core-devkit-%(version)s-%(os)s-%(arch)s.tar.xz"
    url = url_template % params
    exit_code = subprocess.call("curl -Ls {0} | xz -d | tar -C {1} -xf -".format(url, output_dir), shell=True)
if exit_code == 0:
    os.utime(os.path.join(output_dir, "frida-core.h"), None)
sys.exit(exit_code)
