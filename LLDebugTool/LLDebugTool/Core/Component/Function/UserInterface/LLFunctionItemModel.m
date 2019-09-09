//
//  LLFunctionItemModel.m
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

#import "LLFunctionItemModel.h"
#import "LLNetworkComponent.h"
#import "LLLogComponent.h"
#import "LLNetworkComponent.h"
#import "LLAppInfoComponent.h"
#import "LLCrashComponent.h"
#import "LLSandboxComponent.h"
#import "LLScreenshotComponent.h"
#import "LLHierarchyComponent.h"
#import "LLMagnifierComponent.h"
#import "LLImageNameConfig.h"

@implementation LLFunctionItemModel

- (instancetype _Nonnull )initWithAction:(LLDebugToolAction)action {
    if (self = [super init]) {
        _action = action;
        _imageName = [self imageNameFromAction:action];
        _title = [self titleFromAction:action];
        _component = [self componentFromAction:action];
    }
    return self;
}

- (LLComponent *)componentFromAction:(LLDebugToolAction)action {
    switch (action) {
        case LLDebugToolActionNetwork:
            return [[LLNetworkComponent alloc] init];
        case LLDebugToolActionLog:
            return [[LLLogComponent alloc] init];
        case LLDebugToolActionCrash:
            return [[LLCrashComponent alloc] init];
        case LLDebugToolActionAppInfo:
            return [[LLAppInfoComponent alloc] init];
        case LLDebugToolActionSandbox:
            return [[LLSandboxComponent alloc] init];
        case LLDebugToolActionScreenshot:
            return [[LLScreenshotComponent alloc] init];
        case LLDebugToolActionHierarchy:
            return [[LLHierarchyComponent alloc] init];
        case LLDebugToolActionMagnifier:
            return [[LLMagnifierComponent alloc] init];
    }
}

- (NSString *)titleFromAction:(LLDebugToolAction)action {
    switch (action) {
        case LLDebugToolActionNetwork:
            return @"Net";
        case LLDebugToolActionLog:
            return @"Log";
        case LLDebugToolActionCrash:
            return @"Crash";
        case LLDebugToolActionAppInfo:
            return @"App Info";
        case LLDebugToolActionSandbox:
            return @"Sandbox";
        case LLDebugToolActionScreenshot:
            return @"Screenshot";
        case LLDebugToolActionHierarchy:
            return @"Hierarchy";
        case LLDebugToolActionMagnifier:
            return @"Magnifier";
    }
}

- (NSString *)imageNameFromAction:(LLDebugToolAction)action {
    switch (action) {
        case LLDebugToolActionNetwork:
            return kNetworkImageName;
        case LLDebugToolActionLog:
            return kLogImageName;
        case LLDebugToolActionCrash:
            return kCrashImageName;
        case LLDebugToolActionAppInfo:
            return kAppImageName;
        case LLDebugToolActionSandbox:
            return kSandboxImageName;
        case LLDebugToolActionScreenshot:
            return kScreenshotImageName;
        case LLDebugToolActionHierarchy:
            return kHierarchyImageName;
        case LLDebugToolActionMagnifier:
            return kMagnifierImageName;
    }
}

@end
