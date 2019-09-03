工程模块配置:

* Identifier 
	
	模板的唯一标示符
* Kind 

	Xcode.Xcode3.ProjectTemplateUnitKind 都是这个值
* Concrete

	设置为YES的模板才可以显示在new project的dialog中，此时这个模板不能被其他模板继承
* Ancestors

	父模版，从父模版那里继承一些模板的基础属性，可以有多个父类
* Description

	新建工程时，模版的描述
* Targets

	Target的一些设置，包括编译设置
* Platforms

	运行平台
* Project

	项目的一些设置
* Options

	定义新建工程中的storyboard等
* Nodes

	定义添加到工程模版中的文件
* Definitions

	将Nodes中定义的文件添加到项目中
	
### Base模板
主要是继承一些通过父模板

* 单元测试
* deb打包
* 设置显示

Target的编译设置，安装的设备，编译时是否安装等等。

项目的设置:

TARGETED_DEVICE_FAMILY 1,2  Iphone/Ipad

文件导入以及pch文件。

### Debian Package
Package的一些编译设置。

增加文件:
Package/DEBIAN/contrl

以及文件里面的内容。

### PreferenceLoader
是否显示在设置里面。

### Unit Tests
单元测试。

### CaptainHook Tweak
类型:
动态库
编译设置:
安装路径
编译脚本

增加修改文件，编译文件，hook的对象，control内容。

### Logos Tweak
同上。
