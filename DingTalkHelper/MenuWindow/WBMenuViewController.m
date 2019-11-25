//
//  WBMenuViewController.m
//  FlowWindow
//
//  Created by buginux on 2017/7/27.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import "WBMenuViewController.h"
#import "WBGlobalSettingViewController.h"
#import "WBMenuView.h"

@interface WBMenuViewController () <WBGlobalSettingViewControllerDelegate>

@property (nonatomic, strong) WBMenuView *menu;

/// Gesture recognizer for dragging a view in move mode
@property (nonatomic, strong) UIPanGestureRecognizer *movePanGR;

/// Only valid while a move pan gesture is in progress.
@property (nonatomic, assign) CGRect menuFrameBeforeDragging;

/// Tracked so we can restore the key window after dismissing a modal.
/// We need to become key after modal presentation so we can correctly capture intput.
/// If we're just showing the toolbar, we want the main app's window to remain key so that we don't interfere with input, status bar, etc.
@property (nonatomic, strong) UIWindow *previousKeyWindow;

/// Similar to the previousKeyWindow property above, we need to track status bar styling if
/// the app doesn't use view controller based status bar management. When we present a modal,
/// we want to change the status bar style to UIStausBarStyleDefault. Before changing, we stash
/// the current style. On dismissal, we return the staus bar to the style that the app was using previously.
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

@end

@implementation WBMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMenu];
    [self setupMenuActions];
    
    // View moving
    self.movePanGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMovePan:)];
    [self.view addGestureRecognizer:self.movePanGR];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)setupMenu {
    self.menu = [[WBMenuView alloc] init];
    [self.menu sizeToFit];
    
    CGRect frame = self.menu.frame;
    frame.origin.x = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(self.menu.frame);
    frame.origin.y = 100;
    self.menu.frame = frame;
    
    self.menu.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view addSubview:self.menu];
}

- (void)setupMenuActions {
    [self.menu.menuButton addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.menu.closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)menuButtonTapped:(UIButton *)sender {
    [self toggleSettingViewController];
}

- (void)closeButtonTapped:(UIButton *)sender {
    [self.delegate menuViewControllerDidFinish:self];
}

- (void)handleMovePan:(UIPanGestureRecognizer *)movePanGR {
    switch (movePanGR.state) {
        case UIGestureRecognizerStateBegan:
            self.menuFrameBeforeDragging = self.menu.frame;
            [self updateMenuPositionWithDragGesture:movePanGR];
            break;
            
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
            [self updateMenuPositionWithDragGesture:movePanGR];
            break;
            
        default:
            break;
    }
}

- (UIWindow *)statusWindow {
    NSString *statusBarString = [NSString stringWithFormat:@"%@arWindow", @"_statusB"];
    return [[UIApplication sharedApplication] valueForKey:statusBarString];
}

- (void)updateMenuPositionWithDragGesture:(UIPanGestureRecognizer *)movePanGR {
    CGPoint translation = [movePanGR translationInView:self.menu.superview];
    CGRect newSelectedViewFrame = self.menuFrameBeforeDragging;
    newSelectedViewFrame.origin.x = newSelectedViewFrame.origin.x + translation.x;
    newSelectedViewFrame.origin.y = newSelectedViewFrame.origin.y + translation.y;
    self.menu.frame = newSelectedViewFrame;
}

- (void)toggleSettingViewController {
    BOOL menuModalShown = [[self presentedViewController] isKindOfClass:[UINavigationController class]];
    menuModalShown = menuModalShown && [[[(UINavigationController *)[self presentedViewController] viewControllers] firstObject] isKindOfClass:[WBGlobalSettingViewController class]];
    if (menuModalShown) {
        [self resignKeyAndDismissViewControllerAnimated:YES completion:nil];
    } else {
        void (^presentBlock)() = ^{
            WBGlobalSettingViewController *settingViewController = [[WBGlobalSettingViewController alloc] init];
            settingViewController.delegate = self;
            [WBGlobalSettingViewController setApplicationWindow:[[UIApplication sharedApplication] keyWindow]];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingViewController];
            [self makeKeyAndPresentViewController:navigationController animated:YES completion:nil];
        };
        
        if (self.presentedViewController) {
            [self resignKeyAndDismissViewControllerAnimated:NO completion:presentBlock];
        } else {
            presentBlock();
        }
    }
}

#pragma mark - Touch Handling

- (BOOL)shouldReceiveTouchAtWindowPoint:(CGPoint)pointInWindowCoordinates {
    BOOL shouldReceiveTouch = NO;
    
    CGPoint pointInLocalCoordinates = [self.view convertPoint:pointInWindowCoordinates fromView:nil];
    
    // Always if it's on the menu
    if (CGRectContainsPoint(self.menu.frame, pointInLocalCoordinates)) {
        shouldReceiveTouch = YES;
    }
    
    // Always if we have a modal presented
    if (!shouldReceiveTouch && self.presentedViewController) {
        shouldReceiveTouch = YES;
    }
    
    return shouldReceiveTouch;
}

#pragma mark - WBGlobalSettingViewControllerDelegate

- (void)globalSettingViewControllerDidFinish:(WBGlobalSettingViewController *)controller {
    [self resignKeyAndDismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Modal Presentation and Window Management

- (void)makeKeyAndPresentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    // Save the current key window so we can restore it following dismissal.
    self.previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    // Make our window key to correctly handle input.
    [self.view.window makeKeyWindow];
    
    // Move the status bar on top of FLEX so we can get scroll to top behavior for taps.
    [[self statusWindow] setWindowLevel:self.view.window.windowLevel + 1.0];
    
    // If this app doesn't use view controller based status bar management and we're on iOS 7+,
    // make sure the status bar style is UIStatusBarStyleDefault. We don't actully have to check
    // for view controller based management because the global methods no-op if that is turned on.
    self.previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // Show the view controller.
    [self presentViewController:viewController animated:animated completion:completion];
}

- (void)resignKeyAndDismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    UIWindow *previousKeyWindow = self.previousKeyWindow;
    self.previousKeyWindow = nil;
    [previousKeyWindow makeKeyWindow];
    [[previousKeyWindow rootViewController] setNeedsStatusBarAppearanceUpdate];
    
    // Restore the status bar window's normal window level.
    // We want it above FLEX while a modal is presented for scroll to top, but below FLEX otherwise for exploration.
    [[self statusWindow] setWindowLevel:UIWindowLevelStatusBar];
    
    // Restore the stauts bar style if the app is using global status bar management.
    [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle];
    
    [self dismissViewControllerAnimated:animated completion:completion];
}

- (BOOL)wantsWindowToBecomeKey {
    return self.previousKeyWindow != nil;
}

@end
