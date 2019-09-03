#!/usr/bin/env python3

import shutil
import subprocess
import sys

npm = sys.argv[1]
package_json = sys.argv[2]
pkglock_json = sys.argv[3]
output_dir = sys.argv[4]

shutil.copy(package_json, output_dir)
shutil.copy(pkglock_json, output_dir)
process = subprocess.Popen([npm, "install"],
    stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=output_dir)
(stdout_data, stderr_data) = process.communicate()
exit_code = process.returncode
if exit_code != 0:
    sys.stderr.write(stdout_data)
sys.exit(exit_code)
