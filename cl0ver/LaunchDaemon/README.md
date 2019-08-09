# LaunchDaemon

To automatically run cl0ver on every boot:

1. Download [`net.siguza.cl0ver.plist`](https://raw.githubusercontent.com/Siguza/cl0ver/master/LaunchDaemon/net.siguza.cl0ver.plist).
2. Either make sure cl0ver exists in `/usr/local/bin` (as in, the full path is `/usr/local/bin/cl0ver`), or edit the plist and put your own path there.  
   **IF THE PATH TO CL0VER IS NOT VALID, YOUR DEVICE MIGHT NO LONGER BOOT!**
3. Put the plist file in `/Library/LaunchDaemons/` on your device.
4. Make sure the file is owned by root and not writable by anyone else. If in doubt, run these commands (as root):

        chown root:wheel /Library/LaunchDaemons/net.siguza.cl0ver.plist;
        chmod 644 /Library/LaunchDaemons/net.siguza.cl0ver.plist;

As always, use at your own risk.
