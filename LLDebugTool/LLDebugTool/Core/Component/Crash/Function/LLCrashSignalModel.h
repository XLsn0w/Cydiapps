//
//  LLCrashSignalModel.h
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

#import "LLBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLCrashSignalModel : LLBaseModel

/**
 * Signal Name
 */
@property (copy, nonatomic, readonly) NSString *name;

/**
 * Signal stack symbols
 */
@property (strong, nonatomic, readonly, nullable) NSArray <NSString *>*stackSymbols;

/**
 * Crash Date (yyyy-MM-dd HH:mm:ss)
 */
@property (copy, nonatomic, readonly, nullable) NSString *date;

/**
 * Custom User Identity
 */
@property (copy, nonatomic, readonly, nullable) NSString *userIdentity;

/**
 * Dynamic app Infos
 */
@property (strong, nonatomic, readonly, nullable) NSDictionary <NSString *, NSString *>*appInfos;

/**
 Initial method.
 */
- (instancetype _Nonnull)initWithName:(NSString *)name stackSymbols:(NSArray <NSString *>*_Nullable)stackSymbols date:(NSString *_Nullable)date userIdentity:(NSString *_Nullable)userIdentity appInfos:(NSDictionary <NSString *, NSString *>*_Nullable)appInfos;

@end

NS_ASSUME_NONNULL_END
