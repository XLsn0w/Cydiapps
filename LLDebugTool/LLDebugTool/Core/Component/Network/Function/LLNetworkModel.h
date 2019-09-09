//
//  LLNetworkModel.h
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

#import "LLStorageModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Network model. Save and show network request infos.
 */
@interface LLNetworkModel : LLStorageModel

#pragma mark - Request
/**
 Network request start date.
 */
@property (nonatomic, copy) NSString *startDate;

/**
 Network request URL.
 */
@property (nonatomic, strong, nullable) NSURL *url;

/**
 Network request method.
 */
@property (nonatomic, copy, nullable) NSString *method;

/**
 Network request request body.
 */
@property (nonatomic, copy, nullable) NSString *requestBody;

/**
 Network request header.
 */
@property (nonatomic, strong, nullable) NSDictionary <NSString *,NSString *>*headerFields;

/**
 Cookies.
 */
@property (nonatomic, strong, readonly, nullable) NSDictionary <NSString *, NSString *>*cookies;

#pragma mark - Response
/**
 Http response protocol.
 */
@property (nonatomic, copy, nullable) NSString *stateLine;

/**
 Network request mime type.
 */
@property (nonatomic, copy, nullable) NSString *mimeType;

/**
 Network request status code.
 */
@property (nonatomic, copy) NSString *statusCode;

/**
 Network request response data.
 */
@property (nonatomic, strong, nullable) NSData *responseData;

/**
 Is image or not.
 */
@property (nonatomic, assign) BOOL isImage;

/**
 Is gif or not.
 */
@property (nonatomic, assign) BOOL isGif;

/**
 Is html or not.
 */
@property (nonatomic, assign, readonly) BOOL isHTML;

/**
 Is txt or not.
 */
@property (nonatomic, assign, readonly) BOOL isTXT;

/**
 Network request used duration.
 */
@property (nonatomic, copy) NSString *totalDuration;

/**
 Network request error.
 */
@property (nonatomic, strong, nullable) NSError *error;

/**
 Network response header.
 */
@property (nonatomic, strong, nullable) NSDictionary <NSString *,NSString *>*responseHeaderFields;

#pragma mark - Data traffic
/**
 Upload data traffic.
 */
@property (nonatomic, copy, readonly, nullable) NSString *requestDataTraffic;

/**
 Download data traffic.
 */
@property (nonatomic, copy, readonly, nullable) NSString *responseDataTraffic;

/**
 Total data traffic.
 */
@property (nonatomic, copy, readonly, nullable) NSString *totalDataTraffic;

/**
 Request line + headers + body.
 */
@property (nonatomic, assign, readonly) unsigned long long requestDataTrafficValue;

/**
 Response state line + headers + response object.
 */
@property (nonatomic, assign, readonly) unsigned long long responseDataTrafficValue;

/**
 Request data traffic + response data traffic.
 */
@property (nonatomic, assign, readonly) unsigned long long totalDataTrafficValue;

#pragma mark - Other
/**
 Network request identity.
 */
@property (nonatomic, copy, readonly) NSString *identity;

#pragma mark - Quick Getter
/**
 String converted from headerFields.
 */
@property (nonatomic, copy, readonly) NSString *headerString;

/**
 String converted from responseData.
 */
@property (nonatomic, copy, nullable, readonly) NSString *responseString;

/**
 Convent [date] to NSDate.
 */
- (NSDate *_Nullable)dateDescription;

@end

NS_ASSUME_NONNULL_END
