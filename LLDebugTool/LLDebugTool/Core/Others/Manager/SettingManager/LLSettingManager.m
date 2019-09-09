//
//  LLSettingManager.m
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

#import "LLSettingManager.h"
#import "LLFunctionComponent.h"
#import "LLConst.h"

static LLSettingManager *_instance = nil;

@interface LLSettingManager ()

@property (nonatomic, copy) NSString *entryViewDoubleClickComponentKey;

@end

@implementation LLSettingManager

@synthesize entryViewClickComponent = _entryViewClickComponent;
@synthesize entryViewDoubleClickComponent = _entryViewDoubleClickComponent;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLSettingManager alloc] init];
        [_instance initial];
    });
    return _instance;
}

#pragma mark - Primary
- (void)initial {
    _entryViewDoubleClickComponentKey = @"entryViewDoubleClickComponentKey";
}

- (LLComponent *)entryViewClickComponent {
    if (!_entryViewClickComponent) {
        _entryViewClickComponent = [[LLFunctionComponent alloc] init];
    }
    return _entryViewClickComponent;
}

- (LLComponent *)entryViewDoubleClickComponent {
    if (!_entryViewDoubleClickComponent) {
        NSString *componentName = [self stringForKey:_entryViewDoubleClickComponentKey];
        Class cls = NSClassFromString(componentName);
        if (cls == nil || ![cls isKindOfClass:[LLComponent class]]) {
            cls = NSClassFromString(kLLEntryViewDoubleClickComponent);
        }
        _entryViewDoubleClickComponent = [[cls alloc] init];
    }
    return _entryViewDoubleClickComponent;
}

- (void)setEntryViewDoubleClickComponent:(LLComponent *)entryViewDoubleClickComponent {
    if (_entryViewDoubleClickComponent != entryViewDoubleClickComponent) {
        _entryViewDoubleClickComponent = entryViewDoubleClickComponent;
        [self synchronizeSetString:NSStringFromClass(entryViewDoubleClickComponent.class) forKey:_entryViewDoubleClickComponentKey];
    }
}

- (NSString *_Nullable)stringForKey:(NSString *)aKey {
    return [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"LLDebugTool-%@",aKey]];
}

- (void)synchronizeSetString:(NSString *)string forKey:(NSString *)aKey {
    [[NSUserDefaults standardUserDefaults] setObject:string forKey:[NSString stringWithFormat:@"LLDebugTool-%@",aKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
