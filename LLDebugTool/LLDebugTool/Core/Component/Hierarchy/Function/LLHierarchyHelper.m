//
//  LLHierarchyHelper.m
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

#import "LLHierarchyHelper.h"

static LLHierarchyHelper *_instance = nil;

@implementation LLHierarchyHelper

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLHierarchyHelper alloc] init];
    });
    return _instance;
}

- (NSArray <UIWindow *>*)allWindows {
    return [self allWindowsIgnoreClass:nil];
}

- (NSArray <UIWindow *>*)allWindowsIgnoreClass:(Class)cls {
    BOOL includeInternalWindows = YES;
    BOOL onlyVisibleWindows = NO;
    
    SEL allWindowsSelector = NSSelectorFromString(@"allWindowsIncludingInternalWindows:onlyVisibleWindows:");
    
    NSMethodSignature *methodSignature = [[UIWindow class] methodSignatureForSelector:allWindowsSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    
    invocation.target = [UIWindow class];
    invocation.selector = allWindowsSelector;
    [invocation setArgument:&includeInternalWindows atIndex:2];
    [invocation setArgument:&onlyVisibleWindows atIndex:3];
    [invocation invoke];
    
    __unsafe_unretained NSArray<UIWindow *> *windows = nil;
    [invocation getReturnValue:&windows];
    
    windows = [windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow * obj1, UIWindow * obj2) {
        return obj1.windowLevel > obj2.windowLevel;
    }];
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:windows];
    NSMutableArray *removeResults = [[NSMutableArray alloc] init];
    if (cls != nil) {
        for (UIWindow *window in results) {
            if ([window isKindOfClass:cls]) {
                [removeResults addObject:window];
            }
        }
    }
    [results removeObjectsInArray:removeResults];
    
    return [NSArray arrayWithArray:results];
}

- (LLHierarchyModel *)hierarchyInApplication {
    NSMutableArray <LLHierarchyModel *>*allViews = [NSMutableArray array];
    NSArray <UIWindow *>*windows = [self allWindows];
    for (int i = 0; i < windows.count; i++) {
        UIWindow *window = windows[i];
        [allViews addObject:[self hierarchyInView:window section:0 row:i]];
    }
    LLHierarchyModel *model = [[LLHierarchyModel alloc] initWithSubModels:allViews];
    return model;
}

- (LLHierarchyModel *)hierarchyInView:(UIView *)view {
    return [self hierarchyInView:view section:0 row:0];
}

#pragma mark - Primary
- (LLHierarchyModel *)hierarchyInView:(UIView *)view section:(NSInteger)section row:(NSInteger)row {
    NSMutableArray *subModels = [[NSMutableArray alloc] init];
    for (int i = 0; i < view.subviews.count; i++) {
        UIView *subView = view.subviews[i];
        [subModels addObject:[self hierarchyInView:subView section:section + 1 row:i]];
    }
    return [[LLHierarchyModel alloc] initWithView:view section:section row:row subModels:subModels];
}

@end
