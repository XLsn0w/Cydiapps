//
//  LLToastUtils.m
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

#import "LLToastUtils.h"
#import <UIKit/UIKit.h>
#import "LLFactory.h"
#import "LLMacros.h"
#import "UIView+LL_Utils.h"
#import "UILabel+LL_Utils.h"

static LLToastUtils *_instance = nil;

@interface LLToastUtils ()

@property (nonatomic, assign) CGFloat toastTime;

@property (nonatomic, strong) UILabel *toastLabel;

@property (nonatomic, strong) NSTimer *loadingTimer;

@end

@implementation LLToastUtils

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLToastUtils alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _toastTime = 2;
    }
    return self;
}

- (void)toastMessage:(NSString *)message {
    [self showToastLabel:message completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.toastTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hide];
        });
    }];
}

- (void)loadingMessage:(NSString *)message {
    [self showToastLabel:message completion:^{
        [self startLoadingMessageTimer];
    }];
}

- (void)hide {
    if (self.toastLabel.superview) {
        [self removeLoadingMessageTimer];
        [UIView animateWithDuration:0.1 animations:^{
            self.toastLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [self.toastLabel removeFromSuperview];
        }];
    }
}

#pragma mark - Primary
- (void)showToastLabel:(NSString *)message completion:(void (^ __nullable)(void))completion {
    if (self.toastLabel.superview) {
        [self.toastLabel removeFromSuperview];
    }
    
    self.toastLabel.frame = CGRectMake(20, 0, LL_SCREEN_WIDTH - 40, 100);
    self.toastLabel.text = message;
    self.toastLabel.alpha = 0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication].keyWindow addSubview:self.toastLabel];
#pragma clang diagnostic pop
    [self.toastLabel sizeToFit];
    self.toastLabel.center = CGPointMake(LL_SCREEN_WIDTH / 2.0, LL_SCREEN_HEIGHT / 2.0);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.toastLabel.alpha = 1;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)startLoadingMessageTimer {
    [self removeLoadingMessageTimer];
    _loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadingMessageTimerAction:) userInfo:nil repeats:YES];
}

- (void)removeLoadingMessageTimer {
    if ([_loadingTimer isValid]) {
        [_loadingTimer invalidate];
        _loadingTimer = nil;
    }
}

- (void)loadingMessageTimerAction:(NSTimer *)timer {
    if (self.toastLabel.superview) {
        if ([self.toastLabel.text hasSuffix:@"..."]) {
            self.toastLabel.text = [self.toastLabel.text substringToIndex:self.toastLabel.text.length - 3];
        } else {
            self.toastLabel.text = [self.toastLabel.text stringByAppendingString:@"."];
        }
    } else {
        [self removeLoadingMessageTimer];
    }
}

- (UILabel *)toastLabel {
    if (!_toastLabel) {
        _toastLabel = [LLFactory getLabel:nil frame:CGRectMake(20, 0, LL_SCREEN_WIDTH - 40, 100) text:nil font:17 textColor:[UIColor whiteColor]];
        _toastLabel.textAlignment = NSTextAlignmentCenter;
        _toastLabel.numberOfLines = 0;
        _toastLabel.LL_horizontalPadding = 10;
        _toastLabel.LL_verticalPadding = 5;
        _toastLabel.backgroundColor = [UIColor blackColor];
        [_toastLabel LL_setCornerRadius:5];
    }
    return _toastLabel;
}

@end
