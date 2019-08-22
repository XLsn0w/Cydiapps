//
//  MJApp.m
//  MJAppTools
//
//  Created by MJ Lee on 2018/1/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJApp.h"
#import "FBApplicationInfo.h"
#import "LSApplicationProxy.h"
#import "NSFileHandle+Extension.h"
#import "MJMachO.h"

@interface MJApp()
@property(copy, nonatomic) NSString *bundlePath;
@property(copy, nonatomic) NSString *dataPath;
@property(copy, nonatomic) NSString *bundleIdentifier;
@property(copy, nonatomic) NSString *displayName;
@property(copy, nonatomic) NSString *executableName;
@property(assign, nonatomic, getter=isSystemApp) BOOL systemApp;
@property(assign, nonatomic, getter=isHidden) BOOL hidden;
@property (strong, nonatomic) MJMachO *executable;
@end

@implementation MJApp

+ (instancetype)appWithInfo:(FBApplicationInfo *)info
{
    return [[self alloc] initWithInfo:info];
}

- (instancetype)initWithInfo:(FBApplicationInfo *)info
{
    if (self = [super init]) {
        LSApplicationProxy *appProxy = (LSApplicationProxy*)info;
        self.displayName = appProxy.localizedName ? appProxy.localizedName : appProxy.itemName;
        self.bundleIdentifier = info.bundleIdentifier;
        self.bundlePath = info.bundleURL.path;
        self.dataPath = info.dataContainerURL.path;
        self.hidden = [appProxy.appTags containsObject:@"hidden"];
        self.systemApp = [info.applicationType isEqualToString:@"System"];
    }
    return self;
}

- (void)setupExecutable
{
    NSRange range = NSMakeRange([self.bundlePath rangeOfString:@"/" options:NSBackwardsSearch].location + 1, self.bundlePath.lastPathComponent.length - 4);
    self.executableName = [self.bundlePath substringWithRange:range];
    
    NSString *filepath = [self.bundlePath stringByAppendingPathComponent:self.executableName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) return;
    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:filepath];
    
    self.executable = [MJMachO machOWithFileHandle:readHandle];
    
    // 关闭
    [readHandle closeFile];
}

@end
