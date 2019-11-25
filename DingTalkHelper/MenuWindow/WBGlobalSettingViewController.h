//
//  WBGlobalSettingViewController.h
//  DingTalkAssistant
//
//  Created by buginux on 2017/7/28.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WBGlobalSettingViewControllerDelegate;

@interface WBGlobalSettingViewController : UITableViewController

@property (nonatomic, unsafe_unretained) id<WBGlobalSettingViewControllerDelegate> delegate;

/// We pretend that one of the app's windows is still the key window, even though the explorer window may have become key.
/// We want to display debug state about the application, not about this tool.
+ (void)setApplicationWindow:(UIWindow *)applicationWindow;

@end

@protocol WBGlobalSettingViewControllerDelegate <NSObject>

- (void)globalSettingViewControllerDidFinish:(WBGlobalSettingViewController *)viewController;

@end
