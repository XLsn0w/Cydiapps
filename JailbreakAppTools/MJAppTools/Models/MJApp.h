//
//  MJApp.h
//  MJAppTools
//
//  Created by MJ Lee on 2018/1/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FBApplicationInfo, MJMachO;

@interface MJApp : NSObject

@property(copy, nonatomic, readonly) NSString *bundlePath;
@property(copy, nonatomic, readonly) NSString *dataPath;
@property(copy, nonatomic, readonly) NSString *bundleIdentifier;
@property(copy, nonatomic, readonly) NSString *displayName;
@property(copy, nonatomic, readonly) NSString *executableName;
@property(assign, nonatomic, readonly, getter=isSystemApp) BOOL systemApp;
@property(assign, nonatomic, readonly, getter=isHidden) BOOL hidden;
@property (strong, nonatomic, readonly) MJMachO *executable;

- (instancetype)initWithInfo:(FBApplicationInfo *)info;
+ (instancetype)appWithInfo:(FBApplicationInfo *)info;

- (void)setupExecutable;
@end
