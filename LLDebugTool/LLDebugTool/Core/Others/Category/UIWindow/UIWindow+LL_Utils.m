//
//  UIWindow+LL_Utils.m
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

#import "UIWindow+LL_Utils.h"
#import "UIViewController+LL_Utils.h"
#import "NSObject+LL_Runtime.h"

@implementation UIWindow (LL_Utils)

+ (void)load {
//    NSString *canAffectSelectorString = @"_canAffectStatusBarAppearance";
//    SEL canAffectSelector = NSSelectorFromString(canAffectSelectorString);
    
    NSString *canBecomeKeySelectorString = @"_canBecomeKeyWindow";
    SEL canBecomeKeySelector = NSSelectorFromString(canBecomeKeySelectorString);
    
//    [self LL_swizzleInstanceMethodWithOriginSel:canAffectSelector swizzledSel:@selector(_LL_canAffectStatusBarAppearance)];
    [self LL_swizzleInstanceMethodWithOriginSel:canBecomeKeySelector swizzledSel:@selector(_LL_canBecomeKeyWindow)];
}

- (UIViewController *)LL_currentShowingViewController {
    UIViewController *vc = [self.rootViewController LL_currentShowingViewController];
    if (vc == nil) {
        vc = self.rootViewController;
    }
    return vc;
}

- (BOOL)LL_canBecomeKeyWindow {
    return [self _LL_canBecomeKeyWindow];
}

#pragma mark - Primary
- (BOOL)_LL_canBecomeKeyWindow {
    return [self LL_canBecomeKeyWindow];
}

@end
