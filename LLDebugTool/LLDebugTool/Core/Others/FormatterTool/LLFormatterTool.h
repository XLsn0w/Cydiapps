//
//  LLFormatterTool.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Date formatter style.

 - FormatterToolDateStyle1: LLConfig.dateFormatter
 - FormatterToolDateStyle2: "yyyy-MM-dd"
 - FormatterToolDateStyle3: "yyyy-MM-dd HH:mm:ss"
 */
typedef NS_ENUM(NSUInteger, FormatterToolDateStyle) {
    FormatterToolDateStyle1,
    FormatterToolDateStyle2,
    FormatterToolDateStyle3
};

@interface LLFormatterTool : NSObject

/**
 Singleton

 @return Singleton.
 */
+ (instancetype)shared;

/**
 Format date use style.

 @param date Date.
 @param style FormatterToolDateStyle.
 @return Format string.
 */
- (NSString *_Nullable)stringFromDate:(NSDate *)date style:(FormatterToolDateStyle)style;

/**
 Get date use formatted string use style

 @param string Formatted string.
 @param style FormatterToolDateStyle
 @return Date.
 */
- (NSDate *_Nullable)dateFromString:(NSString *)string style:(FormatterToolDateStyle)style;

/**
 Format a CGFloat value with maximumFractionDigits = 2.

 @param number NSNumber.
 @return Format string.
 */
- (NSString *)formatNumber:(NSNumber *)number;

@end

NS_ASSUME_NONNULL_END
