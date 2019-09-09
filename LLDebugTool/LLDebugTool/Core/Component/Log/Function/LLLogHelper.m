//
//  LLLogHelper.m
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

#import "LLLogHelper.h"
#import "LLStorageManager.h"
#import "LLLogModel.h"
#import "LLConfig.h"
#import "LLFormatterTool.h"
#import "LLConfig.h"
#import "NSObject+LL_Utils.h"

static LLLogHelper *_instance = nil;

@implementation LLLogHelper

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLLogHelper alloc] init];
    });
    return _instance;
}

+ (NSArray <NSString *>*)levelsDescription {
    return @[@"Default",@"Alert",@"Warning",@"Error"];
}

- (void)logInFile:(NSString *)file function:(NSString *)function lineNo:(NSInteger)lineNo level:(LLConfigLogLevel)level onEvent:(NSString *)onEvent message:(NSString *)message {
    NSString *date = [[LLFormatterTool shared] stringFromDate:[NSDate date] style:FormatterToolDateStyle1];
    LLConfigLogStyle logStyle = [LLConfig shared].logStyle;
    switch (logStyle) {
        case LLConfigLogDetail:
        case LLConfigLogFileFuncDesc:
        case LLConfigLogFileDesc:{
            
            NSString *header = @"\n--------Debug Tool--------";
            NSString *onEventString = [NSString stringWithFormat:@"\nEvent:<%@>",onEvent];
            NSString *fileString = [NSString stringWithFormat:@"\nFile:<%@>",file];
            NSString *lineNoString = [NSString stringWithFormat:@"\nLine:<%ld>",(long)lineNo];
            NSString *funcString = [NSString stringWithFormat:@"\nFunc:<%@>",function];
            NSString *dateString = [NSString stringWithFormat:@"\nDate:<%@>",date];
            NSString *messageString = [NSString stringWithFormat:@"\nDesc:<%@>",message];
            NSString *footer = @"\n--------------------------";

            NSMutableString *log = [[NSMutableString alloc] initWithString:header];
            if (onEvent.length) {
                [log appendString:onEventString];
            }
            [log appendString:fileString];
            if (logStyle == LLConfigLogDetail) {
                [log appendString:lineNoString];
            }
            if (logStyle == LLConfigLogDetail || logStyle == LLConfigLogFileFuncDesc) {
                [log appendString:funcString];
            }
            if (logStyle == LLConfigLogDetail) {
                [log appendString:dateString];
            }
            [log appendString:messageString];
            [log appendString:footer];
            NSLog(@"%@", log);
        }
            break;
        case LLConfigLogNone: {
        }
            break;
        case LLConfigLogNormal:
        default:{
            NSLog(@"%@",message);
        }
            break;
    }

    if (_enable) {
        LLLogModel *model = [[LLLogModel alloc] initWithFile:file lineNo:lineNo function:function level:level onEvent:onEvent message:message date:date launchDate:[NSObject LL_launchDate] userIdentity:[LLConfig shared].userIdentity];
        [[LLStorageManager shared] saveModel:model complete:nil];
    }
}

@end
