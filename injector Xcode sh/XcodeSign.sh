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
echo "libHJHelper.dylib => FRAMEWORK : $FRAMEWORK"
#签名
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$FRAMEWORK"
done
fi

# ---------------------------------------------------
# 7. 注入我们编写的动态库
echo "开始注入"
# 需要注入的动态库的路径
INJECT_FRAMEWORK_RELATIVE_PATH="Frameworks/libHJHelper.dylib"
#
## 通过工具实现注入
yololib "$TARGET_APP_PATH/$APP_BINARY" "$INJECT_FRAMEWORK_RELATIVE_PATH"
echo "注入完成"
