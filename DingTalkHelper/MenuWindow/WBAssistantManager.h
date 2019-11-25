//
//  WBAssistantManager.h
//  FlowWindow
//
//  Created by buginux on 2017/7/27.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBAssistantManager : NSObject

+ (instancetype)sharedManager;

- (void)showMenu;
- (void)hideMenu;
- (void)toggleMenu;

@end
