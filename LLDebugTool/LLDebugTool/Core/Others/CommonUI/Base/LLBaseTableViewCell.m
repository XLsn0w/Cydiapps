//
//  LLBaseTableViewCell.m
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

#import "LLBaseTableViewCell.h"
#import "LLConfig.h"
#import "LLFactory.h"
#import "LLThemeManager.h"
#import "LLImageNameConfig.h"

@implementation LLBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self baseInitial];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self baseInitial];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellEditControl")]) {
            for (UIView *view in subview.subviews) {
                if ([view isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)view;
                    UIImageRenderingMode mode = UIImageRenderingModeAlwaysTemplate;
                    if (self.isSelected) {
                        imageView.image = [[UIImage LL_imageNamed:kCellSelectImageName] imageWithRenderingMode:mode];
                    } else {
                        imageView.image = [[UIImage LL_imageNamed:kCellUnselectImageName] imageWithRenderingMode:mode];
                    }
                    break;
                }
            }
        }
    }
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    [super setAccessoryType:accessoryType];
    switch (accessoryType) {
        case UITableViewCellAccessoryDisclosureIndicator:{
            self.accessoryView = [LLFactory getImageView:nil frame:CGRectMake(0, 0, 12, 12) image:[[UIImage LL_imageNamed:kRightImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        }
            break;
        case UITableViewCellAccessoryNone: {
            self.accessoryView = nil;
        }
            break;
        default: {
            NSAssert(NO, @"Must code accessory type");
        }
            break;
    }
}

#pragma mark - Primary
- (void)baseInitial {
    self.tintColor = [LLThemeManager shared].primaryColor;
    self.backgroundColor = [LLThemeManager shared].backgroundColor;
    self.selectedBackgroundView = [LLFactory getPrimaryView:nil frame:self.frame alpha:0.2];
    self.textLabel.textColor = [LLThemeManager shared].primaryColor;
    self.detailTextLabel.textColor = [LLThemeManager shared].primaryColor;
    [self configSubviews:self];
}

- (void)configSubviews:(UIView *)view {
    if ([view isKindOfClass:[UILabel class]]) {
        ((UILabel *)view).textColor = [LLThemeManager shared].primaryColor;
    }
    if (view.subviews) {
        for (UIView *subView in view.subviews) {
            [self configSubviews:subView];
        }
    }
}

@end
