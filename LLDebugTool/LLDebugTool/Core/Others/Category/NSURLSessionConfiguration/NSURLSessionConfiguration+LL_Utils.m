//
//  NSURLSessionConfiguration+LL_Utils.m
//
//  Copyright (c) 2018 LLDebugTool Software Foundation (https://github.com/HDB-Li/LLDebugTool)
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

#import "NSURLSessionConfiguration+LL_Utils.h"
#import "LLURLProtocol.h"
#import "LLNetworkHelper.h"
#import "NSObject+LL_Runtime.h"

@implementation NSURLSessionConfiguration (LL_Utils)

+ (void)load {
    [self LL_swizzleClassMethodWithOriginSel:@selector(defaultSessionConfiguration) swizzledSel:@selector(LL_defaultSessionConfiguration)];
    
    [self LL_swizzleClassMethodWithOriginSel:@selector(ephemeralSessionConfiguration) swizzledSel:@selector(LL_ephemeralSessionConfiguration)];
    
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ? : NSClassFromString(@"NSURLSessionConfiguration");
    
    Method method1 = class_getInstanceMethod(cls, @selector(protocolClasses));
    Method method2 = class_getInstanceMethod([NSURLSessionConfiguration class], @selector(LL_protocolClasses));
    
    [self LL_swizzleMethod:method1 anotherMethod:method2];
}

+ (NSURLSessionConfiguration *)LL_defaultSessionConfiguration {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration LL_defaultSessionConfiguration];
    if ([LLNetworkHelper shared].isEnabled) {
        NSMutableArray *protocols = [[NSMutableArray alloc] initWithArray:config.protocolClasses];
        if (![protocols containsObject:[LLURLProtocol class]]) {
            [protocols insertObject:[LLURLProtocol class] atIndex:0];
        }
        config.protocolClasses = protocols;
    }
    return config;
}

+ (NSURLSessionConfiguration *)LL_ephemeralSessionConfiguration {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration LL_ephemeralSessionConfiguration];
    if ([LLNetworkHelper shared].isEnabled) {
        NSMutableArray *protocols = [[NSMutableArray alloc] init];
        [protocols addObjectsFromArray:config.protocolClasses];
        if (![protocols containsObject:[LLURLProtocol class]]) {
            [protocols insertObject:[LLURLProtocol class] atIndex:0];
        }
        config.protocolClasses = protocols;
    }
    return config;
}

- (NSArray<Class> *)LL_protocolClasses {
    NSMutableArray *protocols = [[NSMutableArray alloc] init];
    [protocols addObjectsFromArray:[self LL_protocolClasses]];
    if ([LLNetworkHelper shared].isEnabled) {
        if (![protocols containsObject:[LLURLProtocol class]]) {
            [protocols insertObject:[LLURLProtocol class] atIndex:0];
        }
    }
    return protocols;
}

@end
