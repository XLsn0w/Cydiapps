//
//  LLScreenshotViewController.m
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

#import "LLScreenshotViewController.h"
#import "LLFactory.h"
#import "UIView+LL_Utils.h"
#import "LLConst.h"
#import "LLConfig.h"
#import "LLMacros.h"
#import "LLScreenshotPreviewViewController.h"
#import "LLScreenshotHelper.h"
#import "LLThemeManager.h"
#import "LLImageNameConfig.h"

@interface LLScreenshotViewController ()

@property (nonatomic, strong) UIButton *captureButton;

@end

@implementation LLScreenshotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint capturePoint = [self.view convertPoint:point toView:self.captureButton];
    if ([self.captureButton pointInside:capturePoint withEvent:event]) {
        return YES;
    }
    return NO;
}

#pragma mark - Primary
- (void)initial {
    self.view.backgroundColor = [UIColor clearColor];
    CGFloat width = 60;
    self.captureButton = [LLFactory getButton:self.view frame:CGRectMake((self.view.LL_width - 60) / 2.0, self.view.LL_bottom - kLLGeneralMargin * 2 - width, width, width) target:self action:@selector(captureButtonClicked:)];
    self.captureButton.layer.cornerRadius = width / 2.0;
    self.captureButton.layer.masksToBounds = YES;
    self.captureButton.layer.borderWidth = 1;
    self.captureButton.layer.borderColor = [LLThemeManager shared].primaryColor.CGColor;
    self.captureButton.backgroundColor = [LLThemeManager shared].backgroundColor;
    [self.captureButton setImage:[UIImage LL_imageNamed:kCaptureImageName color:[LLThemeManager shared].primaryColor] forState:UIControlStateNormal];
        
    // Pan, to moveable.
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGR:)];
    
    [self.captureButton addGestureRecognizer:pan];
}

- (void)captureButtonClicked:(UIButton *)sender {
    LLScreenshotPreviewViewController *vc = [[LLScreenshotPreviewViewController alloc] init];
    vc.image = [[LLScreenshotHelper shared] imageFromScreen];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)panGR:(UIPanGestureRecognizer *)sender {
    CGPoint offsetPoint = [sender translationInView:sender.view];
    
    [sender setTranslation:CGPointZero inView:sender.view];
    
    [self changeFrameWithPoint:offsetPoint];
    
}

- (void)changeFrameWithPoint:(CGPoint)point {
    
    CGPoint center = self.captureButton.center;
    center.x += point.x;
    center.y += point.y;
    
    center.x = MIN(center.x, LL_SCREEN_WIDTH);
    center.x = MAX(center.x, 0);
    
    center.y = MIN(center.y, LL_SCREEN_HEIGHT);
    center.y = MAX(center.y, 0);
    
    self.captureButton.center = center;
    
    if (self.captureButton.LL_left < 0) {
        self.captureButton.LL_left = 0;
    }
    if (self.captureButton.LL_right > LL_SCREEN_WIDTH) {
        self.captureButton.LL_right = LL_SCREEN_WIDTH;
    }
}


@end
