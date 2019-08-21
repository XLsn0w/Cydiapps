# issh
> 自动登录ssh，自动打开端口映射，自动签名debugserver，一键调试，一键shell等等，越狱设备用issh就够了



### Introduction

**issh最初由Android的adb启发而来。Android中只需要将设备连接上电脑就能通过adb十分方便的获取shell、安装应用等等操作。反观iOS平台，由于采用的openSSH与设备通信。与设备通信十分繁琐，不仅需要端口映射，每次还需要输入密码。所以我写了这个越狱设备的自动化脚本，只要将设备连接到电脑，就能获得与Android中adb一样的便捷，不仅如此还封装了很多实用的命令比如一键调式，砸壳等等。当然如果你还有其他想法或者实用的命令，都可以随意issue或者pr。一切以减少重复、繁琐工作为目的，enjoy~**



### Install

> Before install, make sure you have installed iproxy,cfgutil cmds
>
> cfgutil通过在mac App Store中下载apple configurator 2安装后就有这个命令(后面会考虑用其他方式替换这个命令)
>
> 另外iOS中的defaults读写plist的命令在[https://repo.chariz.io](https://repo.chariz.io/)源中安装Cephei就有了

- `git clone issh_git_project;`

- `cd issh`

- `./install.sh`

- If your shell is bash run: `source ~/.bash_profile` 

- If your shell is zsh run :`source ~/.zshrc`

  

### Command

```bash
xia0 ~ $ issh -h
[I]:First Run issh on new idevice, you will only input ssh password twice! 
issh show [dylib/Preferences/apps]  show some info       
issh scp remote/local local/remote  cp file from connect device or to device 
issh dump                           Use Frida(frida-ios-dump) to dump IPA 
issh debug [-a wechat -x backboard] auto sign debugserver[Test on iOS9/10/11/12] and happy to debug 
issh install                        install app form local to connect device 
issh device                         show some info about device 
issh apps                           show all app info(Bundleid,BundleExecutable,BundleDisplayName, Fullpath) 
issh shell                          get the shell of connect device 
issh clean                          rm authorized_keys and xia0_ssh.lock from device 
issh run                            execute shell command on connect device 
issh respring                       kill SpringBoard     
issh ldrestart                      kill all daemon without reJailbreak 
issh reboot                         !!!if do reboot, you need reJailbreak! 
issh help/-h                        show this help info 
```

- `issh shell`

  get the shell of connect device

- `issh scp`

  copy file from connect device or copy local file to connect device

- `issh debug [debugArgs:-a pid/processName -x backboard/auto]`

  like `issh debug -a wechat` attach the wechat app

  配合[xia0LLDB](https://github.com/4ch12dy/xia0LLDB)食用更加

- `issh dump [dumpArgs:-l]`

  Use  frida-ios-dump, auto download and run

  用的frida-ios-dump脚本，会自动下载并运行

- `issh run "cmd"`

  run shell command on connect idevice like `issh run ls`

- `issh respring/reboot/ldrestart`

  注销、重启、kill所有守护进程但不重启（保留越狱环境）

- `issh apps`

  显示所有app（包括系统app），包名，显示名，进程名，完整路径等


### Screenshot

![issh-debug](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-debug.png?raw=true)



![issh-device](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-device.png?raw=true)



![issh-dump](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-dump.png?raw=true)



![issh-install](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-install.png?raw=true)



![issh-run](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-run.png?raw=true)



![issh-scp](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-scp.png?raw=true)



![issh-shell](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-shell.png?raw=true)



![issh-show-dylib](https://github.com/4ch12dy/issh/blob/master/screenshot/issh-show-dylib.png?raw=true)

### Credits

- https://github.com/AloneMonkey/frida-ios-dump
- https://github.com/libimobiledevice/usbmuxd

