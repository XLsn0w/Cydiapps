//
//  WBAssistantManager.m
//  FlowWindow
//
//  Created by buginux on 2017/7/27.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import "WBAssistantManager.h"
#import "WBWindow.h"
#import "WBMenuViewController.h"

@interface WBAssistantManager () <WBWindowEventDelegate, WBMenuViewControllerDelegate>

@property (nonatomic, strong) WBWindow *menuWindow;
@property (nonatomic, strong) WBMenuViewController *menuViewController;

@end

@implementation WBAssistantManager

+ (instancetype)sharedManager {
    static WBAssistantManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (WBWindow *)menuWindow {
    NSAssert([NSThread isMainThread], @"You must use %@ from the main thread only.", NSStringFromClass([self class]));
    if (!_menuWindow) {
        _menuWindow = [[WBWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _menuWindow.eventDelegate = self;
        _menuWindow.rootViewController = self.menuViewController;
    }
    return _menuWindow;
}

- (WBMenuViewController *)menuViewController {
    if (!_menuViewController) {
        _menuViewController = [[WBMenuViewController alloc] init];
        _menuViewController.delegate = self;
    }
    return _menuViewController;
}

- (void)showMenu {
    self.menuWindow.hidden = NO;
}

- (void)hideMenu {
    self.menuWindow.hidden = YES;
}

- (void)toggleMenu {
    if (self.menuWindow.isHidden) {
        [self showMenu];
    } else {
        [self hideMenu];
    }
}

#pragma mark - WBWindowEventDelegate

- (BOOL)shouldHandleTouchAtPoint:(CGPoint)pointInWindow {
    return [self.menuViewController shouldReceiveTouchAtWindowPoint:pointInWindow];
}

- (BOOL)canBecomeKeyWindow {
    return [self.menuViewController wantsWindowToBecomeKey];
}

#pragma mark - WBMenuViewControllerDelegate

- (void)menuViewControllerDidFinish:(WBMenuViewController *)menuViewController {
    [self hideMenu];
}

@end
