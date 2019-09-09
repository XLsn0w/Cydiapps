//
//  NSHTTPURLResponse+LL_Utils.m
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

#import "NSHTTPURLResponse+LL_Utils.h"
#import <dlfcn.h>

typedef CFHTTPMessageRef (*LLHTTPURLResponseGetHTTPProtocol)(CFURLRef response);

@implementation NSHTTPURLResponse (LL_Utils)

- (NSString *_Nullable)LL_stateLine {
    
    NSString *stateLine = nil;
    
    NSString *functionName = @"CFURLResponseGetHTTPResponse";
    LLHTTPURLResponseGetHTTPProtocol getMessage = dlsym(RTLD_DEFAULT, [functionName UTF8String]);
    SEL selector = NSSelectorFromString(@"_CFURLResponse");
    if ([self respondsToSelector:selector] && NULL != getMessage) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        CFTypeRef cfResponse = CFBridgingRetain([self performSelector:selector]);
#pragma clang diagnostic pop
        if (NULL != cfResponse) {
            CFHTTPMessageRef messageRef = getMessage(cfResponse);
            if (NULL != messageRef) {
                CFStringRef stateLineRef = CFHTTPMessageCopyResponseStatusLine(messageRef);
                if (NULL != stateLineRef) {
                    stateLine = (__bridge NSString *)stateLineRef;
                    CFRelease(stateLineRef);
                }
            }
            CFRelease(cfResponse);
        }
    }
    return stateLine;
}

@end
