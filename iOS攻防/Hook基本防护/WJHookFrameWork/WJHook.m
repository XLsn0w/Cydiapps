//
//  WJHook.m
//  WJHookFrameWork
//
//  Created by zhihuishequ on 2018/5/13.
//  Copyright © 2018年 WinJayQ. All rights reserved.
//

#import "WJHook.h"
#import <objc/runtime.h>

@implementation WJHook

+(void)load
{
    NSLog(@"WJHook---load");
    Method old = class_getInstanceMethod(objc_getClass("ViewController"), @selector(btnClick2:));
    Method new = class_getInstanceMethod(self, @selector(click2Hook:));
    method_exchangeImplementations(old, new);
}
    
-(void)click2Hook:(id)sender{
    NSLog(@"btnClick2交换成功");
}

@end
