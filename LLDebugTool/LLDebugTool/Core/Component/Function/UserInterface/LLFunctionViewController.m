//
//  LLFunctionViewController.m
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

#import "LLFunctionViewController.h"
#import "LLFunctionItemModel.h"
#import "LLConfig.h"
#import "LLMacros.h"
#import "LLFactory.h"
#import "LLNetworkViewController.h"
#import "LLLogViewController.h"
#import "LLCrashViewController.h"
#import "LLAppInfoViewController.h"
#import "LLSandboxViewController.h"
#import "LLHierarchyViewController.h"
#import "LLFunctionItemContainerView.h"
#import "UIView+LL_Utils.h"
#import "LLThemeManager.h"
#import "LLConst.h"
#import "LLWindowManager.h"

@interface LLFunctionViewController ()<LLHierarchyViewControllerDelegate, LLFunctionContainerViewControllerDelegate>

@property (nonatomic, strong) LLFunctionItemContainerView *toolContainerView;

@property (nonatomic, strong) LLFunctionItemContainerView *shortCutContainerView;

@property (nonatomic, strong) UIButton *settingButton;

@end

@implementation LLFunctionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect toolContainerRect = CGRectMake(kLLGeneralMargin, LL_NAVIGATION_HEIGHT + kLLGeneralMargin, self.view.LL_width - kLLGeneralMargin * 2, self.toolContainerView.LL_height);
    if (!CGRectEqualToRect(self.toolContainerView.frame, toolContainerRect)) {
        self.toolContainerView.frame = toolContainerRect;
    }
    
    CGRect shortCutContainerRect = CGRectMake(self.toolContainerView.LL_left, self.toolContainerView.LL_bottom + kLLGeneralMargin, self.toolContainerView.LL_width , self.shortCutContainerView.LL_height);
    if (!CGRectEqualToRect(self.shortCutContainerView.frame, shortCutContainerRect)) {
        self.shortCutContainerView.frame = shortCutContainerRect;
    }
    
    CGRect settingButtonRect = CGRectMake(self.toolContainerView.LL_left, self.shortCutContainerView.LL_bottom + 30, self.toolContainerView.LL_width, 40);
    if (!CGRectEqualToRect(self.settingButton.frame, settingButtonRect)) {
        self.settingButton.frame = settingButtonRect;
    }
}

#pragma mark - Primary
- (void)initial {
    self.title = @"LLDebugTool";
 
    self.toolContainerView = [[LLFunctionItemContainerView alloc] initWithFrame:CGRectZero];
    self.toolContainerView.delegate = self;
    [self.view addSubview:self.toolContainerView];
    
    self.shortCutContainerView = [[LLFunctionItemContainerView alloc] initWithFrame:CGRectZero];
    self.shortCutContainerView.delegate = self;
    [self.view addSubview:self.shortCutContainerView];
    
    self.settingButton = [LLFactory getButton:self.view frame:CGRectZero target:self action:@selector(settingButtonClicked:)];
    [self.settingButton LL_setCornerRadius:5];
    [self.settingButton setTitle:@"Settings" forState:UIControlStateNormal];
    [self.settingButton setTitleColor:[LLThemeManager shared].primaryColor forState:UIControlStateNormal];
    [self.settingButton LL_setBorderColor:[LLThemeManager shared].primaryColor borderWidth:1];
    self.settingButton.hidden = YES;
    
    [self loadData];
}

- (void)loadData {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:[[LLFunctionItemModel alloc] initWithAction:LLDebugToolActionNetwork]];
    [items addObject:[[LLFunctionItemModel alloc] initWithAction:LLDebugToolActionLog]];
    [items addObject:[[LLFunctionItemModel alloc] initWithAction:LLDebugToolActionCrash]];
    [items addObject:[[LLFunctionItemModel alloc] initWithAction:LLDebugToolActionAppInfo]];
    [items addObject:[[LLFunctionItemModel alloc] initWithAction:LLDebugToolActionSandbox]];
    
    self.toolContainerView.dataArray = [items copy];
    self.toolContainerView.title = @"Function";
    
    [items removeAllObjects];
    
    [items addObject:[[LLFunctionItemModel alloc] initWithAction:LLDebugToolActionScreenshot]];
    [items addObject:[[LLFunctionItemModel alloc] initWithAction:LLDebugToolActionHierarchy]];
    [items addObject:[[LLFunctionItemModel alloc] initWithAction:LLDebugToolActionMagnifier]];
    
    self.shortCutContainerView.dataArray = [items copy];
    self.shortCutContainerView.title = @"Short Cut";
}

- (void)settingButtonClicked:(UIButton *)sender {
    
}

#pragma mark - LLFunctionContainerViewDelegate
- (void)llFunctionContainerView:(LLFunctionItemContainerView *)view didSelectAt:(LLFunctionItemModel *)model {
    LLComponent *component = model.component;
    [component componentDidLoad:nil];
}

#pragma mark - LLHierarchyViewControllerDelegate
- (void)LLHierarchyViewController:(LLHierarchyViewController *)viewController didFinishWithSelectedModel:(LLHierarchyModel *)selectedModel {
    [self.delegate LLFunctionViewController:self didSelectedHierarchyModel:selectedModel];
}

@end
