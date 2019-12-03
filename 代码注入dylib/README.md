# dylibInjecting
iOS逆向之代码注入(dylib)

题外话：此教程是一篇严肃的学术探讨类文章，仅仅用于学习研究，也请读者不要用于商业或其他非法途径上，笔者一概不负责哟~~
##准备工作
* 非越狱的iPhone手机
* 用PP助手下载： 微信6.6.5(越狱应用)
* MachOView
>MachOView下载地址：[http://sourceforge.net/projects/machoview/](https://link.jianshu.com/?t=http://sourceforge.net/projects/machoview/)
>MachOView源码地址：[https://github.com/gdbinit/MachOView](https://link.jianshu.com/?t=https://github.com/gdbinit/MachOView)
* yololib
>yololib下载地址https://github.com/KJCracks/yololib?spm=a2c4e.11153940.blogcont63256.9.5126420eAJpqBD
##代码注入思路：
dylb会加载Frameworks中所有的动态库，那么在Frameworks中加一个自己的动态库，然后在自己动态库中hook和注入代码

###动态库存放的位置：Frameworks
![image.png](https://upload-images.jianshu.io/upload_images/1013424-161997866a52aec0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
###找到可执行文件WeChat
![image.png](https://upload-images.jianshu.io/upload_images/1013424-e4f12b6c6aa5fb93.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

用MachOView打开可执行文件WeChat，在Load Commands里可以查看到动态库
![image.png](https://upload-images.jianshu.io/upload_images/1013424-2f0d040fe1dfc01e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/1013424-35f07623f288ed4c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image.png](https://upload-images.jianshu.io/upload_images/1013424-3a45631e72661e10.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##步骤：
###1、新建工程，在Build Phases 添加脚本
![image.png](https://upload-images.jianshu.io/upload_images/1013424-cac66bb0db55ff6f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/1013424-3ebba57cf84bb67d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
>脚本可以参考[iOS逆向之自动化重签名](https://www.jianshu.com/p/30c1059879aa),我是用文件XcodeSign.sh存在本地。
###2、在工程目录添加APP文件夹，将越狱的微信安装包放入其中
![image.png](https://upload-images.jianshu.io/upload_images/1013424-f5cb065f4c24931b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
###3、先编译运行起来

###4、添加dylib
iOS现在已经不能添加dylib，只能从macOS添加
![image.png](https://upload-images.jianshu.io/upload_images/1013424-13148f3cf395bfd4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/1013424-deb80941a5b97dc2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
###5、引入WJHook
![image.png](https://upload-images.jianshu.io/upload_images/1013424-bc6aae3e65383023.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![image.png](https://upload-images.jianshu.io/upload_images/1013424-ca6a14bfd53f0a8a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
###6、修改Base SDK-     **非常重要**
![image.png](https://upload-images.jianshu.io/upload_images/1013424-928ab3d62eb1e88b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###7、修改Signing -     **非常重要**
![image.png](https://upload-images.jianshu.io/upload_images/1013424-72ebae7687d6cda3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###8、在XcodeSign.sh脚本中编写注入动态库的代码，保存
```
#  注入我们编写的动态库
echo "开始注入"
# 需要注入的动态库的路径  这个路径我就写死了!
INJECT_FRAMEWORK_RELATIVE_PATH="Frameworks/libWJHook.dylib"
#
## 通过工具实现注入
yololib "$TARGET_APP_PATH/$APP_BINARY" "$INJECT_FRAMEWORK_RELATIVE_PATH"
echo "注入完成"
```
完整的脚本如下：
```
# ${SRCROOT} 为工程文件所在的目录
TEMP_PATH="${SRCROOT}/Temp"
#资源文件夹,放三方APP的
ASSETS_PATH="${SRCROOT}/APP"
#ipa包路径
TARGET_IPA_PATH="${ASSETS_PATH}/*.ipa"

#新建Temp文件夹
rm -rf "$TEMP_PATH"
mkdir -p "$TEMP_PATH"

# --------------------------------------
# 1. 解压IPA 到Temp下
unzip -oqq "$TARGET_IPA_PATH" -d "$TEMP_PATH"
# 拿到解压的临时APP的路径
TEMP_APP_PATH=$(set -- "$TEMP_PATH/Payload/"*.app;echo "$1")
# 这里显示打印一下 TEMP_APP_PATH变量
echo "TEMP_APP_PATH: $TEMP_APP_PATH"

# -------------------------------------
# 2. 把解压出来的.app拷贝进去
#BUILT_PRODUCTS_DIR 工程生成的APP包路径
#TARGET_NAME target名称
TARGET_APP_PATH="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app"
echo "TARGET_APP_PATH: $TARGET_APP_PATH"

rm -rf "$TARGET_APP_PATH"
mkdir -p "$TARGET_APP_PATH"
cp -rf "$TEMP_APP_PATH/" "$TARGET_APP_PATH/"

# -------------------------------------
# 3. 为了是重签过程简化，移走extension和watchAPP. 此外个人免费的证书没办法签extension

echo "Removing AppExtensions"
rm -rf "$TARGET_APP_PATH/PlugIns"
rm -rf "$TARGET_APP_PATH/Watch"

# -------------------------------------
# 4. 更新 Info.plist 里的BundleId
#  设置 "Set :KEY Value" "目标文件路径.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $PRODUCT_BUNDLE_IDENTIFIER" "$TARGET_APP_PATH/Info.plist"

# 5.给可执行文件上权限
#添加ipa二进制的执行权限,否则xcode会告知无法运行
#这个操作是要找到第三方app包里的可执行文件名称，因为info.plist的 'Executable file' key对应的是可执行文件的名称
#我们grep 一下,然后取最后一行, 然后以cut 命令分割，取出想要的关键信息。存到APP_BINARY变量里
APP_BINARY=`plutil -convert xml1 -o - $TARGET_APP_PATH/Info.plist|grep -A1 Exec|tail -n1|cut -f2 -d\>|cut -f1 -d\<`

#这个为二进制文件加上可执行权限 +X
chmod +x "$TARGET_APP_PATH/$APP_BINARY"

# -------------------------------------
# 6. 重签第三方app Frameworks下已存在的动态库
TARGET_APP_FRAMEWORKS_PATH="$TARGET_APP_PATH/Frameworks"
if [ -d "$TARGET_APP_FRAMEWORKS_PATH" ];
then
#遍历出所有动态库的路径
for FRAMEWORK in "$TARGET_APP_FRAMEWORKS_PATH/"*
do
echo "🍺🍺🍺🍺🍺🍺FRAMEWORK : $FRAMEWORK"
#签名
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$FRAMEWORK"
done
fi

# ---------------------------------------------------
# 7. 注入我们编写的动态库
echo "开始注入"
# 需要注入的动态库的路径  这个路径我就写死了!
INJECT_FRAMEWORK_RELATIVE_PATH="Frameworks/libWJHook.dylib"
#
## 通过工具实现注入
yololib "$TARGET_APP_PATH/$APP_BINARY" "$INJECT_FRAMEWORK_RELATIVE_PATH"
echo "注入完成"
```
###9、在WJHook中编写注入代码(WJHook也要添加开发者团队签名signing)
![image.png](https://upload-images.jianshu.io/upload_images/1013424-f30273fdc8d0adfb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image.png](https://upload-images.jianshu.io/upload_images/1013424-bba43ab31ab79c78.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###10、编译运行，成功！
![image.png](https://upload-images.jianshu.io/upload_images/1013424-e4f167bee625fced.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

