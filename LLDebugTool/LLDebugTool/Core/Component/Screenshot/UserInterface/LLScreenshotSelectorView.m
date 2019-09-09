//
//  LLScreenshotSelectorView.m
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

#import "LLScreenshotSelectorView.h"
#import "LLScreenshotSelectorModel.h"
#import "LLImageNameConfig.h"
#import "LLFactory.h"
#import "LLConst.h"

@interface LLScreenshotSelectorView ()

@property (nonatomic, strong) UIButton *lastSizeButton;

@property (nonatomic, strong) UIButton *lastColorButton;

@property (nonatomic, strong) LLScreenshotSelectorModel *model;

@end

@implementation LLScreenshotSelectorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (LLScreenshotSelectorModel *)currentSelectorModel {
    return _model;
}

- (void)actionButtonClicked:(UIButton *)sender {
    if (sender.tag <= LLScreenshotSelectorActionBig) {
        // Size button
        if (self.lastSizeButton != sender) {
            self.lastSizeButton.selected = NO;
            sender.selected = YES;
            self.lastSizeButton = sender;
            self.model.size = sender.tag;
        }
    } else {
        // Color button
        if (self.lastColorButton != sender) {
            self.lastColorButton.selected = NO;
            self.lastColorButton.layer.borderWidth = 0;
            sender.selected = YES;
            sender.layer.borderWidth = 2;
            self.lastColorButton = sender;
            self.model.color = sender.tag;
        }
    }
}

#pragma mark - Primary
- (void)initial {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.model = [[LLScreenshotSelectorModel alloc] init];
    
    NSInteger count = 9;
    CGFloat gap = kLLGeneralMargin;
    CGFloat itemWidth = 19;
    CGFloat itemHeight = 19;
    CGFloat itemGap = (self.frame.size.width - gap * 2 - itemWidth * count) / (count - 1);
    CGFloat top = (self.frame.size.height - itemHeight) / 2.0;
    
    for (int i = 0; i < count; i++) {
        UIButton *button = [LLFactory getButton:self frame:CGRectMake(gap + i * (itemWidth + itemGap), top, itemWidth, itemHeight) target:self action:@selector(actionButtonClicked:)];
        NSString *imageName = @"";
        NSString *selectImageName = @"";
        switch (i) {
            case LLScreenshotSelectorActionSmall:{
                imageName = kSelectorSmallImageName;
                selectImageName = kSelectorSmallSelectImageName;
                button.selected = YES;
                self.lastSizeButton = button;
            }
                break;
            case LLScreenshotSelectorActionMedium:{
                imageName = kSelectorMediumImageName;
                selectImageName = kSelectorMediumSelectImageName;
            }
                break;
            case LLScreenshotSelectorActionBig:{
                imageName = kSelectorBigImageName;
                selectImageName = kSelectorBigSelectImageName;
            }
                break;
            case LLScreenshotSelectorActionRed:{
                imageName = kSelectorRedImageName;
                selectImageName = kSelectorRedImageName;
                button.selected = YES;
                button.layer.borderWidth = 2;
                self.lastColorButton = button;
            }
                break;
            case LLScreenshotSelectorActionBlue:{
                imageName = kSelectorBlueImageName;
                selectImageName = kSelectorBlueImageName;
            }
                break;
            case LLScreenshotSelectorActionGreen:{
                imageName = kSelectorGreenImageName;
                selectImageName = kSelectorGreenImageName;
            }
                break;
            case LLScreenshotSelectorActionYellow:{
                imageName = kSelectorYellowImageName;
                selectImageName = kSelectorYellowImageName;
            }
                break;
            case LLScreenshotSelectorActionGray:{
                imageName = kSelectorGrayImageName;
                selectImageName = kSelectorGrayImageName;
            }
                break;
            case LLScreenshotSelectorActionWhite:{
                imageName = kSelectorWhiteImageName;
                selectImageName = kSelectorWhiteImageName;
            }
                break;
            default:
                break;
        }
        [button setImage:[UIImage LL_imageNamed:imageName] forState:UIControlStateNormal];
        [button setImage:[UIImage LL_imageNamed:selectImageName] forState:UIControlStateSelected];
        button.tag = i;
        button.showsTouchWhenHighlighted = NO;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

@end
