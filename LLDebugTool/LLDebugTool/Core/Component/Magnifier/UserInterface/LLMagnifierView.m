//
//  LLMagnifierView.m
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

#import "LLMagnifierView.h"
#import "LLConfig.h"
#import "UIView+LL_Utils.h"
#import "LLScreenshotHelper.h"
#import "UIImage+LL_Utils.h"
#import "UIColor+LL_Utils.h"
#import "LLThemeManager.h"

@interface LLMagnifierView ()

@property (nonatomic, strong, nullable) UIImage *screenshot;

@property (nonatomic, assign) CGPoint targetPoint;

@end

@implementation LLMagnifierView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, self.frame);
    
    NSInteger zoomLevel = [LLConfig shared].magnifierZoomLevel;
    // Image's scale, default screenshot's scale is [UIScreen mainScreen].scale, but we only use 1.0 is ok.
    CGFloat scale = 1.0;
    NSInteger size = [LLConfig shared].magnifierSize;
    NSInteger skip = 1;
    
    CGPoint currentPoint = CGPointMake(self.targetPoint.x * scale, self.targetPoint.y * scale);
    
    currentPoint.x = round(currentPoint.x - size * skip / 2.0 * scale);
    currentPoint.y = round(currentPoint.y - size * skip / 2.0 * scale);
    int i, j;
    NSInteger center = size / 2;
    
    for (j = 0; j < size; j++) {
        for (i = 0; i < size; i++) {
            CGRect gridRect = CGRectMake(zoomLevel * i, zoomLevel * j, zoomLevel, zoomLevel);
            UIColor *gridColor = [UIColor clearColor];
            NSString *hexColorAtPoint = [self.screenshot LL_hexColorAt:currentPoint];
            if (hexColorAtPoint) {
                gridColor = [UIColor LL_colorWithHex:hexColorAtPoint];
            }
            CGContextSetFillColorWithColor(context, gridColor.CGColor);
            CGContextFillRect(context, gridRect);
            if (i == center && j == center) {
                if (hexColorAtPoint) {
                    [self.delegate LLMagnifierView:self update:hexColorAtPoint at:currentPoint];
                }
            }
            currentPoint.x += round(skip * scale);
        }
        
        currentPoint.x -= round(size * skip * scale);
        currentPoint.y += round(skip * scale);
    }
    
    UIGraphicsEndImageContext();
}

#pragma mark - Primary
- (void)initial {
    self.overflow = YES;
    self.layer.cornerRadius = self.LL_width / 2.0;
    self.layer.borderColor = [LLThemeManager shared].primaryColor.CGColor;
    self.layer.borderWidth = 2;
    self.layer.masksToBounds = YES;
    
    NSInteger zoomLevel = [LLConfig shared].magnifierZoomLevel;
    
    NSInteger centerX = self.LL_width / 2.0;
    NSInteger centerY = self.LL_height / 2.0;
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.path = [UIBezierPath bezierPathWithRect:CGRectMake(centerX - zoomLevel / 2.0, centerY - zoomLevel / 2.0, zoomLevel, zoomLevel)].CGPath;
    layer.strokeColor = [LLThemeManager shared].primaryColor.CGColor;
    layer.fillColor = nil;
    layer.lineWidth = 2;
    [self.layer addSublayer:layer];
    
    [self updateScreenshot];
    self.targetPoint = self.center;
    [self setNeedsDisplay];
}

- (void)updateScreenshot {
    self.screenshot = [[LLScreenshotHelper shared] imageFromScreen:1];
}

- (void)viewWillUpdateOffset:(UIPanGestureRecognizer *)sender offset:(CGPoint)offsetPoint {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self updateScreenshot];
        self.targetPoint = self.center;
    }
}

- (void)viewDidUpdateOffset:(UIPanGestureRecognizer *)sender offset:(CGPoint)offsetPoint {
    CGPoint newTargetPoint = CGPointMake(self.targetPoint.x + offsetPoint.x, self.targetPoint.y + offsetPoint.y);
    if (!CGPointEqualToPoint(newTargetPoint, self.targetPoint)) {
        self.targetPoint = newTargetPoint;
        [self setNeedsDisplay];
    }
}

@end
