//
//  WBWindow.h
//  FlowWindow
//
//  Created by buginux on 2017/7/27.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WBWindowEventDelegate;

@interface WBWindow : UIWindow

@property (nonatomic, unsafe_unretained) id<WBWindowEventDelegate> eventDelegate;

@end

@protocol WBWindowEventDelegate <NSObject>

- (BOOL)shouldHandleTouchAtPoint:(CGPoint)pointInWindow;
- (BOOL)canBecomeKeyWindow;

@end
