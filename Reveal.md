# Reveal Loader

Reveal主页：http://revealapp.com

Reveal 是一个界面调试工具，[这里](http://blog.devzeng.com/blog/ios-reveal-integrating.html)有一篇iOS开发中集成Reveal的教程，所以我们就不讨论如何集成到自己的工程中，接下来我们看一下如何使用Reveal查看任意app。

需要的东西：

- 越狱设备
- Cydia
- iFile
- SSH

使用Cydia下载 [**Reveal Loader**](https://github.com/heardrwt/RevealLoader) 并安装后re-spring或重启iOS设备。在系统设置中找到 **Reveal** -> **Enabled Applications** 进行配置，打开你想要Reveal的app。

![这是参考文献中的图](http://bbs.iosre.com/uploads/default/359/db1478db9712f0c5.PNG)

建议需要查看哪个开哪个，其他的关闭掉，这样Reveal加载速度会快一点。
 
![这是参考文献中的图](http://ww3.sinaimg.cn/large/6a011e49gw1eyk3r7s8rvj21520rgwma.jpg)


## 参考文献

- http://c.blog.sina.com.cn/profile.php?blogid=cb8a22ea89000gtw 
	<br/>这篇有点过时了，我修改libReveal.plist时经常出现白苹果😔，可以强制进入[安全模式](https://www.google.com.hk/#newwindow=1&safe=strict&q=iphone+安全模式)后将文件修改好再重新启动。
- http://hilen.github.io/2015/12/01/Reveal-Loader/
