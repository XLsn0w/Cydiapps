##  iOS逆向工程开发 越狱Jailbreak Cydia deb插件开发
![touch4](https://github.com/XLsn0w/Cydia/blob/master/iOS%206.1.6%20jailbreak.JPG?raw=true)

![SE](https://github.com/XLsn0w/Cydia/blob/master/iOS%209.3.2%20jailbreak.JPG?raw=true)
# 我的微信公众号: Cydiapple
![cydiapple](https://raw.githubusercontent.com/XLsn0w/XLsn0w/XLsn0w/XLsn0wLibrary/Cydiapple.png)
## Cycript / Class-dump / Theos / Reveal / Dumpdecrypted  逆向工具使用介绍

# Cycript

官网：http://www.cycript.org/

越狱的设备，在cydia中安装这个插件。


2、设备环境

mac ,  iOS设备（已经越狱）

首先，在手机上安装openssh， 安装方式：cydia。当然，你也可是去官网下载包，然后在将其打包成.deb格式，再拷入iPhone中。

Mac与 iPhone接在了同一个局域网下

3、 简单使用

使用cycript，可实现简单的进程注入。当然，还可以用作其他方面，因为其实时性强。这里，我就实现了简单的进程注入。

4、实现过程：

A、在Mac下使用终端登录到iPhone上，默认密码是：alpine，使用命令：ssh root@192.168.x.x

当然，你也可以在自己的iPhone上装 MTerminal 插件。 如下图
![MTerminal](https://github.com/XLsn0w/Cydia/blob/master/MTerminal.JPG?raw=true)

B、回到主题，继续在终端键入命令  ps -e | grep SpringBoard, 查找 进程id 

C、找到ID 后，就可以用cycript实现注入了，键入命令如下：cycript -p 14823

D、完成注入后，接着键入下面的命令，然后回车，再看看自己的iPhone吧。

alertView = [[[UIAlertView alloc] initWithTitle:@"title" message:@"message" delegate:il cancelButtonTitle:@"ok" otherButtonTitles:nil] show]


我这里注入的进程是 SpringBoard 。 简单的进程注入，只是cycript功能的冰山一角中的一小点，它还有很多强大的功能，看看官网的文档吧。超详细

文档传送门：http://www.cycript.org/manual/


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


```
//                            _ooOoo_
//                           o8888888o
//                           88" . "88
//                           (| -_- |)
//                            O\ = /O
//                        ____/`---'\____
//                      .   ' \\| |// `.
//                       / \\||| : |||// \
//                     / _||||| -:- |||||- \
//                       | | \\\ - /// | |
//                     | \_| ''\---/'' | |
//                      \ .-\__ `-` ___/-. /
//                   ___`. .' /--.--\ `. . __
//                ."" '< `.___\_<|>_/___.' >'"".
//               | | : `- \`.;`\ _ /`;.`/ - ` : | |
//                 \ \ `-. \_ __\ /__ _/ .-` / /
//         ======`-.____`-.___\_____/___.-`____.-'======
//                            `=---='
//
//         .............................................
//                  佛祖镇楼                  BUG辟易
//          佛曰:
//                  写字楼里写字间，写字间里程序员；
//                  程序人员写程序，又拿程序换酒钱。
//                  酒醒只在网上坐，酒醉还来网下眠；
//                  酒醉酒醒日复日，网上网下年复年。
//                  但愿老死电脑间，不愿鞠躬老板前；
//                  奔驰宝马贵者趣，公交自行程序员。
//                  别人笑我忒疯癫，我笑自己命太贱；
//                  不见满街漂亮妹，哪个归得程序员？
//

//_ooOoo_  
//o8888888o  
//88" . "88  
//(| -_- |)  
// O\ = /O  
//___/`---'\____  
//.   ' \\| |// `.  
/// \\||| : |||// \  
/// _||||| -:- |||||- \  
//| | \\\ - /// | |  
//| \_| ''\---/'' | |  
//\ .-\__ `-` ___/-. /  
//___`. .' /--.--\ `. . __  
//."" '< `.___\_<|>_/___.' >'"".  
//| | : `- \`.;`\ _ /`;.`/ - ` : | |  
//\ \ `-. \_ __\ /__ _/ .-` / /  
//======`-.____`-.___\_____/___.-`____.-'======  
//`=---='  
//  
//         .............................................  
//          佛曰：bug泛滥，我已瘫痪！


/**
*　　　　　　　　┏┓　　　┏┓+ +
*　　　　　　　┏┛┻━━━┛┻┓ + +
*　　　　　　　┃　　　　　　　┃
*　　　　　　　┃　　　━　　　┃ ++ + + +
*　　　　　　 ████━████ ┃+
*　　　　　　　┃　　　　　　　┃ +
*　　　　　　　┃　　　┻　　　┃
*　　　　　　　┃　　　　　　　┃ + +
*　　　　　　　┗━┓　　　┏━┛
*　　　　　　　　　┃　　　┃
*　　　　　　　　　┃　　　┃ + + + +
*　　　　　　　　　┃　　　┃　　　　Code is far away from bug with the animal protecting
*　　　　　　　　　┃　　　┃ + 　　　　神兽保佑,代码无bug
*　　　　　　　　　┃　　　┃
*　　　　　　　　　┃　　　┃　　+
*　　　　　　　　　┃　 　　┗━━━┓ + +
*　　　　　　　　　┃ 　　　　　　　┣┓
*　　　　　　　　　┃ 　　　　　　　┏┛
*　　　　　　　　　┗┓┓┏━┳┓┏┛ + + + +
*　　　　　　　　　　┃┫┫　┃┫┫
*　　　　　　　　　　┗┻┛　┗┻┛+ + + +
*/

//
//   █████▒█    ██  ▄████▄   ██ ▄█▀       ██████╗ ██╗   ██╗ ██████╗
// ▓██   ▒ ██  ▓██▒▒██▀ ▀█   ██▄█▒        ██╔══██╗██║   ██║██╔════╝
// ▒████ ░▓██  ▒██░▒▓█    ▄ ▓███▄░        ██████╔╝██║   ██║██║  ███╗
// ░▓█▒  ░▓▓█  ░██░▒▓▓▄ ▄██▒▓██ █▄        ██╔══██╗██║   ██║██║   ██║
// ░▒█░   ▒▒█████▓ ▒ ▓███▀ ░▒██▒ █▄       ██████╔╝╚██████╔╝╚██████╔╝
//  ▒ ░   ░▒▓▒ ▒ ▒ ░ ░▒ ▒  ░▒ ▒▒ ▓▒       ╚═════╝  ╚═════╝  ╚═════╝
//  ░     ░░▒░ ░ ░   ░  ▒   ░ ░▒ ▒░
//  ░ ░    ░░░ ░ ░ ░        ░ ░░ ░
//           ░     ░ ░      ░  ░
//                 ░


//                      d*##$.
// zP"""""$e.           $"    $o
//4$       '$          $"      $
//'$        '$        J$       $F
// 'b        $k       $>       $
//  $k        $r     J$       d$
//  '$         $     $"       $~
//   '$        "$   '$E       $
//    $         $L   $"      $F ...
//     $.       4B   $      $$$*"""*b
//     '$        $.  $$     $$      $F
//      "$       R$  $F     $"      $
//       $k      ?$ u*     dF      .$
//       ^$.      $$"     z$      u$$$$e
//        #$b             $E.dW@e$"    ?$
//         #$           .o$$# d$$$$c    ?F
//          $      .d$$#" . zo$>   #$r .uF
//          $L .u$*"      $&$$$k   .$$d$$F
//           $$"            ""^"$$$P"$P9$
//          JP              .o$$$$u:$P $$
//          $          ..ue$"      ""  $"
//         d$          $F              $
//         $$     ....udE             4B
//          #$    """"` $r            @$
//           ^$L        '$            $F
//             RN        4N           $
//              *$b                  d$
//               $$k                 $F
//               $$b                $F
//                 $""               $F
//                 '$                $
//                  $L               $
//                  '$               $
//                   $               $
//

//         ┌─┐       ┌─┐
//      ┌──┘ ┴───────┘ ┴──┐
//      │                 │
//      │       ───       │
//      │  ─┬┘       └┬─  │
//      │                 │
//      │       ─┴─       │
//      │                 │
//      └───┐         ┌───┘
//          │         │
//          │         │
//          │         │
//          │         └──────────────┐
//          │                        │
//          │                        ├─┐
//          │                        ┌─┘
//          │                        │
//          └─┐  ┐  ┌───────┬──┐  ┌──┘
//            │ ─┤ ─┤       │ ─┤ ─┤
//            └──┴──┘       └──┴──┘
//                神兽保佑
//                代码无BUG!
//          Code is far away from bug with the animal protecting

//                               |~~~~~~~|
//                               |       |
//                               |       |
//                               |       |
//                               |       |
//                               |       |
//    |~.\\\_\~~~~~~~~~~~~~~xx~~~         ~~~~~~~~~~~~~~~~~~~~~/_//;~|
//    |  \  o \_         ,XXXXX),                         _..-~ o /  |
//    |    ~~\  ~-.     XXXXX`)))),                 _.--~~   .-~~~   |
//     ~~~~~~~`\   ~\~~~XXX' _/ ';))     |~~~~~~..-~     _.-~ ~~~~~~~
//              `\   ~~--`_\~\, ;;;\)__.---.~~~      _.-~
//                ~-.       `:;;/;; \          _..-~~
//                   ~-._      `''        /-~-~
//                       `\              /  /
//                         |         ,   | |
//                          |  '        /  |
//                           \/;          |
//                            ;;          |
//                            `;   .       |
//                            |~~~-----.....|
//                           | \             \
//                          | /\~~--...__    |
//                          (|  `\       __-\|
//                          ||    \_   /~    |
//                          |)     \~-'      |
//                           |      | \      '
//                           |      |  \    :
//                            \     |  |    |
//                             |    )  (    )
//                              \  /;  /\  |
//                              |    |/   |
//                              |    |   |
//                               \  .'  ||
//                               |  |  | |
//                               (  | |  |
//                               |   \ \ |
//                               || o `.)|
//                               |`\\\\) |
//                               |       |
//                               |       |





//                  ___====-_  _-====___
//            _--^^^#####//      \\#####^^^--_
//         _-^##########// (    ) \\##########^-_
//        -############//  |\^^/|  \\############-
//      _/############//   (@::@)   \\############\_
//     /#############((     \\//     ))#############\
//    -###############\\    (oo)    //###############-
//   -#################\\  / VV \  //#################-
//  -###################\\/      \//###################-
// _#/|##########/\######(   /\   )######/\##########|\#_
// |/ |#/\#/\#/\/  \#/\##\  |  |  /##/\#/  \/\#/\#/\#| \|
// `  |/  V  V  `   V  \#\| |  | |/#/  V   '  V  V  \|  '
//    `   `  `      `   / | |  | | \   '      '  '   '
//                     (  | |  | |  )
//                    __\ | |  | | /__
//                   (vvv(VVV)(VVV)vvv)
//                  神兽保佑
//                代码无BUG!
//

//                                                    __----~~~~~~~~~~~------___
//                                   .  .   ~~//====......          __--~ ~~
//                   -.            \_|//     |||\\  ~~~~~~::::... /~
//                ___-==_       _-~o~  \/    |||  \\            _/~~-
//        __---~~~.==~||\=_    -_--~/_-~|-   |\\   \\        _/~
//    _-~~     .=~    |  \\-_    '-~7  /-   /  ||    \      /
//  .~       .~       |   \\ -_    /  /-   /   ||      \   /
// /  ____  /         |     \\ ~-_/  /|- _/   .||       \ /
// |~~    ~~|--~~~~--_ \     ~==-/   | \~--===~~        .\
//          '         ~-|      /|    |-~\~~       __--~~
//                      |-~~-_/ |    |   ~\_   _-~            /\
//                           /  \     \__   \/~                \__
//                       _--~ _/ | .-~~____--~-/                  ~~==.
//                      ((->/~   '.|||' -_|    ~~-/ ,              . _||
//                                 -_     ~\      ~~---l__i__i__i--~~_/
//                                 _-~-__   ~)  \--______________--~~
//                               //.-~~~-~_--~- |-------~~~~~~~~
//                                      //.-~~~--\
//                  神兽保佑
//                代码无BUG!

//
//      ,----------------,              ,---------,
//         ,-----------------------,          ,"        ,"|
//       ,"                      ,"|        ,"        ,"  |
//      +-----------------------+  |      ,"        ,"    |
//      |  .-----------------.  |  |     +---------+      |
//      |  |                 |  |  |     | -==----'|      |
//      |  |  I LOVE DOS!    |  |  |     |         |      |
//      |  |  Bad command or |  |  |/----|`---=    |      |
//      |  |  C:\>_          |  |  |   ,/|==== ooo |      ;
//      |  |                 |  |  |  // |(((( [33]|    ,"
//      |  `-----------------'  |," .;'| |((((     |  ,"
//      +-----------------------+  ;;  | |         |,"
//         /_)______________(_/  //'   | +---------+
//    ___________________________/___  `,
//   /  oooooooooooooooo  .o.  oooo /,   \,"-----------
//  / ==ooooooooooooooo==.o.  ooo= //   ,`\--{)B     ,"
// /_==__==========__==_ooo__ooo=_/'   /___________,"
//


//
//                 .-~~~~~~~~~-._       _.-~~~~~~~~~-.
//             __.'              ~.   .~              `.__
//           .'//                  \./                  \\`.
//         .'//                     |                     \\`.
//       .'// .-~"""""""~~~~-._     |     _,-~~~~"""""""~-. \\`.
//     .'//.-"                 `-.  |  .-'                 "-.\\`.
//   .'//______.============-..   \ | /   ..-============.______\\`.
// .'______________________________\|/______________________________`.
//
//


// 亲爱的维护者：
// 如果你尝试了对这段程序进行‘优化’，
// 并认识到这种企图是大错特错，请增加
// 下面这个计数器的个数，用来对后来人进行警告：
// 浪费在这里的总时间 = 39h

/** * 致终于来到这里的勇敢的人：
你是被上帝选中的人，英勇的、不辞劳苦的、不眠不修的来修改
我们这最棘手的代码的编程骑士。你，我们的救世主，人中之龙，
我要对你说：永远不要放弃，永远不要对自己失望，永远不要逃走，辜负了自己。
永远不要哭啼，永远不要说再见。永远不要说谎来伤害自己。 */




/**
*                      江城子 . 程序员之歌
*
*                  十年生死两茫茫，写程序，到天亮。
*                      千行代码，Bug何处藏。
*                  纵使上线又怎样，朝令改，夕断肠。
*
*                  领导每天新想法，天天改，日日忙。
*                      相顾无言，惟有泪千行。
*                  每晚灯火阑珊处，夜难寐，加班狂。
*/

//
//                       .::::.
//                     .::::::::.
//                    :::::::::::          FUCK YOU 
//                 ..:::::::::::'
//              '::::::::::::'
//                .::::::::::
//           '::::::::::::::..
//                ..::::::::::::.
//              ``::::::::::::::::
//               ::::``:::::::::'        .:::.
//              ::::'   ':::::'       .::::::::.
//            .::::'      ::::     .:::::::'::::.
//           .:::'       :::::  .:::::::::' ':::::.
//          .::'        :::::.:::::::::'      ':::::.
//         .::'         ::::::::::::::'         ``::::.
//     ...:::           ::::::::::::'              ``::.
//    ```` ':.          ':::::::::'                  ::::..
//                       '.:::::'                    ':'````..


/**********
.--,       .--,
( (  \.---./  ) )
'.__/o   o\__.'
{=  ^  =}
>  -  <
/       \
//       \\
//|   .   |\\
"'\       /'"_.-~^`'-.
\  _  /--'         `
___)( )(___
(((__) (__)))    高山仰止,景行行止.虽不能至,心向往之。


**********/  


/*
::
:;J7, :,                        ::;7:
,ivYi, ,                       ;LLLFS:
:iv7Yi                       :7ri;j5PL
,:ivYLvr                    ,ivrrirrY2X,
:;r@Wwz.7r:                :ivu@kexianli.
:iL7::,:::iiirii:ii;::::,,irvF7rvvLujL7ur
ri::,:,::i:iiiiiii:i:irrv177JX7rYXqZEkvv17
;i:, , ::::iirrririi:i:::iiir2XXvii;L8OGJr71i
:,, ,,:   ,::ir@mingyi.irii:i:::j1jri7ZBOS7ivv,
,::,    ::rv77iiiriii:iii:i::,rvLq@huhao.Li
,,      ,, ,:ir7ir::,:::i;ir:::i:i::rSGGYri712:
:::  ,v7r:: ::rrv77:, ,, ,:i7rrii:::::, ir7ri7Lri
,     2OBBOi,iiir;r::        ,irriiii::,, ,iv7Luur:
,,     i78MBBi,:,:::,:,  :7FSL: ,iriii:::i::,,:rLqXv::
:      iuMMP: :,:::,:ii;2GY7OBB0viiii:i:iii:i:::iJqL;::
,     ::::i   ,,,,, ::LuBBu BBBBBErii:i:i:i:i:i:i:r77ii
,       :       , ,,:::rruBZ1MBBqi, :,,,:::,::::::iiriri:
,               ,,,,::::i:  @arqiao.       ,:,, ,:::ii;i7:
:,       rjujLYLi   ,,:::::,:::::::::,,   ,:i,:,,,,,::i:iii
::      BBBBBBBBB0,    ,,::: , ,:::::: ,      ,,,, ,,:::::::
i,  ,  ,8BMMBBBBBBi     ,,:,,     ,,, , ,   , , , :,::ii::i::
:      iZMOMOMBBM2::::::::::,,,,     ,,,,,,:,,,::::i:irr:i:::,
i   ,,:;u0MBMOG1L:::i::::::  ,,,::,   ,,, ::::::i:i:iirii:i:i:
:    ,iuUuuXUkFu7i:iii:i:::, :,:,: ::::::::i:i:::::iirr7iiri::
:     :rk@Yizero.i:::::, ,:ii:::::::i:::::i::,::::iirrriiiri::,
:      5BMBBBBBBSr:,::rv2kuii:::iii::,:i:,, , ,,:,:i@petermu.,
, :r50EZ8MBBBBGOBBBZP7::::i::,:::::,: :,:,::i;rrririiii::
:jujYY7LS0ujJL7r::,::i::,::::::::::::::iirirrrrrrr:ii:
,:  :@kevensun.:,:,,,::::i:i:::::,,::::::iir;ii;7v77;ii;i,
,,,     ,,:,::::::i:iiiii:i::::,, ::::iiiir@xingjief.r;7:i,
, , ,,,:,,::::::::iiiiiiiiii:,:,:::::::::iiir;ri7vL77rrirri::
:,, , ::::::::i:::i:::i:i::,,,,,:,::i:i:::iir;@Secbone.ii:::

*/

/**
* ┌───┐   ┌───┬───┬───┬───┐ ┌───┬───┬───┬───┐ ┌───┬───┬───┬───┐ ┌───┬───┬───┐
* │Esc│   │ F1│ F2│ F3│ F4│ │ F5│ F6│ F7│ F8│ │ F9│F10│F11│F12│ │P/S│S L│P/B│  ┌┐    ┌┐    ┌┐
* └───┘   └───┴───┴───┴───┘ └───┴───┴───┴───┘ └───┴───┴───┴───┘ └───┴───┴───┘  └┘    └┘    └┘
* ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───────┐ ┌───┬───┬───┐ ┌───┬───┬───┬───┐
* │~ `│! 1│@ 2│# 3│$ 4│% 5│^ 6│& 7│* 8│( 9│) 0│_ -│+ =│ BacSp │ │Ins│Hom│PUp│ │N L│ / │ * │ - │
* ├───┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─────┤ ├───┼───┼───┤ ├───┼───┼───┼───┤
* │ Tab │ Q │ W │ E │ R │ T │ Y │ U │ I │ O │ P │{ [│} ]│ | \ │ │Del│End│PDn│ │ 7 │ 8 │ 9 │   │
* ├─────┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴─────┤ └───┴───┴───┘ ├───┼───┼───┤ + │
* │ Caps │ A │ S │ D │ F │ G │ H │ J │ K │ L │: ;│" '│ Enter  │               │ 4 │ 5 │ 6 │   │
* ├──────┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴────────┤     ┌───┐     ├───┼───┼───┼───┤
* │ Shift  │ Z │ X │ C │ V │ B │ N │ M │< ,│> .│? /│  Shift   │     │ ↑ │     │ 1 │ 2 │ 3 │   │
* ├─────┬──┴─┬─┴──┬┴───┴───┴───┴───┴───┴──┬┴───┼───┴┬────┬────┤ ┌───┼───┼───┐ ├───┴───┼───┤ E││
* │ Ctrl│    │Alt │         Space         │ Alt│    │    │Ctrl│ │ ← │ ↓ │ → │ │   0   │ . │←─┘│
* └─────┴────┴────┴───────────────────────┴────┴────┴────┴────┘ └───┴───┴───┘ └───────┴───┴───┘
*/

/**
**************************************************************
*                                                            *
*   .=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-.       *
*    |                     ______                     |      *
*    |                  .-"      "-.                  |      *
*    |                 /            \                 |      *
*    |     _          |              |          _     |      *
*    |    ( \         |,  .-.  .-.  ,|         / )    |      *
*    |     > "=._     | )(__/  \__)( |     _.=" <     |      *
*    |    (_/"=._"=._ |/     /\     \| _.="_.="\_)    |      *
*    |           "=._"(_     ^^     _)"_.="           |      *
*    |               "=\__|IIIIII|__/="               |      *
*    |              _.="| \IIIIII/ |"=._              |      *
*    |    _     _.="_.="\          /"=._"=._     _    |      *
*    |   ( \_.="_.="     `--------`     "=._"=._/ )   |      *
*    |    > _.="                            "=._ <    |      *
*    |   (_/                                    \_)   |      *
*    |                                                |      *
*    '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-='      *
*                                                            *
*           LASCIATE OGNI SPERANZA, VOI CH'ENTRATE           *
**************************************************************
*/

/**
* 頂頂頂頂頂頂頂頂頂　頂頂頂頂頂頂頂頂頂
* 頂頂頂頂頂頂頂　　　　　頂頂　　　　　
* 　　　頂頂　　　頂頂頂頂頂頂頂頂頂頂頂
* 　　　頂頂　　　頂頂頂頂頂頂頂頂頂頂頂
* 　　　頂頂　　　頂頂　　　　　　　頂頂
* 　　　頂頂　　　頂頂　　頂頂頂　　頂頂
* 　　　頂頂　　　頂頂　　頂頂頂　　頂頂
* 　　　頂頂　　　頂頂　　頂頂頂　　頂頂
* 　　　頂頂　　　頂頂　　頂頂頂　　頂頂
* 　　　頂頂　　　　　　　頂頂頂　
* 　　　頂頂　　　　　　頂頂　頂頂　頂頂
* 　頂頂頂頂　　　頂頂頂頂頂　頂頂頂頂頂
* 　頂頂頂頂　　　頂頂頂頂　　　頂頂頂頂
*/


/*



.. .vr       
qBMBBBMBMY     
8BBBBBOBMBMv    
iMBMM5vOY:BMBBv        
.r,             OBM;   .: rBBBBBY     
vUL             7BB   .;7. LBMMBBM.   
.@Wwz.           :uvir .i:.iLMOMOBM..  
vv::r;             iY. ...rv,@arqiao. 
Li. i:             v:.::::7vOBBMBL.. 
,i7: vSUi,         :M7.:.,:u08OP. .  
.N2k5u1ju7,..     BMGiiL7   ,i,i.  
:rLjFYjvjLY7r::.  ;v  vr... rE8q;.:,, 
751jSLXPFu5uU@guohezou.,1vjY2E8@Yizero.    
BB:FMu rkM8Eq0PFjF15FZ0Xu15F25uuLuu25Gi.   
ivSvvXL    :v58ZOGZXF2UUkFSFkU1u125uUJUUZ,   
:@kevensun.      ,iY20GOXSUXkSuS2F5XXkUX5SEv.  
.:i0BMBMBBOOBMUi;,        ,;8PkFP5NkPXkFqPEqqkZu.  
.rqMqBBMOMMBMBBBM .           @kexianli.S11kFSU5q5   
.7BBOi1L1MM8BBBOMBB..,          8kqS52XkkU1Uqkk1kUEJ   
.;MBZ;iiMBMBMMOBBBu ,           1OkS1F1X5kPP112F51kU   
.rPY  OMBMBBBMBB2 ,.          rME5SSSFk1XPqFNkSUPZ,.
;;JuBML::r:.:.,,        SZPX0SXSP5kXGNP15UBr.
L,    :@sanshao.      :MNZqNXqSqXk2E0PSXPE .
viLBX.,,v8Bj. i:r7:,     2Zkqq0XXSNN0NOXXSXOU 
:r2. rMBGBMGi .7Y, 1i::i   vO0PMNNSXXEqP@Secbone.
.i1r. .jkY,    vE. iY....  20Fq0q5X5F1S2F22uuv1M; 


又看源码,看你妹妹呀!


*/


/*
__
,-~¨^  ^¨-,           _,
/          / ;^-._...,¨/
/          / /         /
/          / /         /
/          / /         /
/,.-:''-,_ / /         /
_,.-:--._ ^ ^:-._ __../
/^         / /¨:.._¨__.;
/          / /      ^  /
/          / /         /
/          / /         /
/_,.--:^-._/ /         /
^            ^¨¨-.___.:^  (R) - G33K

*/


/*
___                _
/ __|___  ___  __ _| |___
| (_ / _ \/ _ \/ _` |   -_)
\___\___/\___/\__, |_\___|
|___/

*/

/*
_.-"""""-._         _.-"""""-._         _.-"""""-._
,'           `.     ,'           `.     ,'           `.
/               \   /               \   /               \
|                 | |                 | |                 |
|                   |                   |                   |
|                   |                   |                   |
|             _.-"|"|"-._         _.-"|"|"-._             |
\          ,'   /   \   `.     ,'   /   \   `.          /
`.       /   ,'     `.   \   /   ,'     `.   \       ,'
`-..__|..-'         `-..|_|..-'         `-..|__..-'
|                   |                   |
|                   |                   |
|                 | |                 |
\               /   \               /
`.           ,'     `.           ,'
`-..___..-'         `-..___..-'

*/


/*
_
\"-._ _.--"~~"--._
\   "            ^.    ___
/                  \.-~_.-~
.-----'     /\/"\ /~-._      /
/  __      _/\-.__\L_.-/\     "-.
/.-"  \    ( ` \_o>"<o_/  \  .--._\
/'      \    \:     "     :/_/     "`
/  /\ "\    ~    /~"
\ I  \/]"-._ _.-"[
___ \|___/ ./    l   \___   ___
.--v~   "v` ( `-.__   __.-' ) ~v"   ~v--.
.-{   |     :   \_    "~"    _/   :     |   }-.
/   \  |           ~-.,___,.-~           |  /   \
]     \ |                                 | /     [
/\     \|     :                     :     |/     /\
/  ^._  _K.___,^                     ^.___,K_  _.^  \
/   /  "~/  "\                           /"  \~"  \   \
/   /    /     \ _          :          _ /     \    \   \
.^--./    /       Y___________l___________Y       \    \.--^.
[    \   /        |        [/    ]        |        \   /    ]
|     "v"         l________[____/]________j  -Row   }r"     /
}------t          /                       \       /`-.     /
|      |         Y                         Y     /    "-._/
}-----v'         |         :               |     7-.     /
|   |_|          |         l               |    / . "-._/
l  .[_]          :          \              :  r[]/_.  /
\_____]                     "--.             "-.____/

"Dragonball Z"
---Row

*/


/*
MMMMM
MMMMMM
MMMMMMM
MMMMMMMM     .
MMMMMMMMM
HMMMMMMMMMM
MMMMMMMMMMMM  M
MMMMMMMMMMMMM  M
MMMMMMMMMMMMM  M
MMMMMMMMMMMMM:
oMMMMMMMMMMMMMM
.MMMMMMMMMMMMMMo           MMMMMMMMMMMMMMM M
MMMMMMMMMMMMMMMMMMMMMMMMMMM      MMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMM.  oMMMMMMMMMMMMMMM.M
MMMMMMMMMMMMMMMMMMMMMMMMMMMM  MMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
oMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM:                     H
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                  .         MMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM              M       MMMMMM
.MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM          M   MMMMMMMMMM
MM.      MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM       M MMMMMMMMMMMM
MM    MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM    .MMMMMMMMMMMMMM
MM  MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MM MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
.MMMMMMMMM MMMMMMMMMMMMMMMMMMMMMMMM.MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
HMMMMMMMMMMMMMMMMMMMMM.MMMMMMMMM.MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMM MMM.oMMMMMMM..MMMMMMMMM:MMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMM MM..MMMMMMM...MMMMMMM. MMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMM ..MMMMMM...MMMMMM ..MMMMMMMMMMMMMMMMMMM
MMMMMMM:M.MMM.M.. MMMMM M..MMMMM...MMMMMMMMMMMMMMMMMM  MMM
MMMM. .M..MM.M...MMMMMM..MMMMM.. MMMMMMMMMMMMMMMMMMMMMMMMMMMMMM .
MMMM..M....M.....:MMM .MMMMMM..MMMMMMM...MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMM.M.. ...M......MM.MMMMM.......MHM.M  .MMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMM..MM. . MMM.....MMMMMM.M.....M ..MM..M MMMMMMMMMMMMMMMMMMM
.MMMMMHMM. ..MMMM. MMM............o..... . .MMMMMMMMMMMMMMM
MMM. M... .........................M..:.MMMMMMMMMMMM
oMMM............ .................M.M.MMMMMMMMM
.....MM........................ . MMMMMM
M.....M.....................o.MM.MMMMMMMM.
M........................M.. ...MMMMMMMMMMMMMo
:....MMM..............MMM..oMMMMMMM
M...MMM.............MMMMMMM
.............:MMMMMMMM
M..... MMM.....M
M M.............
................M
ooM.................MM  MoMMMMMoooM
MMoooM......................MoooooooH..oMM
MHooooMoM.....................MMooooooM........M
oooooooMoooM......... o........MoooooooM............
Mooooooooooo.......M.........Moooooooo:..............M
MooMoooooooooM...M........:Mooooooooooo:..............M
M..oooooooooooo .........Mooooooooooooooo..............M
M...Mooo:oooooooo.M....ooooooooooooooooooo..M...........M
...oooooMoooooooM..Mooooooooooooo:oooooooM.M...........M.
M...ooooooMoo:ooooMoooooooooooooHoooooooooH:M. ...........:
M..MoooooooMoooooooooooooooooo:ooooooMooooMoM..............M
M..ooooooooooMooooooooooooooHoooooooMooHooooM...............M
...ooooooooooooooooooo:MooooooooooooooMoMoooM................
M...oooooooooooooooooooooooooooooooooooooMooMM................M
...MooooooooooooooooooooooooooooooooooooooooMo ................
...MooooooooooooooooooooooooooooooooooooooooM M................M
M...ooooooooooooooooooooooooooooooooooooooooM   ................M
...MoooooooooooooooooooooooooooooooooooooooMM   .:...............
.....MooooooooooooooooooooooooooooooooooooMoo       .............M
M...... ooooooooooooooooooooooooooooooooooooM       M..............M
M........MooooMMM MM MM  MMMMMMMMMooooooooM         M...............M
.........HM     M:  MM :MMMMMM          M           M...............
M..........M     M   MoM M                           M................M
M.........:M  MoH  M M M MooooHoooMM.   M             M...............M
M..........Moooo MMooM    oooooMooooooooM              M..............H
M.........MooooM  Mooo  : ooooooMooooMoooM              M........ . .o.M
H..  .....ooooo   oooo  M MooooooooooooooM               M... MMMMMMMMMMM
MMMMMMMMMMooooM M oooo  .  ooooooMooooooooM              .MMMMMMMMMMMMMMM
MMMMMMMMMMooooH : ooooH    oooooooooooooooo               MMMMMMMMMMMMMMM
MMMMMMMMMMoooo    ooooM    Moooooooooooooooo              .MMMMMMMMMMMMMMM
MMMMMMMMMMoooo    ooooM    MooooooooooooooooM              MMMMMMMMMMMMMMM
MMMMMMMMMMoooM    ooooM     ooooooooooooooooo               MMMMMMMMMMM:M
MMMMMMMMMMoooM   MooooM     oooooooooooMoooooo               MH...........
. ......Mooo.   MooooM     oooooooooooooooooo              M............M
M.M......oooo    MooooM     Moooooooooooooooooo:           .........M.....
M.M.....Moooo    MooooM      ooooooooooooooooooM            .M............
.......MooooH    MooooM      oooooooooMoooooooooo          M..o...M..o....M
.o....HMooooM    MooooH      MooooooooMooooooooooM          .:M...M.......M
M..M.....MoooM    :oooo:    .MooooooooHooMoooooooooM         M M... ..oM.M
M...M.:.Mooo. MMMMooooo   oooooooooooMoooooooooooooM          ....M. M
M:M..o.Moooooooooooooo MooooooooooooooMooooooooooooM          .Mo
MooooooooooooooMooooooooooooMoMoooooooooooooo
Mooooooooooooooo:ooooooooooooooooooooooooooooo
ooooooooooooooooMooooooooooMoooooooooooooooooo
ooooooooooooooooMoooooooooooMooooooooooooooooHo
ooMooooooooooooooMoooooooooooooooooooooooooooMoM
MooMoooooooooooooo.ooooooooooooooooooooooooooo:oM
MoooooooooooooooooooooooooooooooooooooooooooooooM
MoooMooooooooooooooMooooooooooooooooooooooooooooo.
MoooMooooooooooooooMoooooooooooooooooooooooooMooooM
MooooooooooooooooooMoooooooooooooooooooooooooMoooooM
MooooMoooooooooooooMoooooooooooooooooooooooooMoHooooM
ooooooMooooooooooooooooooooooooooooooooooooooooMoMoooM
MooooooooooooooooooooMooooooooooooooooooooooooooMoooooH:
MoooooooMooooooooooooMoooooooooooooooooooooooooooooHoooM
MooooooooMoooooooooooMoooooooooooooooooooooooooMoooMooooM
Moooooooooooooooooooooooooooooooooooooooooooooo.oooMooooo
MoooooooooooooooooooooooooooooooooooooooooooooMoooooooooM
MooooooooooooooooooooMoooooooooooooooooooooooooooooooooM
MooooooooooooooooooooMHooooooooooooooooooooMoooo:ooooo
MMooooooooooooooooooMoMHoooooooooooooooooooooooMooooo
MMoooooooooooooooMMooo MMooooooooooooooooooooooooooM
MMMoooooooooooooMooooo  oooooooooooooooooooooMooooo
MooMMoooooooooMoooMMoM  ooooHooooooooooooooooMooooM
MooooMooooooMooooMoooM  MoooooMoooooooooooooMooooo
ooooooMMooooooooMooooM  MoooooooooMooooooooooooooM
HooooooMoooooooMooooM    HoooooooHooMooooooooooooo
oooMoooooooooHoooM         MoooooooooMoooooooooM
HooooooooooooHM             MooooooooMMoooooooM
MMMMMMMMMMMMMM                Moooooo:MooooHMM
MMMMMMM: ...                  MMMMMMMMMMMMMM
M............M                  MMMMMMMMM ....
M.MM..........                  M.............M
M ..............MM                 M..............
MMMMM............MMMM                 ..MMMMMMMM ....M
MMMMMMMMMMMMMMMMMMMMMMMM               MMMMMMMMMMMMM...M
.MMMMMMMMMMMMMMMMMMMMMMMMMM               MMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMM                MMMMMMMMMMMMMMMMMMM
:MMMMMMMMMMMMMMMMMMH                     MMMMMMMMMMMMMMMMMMM
By EBEN Jérôme                        MMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMM
HMMMMMM

*/



/*
quu..__
$$$b  `---.__
"$$b        `--.                          ___.---uuudP
`$$b           `.__.------.__     __.---'      $$$$"              .
"$b          -'            `-.-'            $$$"              .'|
".                                       d$"             _.'  |
`.   /                              ..."             .'     |
`./                           ..::-'            _.'       |
/                         .:::-'            .-'         .'
:                          ::''\          _.'            |
.' .-.             .-.           `.      .'               |
: /'$$|           .@"$\           `.   .'              _.-'
.'|$u$$|          |$$,$$|           |  <            _.-'
| `:$$:'          :$$$$$:           `.  `.       .-'
:                  `"--'             |    `-.     \
:##.       ==             .###.       `.      `.    `\
|##:                      :###:        |        >     >
|#'     `..'`..'          `###'        x:      /     /
\                                   xXX|     /    ./
\                                xXXX'|    /   ./
/`-.                                  `.  /   /
:    `-  ...........,                   | /  .'
|         ``:::::::'       .            |<    `.
|             ```          |           x| \ `.:``.
|                         .'    /'   xXX|  `:`M`M':.
|    |                    ;    /:' xXXX'|  -'MMMMM:'
`.  .'                   :    /:'       |-'MMMM.-'
|  |                   .'   /'        .'MMM.-'
`'`'                   :  ,'          |MMM<
|                     `'            |tbap\
\                                  :MM.-'
\                 |              .''
\.               `.            /
/     .:::::::.. :           /
|     .:::::::::::`.         /
|   .:::------------\       /
/   .''               >::'  /
`',:                 :    .'
`:.:'


*/



/*
11111111111111111111111111111111111111001111111111111111111111111
11111111111111111111111111111111111100011111111111111111111111111
11111111111111111111111111111111100001111111111111111111111111111
11111111111111111111111111111110000111111111111111111111111111111
11111111111111111111111111111000000111111111111111111111111111111
11111111111111111111111111100000011110001100000000000000011111111
11111111111111111100000000000000000000000000000000011111111111111
11111111111111110111000000000000000000000000000011111111111111111
11111111111111111111111000000000000000000000000000000000111111111
11111111111111111110000000000000000000000000000000111111111111111
11111111111111111100011100000000000000000000000000000111111111111
11111111111111100000110000000000011000000000000000000011111111111
11111111111111000000000000000100111100000000000001100000111111111
11111111110000000000000000001110111110000000000000111000011111111
11111111000000000000000000011111111100000000000000011110001111111
11111110000000011111111111111111111100000000000000001111100111111
11111111000001111111111111111111110000000000000000001111111111111
11111111110111111111111111111100000000000000000000000111111111111
11111111111111110000000000000000000000000000000000000111111111111
11111111111111111100000000000000000000000000001100000111111111111
11111111111111000000000000000000000000000000111100000111111111111
11111111111000000000000000000000000000000001111110000111111111111
11111111100000000000000000000000000000001111111110000111111111111
11111110000000000000000000000000000000111111111110000111111111111
11111100000000000000000001110000001111111111111110001111111111111
11111000000000000000011111111111111111111111111110011111111111111
11110000000000000001111111111111111100111111111111111111111111111
11100000000000000011111111111111111111100001111111111111111111111
11100000000001000111111111111111111111111000001111111111111111111
11000000000001100111111111111111111111111110000000111111111111111
11000000000000111011111111111100011111000011100000001111111111111
11000000000000011111111111111111000111110000000000000011111111111
11000000000000000011111111111111000000000000000000000000111111111
11001000000000000000001111111110000000000000000000000000001111111
11100110000000000001111111110000000000000000111000000000000111111
11110110000000000000000000000000000000000111111111110000000011111
11111110000000000000000000000000000000001111111111111100000001111
11111110000010000000000000000001100000000111011111111110000001111
11111111000111110000000000000111110000000000111111111110110000111
11111110001111111100010000000001111100000111111111111111110000111
11111110001111111111111110000000111111100000000111111111111000111
11111111001111111111111111111000000111111111111111111111111100011
11111111101111111111111111111110000111111111111111111111111001111
11111111111111111111111111111110001111111111111111111111100111111
11111111111111111111111111111111001111111111111111111111001111111
11111111111111111111111111111111100111111111111111111111111111111
11111111111111111111111111111111110111111111111111111111111111111


*/



/*
.....'',;;::cccllllllllllllcccc:::;;,,,''...'',,'..
..';cldkO00KXNNNNXXXKK000OOkkkkkxxxxxddoooddddddxxxxkkkkOO0XXKx:.
.':ok0KXXXNXK0kxolc:;;,,,,,,,,,,,;;,,,''''''',,''..              .'lOXKd'
.,lx00Oxl:,'............''''''...................    ...,;;'.             .oKXd.
.ckKKkc'...'',:::;,'.........'',;;::::;,'..........'',;;;,'.. .';;'.           'kNKc.
.:kXXk:.    ..       ..................          .............,:c:'...;:'.         .dNNx.
:0NKd,          .....''',,,,''..               ',...........',,,'',,::,...,,.        .dNNx.
.xXd.         .:;'..         ..,'             .;,.               ...,,'';;'. ...       .oNNo
.0K.         .;.              ;'              ';                      .'...'.           .oXX:
.oNO.         .                 ,.              .     ..',::ccc:;,..     ..                lXX:
.dNX:               ......       ;.                'cxOKK0OXWWWWWWWNX0kc.                    :KXd.
.l0N0;             ;d0KKKKKXK0ko:...              .l0X0xc,...lXWWWWWWWWKO0Kx'                   ,ONKo.
.lKNKl...'......'. .dXWN0kkk0NWWWWWN0o.            :KN0;.  .,cokXWWNNNNWNKkxONK: .,:c:.      .';;;;:lk0XXx;
:KN0l';ll:'.         .,:lodxxkO00KXNWWWX000k.       oXNx;:okKX0kdl:::;'',;coxkkd, ...'. ...'''.......',:lxKO:.
oNNk,;c,'',.                      ...;xNNOc,.         ,d0X0xc,.     .dOd,           ..;dOKXK00000Ox:.   ..''dKO,
'KW0,:,.,:..,oxkkkdl;'.                'KK'              ..           .dXX0o:'....,:oOXNN0d;.'. ..,lOKd.   .. ;KXl.
;XNd,;  ;. l00kxoooxKXKx:..ld:         ;KK'                             .:dkO000000Okxl;.   c0;      :KK;   .  ;XXc
'XXdc.  :. ..    '' 'kNNNKKKk,      .,dKNO.                                   ....       .'c0NO'      :X0.  ,.  xN0.
.kNOc'  ,.      .00. ..''...      .l0X0d;.             'dOkxo;...                    .;okKXK0KNXx;.   .0X:  ,.  lNX'
,KKdl  .c,    .dNK,            .;xXWKc.                .;:coOXO,,'.......       .,lx0XXOo;...oNWNXKk:.'KX;  '   dNX.
:XXkc'....  .dNWXl        .';l0NXNKl.          ,lxkkkxo' .cK0.          ..;lx0XNX0xc.     ,0Nx'.','.kXo  .,  ,KNx.
cXXd,,;:, .oXWNNKo'    .'..  .'.'dKk;        .cooollox;.xXXl     ..,cdOKXXX00NXc.      'oKWK'     ;k:  .l. ,0Nk.
cXNx.  . ,KWX0NNNXOl'.           .o0Ooldk;            .:c;.':lxOKKK0xo:,.. ;XX:   .,lOXWWXd.      . .':,.lKXd.
lXNo    cXWWWXooNWNXKko;'..       .lk0x;       ...,:ldk0KXNNOo:,..       ,OWNOxO0KXXNWNO,        ....'l0Xk,
.dNK.   oNWWNo.cXK;;oOXNNXK0kxdolllllooooddxk00KKKK0kdoc:c0No        .'ckXWWWNXkc,;kNKl.          .,kXXk,
'KXc  .dNWWX;.xNk.  .kNO::lodxkOXWN0OkxdlcxNKl,..        oN0'..,:ox0XNWWNNWXo.  ,ONO'           .o0Xk;
.ONo    oNWWN0xXWK, .oNKc       .ONx.      ;X0.          .:XNKKNNWWWWNKkl;kNk. .cKXo.           .ON0;
.xNd   cNWWWWWWWWKOkKNXxl:,'...;0Xo'.....'lXK;...',:lxk0KNWWWWNNKOd:..   lXKclON0:            .xNk.
.dXd   ;XWWWWWWWWWWWWWWWWWWNNNNNWWNNNNNNNNNWWNNNNNNWWWWWNXKNNk;..        .dNWWXd.             cXO.
.xXo   .ONWNWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWNNK0ko:'..OXo          'l0NXx,              :KK,
.OXc    :XNk0NWXKNWWWWWWWWWWWWWWWWWWWWWNNNX00NNx:'..       lXKc.     'lONN0l.              .oXK:
.KX;    .dNKoON0;lXNkcld0NXo::cd0NNO:;,,'.. .0Xc            lXXo..'l0NNKd,.              .c0Nk,
:XK.     .xNX0NKc.cXXl  ;KXl    .dN0.       .0No            .xNXOKNXOo,.               .l0Xk;.
.dXk.      .lKWN0d::OWK;  lXXc    .OX:       .ONx.     . .,cdk0XNXOd;.   .'''....;c:'..;xKXx,
.0No         .:dOKNNNWNKOxkXWXo:,,;ONk;,,,,,;c0NXOxxkO0XXNXKOdc,.  ..;::,...;lol;..:xKXOl.
,XX:             ..';cldxkOO0KKKXXXXXXXXXXKKKKK00Okxdol:;'..   .';::,..':llc,..'lkKXkc.
:NX'    .     ''            ..................             .,;:;,',;ccc;'..'lkKX0d;.
lNK.   .;      ,lc,.         ................        ..,,;;;;;;:::,....,lkKX0d:.
.oN0.    .'.      .;ccc;,'....              ....'',;;;;;;;;;;'..   .;oOXX0d:.
.dN0.      .;;,..       ....                ..''''''''....     .:dOKKko;.
lNK'         ..,;::;;,'.........................           .;d0X0kc'.
.xXO'                                                 .;oOK0x:.
.cKKo.                                    .,:oxkkkxk0K0xc'.
.oKKkc,.                         .';cok0XNNNX0Oxoc,.
.;d0XX0kdlc:;,,,',,,;;:clodkO0KK0Okdl:,'..
.,coxO0KXXXXXXXKK0OOxdoc:,..
...

*/


/*

/88888888888888888888888888\
|88888888888888888888888888/
|~~____~~~~~~~~~"""""""""|
/ \_________/"""""""""""""\
/  |              \         \
/   |  88    88     \         \
/    |  88    88      \         \
/    /                  \        |
/     |   ________        \       |
\     |   \______/        /       |
/"\         \     \____________     /        |
| |__________\_        |  |        /        /
/""""\           \_------'  '-------/       --
\____/,___________\                 -------/
------*            |                    \
||               |                     \
||               |                 ^    \
||               |                | \    \
||               |                |  \    \
||               |                |   \    \
\|              /                /"""\/    /
-------------                |    |    /
|\--_                        \____/___/
|   |\-_                       |
|   |   \_                     |
|   |     \                    |
|   |      \_                  |
|   |        ----___           |
|   |               \----------|
/   |                     |     ----------""\
/"\--"--_|                     |               |  \
|_______/                      \______________/    )
\___/
*/

/*
*     ,MMM8&&&.            *
MMMM88&&&&&    .
MMMM88&&&&&&&
*           MMM88&&&&&&&&
MMM88&&&&&&&&
'MMM88&&&&&&'
'MMM8&&&'      *    
/\/|_    __/\\
/    -\  /-   ~\  .              '
\    =_YT_ =   /
/==*(`    `\ ~ \
/     \     /    `\
|     |     ) ~   (
/       \   /     ~ \
\       /   \~     ~/
jgs_/\_/\__  _/_/\_/\__~__/_/\_/\_/\_/\_/\_
|  |  |  | ) ) |  |  | ((  |  |  |  |  |  |
|  |  |  |( (  |  |  |  \\ |  |  |  |  |  |
|  |  |  | )_) |  |  |  |))|  |  |  |  |  |     Joan Stark
|  |  |  |  |  |  |  |  (/ |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
*/


/*
............HIIMHIMHMMHMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM:.............
...........MMMI:MII:MIHMHMMMMMHMMMMIMMMIMMMMMMMMMMMMMM.............
.........:MMMI:M::HM::MIHHHM:IM:MHM:IMH:IMMMIIMMMHMMMH:............
........:MMMHHM::MMI:HH:MM:I:M:MMMH:IMH:IMM::MH:MM:MM:M............
.......MMMMHMM:MMIMHMII:MM:IIIM:MHMIMMM:MMIIH::MH:HM:M............
...... :MIMMMMMMMMMHMMHMM:HHMHMMMMIMHMMMMHMHMIHIHM::MMI............
.......M:MMMMMMMMMMMMHMMMMMMMMHMMMMMMMMMMHMMMHMMIMHMMMM:...........
.......HHMMMMMMMMMMMMMMMMIMMMM.MMHMMMMHMMMMMMMMMMMIMHMMI...........
........MMMIMMMMMMMMMMIHMIMIM:.M:HMM:MIHMMMMMMMMMMMMMMMI...........
........MM.MMMMMMMMMMMH:MMMHM:.M.:MM.M.HMMMHMMMMMMMMMMMI...........
........MM.MMMMMMMMMMH::M.M.M..M..MM:M.IIMH:MMMMMMMMMMMI...........
........M:.MM:MMMMMMM:.I..:.I..H..IM:I.I.M.IMHMMMMMMMMMI...........
........M..MMMHMMMMM.:HI:HHH......H....II..:MMMMMMMHMM:...........
...........MM.MIMMMM.:H: .::I........ ...:IH:.MMMMMM:MMI...........
...........:H..MMMIM.M.:...:I.........: ..::HHHMMMMIMMMH...........
............H..IMM:I:..I:..:..........I:..:I:::MMMMMMMMM...........
...............MMH::I...I:::..........III.I::MMMHMMMMMMM...........
..............MMMHMII.. ..............:MI:I.HIIIHM:HMMMM...........
.............:MMMMIM::...........:......:H..:II:MHIMMMMM...........
.............MMMMMMMMM......................I.MMMHHMMMMM:..........
............MMMMH:MMMMM........:.:.........:MMMMMMMMMMMMI..........
...........MMMMMMHMMMMMMM.. .............:MMMMMMMMMMMMMMM..........
........ .IMMMMMMMMMMMMMMMM............:MMMMMMMMMHMMMMMMM..........
..........MMMMMMMMMMMMMMMMMI:.......:IHMMMMMMMMM::MMMMMMM..........
.........MMMMMMMIMMMMMMMMMMH:::I:I:.::HMMMMMMMMMHMMMMMMMMI.........
........HMMMMMMM:MMMMMMMMMMI:::::::..:HMMMMMMMMIMMMMMMMMMM.........
.......IMMMMM..MI:MMMMMMMMM::::..:::::.MMMMMMMMMMMMMMMMMMM ........
......:MMMM....:MMHMMMMMM:::::.....::.:.MMMMMMMHMMMMMMMMMM.........
......MMI....:::IMMMMI:.:::::.....:I::::::HMMMHIM::::::MMMH........
.....MM.....:::IMIMMM:.......:....::::::::IMMHMM:I:::I:::MM .......
....MMM.....:I:.MIHMMM........:...:::::::HMMMMI:::::....::M:.......
...:MM:........:MMMHMM..................IMMMMM::...........M.......
...MMM........:::MMMMM......:..........:HMMMMM::...................
..:MM:.......:::::MMMM........... .. .::MMM:HM::.............:.....
..MMM........:::::MMMMM:I..HHIMHMHHHM :IMMHIMH::.............I.....
*/



/*

?$$  "$N        $$$  ^#$            $              d$*  "$d       '$$F  "$r   
'$$   $$k       9$$    '           d$N            $$F     *        $$>    *   
'$$   $$F       9$$  :             $$$r          $$$               $$>  f     
'$$   $$        9$$.e$            . #$$          $$$               $$L.$F     
'$$**#"         9$$ ^$            f  $$L         $$$               $$> #F     
'$$             9$$  '           .   '$$         $$$               $$>  F     
'$$             9$$     "        P""""$$N        '$$r     J        $$>    x   
{$$             9$$   .$              '$$         ^$$.   d$        $$r   dF   
""""           `""""""""       '""    """"           """"         """"""""    

.....               d*##$.                               
zP"""""$e.           $"    $o                              
4$       '$          $"      $                              
'$        '$        J$       $F                             
'b        $k       $>       $                              
$k        $r     J$       d$                              
'$         $     $"       $~                              
'$        "$   '$E       $                               
$         $L   $"      $F ...                           
$.       4B   $      $$$*"""*b                         
'$        $.  $$     $$      $F                        
"$       R$  $F     $"      $                         
$k      ?$ u*     dF      .$                         
^$.      $$"     z$      u$$$$e                      
#$b             $E.dW@e$"    ?$                     
#$           .o$$# d$$$$c    ?F                    
$      .d$$#" . zo$>   #$r .uF                    
$L .u$*"      $&$$$k   .$$d$$F                    
$$"            ""^"$$$P"$P9$                     
JP              .o$$$$u:$P $$                     
$          ..ue$"      ""  $"                     
d$          $F              $                      
$$     ....udE             4B                      
#$    """"` $r            @$                      
^$L        '$            $F                      
RN        4N           $                       
*$b                  d$                       
$$k                 $F                       
$$b                $F                       
$""               $F                       
'$                $                        
$L               $                        
'$               $                        
$               $                        
"   
*/


/*


Einstein
.+~                :xx++::
:`. -          .!!X!~"?!`~!~!. :-:.
{             .!!!H":.~ ::+!~~!!!~ `%X.
'             ~~!M!!>!!X?!!!!!!!!!!...!~.
{!:!MM!~:XM!!!!!!.:!..~ !.  `{
{: `   :~ .:{~!!M!XXHM!!!X!XXHtMMHHHX!  ~ ~
~~~~{' ~!!!:!!!!!XM!!M!!!XHMMMRMSXXX!!!!!!:  {`
`{  {::!!!!!X!X?M!!M!!XMMMMXXMMMM??!!!!!?!:~{
: '~~~{!!!XMMH!!XMXMXHHXXXXM!!!!MMMMSXXXX!!!!!!!~
:    ::`~!!!MMMMXXXtMMMMMMMMMMMHX!!!!!!HMMMMMX!!!!!: ~
'~:~!!!!!MMMMMMMMMMMMMMMMMMMMMMXXX!!!M??MMMM!!X!!i:
{~{!!!!!XMMMMMMMMMMMM8M8MMMMM8MMMMMXX!!!!!!!!X!?t?!:
~:~~!!!!?MMMMMM@M@RMRRR$@@MMRMRMMMMMMXSX!!!XMMMX{?X!
:XX {!!XHMMMM88MM88BR$M$$$$8@8RN88MMMMMMMMHXX?MMMMMX!!!
.:X! {XMSM8M@@$$$$$$$$$$$$$$$$$$$B8R$8MMMMMMMMMMMMMMMMX!X
:!?! !?XMMMMM8$$$$8$$$$$$$$$$$$$$BBR$$MMM@MMMMMMMMMMMMMM!!X
~{!!~ {!!XMMMB$$$$$$$$$$$$$$$$$$$$$$$$MMR$8MR$MMMMMMMMMMMMM!?!:
:~~~ !:X!XMM8$$$$$$$$$$$$$$$$$$$$$$$RR$$MMMMR8NMMMMMMMMMMMMM{!`-
~:{!:~`~':!:HMM8N$$$$$$$$$$$$$$$$$$$$$$$$$8MRMM8R$MRMMMMMMMMRMMMX!
!X!``~~   :~XM?SMM$B$$$$$$$$$$$$$$$$$$$$$$BR$$MMM$@R$M$MMMMMM$MMMMX?L
X~.      : `!!!MM#$RR$$$$$$$$$$$$$$$$$R$$$$$R$M$MMRRRM8MMMMMMM$$MMMM!?:
! ~ {~  !! !!~`` :!!MR$$$$$$$$$$RMM!?!??RR?#R8$M$MMMRM$RMMMM8MM$MMM!M!:>
: ' >!~ '!!  !   .!XMM8$$$$$@$$$R888HMM!!XXHWX$8$RM$MR5$8MMMMR$$@MMM!!!{ ~
!  ' !  ~!! :!:XXHXMMMR$$$$$$$$$$$$$$$$8$$$$8$$$MMR$M$$$MMMMMM$$$MMM!!!!
~{!!!  !!! !!HMMMMMMMM$$$$$$$$$$$$$$$$$$$$$$$$$$MMM$M$$MM8MMMR$$MMXX!!!!/:`
~!!!  !!! !XMMMMMMMMMMR$$$$$$$$$$$$R$RRR$$$$$$$MMMM$RM$MM8MM$$$M8MMMX!!!!:
!~ ~  !!~ XMMM%!!!XMMX?M$$$$$$$$B$MMSXXXH?MR$$8MMMM$$@$8$M$B$$$$B$MMMX!!!!
~!    !! 'XMM?~~!!!MMMX!M$$$$$$MRMMM?!%MMMH!R$MMMMMM$$$MM$8$$$$$$MR@M!!!!!
{>    !!  !Mf x@#"~!t?M~!$$$$$RMMM?Xb@!~`??MS$M@MMM@RMRMMM$$$$$$RMMMMM!!!!
!    '!~ {!!:!?M   !@!M{XM$$R5M$8MMM$! -XXXMMRMBMMM$RMMM@$R$BR$MMMMX??!X!!
!    '!  !!X!!!?::xH!HM:MM$RM8M$RHMMMX...XMMMMM$RMMRRMMMMMMM8MMMMMMMMX!!X!
!     ~  !!?:::!!!MXMR~!MMMRMM8MMMMMS!!M?XXMMMMM$$M$M$RMMMM8$RMMMMMMMM%X!!
~     ~  !~~X!!XHMMM?~ XM$MMMMRMMMMMM@MMMMMMMMMM$8@MMMMMMMMRMMMMM?!MMM%HX!
!!!!XSMMXXMM .MMMMMMMM$$$BB8MMM@MMMMMMMR$RMMMMMMMMMMMMMMMXX!?H!XX
XHXMMMMMMMM!.XMMMMMMMMMR$$$8M$$$$$M@88MMMMMMMMMMMMMMM!XMMMXX!!!XM
~   {!MMMMMMMMRM:XMMMMMMMMMM8R$$$$$$$$$$$$$$$NMMMMMMMM?!MM!M8MXX!!/t!M
'   ~HMMMMMMMMM~!MM8@8MMM!MM$$8$$$$$$$$$$$$$$8MMMMMMM!!XMMMM$8MR!MX!MM
'MMMMMMMMMM'MM$$$$$MMXMXM$$$$$$$$$$$$$$$$RMMMMMMM!!MMM$$$$MMMMM{!M
'MMMMMMMMM!'MM$$$$$RMMMMMM$$$$$$$$$$$$$$$MMM!MMMX!!MM$$$$$M$$M$M!M
!MMMMMM$M! !MR$$$RMM8$8MXM8$$$$$$$$$$$$NMMM!MMM!!!?MRR$$RXM$$MR!M
!M?XMM$$M.{ !MMMMMMSUSRMXM$8R$$$$$$$$$$#$MM!MMM!X!t8$M$MMMHMRMMX$
,-,   '!!!MM$RMSMX:.?!XMHRR$RM88$$$8M$$$$$R$$$$8MM!MMXMH!M$$RMMMMRNMMX!$
-'`    '!!!MMMMMMMMMM8$RMM8MBMRRMR8RMMM$$$$8$8$$$MMXMMMMM!MR$MM!M?MMMMMM$
'XX!MMMMMMM@RMM$MM@$$BM$$$M8MMMMR$$$$@$$$$MM!MMMMXX$MRM!XH!!??XMMM
`!!!M?MHMMM$RMMMR@$$$$MR@MMMM8MMMM$$$$$$$WMM!MMMM!M$RMM!!.MM!%M?~!
!!!!!!MMMMBMM$$RRMMMR8MMMMMRMMMMM8$$$$$$$MM?MMMM!f#RM~    `~!!!~!
~!!HX!!~!?MM?MMM??MM?MMMMMMMMMRMMMM$$$$$MMM!MMMM!!
'!!!MX!:`~~`~~!~~!!!!XM!!!?!?MMMM8$$$$$MMMMXMMM!!
!!~M@MX.. {!!X!!!!XHMHX!!``!XMMMB$MM$$B$M!MMM!!
!!!?MRMM!:!XHMHMMMMMMMM!  X!SMMX$$MM$$$RMXMMM~
!M!MMMM>!XMMMMMMMMXMM!!:!MM$MMMBRM$$$$8MMMM~
`?H!M$R>'MMMM?MMM!MM6!X!XM$$$MM$MM$$$$MX$f
`MXM$8X MMMMMMM!!MM!!!!XM$$$MM$MM$$$RX@"
~M?$MM !MMMMXM!!MM!!!XMMM$$$8$XM$$RM!`
!XMMM !MMMMXX!XM!!!HMMMM$$$$RH$$M!~
'M?MM `?MMXMM!XM!XMMMMM$$$$$RM$$#
`>MMk ~MMHM!XM!XMMM$$$$$$BRM$M"
~`?M. !M?MXM!X$$@M$$$$$$RMM#
`!M  !!MM!X8$$$RM$$$$MM#`
!% `~~~X8$$$$8M$$RR#`
!!x:xH$$$$$$$R$R*`
~!?MMMMRRRM@M#`       
`~???MMM?M"`
*/

/*

:';t)/!||||(//L+)'(-\\/ddjWWW#######WmKK(\!(/-|J=/\\t/!-/\!_L\) 
|-!/(!-)\L\)/!\5(!.!LWW###################WK/|!\\\\/!;\/\T\/((\ 
|!'//\//(-!t\Y/\L!m#####M####################WLt\\!)\/J-//)/;t\ 
--/-.\.\/\.!)///m######K#######################WK!/!-( )-!,|/\ 
//,\--`--!-/\(q#######DD##########################L\\\\-!!//!\\ 
-.-!\'!!\-\/:W########N############################W,).'-.-/\-' 
!.\!-!-!`!-!W#######P|+~**@@@#######################W/,/'\-/,\7 
--`,-- -/.:W###*P!'          \`Z8#####################;,\\`,\,\
`.'.'\`-.-d##5'-           -- '-:V@##########W#########_\-!-\\-
`, -,.'/,G##K- '               - )7KM###################\-----/
- '-  --:##@;                    -!ZZ###################W! \'!- 
'-.`- G###|.                    `,D8K###################|/-.-/ 
-' ,-//###@)                      -)ZWMW##################\` _\
- ' .:Yd###!                     `-!(K5K##################|(/L| 
- :\G###Z-                    ` ! -;55ZZ#################)(4) 
. -!W####!\                     `  ' !-tVG################XNVZ 
tt####@-.                        `  ')(W################D)8@ 
)8#####\                         .-`-/KW#################KD# 
||Z####W!-              .::,\.. -,;\bZKK######8#K#########(#8 
KN8#####( ,:!/GG_      d4KW8ZKW#WWK#W#88#######W##########WK# 
)/8K###K#W#WP~~~T4(    dW##7'___L#M####MM8W###W############bM8 
\!48#K####8##W*###WY;   WRob+~~######*ff/\NM8###############WW# 
.\\KW###W#,~t' !*~!',  -M@)    `~`,),' '.`K#################@KW 
.'8M###### -'..j/Z''    @//-  ,,\\+\'    :|W######M###########8 
:\#8#K###D              \!`             !:Z8###8@#####8W#W###8M 
q8W5######             `!-             `-)8##################M8 
8WZ8#M####-             /  .          .\tK############@######ZJ 
#W#@K###W#|              //           \\tW@###@K##W##W###K###Wm 
##8#M#8###P-            -=/,         /;D8W##############@###W## 
#8###M@####\-      ,   _)jJ;        -((WKK#####W####W##K######K 
###W@K##K##);     `\..KW##WK       )X)KW#M##W###MW##@#W######8# 
#K#W####@#@@/;-     ~M####M\    ,.\\=)D8W##W###W##########8W##@ 
####MW######(`\\'     PPK((.:|/!-\-/)8XN@WMK#######W##MK#@##### 
##8##MK#W#@#b!--\)L_. .(ZLWbW#\'- ,-N|/KM#######W###@########W# 
##KW###K#W###/-  !``~~Yff*N5f -' -.\))KK#######MK##W###M8W#W### 
#W###K@K######J--    .._dd/;)/- !//)NK#8W##########8########M#K 
##8W#K###W#####W!.   `YY\)\\)\7(-)4dW#8#@###K#W#######8######## 
M####8##K#KW###W#/,       '-\\//)88W#M#@#K##M###@##M#8##@#W#8#M 
ZW#W#M#K##########m       -)!/LtWW#W##@#W#####KW#######W###K### 
K##W#####W#M#8#####KL   .-//dD##8W#K######8##########MK###W##M# 
tN#W##W#W#M##########bb4dKW#@##W##K####MK####8###########W##### 
)NM#8W##@###@##############@##@##8##K#W####M##K##K#@###8##M#### 
(tMM###W##M8####@####@###@#########@####8W##8W################M 
tNZ##K###W####@#####8###/4N##8#W##W##M#8#MK#M8#K######W######## 
M/K@8###M@###M##########|!t*Z#N####8##M8Z@ZZ#M###@#W#####K###W# 
WVd4M######@############D,\`(+KKZD#8WK#5@84VZ#WM############W## 
K5WM8#8W#W########8######,,-!/))ZK5@K4)@+(/XV/Z###@###W###M#### 
+8WN@##@K##W###W#########b.-.\!||\X(5)Z/7\\\t5/K########W###### 
8M8###@###@##8#########KDbt! !.-!t`(-\\!.\/.\!ZdG###W#MW###G### 
~~~~~`~~~~~~~~~~~~~~~~'~` ''  ' ` ` ' '   `   ``~`~`~`~~~~'~~~~  

*/

/*

#
##
###
####
#####
#######
#######
########
########
#########
##########
############
##############
################
################
##############
##############                                              ####
##############                                           #####
##############                                      #######
##############                                 ###########
###############                              #############
################                           ##############
#################      #                  ################
##################     ##    #           #################
####################   ###   ##          #################
################  ########          #################
################  #######         ###################
#######################       #####################
#####################       ###################
############################################
###########################################
##########################################
########################################
########################################
######################################
######################################
##########################      #####
###  ###################           ##
##    ###############
#     ##  ##########
##    ###
###
##
#
*/


/*

LL             A
LL            A A
LL           AA AA
LL          AA   AA
LL          AAAAAAA
LL         AA     AA
LL         AA     AA
LLLLLLLLL  AA     AA
LLLLLLLLL  AA     AA
TTTTTTTTTT   OOOOOOO   UU     UU  RRRRRRR              EEEEEEEEE  IIIIIIIIII  FFFFFFFFF  FFFFFFFFF  EEEEEEEEE  LL
TTTTTTTT  OOOOOOOOO  UU     UU  RRRRRRRR             EEEEEEEEE  IIIIIIIIII  FFFFFFFFF  FFFFFFFFF  EEEEEEEEE  LL
TT      OO     OO  UU     UU  RR     RR            EE             II      FF         FF         EE         LL
TT      OO     OO  UU     UU  RR     RR            EE             II      FF         FF         EE         LL
TT      OO     OO  UU     UU  RRRRRRRR             EEEEEEEE       II      FFFFFFFF   FFFFFFFF   EEEEEEEE   LL
TT      OO     OO  UU     UU  RR  RR               EE             II      FF         FF         EE         LL
TT      OO     OO  UU     UU  RR   RR              EE             II      FF         FF         EE         LL
TT      OOOOOOOOO  UUUUUUUUU  RR    RR             EEEEEEEEE  IIIIIIIIII  FF         FF         EEEEEEEEE  LLLLLLLLL
TT       OOOOOOO    UUUUUUU   RR     RR            EEEEEEEEE  IIIIIIIIII  FF         FF         EEEEEEEEE  LLLLLLLLL
.
1
1
1
M
M
M
M
\M/
. ' M ` .
\##-#####-##/
\# ##### #/
###############
###############
\ ! ! ! ! ! /
)! ! ! ! !(
+---------+
+! ! ! ! !+
+----*----+
+`. .':`. .'+
+ .^. : .^. +
+:...:*:...:+
+`. .':`. .'+
+ .^. : .^. +
+:...:*:...:+
+`. .':`. .'+
+. ^. : .^ .+
+:....:*:....:+
+` .  ':`  . '+
+  .^. : .^.  +
+:....:*:....:+
+` .. ':` .. '+
+. '` .:. '` .+
+:....:*:....:+
+ `. .':`. .' +
+   X  :  X   +
+.'  `.:.'  `.+
+:......*......:+
+`.   .':`.   .'+
+   X   :   X   +
+ .' `. : .' `. +
+.......*.......+
+` . . ':` . . '+
+   X   :   X   +
+ '   ` : '   ` +
+../########....+
+`/#########\ .'+
+  ############   +
+ '############`  +
+:.......*.......:+
+ ` .  ' : `  . ' +
+    X   :   X    +
+ .'   `.:.'   `. +
+:.......*.......:+
+`      ':`      '+
+  `   '  :  `   '  +
+    X   : :   X    +
+  '   ` : : '   `  +
+:.......*.*.......:+
+`      ': :`      '+
+ `   '  : :  `   ' +
+   X   : X :   X   +
+  '   ` :' `: '   `  +
+:.......*...*.......:+
+`      ':` ':`      '+
+ `   '  : X :  `   ' +
+   X   :     :   X   +
+ '   ` :/   \: '   ` +
+:.......*.....*.......:+
+`      ':`   ':`      '+
+ `   '  : `.' :  `   ' +
+    X   :  ' `  :   X    +
+  '   ` :'     `: '   `  +
+:.......*.......*.......:+
+ `      ':`     ':`      ' +
+  ` . '  :  `.'  :  ` . '  +
+    ' `  :   ' `   :  ' `    +
+. '    ` : '     ` : '    ` .+
+..........*.........*..........+
+  ###########################  +
+  ###########################  +
+   ###########################   +
#########################################
###########################################
\   1   1   1   1   1   1   1   1   1   /
)  1   1   1   1   1   1   1   1   1  (
+-----:-----+-------------+-----:-----+
+     :     +             +     :     +
*------*-----*-------------*-----*------*
+XXXXXXXXXXX+XXXXXXXXXXXXXXX+XXXXXXXXXXX+
*-----*-----*---------------*-----*-----*
+ `.   :  . '+               +` .  :   .' +
+    . : '   +               +   ` : .    +
+    . *.    +                 +    .* .    +
+ . '  : `.  +                 +  .' :  ` . +
*:......*....:*                 *:....*......:*
+ `.   :   . '+                 +` .   :   .' +
+     `.:. '  +                   +  ` .:.'     +
+   . '* `.   +                   +   .' *` .   +
+ . '   :    `.+                   +.'    :   ` . +
*:.....*.......*                   *.......*.....:*
+  ` .. :  .. ' +                   + ` ..  : .. '  +
+     . *'     +                     +     `* .     +
+  .. ' :   ` . +                     + . '   : ` ..  +
*.:....*.......:*                     *:.......*....:.*
+   ` ..: . - '  +                     +  ` - . :.. '   +
+    .. * ..    +                       +    .. * ..    +
-------------------------------------------------------------------
1 +:       :      +:       :       :       :+      :       :+ 1
1+ :       :      +:       :       :       :+      :       : +1
###################################################################
1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1
1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1
+---------------------------------------------------------------+
+! . ! . ! . ! . !+. ! . ! . ! . ! . ! . ! . ! .+! . ! . ! . ! . !+
+:!: :!: :!: :!: :!+ :!: :!: :!: :!: :!: :!: :!: +!: :!: :!: :!: :!:+
+.!.:.!.:.!.:.!.:.!+:.!.:.!.:.!.:.!.:.!.:.!.:.!.:+!.:.!.:.!.:.!.:.!.+
+XXXXXXXXXXXXXXXXXX+\     \  ..-#######-..  /     /+XXXXXXXXXXXXXXXXXX+
*-------------------* \    .-' \  1 1 1  / `-.    / *-------------------*
+  ` .    : ..  '  +   \.-' \   .-------.   / `-./   +  `  .. :    . '  +
+.......:.*:........+ .-' \  .-''         ``-.  / `-. +........:*.:.......+
+    .  '  : ` .    +\:  \  -'                 `-  /  :/+    . ' :  `  .    +
+..:.......:.....:..+/ \ .-'                     `-. / \+..:.....:.......:..+
+    ` .   :    .  ' + \.'                           `./ + `  .    :   . '    +
+.........:.*..:.....+  /                               \  +.....:..*.:.........+
+     .  '  :   ` .   + /                                 \ +   . '   :  `  .     +
+...:......:........:+ /                                   \ +:........:..........+
+    `  .  :  .  '    +/                                     \+    `  .  :  .  '    +
+...........*.........+                                         +.........*...........+
+     .  '  :   `  .   +                                         +   .  '   :  `  .     +
+...:.......:.........:+                                           +:.........:.......:...+
+    `  .    :   .   '  +                                           +  `   .   :    .  '    +
+..........:.*.:........+                                             +........:.*.:..........+
+     .   '  :   `  .    +                                             +    .  '   :  `   .     +
+...:.........:.........:+                                               +:.........:.........:...+
+   `   .     :     .   ' +                                               + `   .     :     .   '   +
+...........:.*..:........+                                                 +........:..*.:...........+
+      .   '  :   `  .     +                                                 +     .  '   :  `   .      +
+...:.........:..........:.+                                                   +.:..........:.........:...+
+     `  .     :      .  ' +                                                     + `  .      :     .  '     +
+            ` *  - '      +                                                       +      ` -  * '            +
-----------------------------------------------------------------------------------------------------------------
*/

/*


=   ==   => /                                                             
+# = #= +  $=>>  =                                                         
=+%>=$%=/#%+%>%+/ +>/+>+=                                                      
>=+$%#+#>%$#%##$=+$$/+$+=  >=                                                   
>>/%#%###########+#######>==+#>  /                                                
=%+//>$%#%#########################%%#/==              ==               /#$>           
+$+##+#########%##################$$%+/=              /%%%%%%###%###%%%%%%%           
==/+$#########=  =$#######>>#######$##>=                 #%>==##+ %##>>/%/             
//=/%#$#########                +######$%%++$+              ###++##/ +##++###>            
=>/+$############=                #########%%>=              ##$>>+$/ /$/>>##$             
/$##############%=             %######$#$+>=/+             ##$//### %##++##%             
=>>+%$###############%/>     =/$############$+%/=         ++++++++###+###++++###/          
=>/%%$$#########################################/          =/>>%>###+/#$>>>>>%%>>=          
==>+%#######################################$%/>=            $# %##  $##  >>=##>           
=>+##$$######################################++>=           $### +##  >#+ >## %##>          
/+++$#####################################$%$%/+>          $$+  =###########= %+           
>>>++####################################+>/+%=                                           
>>%#####################################$%/=                                            
>$##################################/+>/==>                                            
/#%/>################################+>//                       =>///>                  
=   %+$%##$######################$$//+%%>>                   +##$$#%%###$=              
= >$#/$$#####################$+=                       $#$=  >#    >##$             
>>/+=##############%/+#+$##%+>                     =##=    ##      ##+            
+%%###%%##%%%#% > +//= //%                     ##>    +#%      ###            
>  +>=+>+=%>=##$=> = =                          ##=   %##       ###            
=   =   #>//                               ###>/##%       $##=            
>//=                =$                                    #####>      /###=             
/%+             =%     >/+++/>                          =>     >+###$>               
=$%          >%  +###$+>====>=                              ++/>                   
/#>       >%/##$>                                                                
=#+     >###/                                                                   
=#%   >#%=                                           ++>   /%/                 
=#+  #                                        >=====###>==$##>==+$/           
%#>+/                                        %%%%%%###%%%###%%%%%%=          
###                                          >%%%%###%%%###%###=            
/#%                                           ==>##==##$=/##===>            
#/                                        /$$$$$##$$###$###$$###/          
/+    //=                                      =##  ##% >##                
>%  %+                                      $$$$##$$###$###$###            
# #+                                      >>>>=====##$=====>$$>           
$+#                                       /%%%%%%%%###%%%%%%%%+           
#%                                                ##+                    
>$                                                ##>                    
#                                                                       
/+                                                                      
#                                                                      
$                                                                      
%                                                                      
=   

*/

/*

iEid
iDDDDDDDd
iDDDDDDDDDD
EDDi         iDLINUSTDISSB
DDDDDDi    iDDDDDDDE DDDDD
DDiDDDDDDiDDDDDDDE   DDDDD
DD  EDDDDDDDDDDD     DDDDD
DD   iDDDDDDDDE      DDDDD
DD iDDDDDiDDDDDDi    DDDDD
DDDDDDE   iDDDDDDDiE DDDDD
dDDDE        iFUCKAPPLEDDD
iDDDDDDDDDD
iDDDDDDD
iDid

嫁人要嫁程序员,呆萌单纯可爱多!

*/


/*
请仔细看最后一行的某些英文字母。


LEEIIO01       CHAOS0      MADE!    00000000             00001    10000    0000
000 1001     000  000      000     0  001 0              000      00001  0000
000  000     000  000      000        00                 001      10000  0000
000  000     000  100      000        00                 000      10 0000 100
000  000     000  000      000        001                000      10 1001 100
000  00      100  001      000        001       001      000      00  00  000
F000100        U00001      C0001      K0001      000     G0001    F001     W00!



*/

/*


　◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆　
　　◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆　
　　　　◆◆◆　　◆◆　　　　  ◆◆◆　
　　　　　　◆◆◆　　◆◆◆　◆◆◆　　◆◆◆　
　　　　　　　　◆◆◆　◆◆◆　　◆◆◆◆　 ◆◆◆　
　　　　　　　　　　◆◆◆◆◆◆　　　　◆◆◆◆◆◆◆　
　　　　　　　　　　　　◆◆◆◆◆　　　　　　◆◆◆◆◆◆　
　　　　　　　　　　　　　　◆◆◆◆　　　　　　　◆◆◆◆◆　
　　　　　　　　　　　　　　　　◆◆◆　　　　　　　　 ◆◆◆　
　　　　　　　　　　　　　　　　　　◆◆◆　◆◆◆◆◆◆◆◆◆　  ◆◆◆　
　　　　　　　　　　　　　　　　　　　　◆◆◆　◆◆◆　　　◆◆◆　◆◆◆　
　　　　　　　　　　　　　　　　　　　　　　◆◆◆　◆◆◆　　　◆◆◆　◆◆◆　
　　　　　　　　　　　　　　　　　　　　　　　　◆◆◆　◆◆◆　　　◆◆◆　◆◆◆　
　　　　　　　　　　　　　　　　　　　　　　　　　　◆◆◆　◆◆◆　　　◆◆◆　◆◆◆　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　◆◆◆　◆◆◆　　　◆◆◆　◆◆◆　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　◆◆◆　◆◆◆　　　◆◆◆　◆◆◆　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　◆◆◆◆　　　　　　　　　◆◆◆　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*/
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//    ...．．∵ ∴★．∴∵∴ ╭ ╯╭ ╯╭ ╯╭ ╯∴∵∴∵∴ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//    ．☆．∵∴∵．∴∵∴▍▍ ▍▍ ▍▍ ▍▍☆ ★∵∴ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//    ▍．∴∵∴∵．∴▅███████████☆ ★∵ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//    ◥█▅▅▅▅███▅█▅█▅█▅█▅█▅███◤ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//    ． ◥███████████████████◤ 我们的征途是星辰大海
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//    .．.．◥████████████████■◤
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//                                 _(\_/) 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//                               ,((((^`\
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//                               ((((  (6 \ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//                            ,((((( ,    \
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//         ,,,_              ,(((((  /"._  ,`,
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//        ((((\\ ,...       ,((((   /    `-.-'
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//        )))  ;'    `"'"'""((((   (我是代马      
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//      (((  /            (((      \
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//        )) |                      |
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//       ((  |        .       '     |
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//       ))  \     _ '      `t   ,.')
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//       (   |   y;- -,-""'"-.\   \/  
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//      )   / ./  ) /         `\  \
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//          |./   ( (           / /'
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//          ||     \\          //'|
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//          ||      \\       _//'||
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//          ||       ))     |_/  ||
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//          \_\     |_/          ||
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//          `'"                  \_\
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//   ╭┘└┘└╮
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  └┐．．┌┘────╮
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  ╭┴──┤          ├╮
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  │ｏ　ｏ│          │ ●
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  ╰─┬─╯          │
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//      代码就是牛 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　/////////////////////////////////////////////////////////////////////////////
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　// ┌────────────────┐
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　// │▉▉▉▉▉▉▉▉▉▉▉　 99.9%│
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　// └────────────────┘
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//   开发进度
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　/////////////////////////////////////////////////////////////////////////////
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//              ◢◤◢◤
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　　　　　◢████◤
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　　　⊙███████◤
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　●████████◤         齐心协力
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　　▼　　～◥███◤
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　　▲▃▃◢███　●　　●　　●　　●　　●　　●　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　　　　　　███／█　／█　／█　／█　／█　／█　　　◢◤
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　　　　　　███████████████████████◤
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  ＃〓○〓〓〓〓〓○〓〓〓〓〓〓○〓〓〓〓〓○〓＃ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　　↓　　　　　↓　　　　　　↓　　　　　↓ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　☆★☆　　　☆★☆　　　　☆★☆　　　☆★☆ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  ☆　神　☆　☆　来　☆　　☆　之　☆　☆　笔　☆ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　☆★☆　　　☆★☆　　　　☆★☆　　　☆★☆ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　　↓　　　　　↓　　　　　　↓　　　　　↓ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　//  　　※　　　　　※　　　　　　※　　　　　※ 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　/**
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　* http://www.freebuf.com/
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*           _.._        ,------------.
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*        ,'      `.    ( We want you! )
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*       /  __) __` \    `-,----------'
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*      (  (`-`(-')  ) _.-'
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*      /)  \  = /  (
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*     /'    |--' .  \
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*    (  ,---|  `-.)__`
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*     )(  `-.,--'   _`-.
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*    '/,'          (  Uu",
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*     (_       ,    `/,-' )
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*     `.__,  : `-'/  /`--'
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*       |     `--'  |
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*       `   `-._   /
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*        \        (
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*        /\ .      \.  freebuf
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*       / |` \     ,-\
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*      /  \| .)   /   \
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*     ( ,'|\    ,'     :
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*     | \,`.`--"/      }
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*     `,'    \  |,'    /
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*    / "-._   `-/      |
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*    "-.   "-.,'|     ;
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*   /        _/["---'""]
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*  :        /  |"-     '
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*  '           |      /
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*              `      |
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*/
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　/** 
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　* https://campus.alibaba.com/
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*                                 `:::::::::::,
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*                             `::;:::::::;:::::::,  `
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*                          `::;;:::::::@@@@;:::::::`
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*                        ,:::::::::::::@    #@':::::`
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*                      :::::::::::::::'@@      @;::::
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*                    ::::::::::::'@@@@'```      .+:::`
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*                  ::::::::::;@@@#.              ,:::,
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*                .::::::::+@#@`                   ::::
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*               :::::::+@@'                       ::::
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*             `:::::'@@:                         `:::.
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*            ,::::@@:  `                         ::::
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*           ;::::::@                            .:::;
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*          :;:::::;@`        `                  :::;
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*         :::::::::@`        @                 ;::::
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*        :::::::::#`          @`              ,::::
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*       :::::::::@`         +@ @             .::::`
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*      .::::::'@@`       `@@'  @             ::::,
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*      :::::::++@@@@@@@@@@.                 ::::;
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*     ;:::::::+,   `..`                    :::::
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*    ,::::::::',                          :::::
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*    :::::::::+,                         :::::`
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*   :::::::::+@.                        ,::::.`                     `,
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*   ::::::;;@+                         .::;::                     `;
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*  :::::::@@                          `:::;:                   `::``
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*  ::::::#@                           ;::::                  .::`
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*  :::::;@                           :::::`               .;::`
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*  :::::@                           `:;:::            `::::;
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*  :::::#                           :::::.        `,;:::::
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*  ::::::                    `      ::::::,.,::::::::::.
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*  ,::::::`              .::        ::::::::::::::::;`
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*   ;::::::::,````.,:::::,          ::::::::::::::.
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*    :::::::::::::::::: `           `::::::::::`
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*     `::::::::::::,                  .:::.
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*         `..`
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　*/
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　```
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
