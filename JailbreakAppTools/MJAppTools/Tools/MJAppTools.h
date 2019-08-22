//
//  MJAppTools.h
//  MJAppTools
//
//  Created by MJ Lee on 2018/1/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJApp.h"

typedef enum {
    MJListAppsTypeUser,
    MJListAppsTypeUserEncrypted,
    MJListAppsTypeUserDecrypted,
    MJListAppsTypeSystem
} MJListAppsType;

@interface MJAppTools : NSObject

+ (void)listUserAppsWithType:(MJListAppsType)type regex:(NSString *)regex operation:(void (^)(NSArray *apps))operation;

@end
