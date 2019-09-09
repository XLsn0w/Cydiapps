//
//  LLWindowManager.m
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

#import "LLWindowManager.h"
#import "LLConfig.h"
#import "UIView+LL_Utils.h"
#import "LLMacros.h"
#import "LLConst.h"
#import "LLThemeManager.h"

static LLWindowManager *_instance = nil;

@interface LLWindowManager ()

@property (nonatomic, strong) LLEntryWindow *entryWindow;

@property (nonatomic, assign) UIWindowLevel presentWindowLevel;

@property (nonatomic, assign) UIWindowLevel normalWindowLevel;

@property (nonatomic, assign) UIWindowLevel entryWindowLevel;

@property (nonatomic, strong) NSMutableArray *visibleWindows;

@property (nonatomic, strong) UIWindow *keyWindow;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@implementation LLWindowManager

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLWindowManager alloc] init];
    });
    return _instance;
}

+ (LLFunctionWindow *)functionWindow {
    return (LLFunctionWindow *)[self createWindowWithClassName:NSStringFromClass([LLFunctionWindow class])];
}

+ (LLMagnifierWindow *)magnifierWindow {
    return (LLMagnifierWindow *)[self createWindowWithClassName:NSStringFromClass([LLMagnifierWindow class])];
}

+ (LLNetworkWindow *)networkWindow {
    return (LLNetworkWindow *)[self createWindowWithClassName:NSStringFromClass([LLNetworkWindow class])];
}

+ (LLLogWindow *)logWindow {
    return (LLLogWindow *)[self createWindowWithClassName:NSStringFromClass([LLLogWindow class])];
}

+ (LLCrashWindow *)crashWindow {
    return (LLCrashWindow *)[self createWindowWithClassName:NSStringFromClass([LLCrashWindow class])];
}

+ (LLAppInfoWindow *)appInfoWindow {
    return (LLAppInfoWindow *)[self createWindowWithClassName:NSStringFromClass([LLAppInfoWindow class])];
}

+ (LLSandboxWindow *)sandboxWindow {
    return (LLSandboxWindow *)[self createWindowWithClassName:NSStringFromClass([LLSandboxWindow class])];
}

+ (LLHierarchyWindow *)hierarchyWindow {
    return (LLHierarchyWindow *)[self createWindowWithClassName:NSStringFromClass([LLHierarchyWindow class])];
}

+ (LLHierarchyPickerWindow *)hierarchyPickerWindow {
    return (LLHierarchyPickerWindow *)[self createWindowWithClassName:NSStringFromClass([LLHierarchyPickerWindow class])];
}

+ (LLHierarchyDetailWindow *)hierarchyDetailWindow {
    return (LLHierarchyDetailWindow *)[self createWindowWithClassName:NSStringFromClass([LLHierarchyDetailWindow class])];
}

+ (LLScreenshotWindow *)screenshotWindow {
    return (LLScreenshotWindow *)[self createWindowWithClassName:NSStringFromClass([LLScreenshotWindow class])];
}

- (void)showEntryWindow {
    [self addWindow:self.entryWindow animated:YES completion:nil];
}

- (void)hideEntryWindow {
    [self removeWindow:self.entryWindow animated:YES automaticallyShowEntry:NO completion:nil];
}

- (void)showWindow:(LLBaseWindow *)window animated:(BOOL)animated {
    [self showWindow:window animated:animated completion:nil];
}

- (void)showWindow:(LLBaseWindow *)window animated:(BOOL)animated completion:(void (^ _Nullable)(void))completion {
    [self addWindow:window animated:animated completion:completion];
}

- (void)hideWindow:(LLBaseWindow *)window animated:(BOOL)animated {
    [self hideWindow:window animated:animated completion:nil];
}

- (void)hideWindow:(LLBaseWindow *)window animated:(BOOL)animated completion:(void (^ _Nullable)(void))completion {
    [self removeWindow:window animated:animated automaticallyShowEntry:YES completion:nil];
}

#pragma mark - Primary
- (instancetype)init {
    if (self = [super init]) {
        self.visibleWindows = [[NSMutableArray alloc] init];
        _presentWindowLevel = UIWindowLevelStatusBar - 200;
        _normalWindowLevel = UIWindowLevelStatusBar - 300;
        _entryWindowLevel = UIWindowLevelStatusBar + 1;
    }
    return self;
}

- (void)addWindow:(LLBaseWindow *)window animated:(BOOL)animated completion:(void (^)(void))completion {
    
    // Avoid call on child thread.
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self addWindow:window animated:animated completion:completion];
        });
        return;
    }
    
    
    if (!window) {
        return;
    }
    [self removeAllVisibleWindows];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (window == self.entryWindow) {
        [self.keyWindow makeKeyWindow];
        self.keyWindow = nil;
        window.hidden = NO;
        window.windowLevel = self.entryWindowLevel;
        [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle];
    } else {
        if (![[UIApplication sharedApplication].keyWindow isKindOfClass:[LLBaseWindow class]]) {
            self.keyWindow = [UIApplication sharedApplication].keyWindow;
            self.statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        }
        [window makeKeyAndVisible];
        window.windowLevel = self.presentWindowLevel;
        [[UIApplication sharedApplication] setStatusBarStyle:[LLThemeManager shared].statusBarStyle animated:animated];
    }
#pragma clang diagnostic pop
    
    [self.visibleWindows addObject:window];
    
    if (animated) {
        __block CGFloat alpha = window.alpha;
        __block CGFloat x = window.LL_x;
        __block CGFloat y = window.LL_y;
        
        switch (window.showAnimateStyle) {
            case LLBaseWindowShowAnimateStyleFade:{
                window.alpha = 0;
            }
                break;
            case LLBaseWindowShowAnimateStylePresent:{
                window.LL_y = LL_SCREEN_HEIGHT;
            }
                break;
            case LLBaseWindowShowAnimateStylePush:{
                window.LL_x = LL_SCREEN_WIDTH;
            }
                break;
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            window.alpha = alpha;
            window.LL_x = x;
            window.LL_y = y;
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        if (completion) {
            completion();
        }
    }
}

- (void)removeWindow:(LLBaseWindow *)window animated:(BOOL)animated automaticallyShowEntry:(BOOL)automaticallyShowEntry completion:(void (^)(void))completion {
    
    // Avoid call on child thread.
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self removeWindow:window animated:animated automaticallyShowEntry:automaticallyShowEntry completion:completion];
        });
        return;
    }
    
    if (!window) {
        return;
    }
    
    [self removeVisibleWindow:window automaticallyShowEntry:automaticallyShowEntry];
    
    if (animated) {
        __block CGFloat alpha = window.alpha;
        __block CGFloat x = window.LL_x;
        __block CGFloat y = window.LL_y;
        [UIView animateWithDuration:0.25 animations:^{
            switch (window.hideAnimateStyle) {
                case LLBaseWindowHideAnimateStyleFade: {
                    window.alpha = 0;
                }
                    break;
                case LLBaseWindowHideAnimateStyleDismiss:{
                    window.LL_y = LL_SCREEN_HEIGHT;
                }
                    break;
                case LLBaseWindowHideAnimateStylePop: {
                    window.LL_x = LL_SCREEN_WIDTH;
                }
                    break;
                default:
                    break;
            }
        } completion:^(BOOL finished) {
            window.hidden = YES;
            window.alpha = alpha;
            window.LL_x = x;
            window.LL_y = y;
            window.windowLevel = self.normalWindowLevel;
            if (completion) {
                completion();
            }
        }];
    } else {
        window.hidden = YES;
        window.windowLevel = self.normalWindowLevel;
        if (completion) {
            completion();
        }
    }
}

- (void)removeAllVisibleWindows {
    for (LLBaseWindow *window in self.visibleWindows) {
        [self removeWindow:window animated:YES automaticallyShowEntry:NO completion:nil];
    }
    [self.visibleWindows removeAllObjects];
}

- (void)removeVisibleWindow:(LLBaseWindow *)window automaticallyShowEntry:(BOOL)automaticallyShowEntry {
    [self.visibleWindows removeObject:window];
    if (automaticallyShowEntry) {
        if (self.visibleWindows.count == 0) {
            [self showEntryWindow];
        }
    }
}

+ (LLBaseWindow *)createWindowWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    NSAssert(cls, ([NSString stringWithFormat:@"%@ can't register a class.",className]));
    __block LLBaseWindow *window = nil;
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
           window = [[cls alloc] initWithFrame:[UIScreen mainScreen].bounds];
        });
    } else {
        window = [[cls alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    NSAssert([window isKindOfClass:[LLBaseWindow class]], ([NSString stringWithFormat:@"%@ isn't a LLBaseWindow class",className]));
    return window;
}

#pragma mark - Lazy
- (LLEntryWindow *)entryWindow {
    if (!_entryWindow) {
        _entryWindow = (LLEntryWindow *)[[self class] createWindowWithClassName:NSStringFromClass([LLEntryWindow class])];
    }
    return _entryWindow;
}

@end
