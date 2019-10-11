##  iOS逆向工程开发 越狱Jailbreak Cydia deb插件开发
![touch4](https://github.com/XLsn0w/Cydia/blob/master/iOS%206.1.6%20jailbreak.JPG?raw=true)

![SE](https://github.com/XLsn0w/Cydia/blob/master/iOS%209.3.2%20jailbreak.JPG?raw=true)
# 我的微信公众号: Cydiapple
![cydiapple](https://github.com/XLsn0w/XLsn0w/raw/XLsn0w/XLsn0w/Cydiapple.png?raw=true)
## Cycript / Class-dump / Theos / Reveal / Dumpdecrypted  逆向工具使用介绍

越狱开发常见的工具OpenSSH，Dumpdecrypted，class-dump、Theos、Reveal、IDA，Hopper，

# 添加我的Github个人Cydia插件源: 
```
https://xlsn0w.github.io/CydiaRepo
https://xlsn0w.github.io/ipas

```

![CydiaRepo](https://github.com/XLsn0w/Cydia/blob/master/xlsn0w.github.io:CydiaRepo.png?raw=true)

# fishhook
# 相关分析文章
[fishhook源码分析](http://turingh.github.io/2016/03/22/fishhook%E6%BA%90%E7%A0%81%E5%88%86%E6%9E%90/)

# 更多细节，可以阅读这两篇文章
[mach-o格式介绍](http://turingh.github.io/2016/03/07/mach-o%E6%96%87%E4%BB%B6%E6%A0%BC%E5%BC%8F%E5%88%86%E6%9E%90/)
[mach-o延时绑定](http://turingh.github.io/2016/03/10/Mach-O%E7%9A%84%E5%8A%A8%E6%80%81%E9%93%BE%E6%8E%A5/)

以下是官方内容
===
__fishhook__ is a very simple library that enables dynamically rebinding symbols in Mach-O binaries running on iOS in the simulator and on device. This provides functionality that is similar to using [`DYLD_INTERPOSE`][interpose] on OS X. At Facebook, we've found it useful as a way to hook calls in libSystem for debugging/tracing purposes (for example, auditing for double-close issues with file descriptors).

[interpose]: http://opensource.apple.com/source/dyld/dyld-210.2.3/include/mach-o/dyld-interposing.h    "<mach-o/dyld-interposing.h>"

## Usage

Once you add `fishhook.h`/`fishhook.c` to your project, you can rebind symbols as follows:
```Objective-C
#import <dlfcn.h>

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "fishhook.h"

static int (*orig_close)(int);
static int (*orig_open)(const char *, int, ...);

int my_close(int fd) {
  printf("Calling real close(%d)\n", fd);
  return orig_close(fd);
}

int my_open(const char *path, int oflag, ...) {
  va_list ap = {0};
  mode_t mode = 0;

  if ((oflag & O_CREAT) != 0) {
    // mode only applies to O_CREAT
    va_start(ap, oflag);
    mode = va_arg(ap, int);
    va_end(ap);
    printf("Calling real open('%s', %d, %d)\n", path, oflag, mode);
    return orig_open(path, oflag, mode);
  } else {
    printf("Calling real open('%s', %d)\n", path, oflag);
    return orig_open(path, oflag, mode);
  }
}

int main(int argc, char * argv[])
{
  @autoreleasepool {
    rebind_symbols((struct rebinding[2]){{"close", my_close, (void *)&orig_close}, {"open", my_open, (void *)&orig_open}}, 2);

    // Open our own binary and print out first 4 bytes (which is the same
    // for all Mach-O binaries on a given architecture)
    int fd = open(argv[0], O_RDONLY);
    uint32_t magic_number = 0;
    read(fd, &magic_number, 4);
    printf("Mach-O Magic Number: %x \n", magic_number);
    close(fd);

    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
```
### Sample output
```
Calling real open('/var/mobile/Applications/161DA598-5B83-41F5-8A44-675491AF6A2C/Test.app/Test', 0)
Mach-O Magic Number: feedface 
Calling real close(3)
...
```

## How it works

`dyld` binds lazy and non-lazy symbols by updating pointers in particular sections of the `__DATA` segment of a Mach-O binary. __fishhook__ re-binds these symbols by determining the locations to update for each of the symbol names passed to `rebind_symbols` and then writing out the corresponding replacements.

For a given image, the `__DATA` segment may contain two sections that are relevant for dynamic symbol bindings: `__nl_symbol_ptr` and `__la_symbol_ptr`. `__nl_symbol_ptr` is an array of pointers to non-lazily bound data (these are bound at the time a library is loaded) and `__la_symbol_ptr` is an array of pointers to imported functions that is generally filled by a routine called `dyld_stub_binder` during the first call to that symbol (it's also possible to tell `dyld` to bind these at launch). In order to find the name of the symbol that corresponds to a particular location in one of these sections, we have to jump through several layers of indirection. For the two relevant sections, the section headers (`struct section`s from `<mach-o/loader.h>`) provide an offset (in the `reserved1` field) into what is known as the indirect symbol table. The indirect symbol table, which is located in the `__LINKEDIT` segment of the binary, is just an array of indexes into the symbol table (also in `__LINKEDIT`) whose order is identical to that of the pointers in the non-lazy and lazy symbol sections. So, given `struct section nl_symbol_ptr`, the corresponding index in the symbol table of the first address in that section is `indirect_symbol_table[nl_symbol_ptr->reserved1]`. The symbol table itself is an array of `struct nlist`s (see `<mach-o/nlist.h>`), and each `nlist` contains an index into the string table in `__LINKEDIT` which where the actual symbol names are stored. So, for each pointer `__nl_symbol_ptr` and `__la_symbol_ptr`, we are able to find the corresponding symbol and then the corresponding string to compare against the requested symbol names, and if there is a match, we replace the pointer in the section with the replacement.

The process of looking up the name of a given entry in the lazy or non-lazy pointer tables looks like this:
![Visual explanation](http://i.imgur.com/HVXqHCz.png)



# MachOView

源码地址：https://github.com/gdbinit/MachOView

Mach-O格式全称为Mach Object文件格式的缩写，是mac上可执行文件的格式，类似于windows上的PE格式 (Portable Executable ), linux上的elf格式 (Executable and Linking Format)。

mach-o文件类型分为：
```
1、Executable：应用的主要二进制

2、Dylib Library：动态链接库（又称DSO或DLL）

3、Static Library：静态链接库

4、Bundle：不能被链接的Dylib，只能在运行时使用dlopen( )加载，可当做macOS的插件

5、Relocatable Object File ：可重定向文件类型
```
## 那什么又是FatFile/FatBinary？

简单来说，就是一个由不同的编译架构后的Mach-O产物所合成的集合体。一个架构的mach-O只能在相同架构的机器或者模拟器上用，为了支持不同架构需要一个集合体。

一、使用方式
1、MachOView工具概述

MachOView工具可Mac平台中可查看MachO文件格式信息，IOS系统中可执行程序属于Mach-O文件格式，有必要介绍如何利用工具快速查看Mach-O文件格式。

点击“MachOView”之后，便在Mac系统左上角出现MachOView工具的操作菜单

将“MachOView”拖到Application文件夹，就可以像其他程序一样启动了

下面介绍MachOView文件功能使用。

2、加载Mach-O文件
点击MachOView工具的主菜单“File”中的“Open”选项便可加载IOS平台可执行文件，对应功能接入如下所示：

例如加载文件名为“libLDCPCircle.a”的静态库文件，

3、文件头信息
MachOView工具成功加载Mach-O文件之后，每个.o文件对应一个类编译后的文件

在左边窗口点击“Mach Header”选项，可以看到每个类的cpu架构信息、load commands数量 、load commandssize 、file type等信息。

4、查看Fat文件
我们打开一个Fat文件可以看到：

可以看到，fat文件只是对各种架构文件的组装，点开 “Fat Header”可以看到支持的架构，显示的支持ARM_V7  、ARM_V7S  、ARM_64 、i386 、 X86_64。


点开每一个Static Library 可以看到，和每一个单独的Static Library的信息一样。

命令：
```
lipo LoginSDK.a -thin armv7 -output arm/LoginSDK.a  将fat文件拆分得到armv7类型

lipo  -create    ibSyncSDKA.i386.a    libSyncSDK.arm7.a  -output  libSyncSDK.a  合成一个i386和armV7架构的fat文件
```

## OpenSSH


这个工具是通过命令行工具访问苹果手机，执行命令行脚本。在Cydia中搜索openssh，安装。具体用法如下：
1、打开mac下的terminal，输入命令ssh root@192.168.2.2（越狱设备ip地址）
2、接下来会提示输入超级管理员账号密码，默认是alpine
3、回车确认，即可root登录设备
你也可以将你mac的公钥导入设备的/var/root/.ssh/authorized_keys文件，这样就可以免密登录root了。

![Reverse](https://github.com/XLsn0w/Cydia/blob/master/iOS%20Reverse.png?raw=true)

## Cycript


Cycript是大神saurik开发的一个非常强大的工具，可以让开发者在命令行下和应用交互，在运行时查看和修改应用。它可以帮助你HOOK一个App。Cycript最为贴心和实用的功能是它可以帮助我们轻松测试函数效果，整个过程安全无副作用，效果十分显著，实乃业界良心！
安装方式：在Cydia中搜索Cycript安装
使用方法：
1、root登录越狱设备
2、cycript-p 你想要测试的进程名
3、随便玩，完全兼容OC语法比如cy# [#0x235b4fb1 hidden]
Cycript有几条非常有用的命令：
choose：如果知道一个类对象存在于当前的进程中，却不知道它的地址，不能通过“#”操作符来获取它，此时可以使用choose命令获取到该类的所有对象的内存地址
打印一个对象的所有属性 [obj _ivarDescription].toString()
打印一个对象的所有方法[obj _methodDescription].toString()
动态添加属性 objc_setAssociatedObject(obj,@”isAdd”, [NSNumbernumberWithBool:YES], 0);
获取动态添加的属性 objc_getAssociatedObject(self, @”isAdd”)


## Reveal


Reveal是由ITTY BITTY出品的UI分析工具，可以直观地查看App的UI布局，我们可以用来研究别人的App界面是怎么做的，有哪些元素。更重要的是，可以直接找到你要HOOK的那个ViewController，贼方便不用瞎猫抓耗子一样到处去找是哪个ViewController了。
安装方法：
1、下载安装Mac版的Reveal
2、iOS安装Reveal Loader，在Cydia中搜索并安装Reveal Loader
在安装Reveal Loader的时候，它会自动从Reveal的官网下载一个必须的文件libReveal.dylib。如果网络状况不太好，不一定能够成功下载这个dylib文件，所以在下载完Reveal Loader后，检查iOS上的“/Library/RHRevealLoader/”目录下有没有一个名为“libReveal.dylib”的文件。如果没有就打开mac Reveal，在它标题栏的“Help”选项下，选中其中的“Show Reveal Library in Finder”，找到libReveal.dylib文件，使用scp拷贝到 iOS的/Library/RHRevealLoader/目录下。至此Reveal安装完毕！


## Dumpdecrypted


Dumpdecrypted就是著名的砸壳工具，所谓砸壳，就是对 ipa 文件进行解密。因为在上传到 AppStore 之后，AppStore自动给所有的 ipa 进行了加密处理。而对于加密后的文件，直接使用 class-dump 是得不到什么东西的，或者是空文件，或者是一堆加密后的方法/类名。
使用步骤如下：
1、设备中打开需要砸壳的APP。
2、SSH连接到手机，找到ipa包的位置并记录下来。
3、Cycript到该ipa的进程，找到App的Documents文件夹位置并记录下来。
4、拷贝dumpdecrypted.dylib到App的Documents 的目录。
5、执行砸壳后，并拷贝出砸壳后的二进制文件。
具体执行命令：
1、ssh root@192.168.2.2 （iP地址为越狱设备的iP地址）
2、 ps -e （查看进程，把进程对应的二进制文件地址记下来）
3、cycript -p 进程名
4、 [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
inDomains:NSUserDomainMask][0] （找到程序的documents目录）
5、scp ~/dumpdecrypted.dylib root@192.168.2.2:/var/mobile/Containers/Data/Application/XXXXXX/Documents
6、DYLD_INSERT_LIBRARIES=dumpdecrypted.dylib /var/mobile/Containers/Bundle/
Application/XXXXXX/xxx.app/xxx
然后就会生成.decrypted的文件，这个就是砸壳后的文件。接下来各种工具都随便上了class-dump、IDA、Hopper Disassembler


## class-dump

dump demo
```
$ class-dump -H /Users/xlsn0w/Desktop/Payload/JYLIM.app -o /Users/xlsn0w/Desktop/Header

```

class-dump就是用来dump二进制运行文件里面的class信息的工具。它利用Objective-C语言的runtime特性，将存储在Mach-O文件中的头文件信息提取出来，并生成对应的.h文件，这个工具非常有用，有了这个工具我们就像四维世界里面看三维物体，一切架构尽收眼底。
class-dump用法：
class-dump –arch armv7 -s -S -H 二进制文件路径 -o 头文件保存路径


## IDA


IDA是大名鼎鼎的反编译工具，它乃逆向工程中最负盛名的神器之一。支持Windows、Linux和Mac OS X的多平台反汇编器/调试器，它的功能非常强大。class-dump可以帮我们罗列出要分析的头文件，IDA能够深入各个函数的具体实现，无论的C，C++，OC的函数都可以反编译出来。不过反编译出来的是汇编代码，你需要有一定的汇编基础才能读的懂。
IDA很吃机器性能（我的机器经常卡住不动），还有另外一个反编译工具Hopper，对机器性能要求没那么高，也很好用，杀人越货的利器。

![CydiaRepo](https://github.com/XLsn0w/Cydia/blob/master/iOS%209.3.2%20jailbreak%20SE.png?raw=true)

## LLDB


LLDB是由苹果出品，内置于Xcode中的动态调试工具，可以调试C、C++、Objective-C，还全盘支持OSX、iOS，以及iOS模拟器。LLDB要配合debugserver来使用。常见的LLDB命令有：
p命令：首先p是打印非对象的值。如果使用它打印对象的话，那么它会打印出对象的地址，如果打印非对象它一般会打印出基本变量类型的值。当然用它也可以申明一个变量譬如 p int a=10;（注lldb使用a = 10; （注lldb使用在变量前来声明为lldb内的命名空间的）
po 命令：po 命令是我们最常用的命令因为在ios开发中，我们时刻面临着对象，所以我们在绝大部分时候都会使用po。首先po这个命令会打印出对象的description描述。
bt [all] 打印调用堆栈，是thread backtrace的简写，加all可打印所有thread的堆栈。
br l 是breakpoint list的简写，列出所有的断点
image list -o -f 列出模块和ASLR偏移，以及偏移后的地址，可以通过偏移后的地址-ASLR偏移来得出模块的基地址。
b NSLog给函数设置断点
br s -a IDA中偏移前的地址+ASLR偏移量 给内存地址设置断点
p (char *)$r1打印函数名称
br dis、br en和br del表示禁用、启用和删除断点
nexti（ni）跳过一行
stepi（si）跳入函数
c继续执行直到断点
register write r0 1修改寄存器的值usbmuxd很多人都是通过WiFi连接使用SSH服务的，因为无线网络的不稳定性及传输速度的限制，在复制文件或用LLDB远程调试时，iOS的响应很慢，效率不高。iOS越狱社区的知名人士Nikias Bassen开发了一款可以把本地OSX/Windows端口转发到远程iOS端口的工具usbmuxd，使我们能够通过USB连接线ssh到iOS中，大大增加了ssh连接的速度，也方便了那些没有WiFi的朋友。使用usbmuxd能极大提升ssh的速度，用LLDB远程连接debugserver的时间被缩短至15秒以内，强烈建议大家把usbmuxd作为ssh连接的首选方案


## Theos


以上都是App的分析工具，而Theos是一个越狱开发工具包（具体写代码），由iOS越狱界知名人士Dustin Howett开发并分享到GitHub上。Theos与其他越狱开发工具相比，最大的特点就是简单：下载安装简单、Logos语法简单、编译发布简单，可以让使用者把精力都放在开发工作上去。就是让你省去了繁琐的原始代码编写，简化了编译和安装过程。同样有一款工具iOSOpenDev是整合在Xcode里的，可以直接在Xcode中配置开发、运行越狱程序，不过iOSOpenDev的安装，过程真的是让人要吐血（我有一台mac死活都装不上）。
用法，theos有多种模板可以选择，最常用的就是tweak插件了：
/opt/theos/bin/nic.plNIC 2.0 - New Instance Creator
[1.] iphone/application
[2.] iphone/library
[3.] iphone/preference_bundle
[4.] iphone/tool
[5.] iphone/tweak
打包编译安装，需要按照固定格式编写Makefile文件，然后执行命令
make package install，自动编译打包安装到iOS设备。
如果你用的是IOSOpenDev就更简单了，配置好iOS设备ip地址，直接执行product->Bulid for－>profiling，自动打包安装好

一、 安装theos

1.打开终端(terminal)
2.先安装Homebrew
3.brew install ldid

4.下载theos 建议最好使用命令行的方式进行下载安装，因为theos内含有一些依赖文件
git clone --recursive https://github.com/theos/theos.git $THEOS
pS：$THEOS为环境变量，theos下载的目录
配置环境变量的方法如下->
```
$ ls -al /*找到bash_profile */
$ vim .bash_profile /* 编辑文件 */
$ export THEOS=~/theos /* 加入环境变量 */
$ export PATH=~/theos/bin:$PATH /* 如果不加入这行，theos的命令会无效。 */ /** $PATH 千万不要忘记写或者写错，不然所有的命令都用不了了。如果真这样了请打开这个链接按步骤进行https://zhidao.baidu.com/question/1755826278714933228.html **/
$ :wq  /* 保存退出 */
$ source .bash_profile /* 使新添加的环境变量立即生效 */

```
新建项目
```
$ nic.pl

NIC 2.0 - New Instance Creator
------------------------------
[1.] iphone/activator_event
[2.] iphone/application_modern
[3.] iphone/application_swift
[4.] iphone/flipswitch_switch
[5.] iphone/framework
[6.] iphone/library
[7.] iphone/preference_bundle_modern
[8.] iphone/tool
[9.] iphone/tool_swift
[10.] iphone/tweak
[11.] iphone/xpc_service
Choose a Template (required): 10
Project Name (required): XLsn0wtweak
Package Name [com.yourcompany.xlsn0wtweak]: com.xlsn0w.xlsn0wtweak
Author/Maintainer Name [Mac]: XLsn0w
[iphone/tweak] MobileSubstrate Bundle filter [com.apple.springboard]: 
[iphone/tweak] List of applications to terminate upon installation (space-separated, '-' for none) [SpringBoard]: 
Instantiating iphone/tweak in xlsn0wtweak/...
Done.


 ****** How to Hook with Logos ******
 
 
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
%log; // Write a message about this call, including its class, name and arguments, to the system log.

%orig; // Call through to the original function with its original arguments.
%orig(nil); // Call through to the original function with a custom argument.

// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
%log;
id awesome = %orig;
[awesome doSomethingElse];

return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end


```

![Cydiapple](https://github.com/XLsn0w/XLsn0w/raw/XLsn0w/XLsn0w/Cydiapple.png?raw=true)

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

## Logos语法
http://iphonedevwiki.net/index.php/Logos

新建Monkey工程时,MonkeyDev已经将libsubstrate.dylib库和RevealServer.framework库注入进去了，有了libsubstrate.dylib库就能写Logos语法

Logos语法    功能解释    事例
```
%hook    需要hook哪个类    %hook Classname
%end    代码块结束标记    
%group    分组    %group Groupname
%new    添加新方法    %new(signature)
%ctor    构造函数    %ctor { … }
%dtor    析构函数    %dtor { … }
%log    输出打印    %log; %log([(
%orig    保持原有方法    %orig；%orig(arg1, …)；
%c        %c([+/-]Class)；
```

1.%hook 
   %end

指定需要hook的class,必须以％end结尾。

// hook SpringBoard类里面的_menuButtonDown函数,先打印一句话,再之子那个函数原始的操作
%hook SpringBorad
```
- (void)_menuButtonDown:(id)down
{
NSLog(@"111111");
%orig; // 调用原始的_menuButtonDown函数
}
%end
```
2.%group

该指令用于将%hook分组，便于代码管理及按条件初始化分组，必须以%end结尾。
一个％group可以包含多个%hook,所有不属于某个自定义group的％hook会被隐式归类到％group_ungrouped中。
```
%group iOS8
%hook IOS8_SPECIFIC_CLASS
// your code here
%end // end hook
%end // end group ios8

%group iOS9
%hook IOS9_SPECIFIC_CLASS
// your code here
%end // end hook
%end // end group ios9

%ctor {
if (kCFCoreFoundationVersionNumber > 1200) {
%init(iOS9);
} else {
%init(iOS8);
}
}
```
3.%new

在%hook内部使用，给一个现有class添加新函数，功能与class_addMethod相同.
注：
Objective-C的category与class_addMethod的区别：
前者是静态的而后者是动态的。使用%new添加,而不需要向.h文件中添加函数声明,如果使用category,可能与遇到这样那样的错误.
```
%hook SpringBoard
%new
- (void)addNewMethod
{
NSLog(@"动态添加一个方法到SpringBoard");
}
%end
```
4.%ctor

tweak的constructor,完成初始化工作；如果不显示定义，Theos会自动生成一个%ctor,并在其中调用%init(_ungrouped)。%ctor一般可以用来初始化%group,以及进行MSHookFunction等操作,如下:
```
#ifndef KCFCoreFoundationVersionNumber_iOS_8_0
#define KCFCoreFoundationVersionNumber_iOS_8_0      1140.10
#endif

%ctor
{
%init;

if (KCFCoreFoundationVersionNumber >= KCFCoreFoundationVersionNumber_iOS_7_0 && KCFCoreFoundationVersionNumber > KCFCoreFoundationVersionNumber_iOS_8_0)
%init(iOS7Hook);
if (KCFCoreFoundationVersionNumber >= KCFCoreFoundationVersionNumber_iOS_8_0)
%init(iOS8Hook);
MSHookFunction((void *)&AudioServicesPlaySystemSound,(void *)&replaced_AudioServerPlaySystemSound,(void **)&orginal_AudioServicesPlaySystemSound);
}
```
5.%dtor

Generate an anonymous deconstructor (of default priority).

%dtor { … }
6.%log

该指令在%hook内部使用，将函数的类名、参数等信息写入syslog,可以％log([(),…..])的格式追加其他打印信息。
```
%hook SpringBorad
- (void)_menuButtonDown:(id)down
{
%log((NSString *)@"iosre",(NSString *)@"Debug");
%orig; // 调用原始的_menuButtonDown方法
}
%end
```
6.%orig

该指令在%hook内部使用，执行被hook的函数的原始代码；也可以用％orig更改原始函数的参数。
```
%hook SpringBorad
- (void)setCustomSubtitleText:(id)arg1 withColor:   (id)arg2
{
%orig(@"change arg2",arg2);// 将arg2的参数修 改为"change arg2"
}
%end
```
7.%init

该指令用于初始化某个％group，必须在%hook或％ctor内调用；如果带参数，则初始化指定的group，如果不带参数，则初始化_ungrouped.
注： 切记，只有调用了％init,对应的%group才能起作用！

8.%c

该指令的作用等同于objc_getClass或NSClassFromString,即动态获取一个类的定义，在%hook或％ctor内使用 。


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


## 符号表历来是逆向工程中的“必争之地”，而iOS应用在上线前都会裁去符号表，以避免被逆向分析。

直接看效果,支付宝恢复符号表后的样子:

![](http://blog.imjun.net/posts/restore-symbol-of-iOS-app/after_restore.jpg)

支付宝恢复符号表后

文章有点长，请耐心看到最后，亮点在最后。

为什么要恢复符号表
逆向工程中，调试器的动态分析是必不可少的，而 Xcode + lldb 确实是非常好的调试利器, 比如我们在Xcode里可以很方便的查看调用堆栈，如上面那张图可以很清晰的看到支付宝登录的RPC调用过程。

实际上，如果我们不恢复符号表的话，你看到的调试页面应该是下面这个样子：

![](http://blog.imjun.net/posts/restore-symbol-of-iOS-app/before_restore.jpg)

恢复符号表前

同一个函数调用过程，Xcode的显示简直天差地别。

原因是，Xcode显示调用堆栈中符号时，只会显示符号表中有的符号。为了我们调试过程的顺利，我们有必要把可执行文件中的符号表恢复回来。

符号表是什么
我们要恢复符号表，首先要知道符号表是什么，他是怎么存在于 Mach-O 文件中的。

符号表储存在 Mach-O 文件的 __LINKEDIT 段中，涉及其中的符号表（Symbol Table）和字符串表（String Table）。

这里我们用 MachOView 打开支付宝的可执行文件，找到其中的 Symbol Table 项。

![](http://blog.imjun.net/posts/restore-symbol-of-iOS-app/symbol_table.jpg)

符号表的结构是一个连续的列表，其中的每一项都是一个 struct nlist。

//  位于系统库 <macho-o/nlist.h> 头文件中
struct nlist {
union {
//符号名在字符串表中的偏移量
uint32_t n_strx;    
} n_un;
uint8_t n_type;
uint8_t n_sect;
int16_t n_desc;
//符号在内存中的地址，类似于函数指针
uint32_t n_value;
};
这里重点关注第一项和最后一项，第一项是符号名在字符串表中的偏移量，用于表示函数名，最后一项是符号在内存中的地址，类似于函数指针（这里只说明大概的结构，详细的信息请参考官方Mach O文件格式的文档）。

也就是说如果我们知道了符号名和内存地址的对应关系，我们是可以根据这个结构来逆向构造出符号表数据的。

知道了如何构造符号表，下一步就是收集符号名和内存地址的对应关系了。

获取OC方法的符号表
因为OC语言的特性，编译器会将类名、函数名等编译进最后的可执行文件中，所以我们可以根据Mach-O文件的结构逆向还原出工程里的所有类，这也就是大名鼎鼎的逆向工具 class-dump 了。class-dump 出来的头文件里是有函数地址的：

所以我们只要对class-dump的源码稍作修改，即可获取我们要的信息。

符号表恢复工具
整理完数据格式，又理清了数据来源，我们就可以写工具了。

实现过程就不详细说明了，工具开源在我的Github上了，链接：
https://github.com/tobefuturer/restore-symbol

我们来看看怎么用这个工具：

1.下载源码编译

git clone --recursive https://github.com/tobefuturer/restore-symbol.git
cd restore-symbol && make
./restore-symbol
2.恢复OC的符号表，非常简单

1
./restore-symbol ./origin_AlipayWallet -o ./AlipayWallet_with_symbol
origin_AlipayWallet 为Clutch砸壳后，没有符号表的 Mach-O 文件
-o 后面跟输出文件位置

3.把 Mach-O 文件重签名打包，看效果

文件恢复符号表后，多出了20M的符号表信息


Xcode里查看调用栈

![](http://blog.imjun.net/posts/restore-symbol-of-iOS-app/restore_only_oc.jpg)


可以看到，OC函数这部分的符号已经恢复了，函数调用栈里已经能看出大致的调用过程了，但是支付宝里，采用了block的回调形式，所以还有很大一部分的符号没能正确显示。

下面我们就来看看怎么样恢复这部分block的符号。

获取block的符号信息
还是同样的思路，要恢复block的符号信息，我们必须知道block在文件中的储存形式。

block在内存中的结构
首先，我们先分析下运行时，block在内存中的存在形式。block在内存中是以一个结构体的形式存在的，大致的结构如下：


struct __block_impl {
/**
block在内存中也是类NSObject的结构体，
结构体开始位置是一个isa指针
*/
Class isa;

/** 这两个变量暂时不关心 */
int flags;
int reserved;

/**
真正的函数指针！！
*/
void (*invoke)(...);
...
}
说明下block中的isa指针，根据实际情况会有三种不同的取值，来表示不同类型的block：

_NSConcreteStackBlock

栈上的block，一般block创建时是在栈上分配了一个block结构体的空间，然后对其中的isa等变量赋值。

_NSConcreteMallocBlock

堆上的block，当block被加入到GCD或者被对象持有时，将栈上的block复制到堆上，此时复制得到的block类型变为了_NSConcreteMallocBlock。

_NSConcreteGlobalBlock

全局静态的block，当block不依赖于上下文环境，比如不持有block外的变量、只使用block内部的变量的时候，block的内存分配可以在编译期就完成，分配在全局的静态常量区。

第2种block在运行时才会出现，我们只关注1、3两种，下面就分析这两种isa指针和block符号地址之间的关联。

block isa指针和符号地址之间的关联
分析这部分需要用到IDA这个反汇编软件, 这里结合两个实际的小例子来说明：

1._NSConcreteStackBlock
假设我们的源代码是这样很简单的一个block：

11
@implementation ViewController
- (void)viewDidLoad {
int t = 2;
void (^ foo)() = ^(){
NSLog(@"%d", t); //block 引用了外部的变量t
};
foo();
}
@end
编译完后，实际的汇编长这个样子：


实际运行时，block的构造过程是这样：

为block开辟栈空间
为block的isa指针赋值（一定会引用全局变量：_NSConcreteStackBlock）
获取函数地址，赋值给函数指针
所以我们可以整理出这样一个特征：

重点来了!!!

凡是代码里用到了栈上的block，一定会获取__NSConcreteStackBlock作为isa指针，同时会紧接着获取一个函数地址，那个函数地址就是block的函数地址。

结合下面这个图，仔细理解上面这句话
（这张图和上面那张图是同一个文件，不过裁掉了符号表）


利用这个特征，逆向分析时我们可以做如下推断：

在一个OC方法里发现引用了__NSConcreteStackBlock这个变量，那么在这附近，一定会出现一个函数地址，这个函数地址就是这个OC方法里的一个block。

比如上面图中，我们发现 viewDidLoad 里，引用了__NSConcreteStackBlock,同时紧接着加载了 sub_100049D4 的函数地址，那我们就可以认定sub_100049D4是viewDidLoad里的一个block, sub_100049D4函数的符号名应该是 viewDidLoad_block.

2. _NSConcreteGlobalBlock
全局的静态block，是那种不引用block外变量的block，他因为不引用外部变量，所以他可以在编译期就进行内存分配操作，也不用担心block的复制等等操作，他存在于可执行文件的常量区里。

不太理解的话，看个例子：

我们把源代码改成这样：

@implementation ViewController
- (void)viewDidLoad {

void (^ foo)() = ^(){
//block 不引用外部的变量
NSLog(@"%d", 123);
};
foo();
}
@end
那么在编译后会变成这样：


那么借鉴上面的思路，在逆向分析的时候，我们可以这么推断

在静态常量区发现一个_NSConcreteGlobalBlock的引用
这个地方必然存在一个block的结构体数据
在这个结构体第16个字节的地方会出现一个值，这个值是一个block的函数地址
3. block 的嵌套结构
实际在使用中，可能会出现block内嵌block的情况：

- (void)viewDidLoad {
dispatch_async(background_queue ,^{
...
dispatch_async(main_queue, ^{
...     
});
});
}
所以这里block就出现了父子关系，如果我们将这些父子关系收集起来，就可以发现，这些关系会构成图论里的森林结构，这里可以简单用递归的深度优先搜索来处理，详细过程不再描述。

block符号表提取脚本（IDA+python）
整理上面的思路，我们发现搜索过程依赖于IDA提供各种引用信息，而IDA是提供了编程接口的，可以利用这些接口来提取引用信息。

IDA提供的是Python的SDK，最后完成的脚本也放在仓库里search_oc_block/ida_search_block.py。

提取block符号表
这里简单介绍下怎么使用上面这个脚本

用IDA打开支付宝的 Mach-O 文件
等待分析完成！ 可能要一个小时
Alt + F7 或者 菜单栏 File -> Script file...

等待脚本运行完成，预计30s至60s，运行过程中会有这样的弹窗

弹窗消失即block符号表提取完成
在IDA打开文件的目录下,会输出一份名为block_symbol.json的json格式block符号表


恢复符号表&实际分析
用之前的符号表恢复工具，将block的符号表导入Mach-O文件

1
./restore-symbol ./origin_AlipayWallet -o ./AlipayWallet_with_symbol -j block_symbol.json
-j 后面跟上之前得到的json符号表

最后得到一份同时具有OC函数符号表和block符号表的可执行文件

这里简单介绍一个分析案例, 你就能体会到这个工具的强大之处了。

在Xcode里对 -[UIAlertView show] 设置断点

运行程序，并在支付宝的登录页面输入手机号和错误的密码，点击登录
Xcode会在‘密码错误’的警告框弹出时停下，左侧会显示出这样的调用栈
一张图看完支付宝的登录过程
![](http://blog.imjun.net/posts/restore-symbol-of-iOS-app/xcode_backtrace.jpg)

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
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
