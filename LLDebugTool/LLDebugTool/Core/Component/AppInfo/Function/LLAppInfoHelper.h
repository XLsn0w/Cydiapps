//
//  LLAppInfoHelper.h
//
//  Copyright (c) 2018 LLDebugTool Software Foundation (https://github.com/HDB-Li/LLDebugTool)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Notifications will post each second on main thread.
 Cpu is between 0.0% to 100.0%.
 Memory's unit is byte.
 Fps is float between 0.0 to 60.0.
 Request data traffic is upload data.
 Response data traffic is download data.
 Total data traffic is total data.
 */
UIKIT_EXTERN NSNotificationName _Nonnull const LLAppInfoHelperDidUpdateAppInfosNotificationName;

UIKIT_EXTERN NSString * _Nonnull const LLAppInfoHelperCPUKey;
UIKIT_EXTERN NSString * _Nonnull const LLAppInfoHelperMemoryUsedKey;
UIKIT_EXTERN NSString * _Nonnull const LLAppInfoHelperMemoryFreeKey;
UIKIT_EXTERN NSString * _Nonnull const LLAppInfoHelperMemoryTotalKey;
UIKIT_EXTERN NSString * _Nonnull const LLAppInfoHelperFPSKey;
UIKIT_EXTERN NSString * _Nonnull const LLAppInfoHelperRequestDataTrafficKey;
UIKIT_EXTERN NSString * _Nonnull const LLAppInfoHelperResponseDataTrafficKey;
UIKIT_EXTERN NSString * _Nonnull const LLAppInfoHelperTotalDataTrafficKey;

NS_ASSUME_NONNULL_BEGIN

/**
 Monitoring app's properties.
 */
@interface LLAppInfoHelper : NSObject

/**
 Singleton to monitoring appinfos.
 
 @return Singleton
 */
+ (instancetype _Nonnull)shared;

/**
 Set enable to monitoring network request.
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enable;

/**
 Get current app infos. Include "CPU Usage","Memory Usage","FPS","Data Traffic","App Name","Bundle Identifier","App Version","App Start Time","Device Model","Device Name","System Version","Screen Resolution","Language Code","Battery Level","CPU Type","Disk","Network State" and "SSID".
 */
- (NSMutableArray <NSArray <NSDictionary <NSString *,NSString *>*>*>*)appInfos;

/**
 Get dynamic app infos this time.
 */
- (NSDictionary <NSString *, NSString *>*)dynamicAppInfos;

/**
 Current cpu usage.
 */
- (NSString *)cpuUsage;

/**
 Current memory usage.
 */
- (NSString *)memoryUsage;

/**
 Current FPS.
 */
- (NSString *)fps;

/**
 Current data traffic.
 Format is "{total} ({upload}↑ / {download}↓)"
 */
- (NSString *)dataTraffic;

/**
 Application name.
 */
- (NSString *)appName;

/**
 Application bundle identifier.
 */
- (NSString *)bundleIdentifier;

/**
 Application version.
 */
- (NSString *)appVersion;

/**
 Application start time consuming.
 */
- (NSString *)appStartTimeConsuming;

/**
 Device model.
 */
- (NSString *)deviceModel;

/**
 Device name.
 */
- (NSString *)deviceName;

/**
 Device system version.
 */
- (NSString *)systemVersion;

/**
 Device screen resolution.
 */
- (NSString *)screenResolution;

/**
 Current languageCode.
 */
- (NSString *)languageCode;

/**
 Current battery level.
 */
- (NSString *)batteryLevel;

/**
 Current cpu type.
 */
- (NSString *)cpuType;

/**
 Current disk infos.
 */
- (NSString *)disk;

/**
 Current network state.
 */
- (NSString *)networkState;

/**
 Current ssid.
 */
- (NSString *_Nullable)ssid;

#pragma mark - PRIMARY (This part of the method is used for internal calls, and users do not actively invoke these interfaces, nor need to care about them.)
/**
 Update data traffic when finish a network request.
 */
- (void)updateRequestDataTraffic:(unsigned long long)requestDataTraffic responseDataTraffic:(unsigned long long)responseDataTraffic;

@end

NS_ASSUME_NONNULL_END
