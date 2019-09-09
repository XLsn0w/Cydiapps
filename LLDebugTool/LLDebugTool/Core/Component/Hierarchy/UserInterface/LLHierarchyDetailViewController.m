//
//  LLHierarchyDetailViewController.m
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

#import "LLHierarchyDetailViewController.h"
#import "LLConst.h"
#import "UIView+LL_Utils.h"
#import "LLFactory.h"
#import "LLMacros.h"
#import "LLConfig.h"
#import "LLHierarchyDetailCell.h"
#import "UIColor+LL_Utils.h"
#import "UILabel+LL_Utils.h"
#import "UIControl+LL_Utils.h"
#import "UIButton+LL_Utils.h"
#import "LLFormatterTool.h"
#import "LLThemeManager.h"

@interface LLHierarchyDetailViewController ()

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSMutableArray *objectDatas;

@property (nonatomic, strong) NSMutableArray *sizeDatas;

@end

@implementation LLHierarchyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

#pragma mark - Primary
- (void)initial {
    self.navigationItem.title = @"Hierarchy Detail";
    self.objectDatas = [[NSMutableArray alloc] init];
    self.sizeDatas = [[NSMutableArray alloc] init];
    
    self.segmentedControl = [LLFactory getSegmentedControl:self.view frame:CGRectMake(kLLGeneralMargin, LL_NAVIGATION_HEIGHT + kLLGeneralMargin, self.view.LL_width - kLLGeneralMargin * 2, 30) items:@[@"Object", @"Size"]];
    self.segmentedControl.tintColor = [LLThemeManager shared].primaryColor;
    self.segmentedControl.selectedSegmentIndex = 0;
    
    self.tableView.frame = CGRectMake(0, self.segmentedControl.LL_bottom + kLLGeneralMargin, self.view.LL_width, self.view.LL_height - self.segmentedControl.LL_bottom - kLLGeneralMargin);
}

- (void)loadData {
    [self.objectDatas removeAllObjects];
    
    NSMutableArray *section = [[NSMutableArray alloc] init];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"ClassName" content:NSStringFromClass(self.selectView.class)]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Address" content:[NSString stringWithFormat:@"%p",self.selectView]]];
    [self.objectDatas addObject:[[LLHierarchyDetailSectionModel alloc] initWithTitle:@"Object" models:section]];
    
    [section removeAllObjects];
    
    
}

- (LLHierarchyDetailSectionModel *)sectionModelWithClass:(Class)cls {
    if (cls == [NSObject class]) {
        
    } else if (cls == [UIView class]) {
        return [self sectionModelWithView:self.selectView];
    } else if (cls == [UILabel class]) {
        UILabel *label = (UILabel *)self.selectView;
        return [self sectionModelWithLabel:label];
    }
    return nil;
}

- (LLHierarchyDetailSectionModel *)sectionModelWithObject:(NSObject *)object {
    NSMutableArray *section = [[NSMutableArray alloc] init];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Class Name" content:NSStringFromClass(object.class)]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Address" content:[NSString stringWithFormat:@"%p",object]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Description" content:object.description]];
    return [[LLHierarchyDetailSectionModel alloc] initWithTitle:@"Object" models:section];
}

- (LLHierarchyDetailSectionModel *)sectionModelWithView:(UIView *)view {
    NSMutableArray *section = [[NSMutableArray alloc] init];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Layer" content:view.layer.description]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Layer Class" content:NSStringFromClass(view.layer.class)]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Content Model" content:view.LL_contentModeDescription]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Tag" content:[NSString stringWithFormat:@"%ld",(long)view.tag]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Interaction" content:[NSString stringWithFormat:@"User Interaction Enabled %@", view.isUserInteractionEnabled ? @"On" : @"Off"]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:[NSString stringWithFormat:@"Multiple Touch %@", view.isMultipleTouchEnabled ? @"On" : @"Off"]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Alpha" content:[[LLFormatterTool shared] formatNumber:@(view.alpha)]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Background" content:[self colorDescription:view.backgroundColor]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Tint" content:[self colorDescription:view.tintColor]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Drawing" content:[NSString stringWithFormat:@"Opaque %@", view.isOpaque ? @"On" : @"Off"]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:[NSString stringWithFormat:@"Hidden %@", view.isHidden ? @"On" : @"Off"]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:[NSString stringWithFormat:@"Clears Graphics Context %@", view.clearsContextBeforeDrawing ? @"On" : @"Off"]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:[NSString stringWithFormat:@"Clip To Bounds %@", view.clipsToBounds ? @"On" : @"Off"]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:[NSString stringWithFormat:@"Autoresizes Subviews %@", view.autoresizesSubviews ? @"On" : @"Off"]]];
    return [[LLHierarchyDetailSectionModel alloc] initWithTitle:@"View" models:section];
}

- (LLHierarchyDetailSectionModel *)sectionModelWithLabel:(UILabel *)label {
    NSMutableArray *section = [[NSMutableArray alloc] init];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Text" content:label.text]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:label.attributedText == nil ? @"Attributed Text" : @"Plain Text"]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Text" content:[self colorDescription:label.textColor]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:label.font.description]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:[NSString stringWithFormat:@"Aligned %@", label.LL_textAlignmentDescription]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Lines" content:[NSString stringWithFormat:@"%ld",(long)label.numberOfLines]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Behavior" content:[NSString stringWithFormat:@"Enabled %@",label.isEnabled ? @"On" : @"Off"]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:[NSString stringWithFormat:@"Highlighted %@",label.isHighlighted ? @"On" : @"Off"]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Baseline" content:[NSString stringWithFormat:@"Align %@",label.LL_baselineAdjustmentDescription]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Line Break" content:label.LL_lineBreakModeDescription]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Min Font Scale" content:[[LLFormatterTool shared] formatNumber:@(label.minimumScaleFactor)]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Highlighted" content:label.highlightedTextColor.LL_description]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Shadow" content:label.shadowColor.LL_description]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Shadow Offset" content:[NSString stringWithFormat:@"w %@   h %@",[[LLFormatterTool shared] formatNumber:@(label.shadowOffset.width)], [[LLFormatterTool shared] formatNumber:@(label.shadowOffset.height)]]]];
    return [[LLHierarchyDetailSectionModel alloc] initWithTitle:@"Label" models:section];
}

- (LLHierarchyDetailSectionModel *)sectionModelWithControl:(UIControl *)control {
    NSMutableArray *section = [[NSMutableArray alloc] init];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Alignment" content:[NSString stringWithFormat:@"%@ Horizonally", [control LL_contentHorizontalAlignmentDescription]]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:[NSString stringWithFormat:@"%@ Vertically", [control LL_contentVerticalAlignmentDescription]]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Content" content:control.isSelected ? @"Selected" : @"Not Selected"]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:control.isEnabled ? @"Enabled" : @"Not Enabled"]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:nil content:control.isHighlighted ? @"Highlighted" : @"Not Highlighted"]];
    return [[LLHierarchyDetailSectionModel alloc] initWithTitle:@"Control" models:section];
}

- (LLHierarchyDetailSectionModel *)sectionModelWithButton:(UIButton *)button {
    NSMutableArray *section = [[NSMutableArray alloc] init];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Type" content:[button LL_typeDescription]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"State" content:[button LL_stateDescription]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Title" content:button.currentTitle]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Title" content:button.currentAttributedTitle == nil ? @"Plain Text" : @"Attributed Text"]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Text Color" content:[self colorDescription:button.currentTitleColor]]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Shadow Color" content:[self colorDescription:button.currentTitleShadowColor]]];
//    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Target" content:button.allTargets.description]];
//    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Action" content:button.allTargets.description]];
    [section addObject:[[LLHierarchyDetailModel alloc] initWithTitle:@"Image" content:button.currentImage ? nil : @"No image"]];
    return [[LLHierarchyDetailSectionModel alloc] initWithTitle:@"Button" models:section];
}


- (NSString *)colorDescription:(UIColor *_Nullable)color {
    if (!color) {
        return @"<nil color>";
    }
    
    NSArray *rgba = [color LL_RGBA];
    return [NSString stringWithFormat:@"R:%@ G:%@ B:%@ A:%@", [[LLFormatterTool shared] formatNumber:rgba[0]], [[LLFormatterTool shared] formatNumber:rgba[1]], [[LLFormatterTool shared] formatNumber:rgba[2]], [[LLFormatterTool shared] formatNumber:rgba[3]]];
}

@end
