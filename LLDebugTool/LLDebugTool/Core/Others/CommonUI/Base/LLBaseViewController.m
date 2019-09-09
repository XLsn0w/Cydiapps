//
//  LLBaseViewController.m
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

#import "LLBaseViewController.h"
#import "LLImageNameConfig.h"
#import "LLMacros.h"
#import "LLConfig.h"
#import "LLFactory.h"
#import "LLThemeManager.h"

@interface LLBaseViewController ()

@end

@implementation LLBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self baseInitial];
}

#pragma mark - Public
- (void)showAlertControllerWithMessage:(NSString *)message handler:(void (^)(NSInteger action))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Note" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        if (handler) {
            handler(0);
        }
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        if (handler) {
            handler(1);
        }
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)leftItemClick:(UIButton *)sender {
    
}

- (void)rightItemClick:(UIButton *)sender {
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}

- (void)initNavigationItemWithTitle:(NSString *_Nullable)title imageName:(NSString *_Nullable)imageName isLeft:(BOOL)flag {
    if (flag) {
        UIButton *btn = [self navigationButtonWithTitle:title imageName:imageName target:self action:@selector(leftItemClick:)];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.leftNavigationButton = btn;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    } else {
        UIButton *btn = [self navigationButtonWithTitle:title imageName:imageName target:self action:@selector(rightItemClick:)];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.rightNavigationButton = btn;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
}

#pragma mark - Primary
- (void)baseInitial {
    [self resetDefaultSettings];
    self.view.backgroundColor = [LLThemeManager shared].backgroundColor;
    [self initNavigationItems];
}

- (void)initNavigationItems {
    if (self.navigationController) {
        self.navigationItem.hidesBackButton = YES;
        if (self.navigationController.viewControllers.count <= 1) {
            [self initNavigationItemWithTitle:nil imageName:kCloseImageName isLeft:YES];
        } else {
            UIButton *btn = [self navigationButtonWithTitle:nil imageName:kBackImageName target:self action:@selector(backAction:)];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        }
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [LLThemeManager shared].primaryColor}];
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.navigationBar.tintColor = [LLThemeManager shared].primaryColor;
    }
}

- (void)resetDefaultSettings {
    // Used to solve problems caused by modifying some systems default values with Runtime in the project.
    // Hopefully you changed these defaults at runtime in viewDidLoad, not viewWillAppear or viewDidAppear
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.automaticallyAdjustsScrollViewInsets = YES;
#pragma clang diagnostic pop
    self.navigationController.navigationBar.translucent = YES;
}

- (UIButton *)navigationButtonWithTitle:(NSString *_Nullable)title imageName:(NSString *_Nullable)imageName target:(id _Nullable)target action:(SEL _Nullable)action {
    UIButton *btn = [LLFactory getButton:nil frame:CGRectMake(0, 0, 40, 40) target:target action:action];
    btn.showsTouchWhenHighlighted = NO;
    btn.tintColor = [LLThemeManager shared].primaryColor;
    if ([title length]) {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    if (imageName) {
        UIImageRenderingMode mode = UIImageRenderingModeAlwaysTemplate;
        [btn setImage:[[UIImage LL_imageNamed:imageName] imageWithRenderingMode:mode] forState:UIControlStateNormal];
    }
    return btn;
}

- (void)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
