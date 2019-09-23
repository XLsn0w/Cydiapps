//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  ipaDylib.h
//  ipaDylib
//
//  Created by mac on 2019/9/23.
//  Copyright (c) 2019 XLsn0w. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INSERT_SUCCESS_WELCOME "               🎉!!！congratulations!!！🎉\n👍----------------insert dylib success----------------👍\n"

@interface CustomViewController

@property (nonatomic, copy) NSString* newProperty;

+ (void)classMethod;

- (NSString*)getMyName;

- (void)newMethod:(NSString*) output;

@end
