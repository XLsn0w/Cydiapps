//
//  LLHierarchyExplorerToolBar.m
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

#import "LLHierarchyExplorerToolBar.h"
#import "LLConfig.h"
#import "LLImageNameConfig.h"
#import "LLHierarchyModel.h"
#import "LLMacros.h"
#import "LLTool.h"
#import "LLFactory.h"
#import "UIView+LL_Utils.h"
#import "NSObject+LL_Utils.h"
#import "LLThemeManager.h"

@interface LLHierarchyExplorerToolBar () <UITabBarDelegate>

@property (nonatomic, strong) UITabBar *tabBar;

@property (nonatomic, strong) UIPanGestureRecognizer *panGR;

@property (nonatomic, strong) UIView *descriptionBackgroundView;

@property (nonatomic, strong) UIView *descriptionTintView;

@property (nonatomic, strong) UILabel *descriptionLabel;

@end

@implementation LLHierarchyExplorerToolBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initial];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initial];
    }
    return self;
}

- (void)confirmWithView:(UIView *)selectView {
    self.descriptionTintView.backgroundColor = selectView.LL_hashColor;
    self.descriptionLabel.text = [NSString stringWithFormat:@"%@, %@",NSStringFromClass(selectView.class),[LLTool stringFromFrame:selectView.frame]];
}

#pragma mark - Primary
- (void)initial {
    
    self.tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, LL_SCREEN_WIDTH, 49)];
    self.tabBar.tintColor = [LLThemeManager shared].primaryColor;
    self.tabBar.barTintColor = [LLThemeManager shared].backgroundColor;
    self.tabBar.delegate = self;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:[self itemWithTitle:@"Views" imageName:kPickImageName]];
    self.selectItem = [self itemWithTitle:@"Select" imageName:kPickImageName];
    [items addObject:self.selectItem];
    self.moveItem = [self itemWithTitle:@"Move" imageName:kPickImageName];
    [items addObject:self.moveItem];
    [items addObject:[self itemWithTitle:@"Close" imageName:kPickImageName]];
    [self.tabBar setItems:items];
    [self addSubview:self.tabBar];
    
    self.descriptionBackgroundView = [LLFactory getBackgroundView:self frame:CGRectMake(0, 49, LL_SCREEN_WIDTH, 30) alpha:[LLConfig shared].normalAlpha];
    
    CGFloat itemsMargin = 15;
    CGFloat tintWidth = 15;
    CGRect tintViewFrame = CGRectMake(itemsMargin, (self.descriptionBackgroundView.frame.size.height - tintWidth) / 2.0, tintWidth, tintWidth);
    self.descriptionTintView = [LLFactory getView:self.descriptionBackgroundView frame:tintViewFrame];
    [self.descriptionTintView LL_setCornerRadius:tintWidth / 2.0];
    
    CGFloat labelLeftMargin = tintViewFrame.origin.x + tintViewFrame.size.width + itemsMargin;
    self.descriptionLabel = [LLFactory getLabel:self.descriptionBackgroundView frame:CGRectMake(labelLeftMargin, 0, LL_SCREEN_WIDTH - labelLeftMargin - itemsMargin, self.descriptionBackgroundView.frame.size.height) text:nil font:2 textColor:[LLThemeManager shared].primaryColor];
    self.descriptionLabel.numberOfLines = 2;
    self.descriptionLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGRHandle:)];
    [self addGestureRecognizer:self.panGR];
}

- (void)panGRHandle:(UIPanGestureRecognizer *)sender {
    [self.delegate LLHierarchyExplorerToolBar:self handlePanOffset:[sender translationInView:self]];
    [sender setTranslation:CGPointZero inView:self];
}

- (UITabBarItem *)itemWithTitle:(NSString *)title imageName:(NSString *)imageName {
    return [[UITabBarItem alloc] initWithTitle:title image:[UIImage LL_imageNamed:imageName] selectedImage:nil];
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self.delegate LLHierarchyExplorerToolBar:self didSelectIndex:[tabBar.items indexOfObject:item]];
}

#pragma mark - Override
- (NSInteger)selectedIndex {
    return [self.tabBar.items indexOfObject:self.selectedItem];
}

- (void)setSelectedItem:(UITabBarItem *)selectedItem {
    self.tabBar.selectedItem = selectedItem;
}

- (UITabBarItem *)selectedItem {
    return self.tabBar.selectedItem;
}

@end
