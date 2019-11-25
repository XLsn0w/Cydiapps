//
//  WBWindow.m
//  FlowWindow
//
//  Created by buginux on 2017/7/27.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import "WBWindow.h"

@implementation WBWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        // Some apps have windows at UIWindowLevelStatusBar + n.
        // If we make the window level too high, we block out UIAlertViews.
        // There's a balance between staying above the app's windows and staying below alerts.
        // UIWindowLevelStatusBar + 100 seems to hit that balance.
        self.windowLevel = UIWindowLevelStatusBar + 100.0;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = NO;
    
    if ([self.eventDelegate shouldHandleTouchAtPoint:point]) {
        pointInside = [super pointInside:point withEvent:event];
    }
    
    return pointInside;
}

- (BOOL)shouldAffectStatusBarAppearance {
    return [self isKeyWindow];
}



@end
