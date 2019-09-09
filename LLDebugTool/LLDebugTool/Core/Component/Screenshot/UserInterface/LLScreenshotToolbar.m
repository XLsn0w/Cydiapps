//
//  LLScreenshotToolbar.m
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

#import "LLScreenshotToolbar.h"
#import "LLScreenshotSelectorView.h"
#import "LLScreenshotActionView.h"
#import "LLImageNameConfig.h"
#import "LLFactory.h"
#import "LLConst.h"

@interface LLScreenshotToolbar () <LLScreenshotActionViewDelegate>

@property (nonatomic, strong) LLScreenshotActionView *actionView;

@property (nonatomic, strong) UIView *selectorBackgroundView;

@property (nonatomic, strong) NSMutableArray <LLScreenshotSelectorView *>*selectorViews;

@property (nonatomic, strong) LLScreenshotSelectorView *lastSelectorView;

@property (nonatomic, strong) UIImageView *triangleView;

@property (nonatomic, assign) BOOL selectorViewShowed;

@end

@implementation LLScreenshotToolbar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

#pragma mark - Primary
- (void)initial {
    self.clipsToBounds = YES;
    self.selectorViews = [[NSMutableArray alloc] init];
    
    CGFloat itemHeight = (self.frame.size.height - kLLGeneralMargin) /2.0;
    self.actionView = [[LLScreenshotActionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, itemHeight)];
    self.actionView.delegate = self;
    [self addSubview:self.actionView];
    
    self.selectorBackgroundView = [LLFactory getView:self frame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height - itemHeight)];
    
    CGFloat triangleHeight = 10;
    self.triangleView = [LLFactory getImageView:self.selectorBackgroundView frame:CGRectMake(0, 0, triangleHeight * 2, triangleHeight) image:[UIImage LL_imageNamed:kSelectorTriangleImageName]];
    
    for (int i = 0; i < 5; i++) {
        LLScreenshotSelectorView *selectorView = [[LLScreenshotSelectorView alloc] initWithFrame:CGRectMake(0, triangleHeight, self.selectorBackgroundView.frame.size.width, self.selectorBackgroundView.frame.size.height - triangleHeight)];
        [self.selectorViews addObject:selectorView];
        [self.selectorBackgroundView addSubview:selectorView];
    }

    self.lastSelectorView = [self.selectorViews firstObject];
    [self.selectorBackgroundView bringSubviewToFront:[self.selectorViews firstObject]];
}

- (void)showSelectorView:(NSInteger)index position:(CGFloat)position {
    LLScreenshotSelectorView *selectedView = self.selectorViews[index - 1];
    if (selectedView != self.lastSelectorView) {
        self.lastSelectorView = selectedView;
        [self.selectorBackgroundView bringSubviewToFront:selectedView];
    }
    
    if (self.selectorViewShowed) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect oriFrame = self.triangleView.frame;
            self.triangleView.frame = CGRectMake(position - oriFrame.size.width / 2.0, oriFrame.origin.y, oriFrame.size.width, oriFrame.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect oriFrame = self.triangleView.frame;
            CGFloat actionViewBottom = self.actionView.frame.size.height + self.actionView.frame.origin.y;
            self.triangleView.frame = CGRectMake(position - oriFrame.size.width / 2.0, oriFrame.origin.y, oriFrame.size.width, oriFrame.size.height);
            self.selectorBackgroundView.frame = CGRectMake(0, actionViewBottom, self.selectorBackgroundView.frame.size.width, self.selectorBackgroundView.frame.size.height);
        } completion:^(BOOL finished) {
            self.selectorViewShowed = YES;
        }];
    }
}

- (void)hideSelectorView {
    if (self.selectorViewShowed) {
        [UIView animateWithDuration:0.25 animations:^{
            self.selectorBackgroundView.frame = CGRectMake(0, self.frame.size.height, self.selectorBackgroundView.frame.size.width, self.selectorBackgroundView.frame.size.height);
        } completion:^(BOOL finished) {
            self.selectorViewShowed = NO;
        }];
    }
}

#pragma mark - LLScreenshotActionViewDelegate
- (void)LLScreenshotActionView:(LLScreenshotActionView *)actionView didSelectedAction:(LLScreenshotAction)action isSelected:(BOOL)isSelected position:(CGFloat)position {
    switch (action) {
        case LLScreenshotActionRect:
        case LLScreenshotActionRound:
        case LLScreenshotActionLine:
        case LLScreenshotActionPen:
        case LLScreenshotActionText:{
            if (isSelected) {
                [self showSelectorView:action position:position];
            } else {
                [self hideSelectorView];
            }
        }
            break;
        case LLScreenshotActionBack:{
            
        }
            break;
        case LLScreenshotActionCancel:{
            
        }
            break;
        case LLScreenshotActionConfirm:{
            
        }
            break;
        default:
            break;
    }
    
    if ([_delegate respondsToSelector:@selector(LLScreenshotToolbar:didSelectedAction:selectorModel:)]) {
        LLScreenshotSelectorModel *model = nil;
        if (action < LLScreenshotActionBack) {
            if (isSelected) {
                model = [self.selectorViews[action - 1] currentSelectorModel];
            } else {
                action = LLScreenshotActionNone;
            }
        }
        [_delegate LLScreenshotToolbar:self didSelectedAction:action selectorModel:model];
    }
}

@end
