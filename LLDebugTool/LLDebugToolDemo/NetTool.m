//
//  NetTool.m
//  LLDebugToolDemo
//
//  Created by Li on 2018/5/30.
//  Copyright © 2018年 li. All rights reserved.
//

#import "NetTool.h"

static NetTool *_instance = nil;

@implementation NetTool

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NetTool alloc] init];
    });
    return _instance;
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _session;
}

-(AFURLSessionManager *)afURLSessionManager {
    if (!_afURLSessionManager) {
        _afURLSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _afURLSessionManager;
}

- (AFHTTPSessionManager *)afHTTPSessionManager {
    if (!_afHTTPSessionManager) {
        _afHTTPSessionManager = [AFHTTPSessionManager manager];
    }
    return _afHTTPSessionManager;
}

@end
