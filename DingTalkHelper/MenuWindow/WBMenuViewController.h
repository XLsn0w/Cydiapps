//
//  WBMenuViewController.h
//  FlowWindow
//
//  Created by buginux on 2017/7/27.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WBMenuViewControllerDelegate;

@interface WBMenuViewController : UIViewController

@property (nonatomic, unsafe_unretained) id<WBMenuViewControllerDelegate> delegate;

- (BOOL)shouldReceiveTouchAtWindowPoint:(CGPoint)pointInWindowCoordinates;
- (BOOL)wantsWindowToBecomeKey;

@end

@protocol WBMenuViewControllerDelegate <NSObject>

- (void)menuViewControllerDidFinish:(WBMenuViewController *)menuViewController;

@end
