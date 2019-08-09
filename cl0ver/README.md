# cl0ver

A tfp0 patch for iOS 9, based on the Pegasus/Trident vulnerabilities.

### Download

Precompiled binaries can be obtained from [here](https://github.com/Siguza/cl0ver/releases).

### Building

On macOS with XCode and XCode's command line tools installed:

    make

On a different OS with an iOS SDK and `ldid` installed:

*   Download a [XNU source tarball](https://opensource.apple.com/tarballs/xnu/) and unzip it.
*   Download an [IOKitUser source tarball](https://opensource.apple.com/tarballs/IOKitUser/) and unzip it.
*   Export the following environment variables:

        LIBKERN=path/to/xnu/libkern
        OSFMK=path/to/xnu/osfmk
        IOKIT=path/to/IOKitUser
        IGCC=ios-compiler-command
        LIBTOOL=ios-libtool-command
        SIGN=ldid
        SIGN_FLAGS=-S

### Usage

Command line arguments:

    ./cl0ver panic [log=file]
        Panic the device, loading to PC:
        on 32-bit: the base address of __DATA.__const
        on 64-bit: the OSString vtable

    ./cl0ver slide [log=file]
        Print kernel slide

    ./cl0ver dump [log=file]
        Dump kernel to kernel.bin

    ./cl0ver [log=file]
        Apply tfp0 kernel patch

    If log=file is give, output is written to "file" instead of stderr/syslog.

But before you can use it, cl0ver needs information about your kernel. There are 3 files it might or might not need:

* `/etc/cl0ver/config.txt`  
  Start by running `./cl0ver slide`. If that tells you the kernel slide, this file isn't required. If it tells you "Unhandled error: Unsupported device", do the following:  
  Run `./cl0ver panic` (preferably over SSH) and save the output you get. This should crash your device and generate a panic log (you can find panic logs in Settings > Privacy > Diagnostics & Usage > Diagnostics & Usage > panic-XXX.ips). Somewhere near the top you should see "panic(cpu 0 caller 0xffffff80...)". The message after that should read "Kernel instruction fetch abort: pc=0xffffff80...". **It is important that the first 8 characters of that value are `0xffffff80`. Any value starting with `0xffffff81` is useless.**
  If you didn't get a panic log, or if the panic log does not fulfill the above criteria, repeat the process (also discard the saved output of cl0ver and save the new one).  
  Once you get a panic log, [open a ticket](https://github.com/Siguza/cl0ver/issues/new) and post both your saved output and your panic log (they might be too long to include in your ticket - in that case, post them to pastebin or something and leave a link). I will then attempt to extract the values you have to put in your config.
* `/etc/cl0ver/offsets.dat`  
  Check the [offsets folder](https://github.com/Siguza/cl0ver/tree/master/offsets) to see if a file for your device and OS version is available. If there is one, download it and put it at the mentioned path. If there isn't one available, simply skip this file.
* `/etc/cl0ver/kernel.bin`  
  If you already got an `offsets.dat` file, this file isn't required.  
  if you have no offsets file, first check if [decryption keys](https://www.theiphonewiki.com/wiki/Firmware_Keys/9.x) are available for your device/OS version. If they are, decrypt and extract your kernel from the IPSW and put it at `/etc/cl0ver/kernel.bin`.  
  If none of the above is the case, run `./cl0ver dump`, but be warned: due to the nature of the Pegasus vulnerabilities, dumping is inherently unstable, and there's a good chance your device will just crash. If your device (eventually) doesn't crash however, you should be left with a `kernel.bin` file. Simply move it to `/etc/cl0ver/kernel.bin`.

Once you've verified for each of the above files that you either have it or don't need it, you can go ahead and run `./cl0ver` without any other arguments. It should take less than a second to complete, and end with the line:

    [*] Successfully installed patch

If you see this line, the chances that it went _wrong_ are practically zero, but if you like, you can still verify with any tool that uses the kernel task. `kmap` from [kern-utils](https://github.com/Siguza/ios-kern-utils) is a good candidate IMO (just make sure to run as root).

Now, if it all worked out for you and there was no `offsets.dat` available for your device/OS version, **please [open a ticket](https://github.com/Siguza/cl0ver/issues/new) and attach it there** - you'll be doing others a great favour. :)

### GUI/Sandbox

This repo doesn't contain any code for a GUI/Sandbox app, but a `libcl0ver.a` is built, which can be linked against. You'll most likely want to call functions from `exploit.h`.  
And you'll want to call them like:

    dump_kernel([[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"kernel.bin"].UTF8String);
    // or
    get_kernel_task([NSHomeDirectory() stringByAppendingPathComponent:@"Documents"].UTF8String);

# Writeup

**[ [tfp0 powered by Pegasus](https://siguza.github.io/cl0ver/) ]**

# License

Unless otherwise noted at the top of the file, all files in this repository are released under the [MIT License](LICENSE).
