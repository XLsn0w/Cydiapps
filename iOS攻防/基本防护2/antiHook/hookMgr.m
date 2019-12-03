//
//  hookMgr.m
//  基本防护
//
//  Created by zhihuishequ on 2018/5/28.
//  Copyright © 2018年 WinJayQ. All rights reserved.
//

#import "hookMgr.h"
#import "fishhook.h"
#import <objc/message.h>

@implementation hookMgr

//专门HOOK
+(void)load{
    NSLog(@"hookMgr--Load");
    //内部用到的交换代码
    Method old = class_getInstanceMethod(objc_getClass("ViewController"), @selector(btnClick1:));
    Method new = class_getInstanceMethod(self, @selector(click1Hook:));
    method_exchangeImplementations(old, new);
    
    //在交换代码之前，把所有的runtime代码写完 
    
    //基本防护
    struct rebinding bd;
    bd.name = "method_exchangeImplementations";
    bd.replacement=myExchang;
    bd.replaced=(void *)&exchangeP;
    
    struct rebinding bd1;
    bd1.name = "method_setImplementation";
    bd1.replacement=myExchang;
    bd1.replaced=(void *)&setIMP;
    
    struct rebinding bd2;
    bd2.name = "method_getImplementation";
    bd2.replacement=myExchang;
    bd2.replaced=(void *)&getIMP;
    
    struct rebinding rebindings[]={bd,bd1,bd2};
    rebind_symbols(rebindings, 3);
}

//保留原来的交换函数
void (* exchangeP)(Method _Nonnull m1, Method _Nonnull m2);
IMP _Nonnull (* setIMP)(Method _Nonnull m, IMP _Nonnull imp);
IMP _Nonnull (* getIMP)(Method _Nonnull m);

//新的函数
void myExchang(Method _Nonnull m1, Method _Nonnull m2){
    NSLog(@"检测到了hook");
    //强制退出
    exit(1);
}
-(void)click1Hook:(id)sender{
    NSLog(@"原来APP的hook保留");
}
@end






















