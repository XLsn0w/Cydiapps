//
//  NSObject+LL_Runtime.m
//
//  Copyright (c) 2018 LLBaseFoundation Software Foundation (https://github.com/HDB-Li/LLDebugTool)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "NSObject+LL_Runtime.h"

@implementation NSObject (LL_Runtime)

+ (void)LL_swizzleClassMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel {
    Class cls = object_getClass(self);
    
    Method originAddObserverMethod = class_getClassMethod(cls, oriSel);
    Method swizzledAddObserverMethod = class_getClassMethod(cls, swiSel);
    
    [self LL_swizzleMethod:originAddObserverMethod anotherMethod:swizzledAddObserverMethod];
}

+ (void)LL_swizzleInstanceMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel {
    Method originAddObserverMethod = class_getInstanceMethod(self, oriSel);
    Method swizzledAddObserverMethod = class_getInstanceMethod(self, swiSel);
    
    [self LL_swizzleMethod:originAddObserverMethod anotherMethod:swizzledAddObserverMethod];
}

+ (void)LL_swizzleMethod:(Method)method1 anotherMethod:(Method)method2 {
    method_exchangeImplementations(method1, method2);
}

+ (NSArray *)LL_getPropertyNames {
    // Property count
    unsigned int count;
    // Get property list
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    // Get names
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        // objc_property_t
        objc_property_t property = properties[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        if (name.length) {
            [array addObject:name];
        }
    }
    free(properties);
    return array;
}

- (NSArray *)LL_getPropertyNames {
    return [[self class] LL_getPropertyNames];
}

- (void)LL_setStringProperty:(NSString *)string key:(const char *)key {
    objc_setAssociatedObject(self, key, string, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *_Nullable)LL_getStringProperty:(const char *)key {
    return objc_getAssociatedObject(self, key);
}

- (void)LL_setCGFloatProperty:(CGFloat)number key:(const char *)key {
    objc_setAssociatedObject(self, key, @(number), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)LL_getCGFloatProperty:(const char *)key {
    return (CGFloat)[objc_getAssociatedObject(self, key) doubleValue];
}

@end
