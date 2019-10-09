//
//  KeychainHelper.h
//  KeychainIDFA
//
//  Created by Qixin on 14/12/18.
//  Copyright (c) 2014年 Qixin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeychainHelper : NSObject
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;
@end
