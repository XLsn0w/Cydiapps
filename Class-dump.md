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
