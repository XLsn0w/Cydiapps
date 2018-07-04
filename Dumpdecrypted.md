# Dumpdecrypted

## 路径

用iFile、Filza等工具找到：

iOS7在`/var/mobile/Application/`

iOS8在`/var/mobile/Containers/Bundle/Application/`

sandbox路径：`/var/mobile/Containers/Data/Application/xxx`

## 编译
源码地址：https://github.com/stefanesser/dumpdecrypted/archive/master.zip

`make`后生成`dumpdecrypted.dylib`文件

>**ps:** 这里有几个编译好的dylib可以下载：
</br>
https://github.com/iosre/Ready2Rock/blob/master/dumpdecrypted_5.dylib
https://github.com/iosre/Ready2Rock/blob/master/dumpdecrypted_6.dylib
https://github.com/iosre/Ready2Rock/blob/master/dumpdecrypted_7.dylib


## 砸壳
把编译好的`dumpdecrypted.dylib`文件放入想要砸壳的app的documents文件夹里

执行以下代码砸壳：
```ruby
DYLD_INSERT_LIBRARIES=dumpdecrypted.dylib /var/mobile/Containers/Bundle/Application/AppPath/Name.app/Name 
```

记录一次成功日志
```ruby
Last login: Sat Jul 16 21:36:39 on ttys000
localhost:~ lihao$ sudo ssh root@192.168.1.13
ssh: connect to host 192.168.1.13 port 22: Operation timed out
localhost:~ lihao$ sudo ssh root@192.168.1.13
root@192.168.1.13's password: 
iPhone:~ root# cd /var/mobile
iPhone:/var/mobile root# cd Containers/Data/Application/  
iPhone:/var/mobile/Containers/Data/Application/4ED085B4-FF7F-4B90-98F9-F17E241E1534 root# cd Documents/

iPhone:/var/mobile/Containers/Data/Application/4ED085B4-FF7F-4B90-98F9-F17E241E1534/Documents root# DYLD_INSERT_LIBRARIES=dumpdecrypted.dylib /var/mobile/Containers/Bundle/Application/1BD15C2B-3661-4104-B8D4-3DE455EB4FB1/NewsBoard.app/NewsBoard

mach-o decryption dumper
DISCLAIMER: This tool is only meant for security research purposes, not for application crackers.

[+] detected 32bit ARM binary in memory.
[+] offset to cryptid found: @0xc6a90(from 0xc6000) = a90
[+] Found encrypted data at address 00004000 of length 12861440 bytes - type 1.
[+] Opening /private/var/mobile/Containers/Bundle/Application/1BD15C2B-3661-4104-B8D4-3DE455EB4FB1/NewsBoard.app/NewsBoard for reading.
[+] Reading header
[+] Detecting header type
[+] Executable is a FAT image - searching for right architecture
[+] Correct arch is at offset 16384 in the file
[+] Opening NewsBoard.decrypted for writing.
[+] Copying the not encrypted start of the file
[+] Dumping the decrypted data into the file
[+] Copying the not encrypted remainder of the file
[+] Setting the LC_ENCRYPTION_INFO->cryptid to 0 at offset 4a90
[+] Closing original file
[+] Closing dump file
iPhone:/var/mobile/Containers/Data/Application/4ED085B4-FF7F-4B90-98F9-F17E241E1534/Documents 

root# 
```

成功后会生成`Name.decrypted`文件

## 分析

当砸壳完毕后，将砸壳生成的 ***.decrypted 文件拷贝至你的MAC。

通过class-dump分析：

```ruby
class-dump --arch armv7 /Users/lihao/Desktop/Name.decrypted -H -o path/
```

## 注意
- 通过Cydia等第三方渠道下载的app有的不需要砸壳，当使用dumpdecrypted时会提示以下信息：
`This mach-o file is not encrypted. Nothing was decrypted.`
- 当砸壳完毕后，使用 class-dump 仍然只导出 CDStructures.h 一个文件，则可能架构选择错误；因为dumpdecrypted只能砸相应手机处理器对应的壳。



## 参考文献
- http://bbs.iosre.com/t/dumpdecrypted-app/22/65
- http://bbs.iosre.com/t/dumpdecrypted-app/160
- http://bbs.iosre.com/t/class-dump-error-cannot-find-offset-for-address-xxxx-in-dataoffsetforaddress/1911