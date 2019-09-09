//
//  LLEntryBallView.m
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

#import "LLEntryBallView.h"
#import "LLThemeManager.h"
#import "LLFactory.h"
#import "UIView+LL_Utils.h"
#import "LLImageNameConfig.h"
#import "LLConfig.h"
#import "LLMacros.h"

@interface LLEntryBallView ()

@property (nonatomic, strong) UIImageView *logoImageView;

@end

@implementation LLEntryBallView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)viewDidUpdateOffset:(UIPanGestureRecognizer *)sender offset:(CGPoint)offsetPoint {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self becomeActive];
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed) {
        [self resignActive];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Primary
- (void)initial {
    self.overflow = YES;
    self.moveable = [LLConfig shared].suspensionBallMoveable;
    self.alpha = [LLConfig shared].normalAlpha;
    self.backgroundColor = [LLThemeManager shared].backgroundColor;
    [self LL_setBorderColor:[LLThemeManager shared].primaryColor borderWidth:2];
    [self LL_setCornerRadius:self.LL_width / 2];
    self.logoImageView = [LLFactory getImageView:self frame:CGRectMake(self.LL_width / 4.0, self.LL_height / 4.0, self.LL_width / 2.0, self.LL_height / 2.0) image:[UIImage LL_imageNamed:kLogoImageName color:[LLThemeManager shared].primaryColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeManagerUpdatePrimaryColorNotificaion:) name:kThemeManagerUpdatePrimaryColorNotificaionName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeManagerUpdateBackgroundColorNotificaion:) name:kThemeManagerUpdateBackgroundColorNotificaionName object:nil];
}

- (void)becomeActive {
    self.alpha = [LLConfig shared].activeAlpha;
}

- (void)resignActive {
    if (![LLConfig shared].isAutoAdjustSuspensionWindow) {
        self.alpha = [LLConfig shared].normalAlpha;
        return;
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = [LLConfig shared].normalAlpha;
        // Calculate End Point
        CGFloat x = self.LL_centerX;
        CGFloat y = self.LL_centerY;
        CGFloat x1 = LL_SCREEN_WIDTH / 2.0;
        CGFloat y1 = LL_SCREEN_HEIGHT / 2.0;

        CGFloat distanceX = x1 > x ? x : LL_SCREEN_WIDTH - x;
        CGFloat distanceY = y1 > y ? y : LL_SCREEN_HEIGHT - y;
        CGPoint endPoint = CGPointZero;

        if (distanceX <= distanceY) {
            // animation to left or right
            endPoint.y = y;
            if (x1 < x) {
                // to right
                endPoint.x = LL_SCREEN_WIDTH - self.LL_width / 2.0 + [LLConfig shared].suspensionWindowHideWidth;
            } else {
                // to left
                endPoint.x = self.LL_width / 2.0 - [LLConfig shared].suspensionWindowHideWidth;
            }
        } else {
            // animation to top or bottom
            endPoint.x = x;
            if (y1 < y) {
                // to bottom
                endPoint.y = LL_SCREEN_HEIGHT - self.LL_height / 2.0 + [LLConfig shared].suspensionWindowHideWidth;
            } else {
                // to top
                endPoint.y = self.LL_height / 2.0 - [LLConfig shared].suspensionWindowHideWidth;
            }
        }
        self.center = endPoint;

    } completion:^(BOOL finished) {

    }];
}

#pragma mark - NSNotification
- (void)didReceiveThemeManagerUpdatePrimaryColorNotificaion:(NSNotification *)notification {
    self.layer.borderColor = [LLThemeManager shared].primaryColor.CGColor;
    self.logoImageView.image = [UIImage LL_imageNamed:kLogoImageName color:[LLThemeManager shared].primaryColor];
}

- (void)didReceiveThemeManagerUpdateBackgroundColorNotificaion:(NSNotification *)notification {
    self.backgroundColor = [LLThemeManager shared].backgroundColor;
}

@end
