

#  Script.sh
#  IPAForce
#
#  Created by Lakr Sakura on 2018/10/1.
#  Copyright © 2018 Lakr Sakura. All rights reserved.

# export $SSHADDR=com.lakr.IPAForce.PRESET.sshaddr
# export $SSHPORT=com.lakr.IPAForce.PRESET.sshport

if (exec 3<>/dev/tcp/$SSHADDR/$SSHPORT) 2> /dev/null; then
echo "[*] Servers available."
else
echo "[Error] Servers not available."
fi
