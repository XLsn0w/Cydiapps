# rootlessJB12.4
# Description

Blah blah, read this: [How to make a jailbreak without a filesystem remount as r/w](https://github.com/jakeajames/rootlessJB/blob/master/writeup.pdf)

- Powered by jelbrekLib


## Support

- All A9-A11 devices
- All A7-A8 devices
- iOS 12.0 - 12.2 & 12.4

## RootlessInstaller

- SSH into your device and run these following commands

- sh /var/mobile/install.sh

- After you do that, clicking get root it will no longer give you a error in the app.


## Usage notes

- SockPort is used for everything
- Binaries are located in: /var/containers/Bundle/iosbinpack64
- Launch daemons are located in /var/containers/Bundle/iosbinpack64/LaunchDaemons
- /var/containers/Bundle/tweaksupport contains a filesystem simulation where tweaks and stuff get installed
- Symlinks include: /var/LIB, /var/ulb, /var/bin, /var/sbin, /var/Apps, /var/libexec

All executables must have at least these two entitlements:

<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>platform-application</key>
<true/>
<key>com.apple.private.security.container-required</key>
<false/>
</dict>
</plist>


- Tweaks and stuff get installed in: /var/containers/Bundle/tweaksupport the same way you did with Electra betas.
- Tweaks must be patched using the patcher script provided. (Mac/Linux/iOS only) or manually with a hex editor
- Apps get installed in /var/Apps and later you need to run /var/containers/Bundle/iosbinpack64/usr/bin/uicache (other uicache binaries won't work)

# iOS 12
- amfid is patched, however it'll require you to resign everything with a cert. Use `codesign -s 'IDENTITY' --entitlements /path/to/entitlements.xml --force /path/to/binary` **or** inject everything as usual. However note that soon I won't be injecting stuff automatically on jailbreak anymore!
- You **can** tweak App Store apps, but you'll either have to call jailbreakd's fixMmap() yourself **or** resign things with a real cert and amfid will handle that for you. Second option is preferred. See previous point on how to.
- This is not dangerous and cannot screw you up.
- Tweaks pre-patched for rootlessJB 1.0 and 2.0 will not work. Use new patcher script. (ldid was replaced with ldid2!)

patcher usage:
./patcher /path/to/deb /path/to/output_folder

Thanks to: Ian Beer, Brandon Azad, Brandon Plank, Jonathan Levin, Electra Team, IBSparkes, Sam Bingner, Sammy Guichelaar, and @Chr0nicT.
