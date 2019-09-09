//
//  LLLogModel.m
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

#import "LLLogModel.h"
#import "LLFormatterTool.h"
#import "LLConfig.h"
#import "LLTool.h"

@interface LLLogModel ()

@property (nonatomic, strong) NSDate *dateDescription;

@end

@implementation LLLogModel

- (instancetype)initWithFile:(NSString *)file lineNo:(NSInteger)lineNo function:(NSString *)function level:(LLConfigLogLevel)level onEvent:(NSString *)onEvent message:(NSString *)message date:(NSString *)date launchDate:(NSString *)launchDate userIdentity:(NSString *)userIdentity {
    if (self = [super init]) {
        _file = [file copy];
        _lineNo = lineNo;
        _function = [function copy];
        _level = level;
        _event = [onEvent copy];
        _message = [message copy];
        _date = [date copy];
        _launchDate = [launchDate copy];
        _userIdentity = [userIdentity copy];
        _identity = [date stringByAppendingString:[LLTool absolutelyIdentity]];
    }
    return self;
}

- (NSString *)levelDescription {
    switch (self.level) {
        case LLConfigLogLevelDefault:
            return @"Default";
            break;
        case LLConfigLogLevelAlert:
            return @"Alert";
            break;
        case LLConfigLogLevelWarning:
            return @"Warning";
            break;
        case LLConfigLogLevelError:
            return @"Error";
            break;
        default:
            break;
    }
    return @"Unknown";
}

- (NSDate *)dateDescription {
    if (!_dateDescription && self.date.length) {
        _dateDescription = [[LLFormatterTool shared] dateFromString:self.date style:FormatterToolDateStyle1];
    }
    return _dateDescription;
}

- (NSString *)storageIdentity {
    return self.identity;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[LLLogModel] \n message:%@,\n file:%@,\n function:%@,\n lineNo:%ld,\n event:%@,\n level:%@,\n date:%@,\n launchDate:%@,\n userIdentity:%@,\n identity:%@",self.message,self.file,self.function,(long)self.lineNo,self.event,self.levelDescription,self.dateDescription,self.launchDate,self.userIdentity,self.identity];
}

@end
