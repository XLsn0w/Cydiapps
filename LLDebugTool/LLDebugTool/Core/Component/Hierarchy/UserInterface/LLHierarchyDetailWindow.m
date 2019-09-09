//
//  LLHierarchyDetailWindow.m
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

#import "LLHierarchyDetailWindow.h"
#import "LLHierarchyDetailViewController.h"
#import "LLNavigationController.h"
#import "LLWindowManager.h"

@implementation LLHierarchyDetailWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)setSelectView:(UIView *)selectView {
    LLNavigationController *nav = (LLNavigationController *)self.rootViewController;
    LLHierarchyDetailViewController *vc = (LLHierarchyDetailViewController *)[nav.viewControllers firstObject];
    vc.selectView = selectView;
}

- (UIView *)selectView {
    LLNavigationController *nav = (LLNavigationController *)self.rootViewController;
    LLHierarchyDetailViewController *vc = (LLHierarchyDetailViewController *)[nav.viewControllers firstObject];
    return vc.selectView;
}

#pragma mark - Primary
- (void)initial {
    if (!self.rootViewController) {
        self.rootViewController = [[LLNavigationController alloc] initWithRootViewController:[[LLHierarchyDetailViewController alloc] init]];
    }
}

@end
