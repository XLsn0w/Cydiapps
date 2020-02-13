##  iOS逆向工程开发 越狱Jailbreak Cydia deb插件开发
![touch4](https://github.com/XLsn0w/Cydia/blob/master/iOS%206.1.6%20jailbreak.JPG?raw=true)

# 我的微信公众号: CydiaInstaller
![cydiapple](https://github.com/XLsn0w/XLsn0w/raw/XLsn0w/XLsn0w/Cydiapple.png?raw=true)
## Cycript / Class-dump / Theos / Reveal / Dumpdecrypted  逆向工具使用介绍

# 越狱开发常见的工具OpenSSH，Dumpdecrypted，class-dump、Theos、Reveal、IDA，Hopper，

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
br l 是break
