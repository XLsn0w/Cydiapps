# FLEX iOS Jailbreak Tweak

FLEXLoader 可以在越狱设备上动态加载 libFLEX.dylib 到任意应用中，以使用 FLEX 进行应用内调试。

关于 FLEX 可以参考[它的项目主页](https://github.com/Flipboard/FLEX)。

关于本项目更详细的内容，可以参考[我的这篇博客](http://swiftyper.com/2017/06/04/inspect-third-party-app-using-flexloader/)。

## 安装

FLEXLoader 已经提交 Cydia 市场审核，审核通过后可以直接从 Cydia 中进行下载安装。

### 手动安装

将本项目 clone 到本地，修改 Makefile 中的设备 IP 和 PORT，然后执行 `make package install` 即可。

## 使用

在系统设置界面中找到 FLEXLoader，选择要你想要调试的程序打开开关。

启动对应的应用，就可以在应用中看到调试窗口了。

## 效果

![](http://7xqonv.com1.z0.glb.clouddn.com/inspect-third-party-app-using-flexloader-pic-2-1.png)

## 公众号

如果你对本项目有兴趣，可以关注我的公众号。

![](http://7xqonv.com1.z0.glb.clouddn.com/offical_wechat_account_qrcode.jpg)
