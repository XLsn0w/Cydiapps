//require('HJHelperUtils,HJHelper');
////修改版本号，以确定用户是否成功加载补丁
//defineClass('HJHelperUtils', {
//            version: function() {
//            return "3.152.1";
//            },
//
//            });
//
//defineClass('HJTouchViewManager', {
//            kmcError: function(notification) {
//
//            },
//            });

//defineClass('HJHelper', {
//            didFinishLanchApplication: function(notification) {
//            if (HJHelperUtils.sharedUtils().version().floatValue() < 3.165) {
//            console.log("Do not support!!!")
//            return;
//            }
//            },
//            });

//require('NSBundle,HJTouchUserDataManager,HJYunConfigManager,PopoverAction,PopoverView,HJPushMessageManager,XFAssistiveTouch,NSNotificationCenter,HJCerProtectManager,HJCerProtectAlert,HJHelperUtils,HJCAlertView,HJBundle,NSString,HJTouchManager,HJKeyNormalItem,HJKeyMultiClickItem,HJKeyTwoPointItem,HJDragItem,UIColor');


//修改版本号，以确定用户是否成功加载补丁
//defineClass('HJHelperUtils', {
//            version: function() {
//            return "3.01.5";
//            },
//            
//            });
//
//
//defineClass('HJTouchViewManager', {
//            showSome: function() {
//            
//            },
//            });


//defineClass("BTTransferManager", {
//            recvBLEData_withCharacteristicUUID: function(data, characteristicUUID) {
//            if (characteristicUUID.isEqualToString("ff01") || characteristicUUID.isEqualToString("ff04")) {
//            var code;
//            code = self.bleDataAnalysis(data);
//            for (var i = 0; i < code.length(); i += 2) {
//            var range = {location: i, length: 2};
//            var bit = code.substringWithRange(range);
//            self.recvByteData(bit);
//            }
//            } else if (characteristicUUID.isEqualToString("ff02") || characteristicUUID.isEqualToString("fff2")) {
//            var code;
//            code = self.bleDataAnalysis(data);
//            self.newDataAnalyse(code);
//            } else if (characteristicUUID.isEqualToString("fff5")) {
//            self.recvDeviceInfo(data);
//            } else if (characteristicUUID.isEqualToString("fff6")) {} else if (characteristicUUID.isEqualToString("fff7")) {} else if (characteristicUUID.isEqualToString("fff9")) {} else if (characteristicUUID.isEqualToString("A71EB84E-2AB5-4C00-8581-8FE418B60856".lowercaseString())) {
//            self.delegate().setHSKey(self.bleDataAnalysis(data));
//            } else if (characteristicUUID.isEqualToString("F000FFC1-0451-4000-B000-000000000000".lowercaseString())) {} else if (characteristicUUID.isEqualToString("F000FFC2-0451-4000-B000-000000000000".lowercaseString())) {}
//            }
//            }, {});

