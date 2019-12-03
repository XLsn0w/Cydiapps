//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  Created by AloneMonkey on 2017/9/6.
//  Copyright © 2017年 AloneMonkey. All rights reserved.
//

#import "ANYMethodLog.h"
#import "MethodTrace.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation MethodTrace : NSObject

+(void)addClassTrace:(NSString *)className{
    [self addClassTrace:className methodList:nil];
}

+(void)addClassTrace:(NSString *)className methodName:(NSString *)methodName{
    [self addClassTrace:className methodList:@[methodName]];
}

+(void)addClassTrace:(NSString *)className methodList:(NSArray *)methodList{
    Class targetClass = objc_getClass([className UTF8String]);
    if(targetClass != nil){
        [ANYMethodLog logMethodWithClass:NSClassFromString(className) condition:^BOOL(SEL sel) {
            return (methodList == nil || methodList.count == 0) ? YES : [methodList containsObject:NSStringFromSelector(sel)];
        } before:^(id target, SEL sel, NSArray *args, int deep) {
            NSString *selector = NSStringFromSelector(sel);
            NSArray *selectorArrary = [selector componentsSeparatedByString:@":"];
            selectorArrary = [selectorArrary filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
            NSMutableString *selectorString = [NSMutableString new];
            for (int i = 0; i < selectorArrary.count; i++) {
                [selectorString appendFormat:@"%@:%@ ", selectorArrary[i], args[i]];
            }
            NSMutableString *deepString = [NSMutableString new];
            for (int i = 0; i < deep; i++) {
                [deepString appendString:@"-"];
            }
            NSLog(@"%@[%@ %@]", deepString , target, selectorString);
        } after:^(id target, SEL sel, NSArray *args, NSTimeInterval interval,int deep, id retValue) {
            NSMutableString *deepString = [NSMutableString new];
            for (int i = 0; i < deep; i++) {
                [deepString appendString:@"-"];
            }
            NSLog(@"%@ret:%@", deepString, retValue);
        }];
    }else{
        NSLog(@"canot find class %@", className);
    }
}

@end

static __attribute__((constructor)) void entry(){
    NSString* configFilePath = [[NSBundle mainBundle] pathForResource:@"MethodTraceConfig" ofType:@"plist"];
    if(configFilePath == nil){
        NSLog(@"MethodTraceConfig.plist file is not exits!!!");
        return;
    }
    NSMutableDictionary *configItem = [NSMutableDictionary dictionaryWithContentsOfFile:configFilePath];
    BOOL isEnable = [[configItem valueForKey:@"ENABLE_METHODTRACE"] boolValue];
    if(isEnable){
        NSDictionary* classListDictionary = [configItem valueForKey:@"TARGET_CLASS_LIST"];
        for (NSString* className in classListDictionary.allKeys) {
            Class targetClass = objc_getClass([className UTF8String]);
            if(targetClass != nil){
                id methodList = [classListDictionary valueForKey:className];
                if([methodList isKindOfClass:[NSArray class]]){
                    [MethodTrace addClassTrace:className methodList:methodList];
                }else{
                    [MethodTrace addClassTrace:className];
                }
            }else{
                NSLog(@"canot find class %@", className);
            }
        }
    }else{
        NSLog(@"Method Trace is disable");
    }
}
