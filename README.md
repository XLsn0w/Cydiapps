## Cydia iOS逆向工程开发

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







## 参考文献

- http://security.ios-wiki.com/issue-3-7/
