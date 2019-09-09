//
//  LLConfig.m
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

#import "LLConfig.h"
#import "LLFactory.h"
#import "LLConst.h"
#import "LLThemeManager.h"
#import "LLTool.h"
#import "LLDebugTool.h"
#import "LLNetworkHelper.h"
#import "LLLogHelper.h"
#import "LLCrashHelper.h"
#import "LLAppInfoHelper.h"
#import "LLScreenshotHelper.h"

static LLConfig *_instance = nil;

NSNotificationName const LLConfigDidUpdateWindowStyleNotificationName = @"LLConfigDidUpdateWindowStyleNotificationName";

@implementation LLConfig

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLConfig alloc] init];
        [_instance initial];
    });
    return _instance;
}

- (void)setColorStyle:(LLConfigColorStyle)colorStyle {
    if (colorStyle != LLConfigColorStyleCustom) {
        _colorStyle = colorStyle;
        [self updateColor];
    }
}

- (void)setEntryWindowStyle:(LLConfigEntryWindowStyle)entryStyle {
    if (_entryWindowStyle != entryStyle) {
        _entryWindowStyle = entryStyle;
        [[NSNotificationCenter defaultCenter] postNotificationName:LLConfigDidUpdateWindowStyleNotificationName object:nil userInfo:nil];
    }
}

- (void)setAvailables:(LLConfigAvailableFeature)availables {
    if (_availables != availables) {
        BOOL networkEnable = availables & LLConfigAvailableNetwork;
        BOOL logEnable = availables & LLConfigAvailableLog;
        BOOL crashEnable = availables & LLConfigAvailableCrash;
        BOOL appInfoEnable = availables & LLConfigAvailableAppInfo;
        BOOL sandboxEnable = availables & LLConfigAvailableSandbox;
        BOOL screenshotEnable = availables & LLConfigAvailableScreenshot;
        BOOL hierarchyEnable = availables & LLConfigAvailableHierarchy;
        if (!networkEnable && !logEnable && !crashEnable && !appInfoEnable && !sandboxEnable && !screenshotEnable && !hierarchyEnable) {
            // Can't set none availables.
            return;
        }
        BOOL allEnable = networkEnable && logEnable && crashEnable && appInfoEnable && sandboxEnable && screenshotEnable && hierarchyEnable;
        if (allEnable && (availables != LLConfigAvailableAll)) {
            // Check if input wrong.
            _availables = LLConfigAvailableAll;
        } else {
            _availables = availables;
        }
        // Start or close features.
        if ([LLDebugTool sharedTool].isWorking) {
            BOOL networkEnable = availables & LLConfigAvailableNetwork;
            BOOL logEnable = availables & LLConfigAvailableLog;
            BOOL crashEnable = availables & LLConfigAvailableCrash;
            BOOL appInfoEnable = availables & LLConfigAvailableAppInfo;
            BOOL screenshotEnable = availables & LLConfigAvailableScreenshot;
            [[LLNetworkHelper shared] setEnable:networkEnable];
            [[LLLogHelper shared] setEnable:logEnable];
            [[LLCrashHelper shared] setEnable:crashEnable];
            [[LLAppInfoHelper shared] setEnable:appInfoEnable];
            [[LLScreenshotHelper shared] setEnable:screenshotEnable];
        }
    }
}

- (void)configBackgroundColor:(UIColor *)backgroundColor primaryColor:(UIColor *)primaryColor statusBarStyle:(UIStatusBarStyle)statusBarStyle {
    _colorStyle = LLConfigColorStyleCustom;
    [[LLThemeManager shared] setPrimaryColor:primaryColor];
    [[LLThemeManager shared] setBackgroundColor:backgroundColor];
    [[LLThemeManager shared] setStatusBarStyle:statusBarStyle];
}

- (void)configStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [LLThemeManager shared].statusBarStyle = statusBarStyle;
}

- (CGFloat)suspensionBallWidth {
    return MAX(_suspensionBallWidth, kLLSuspensionWindowMinWidth);
}

- (void)setMagnifierSize:(NSInteger)magnifierSize {
    if (_magnifierSize != magnifierSize) {
        if (magnifierSize % 2 == 0) {
            _magnifierSize = magnifierSize + 1;
        } else {
            _magnifierSize = magnifierSize;
        }
    }
}

#pragma mark - Primary
/**
 Initialize something.
 */
- (void)initial {
    // Set internal
    _showDebugToolLog = YES;
    
    // Set default values
    // Set folder Path
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _folderPath = [doc stringByAppendingPathComponent:@"LLDebugTool"];
    
    // Set XIB resources.
    _XIBBundle = [NSBundle bundleForClass:self.class];
    NSString *imageBundlePath = [[NSBundle bundleForClass:self.class] pathForResource:@"LLDebugTool" ofType:@"bundle"];
    _imageBundle = [NSBundle bundleWithPath:imageBundlePath];
    if (!_XIBBundle) {
        [LLTool log:@"Failed to load the XIB bundle"];
    }
    if (!_imageBundle) {
        [LLTool log:@"Failed to load the image bundle"];
    }
    
    // Set date formatter string.
    _dateFormatter = @"yyyy-MM-dd HH:mm:ss";
    
    // Set default color style.
    _colorStyle = LLConfigColorStyleHack;
    
    // Set default suspension ball attributes.
    _suspensionBallWidth = kLLSuspensionWindowWidth;
    _suspensionWindowHideWidth = kLLSuspensionWindowHideWidth;
    _suspensionWindowTop = kLLSuspensionWindowTop;
    _normalAlpha = kLLSuspensionWindowNormalAlpha;
    _activeAlpha = kLLSuspensionWindowActiveAlpha;
    _suspensionBallMoveable = YES;
    _autoAdjustSuspensionWindow = YES;
    
    // Set default magnifier properties.
    _magnifierZoomLevel = kLLMagnifierWindowZoomLevel;
    _magnifierSize = kLLMagnifierWindowSize;
    
    // Show LLDebugTool's log.
    _autoCheckDebugToolVersion = YES;
    
    // Set log style.
    _logStyle = LLConfigLogDetail;
    
    // Set default window's style.
    _entryWindowStyle = LLConfigEntryWindowStyleSuspensionBall;
    
    // Set default availables.
    _availables = LLConfigAvailableAll;
    
    // Update color.
    [self updateColor];
}

- (void)updateColor {
    switch (self.colorStyle) {
        case LLConfigColorStyleSimple:{
            [[LLThemeManager shared] setPrimaryColor:[UIColor darkTextColor]];
            [[LLThemeManager shared] setBackgroundColor:[UIColor whiteColor]];
            [[LLThemeManager shared] setStatusBarStyle:UIStatusBarStyleDefault];
        }
            break;
        case LLConfigColorStyleSystem: {
            [[LLThemeManager shared] setPrimaryColor:[LLThemeManager shared].systemTintColor];
            [[LLThemeManager shared] setBackgroundColor:[UIColor whiteColor]];
            [[LLThemeManager shared] setStatusBarStyle:UIStatusBarStyleDefault];
        }
            break;
        case LLConfigColorStyleCustom:{
            
        }
            break;
        case LLConfigColorStyleHack:
        default:{
            [[LLThemeManager shared] setPrimaryColor:[UIColor greenColor]];
            [[LLThemeManager shared] setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]];
            [[LLThemeManager shared] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
            break;
    }
}

@end
