//
//  LLNetworkModel.m
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

#import "LLNetworkModel.h"
#import "LLTool.h"
#import "NSString+LL_Utils.h"
#import "NSData+LL_Utils.h"
#import "NSDictionary+LL_Utils.h"
#import "LLFormatterTool.h"

@interface LLNetworkModel ()

@property (nonatomic, copy, nullable) NSString *requestDataTraffic;

@property (nonatomic, copy, nullable) NSString *responseDataTraffic;

@property (nonatomic, copy, nullable) NSString *totalDataTraffic;

@property (nonatomic, assign) unsigned long long requestDataTrafficValue;

@property (nonatomic, assign) unsigned long long responseDataTrafficValue;

@property (nonatomic, assign) unsigned long long totalDataTrafficValue;

@property (nonatomic, copy) NSString *headerString;

@property (nonatomic, copy) NSString *responseHeaderString;

@property (nonatomic, copy) NSString *responseString;

@property (nonatomic, strong) NSDate *dateDescription;

@property (nonatomic, strong, nullable) NSDictionary <NSString *, NSString *>*cookies;

@end

@implementation LLNetworkModel

- (void)setStartDate:(NSString *)startDate {
    if (![_startDate isEqualToString:startDate]) {
        _startDate = [startDate copy];
        if (!_identity) {
            _identity = [startDate stringByAppendingString:[LLTool absolutelyIdentity]];
        }
    }
}

- (void)setMimeType:(NSString *)mimeType {
    if (![_mimeType isEqualToString:mimeType]) {
        _mimeType = [mimeType copy];
        [self dealWithMimeType:mimeType];
    }
}

- (NSString *)headerString {
    if (!_headerString) {
        _headerString = [self.headerFields LL_toJsonString];
    }
    return _headerString;
}

- (NSString *)responseHeaderString {
    if (!_responseHeaderString) {
        _responseHeaderString = [self.responseHeaderFields LL_toJsonString];
    }
    return _responseHeaderString;
}

- (NSString *)responseString {
    if (!_responseString && !self.isImage) {
        _responseString = [self.responseData LL_toJsonString];
    }
    return _responseString;
}

- (NSDate *)dateDescription {
    if (!_dateDescription && self.startDate.length) {
        _dateDescription = [[LLFormatterTool shared] dateFromString:self.startDate style:FormatterToolDateStyle1];
    }
    return _dateDescription;
}

- (NSDictionary<NSString *,NSString *> *)cookies {
    if (!_cookies) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookiesForURL:self.url];
        if (cookies.count) {
            _cookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        }
    }
    return _cookies;
}

- (NSString *)requestDataTraffic {
    if (!_requestDataTraffic) {
        _requestDataTraffic = [NSByteCountFormatter stringFromByteCount:self.requestDataTrafficValue countStyle:NSByteCountFormatterCountStyleFile];
    }
    return _requestDataTraffic;
}

- (NSString *)responseDataTraffic {
    if (!_responseDataTraffic) {
        _responseDataTraffic = [NSByteCountFormatter stringFromByteCount:self.responseDataTrafficValue countStyle:NSByteCountFormatterCountStyleFile];
    }
    return _responseDataTraffic;
}

- (NSString *)totalDataTraffic {
    if (!_totalDataTraffic) {
        _totalDataTraffic = [NSByteCountFormatter stringFromByteCount:self.totalDataTrafficValue countStyle:NSByteCountFormatterCountStyleFile];
    }
    return _totalDataTraffic;
}

- (unsigned long long)requestDataTrafficValue {
    if (!_requestDataTrafficValue) {
        // Can't get really header in a NSURLRequest, most of the missing headers are small, just add cookie.
        unsigned long long headerTraffic = [self dataTrafficLength:self.headerString] + [self dataTrafficLength:self.cookies.LL_toJsonString];
        unsigned long long bodyTraffic = self.requestBody.LL_byteLength;
        unsigned long long lineTraffic = [self dataTrafficLength:[self simulationHTTPRequestLine]];
        _requestDataTrafficValue = headerTraffic + bodyTraffic + lineTraffic;
    }
    return _requestDataTrafficValue;
}

- (unsigned long long)responseDataTrafficValue {
    if (!_responseDataTrafficValue) {
        unsigned long long headerTraffic = [self dataTrafficLength:self.responseHeaderString];
        unsigned long long bodyTraffic = self.responseData.length;
        unsigned long long stateLineTraffic = [self dataTrafficLength:self.stateLine];
        _responseDataTrafficValue = headerTraffic + bodyTraffic + stateLineTraffic;
    }
    return _responseDataTrafficValue;
}

- (unsigned long long)totalDataTrafficValue {
    if (!_totalDataTrafficValue) {
        _totalDataTrafficValue = self.requestDataTrafficValue + self.responseDataTrafficValue;
    }
    return _totalDataTrafficValue;
}

- (NSString *)storageIdentity {
    return self.identity;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[LLNetworkModel] \n url:%@,\n startDate:%@,\n method:%@,\n mimeType:%@,\n requestBody:%@,\n statusCode:%@,\n header:%@,\n response:%@,\n totalDuration:%@,\n dataTraffic:%@,\n error:%@,\n identity:%@",self.url.absoluteString,self.startDate,self.method,self.mimeType,self.requestBody,self.statusCode,self.headerString,self.responseString,self.totalDuration,self.totalDataTraffic,self.error.localizedDescription,self.identity];
}

#pragma mark - Primary
- (void)dealWithMimeType:(NSString *)mimeType {
    // See http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types
    NSString *mime = mimeType.lowercaseString;
    if ([mime isEqualToString:@"image/jpeg"] || [mime isEqualToString:@"image/png"] || [mime isEqualToString:@"image/jpg"]) {
        _isImage = YES;
    } else if ([mime isEqualToString:@"image/gif"]) {
        _isImage = YES;
        _isGif = YES;
    } else if ([mime isEqualToString:@"text/html"]) {
        _isHTML = YES;
    } else if ([mime isEqualToString:@"text/plain"]) {
        _isTXT = YES;
    } else if ([mime isEqualToString:@"video/quicktime"]) {
        
    } else if ([mime isEqualToString:@"video/x-msvideo"]) {
        
    } else if ([mime isEqualToString:@"audio/mpeg"]) {
        
    } else if ([mime isEqualToString:@"audio/x-wav"]) {
        
    } else if ([mime isEqualToString:@"application/json"]) {
        
    } else if ([mime isEqualToString:@"application/pdf"]) {
        
    } else if ([mime isEqualToString:@"application/vnd.ms-excel"]) {
        
    } else if ([mime isEqualToString:@"application/vnd.ms-powerpoint"]) {
        
    } else if ([mime isEqualToString:@"application/msword"]) {
        
    }
}

- (unsigned long long)dataTrafficLength:(NSString *)string {
    if (string == nil || ![string isKindOfClass:[NSString class]] || string.length == 0) {
        return 0;
    }
    
    return [string dataUsingEncoding:NSUTF8StringEncoding].length ?: string.LL_byteLength;
}

- (NSString *)simulationHTTPRequestLine {
    return [NSString stringWithFormat:@"%@ %@ %@\n", self.method, self.url.path, @"HTTP/1.1"];
}

@end
