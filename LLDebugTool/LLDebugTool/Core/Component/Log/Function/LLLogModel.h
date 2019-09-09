//
//  LLLogModel.h
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
#import "LLLogHelper.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Log model. Save and show log infos.
 */
@interface LLLogModel : LLStorageModel

/**
 File name.
 */
@property (nonatomic, copy, readonly, nullable) NSString *file;

/**
 Line number.
 */
@property (nonatomic, assign, readonly) NSInteger lineNo;

/**
 Function name.
 */
@property (nonatomic, copy, readonly, nullable) NSString *function;

/**
 Log level.
 */
@property (nonatomic, assign, readonly) LLConfigLogLevel level;

/**
 Event.
 */
@property (nonatomic, copy, readonly, nullable) NSString *event;

/**
 Message.
 */
@property (nonatomic, copy, readonly) NSString *message;

/**
 Print log's date.
 */
@property (nonatomic, copy, readonly) NSString *date;

/**
 App launch date.
 */
@property (nonatomic, copy, readonly) NSString *launchDate;

/**
 User identity in LLConfig when printing.
 */
@property (nonatomic, copy, readonly, nullable) NSString *userIdentity;

/**
 Model identity.
 */
@property (nonatomic, copy, readonly) NSString *identity;

#pragma mark - Quick Getter
/**
 Convent [level] to NSString.
 */
- (NSString *)levelDescription;

/**
 Convent [date] to NSDate.
 */
- (NSDate *_Nullable)dateDescription;

/**
 Initialization of the model.
 */
- (instancetype _Nonnull)initWithFile:(NSString *_Nullable)file lineNo:(NSInteger)lineNo function:(NSString *_Nullable)function level:(LLConfigLogLevel)level onEvent:(NSString *_Nullable)onEvent message:(NSString *_Nullable)message date:(NSString *)date launchDate:(NSString *)launchDate userIdentity:(NSString *_Nullable)userIdentity;

@end

NS_ASSUME_NONNULL_END
