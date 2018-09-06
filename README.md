##  iOS逆向工程开发 越狱Jailbreak Cydia deb插件开发
![touch4](https://github.com/XLsn0w/Cydia/blob/master/iOS%206.1.6%20jailbreak.JPG?raw=true)

![SE](https://github.com/XLsn0w/Cydia/blob/master/iOS%209.3.2%20jailbreak.JPG?raw=true)
# 我的微信公众号: Cydiapple
![cydiapple](https://raw.githubusercontent.com/XLsn0w/XLsn0w/XLsn0w/XLsn0wLibrary/Cydiapple.png)
##  Class-dump / Theos / Reveal / Dumpdecrypted  逆向工具使用介绍

# Theos

Git仓库地址：<https://github.com/theos/theos> by [Github@DHowett](https://github.com/DHowett?tab=repositories)

更新模版：<https://github.com/DHowett/theos-nic-templates>

lidi: <http://joedj.net/ldid>

dpkg-deb：<https://github.com/DHowett/dm.pl>


## 安装
- 下载**theos**并安装到 `/opt/theos` 
- 配置环境变量 `cd ~` -> `export THEOS=/opt/theos`
- 下载**ldid**到`/opt/theos/bin` 修改权限 `sudo chmod 777 /opt/theos/bin/ldid`
- 下载**dm.pl**重命名为**dpkg-deb**到`/opt/theos/bin` 修改权限 `sudo chmod 777 /opt/theos/bin/dpkg-deb`
- 更新**模版jar**下载拷贝至`opt/theos/templates/iphone/`，注意去重	
## 创建工程

终端运行 `$THEOS/bin/nic.pl`

```ruby

NIC 2.0 - New Instance Creator
------------------------------
  [1.] iphone/activator_event
  [2.] iphone/application_modern
  [3.] iphone/cydget
  [4.] iphone/flipswitch_switch
  [5.] iphone/framework
  [6.] iphone/ios7_notification_center_widget
  [7.] iphone/library
  [8.] iphone/notification_center_widget
  [9.] iphone/preference_bundle_modern
  [10.] iphone/sbsettingstoggle
  [11.] iphone/tool
  [12.] iphone/tweak
  [13.] iphone/xpc_service
Choose a Template (required): 

```






# Class-dump

Github地址： https://github.com/nygard/class-dump

主页：http://stevenygard.com/projects/class-dump

下载并打开[安装包](http://stevenygard.com/download/class-dump-3.5.dmg)（版本可能会随时更新）
将class-dump可执行文件放到`/usr/bin`下或者`/usr/local/bin`

```ruby
class-dump 3.5 (64 bit)
Usage: class-dump [options] <mach-o-file>

where options are:
-a             显示实例变量的偏移
-A             显示实现地址
--arch <arch>  选择通用二进制特定的架构(PPC,PPC64,是i386,x86_64）
-C <regex>     只显示类匹配的正则表达式
-f <str>       找到方法名字符串
-H             在当前路径下导出头文件，或者通过-o指定路径
-I             排序类，类别，以及通过继承协议 ps:此参数将覆盖-s
-o <dir>       -H导出头文件的指定保存路径
-r             递归扩展框架和固定VM共享库
-s             类和类名排序
-S             按名称排序
-t             阻止头文件输出，主要用于测试
--list-arches  列出文件中的架构，然后退出
--sdk-ios      指定的iOS SDK版本（会看在/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS<version>.sdk
--sdk-mac      指定Mac OS X版本（会看在/Developer/SDKs/MacOSX<version>.sdk
--sdk-root     指定完整的SDK根路径（或使用--sdk -IOS / - SDK -MAC的快捷方式）
```

- 如果dump出的文件只有CDStructures.h文件，则表示出现错误。
- 如果dump导出的文件命名为XXEncryptedXXX，则需要通过AppCrackr、Clutch、dumpcrypted等进行砸壳。 [这里是dumpcrypted的使用](Dumpdecrypted.md)


## 例子
class-dump AppKit:

```ruby
class-dump /System/Library/Frameworks/AppKit.framework
```

class-dump UIKit:

```ruby
class-dump /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.3.sdk/System/Library/Frameworks/UIKit.framework
```

class-dump UIKit and all the frameworks it uses:

```ruby
class-dump /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.3.sdk/System/Library/Frameworks/UIKit.framework -r --sdk-ios 4.3
```

class-dump UIKit (and all the frameworks it uses) from developer tools that have been installed in /Dev42 instead of /Developer:

```ruby
class-dump /Dev42/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk/System/Library/Frameworks/UIKit.framework -r --sdk-root /Dev42/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk
```

使用dumpdecrypted给App砸壳后

```ruby
class-dump --arch armv7 app.decrypted -H -o ./heads/
```

## class-dump-z

主页：https://code.google.com/p/networkpx/wiki/class_dump_z

使用wiki： https://code.google.com/archive/p/networkpx/wikis/class_dump_z.wiki

将`class-dump-z`可执行文件放到`/usr/bin`下或者`/usr/local/bin`


## 参考文献

- http://itony.me/200.html







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







# Reveal

Reveal主页：http://revealapp.com

Reveal 是一个界面调试工具，[这里](http://blog.devzeng.com/blog/ios-reveal-integrating.html)有一篇iOS开发中集成Reveal的教程，所以我们就不讨论如何集成到自己的工程中，接下来我们看一下如何使用Reveal查看任意app。

需要的东西：

- 越狱设备
- Cydia
- iFile
- SSH

使用Cydia下载 [**Reveal Loader**](https://github.com/heardrwt/RevealLoader) 并安装后re-spring或重启iOS设备。在系统设置中找到 **Reveal** -> **Enabled Applications** 进行配置，打开你想要Reveal的app。


建议需要查看哪个开哪个，其他的关闭掉，这样Reveal加载速度会快一点。

![这是参考文献中的图](http://ww3.sinaimg.cn/large/6a011e49gw1eyk3r7s8rvj21520rgwma.jpg)


## 参考文献

- http://c.blog.sina.com.cn/profile.php?blogid=cb8a22ea89000gtw 
<br/>这篇有点过时了，修改libReveal.plist时经常出现白苹果，可以强制进入[安全模式](https://www.google.com.hk/#newwindow=1&safe=strict&q=iphone+安全模式)后将文件修改好再重新启动。
- http://hilen.github.io/2015/12/01/Reveal-Loader/

