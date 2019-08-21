It is recommended to use [frida-ios-dump](https://github.com/AloneMonkey/frida-ios-dump) instead!

Dumps decrypted mach-o files from encrypted `applications`、`framework` or `app extensions`.    

### You should install [MonkeyDev](https://github.com/AloneMonkey/MonkeyDev) first 


# Usage

1) open `dumpdecrypted.xcodeproj` edit `dumpdecrypted.plist`   

```
{
	Filter = {
		Bundles = ("target.bundle.id");
	};
}
```

2) Set Build Settings

* MonkeyDevDeviceIP      
* MonkeyDevDevicePort

3) launch application or app extension

```
mach-o decryption dumper
DISCLAIMER: This tool is only meant for security research purposes, not for application crackers.
[+] detected 32bit ARM binary in memory.
[+] offset to cryptid found: @0x1ba08(from 0x1b000) = a08
[+] Found encrypted data at address 00004000 of length 573440 bytes - type 1.
[+] Opening /private/var/mobile/Containers/Bundle/Application/A9622900-FC0A-4D64-AC2E-AC9B69773A22/xxx.app/PlugIns/xxx.appex/xxx for reading.
[+] Reading header
[+] Detecting header type
[+] Executable is a FAT image - searching for right architecture
[+] Correct arch is at offset 16384 in the file
[+] Opening /var/mobile/Containers/Data/PluginKitPlugin/D5C1CB12-DB5B-4C53-9191-B23142841035/Documents/xxx.decrypted for writing.
[+] Copying the not encrypted start of the file
[+] Dumping the decrypted data into the file
[+] Copying the not encrypted remainder of the file
[+] Setting the LC_ENCRYPTION_INFO->cryptid to 0 at offset 4a08
[+] Closing original file
[+] Closing dump file
```

# Check And Thin
$ otool -l xxx.decrypted | grep crypt 

```
xxx.decrypted (architecture armv7):
     cryptoff 16384
    cryptsize 10960896
      cryptid 0
xxx.decrypted (architecture arm64):
     cryptoff 16384
    cryptsize 12124160
      cryptid 1
```

Thin:

```  
$ lipo -thin armv7 xxx.decrypted -output xxx_armv7.decrypted  
$ lipo -thin armv64 xxx.decrypted -output xxx_arm64.decrypted
```


# Author

[Dumpdecrypted](https://github.com/stefanesser/dumpdecrypted) was orignally developed by [stefanesser](https://github.com/stefanesser). 
Learn from [conradev](https://github.com/conradev/dumpdecrypted)
