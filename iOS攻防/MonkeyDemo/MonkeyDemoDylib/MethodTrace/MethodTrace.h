//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  Created by AloneMonkey on 2017/9/7.
//  Copyright © 2017年 AloneMonkey. All rights reserved.
//

#ifndef MethodTrace_h
#define MethodTrace_h

#import <UIKit/UIKit.h>

@interface MethodTrace : NSObject

+ (void)addClassTrace:(NSString*) className;

+ (void)addClassTrace:(NSString *)className methodName:(NSString*) methodName;

+ (void)addClassTrace:(NSString *)className methodList:(NSArray*) methodList;

@end

#endif /* MethodTrace_h */
