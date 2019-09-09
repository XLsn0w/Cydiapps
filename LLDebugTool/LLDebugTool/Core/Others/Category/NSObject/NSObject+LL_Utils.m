//
//  NSObject+LL_Utils.m
//
//  Copyright (c) 2018 LLBaseFoundation Software Foundation (https://github.com/HDB-Li/LLBaseFoundation)
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

#import "NSObject+LL_Utils.h"
#import <mach-o/arch.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import "LLFormatterTool.h"

static uint64_t _loadTime;
static NSTimeInterval _startLoadTime;
static uint64_t _loadDate;
static uint64_t _applicationRespondedTime = -1;
static mach_timebase_info_data_t _timebaseInfo;
static NSString *_launchDate = nil;

static inline NSTimeInterval MachTimeToSeconds(uint64_t machTime) {
    return ((machTime / 1e9) * _timebaseInfo.numer) / _timebaseInfo.denom;
}

@implementation NSObject (LL_Utils)

/**
 Record the launch time of App.
 */
+ (void)load {
    _loadTime = mach_absolute_time();
    mach_timebase_info(&_timebaseInfo);
    
    _loadDate = [[NSDate date] timeIntervalSince1970];
    
    @autoreleasepool {
        __block __weak id<NSObject> obs;
        obs = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                                object:nil queue:nil
                                                            usingBlock:^(NSNotification *note) {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    _applicationRespondedTime = mach_absolute_time();
                                                                    _startLoadTime = MachTimeToSeconds(_applicationRespondedTime - _loadTime);
                                                                });
                                                                [[NSNotificationCenter defaultCenter] removeObserver:obs];
                                                            }];
    }
}

+ (NSString *)LL_launchDate {
    if (!_launchDate) {
        _launchDate = [[LLFormatterTool shared] stringFromDate:[NSDate dateWithTimeIntervalSince1970:_loadDate] style:FormatterToolDateStyle3];
        if (!_launchDate) {
            _launchDate = @"";
        }
    }
    return _launchDate;
}

+ (NSTimeInterval)LL_startLoadTime {
    return _startLoadTime;
}

- (UIColor *)LL_hashColor {
    CGFloat hue = ((self.hash >> 4) % 256) / 255.0;
    return [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
}

@end
