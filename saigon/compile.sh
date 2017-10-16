#!/bin/bash
echo "[*] Compiling Saïgon.."
$(which xcodebuild) clean build CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" -sdk `xcrun --sdk iphoneos --show-sdk-path` -arch arm64
mv build/Release-iphoneos/saïgon.app saïgon.app
mkdir Payload
mv saïgon.app Payload/saïgon.app
echo "[*] Zipping into .ipa"
zip -r9 Saïgon.ipa Payload/saïgon.app
rm -rf build Payload
echo "[*] Done! Install .ipa with Impactor"
