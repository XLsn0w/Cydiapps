//
//  LLLogHelper.h
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
#import <UIKit/UIKit.h>
#import "LLConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Quick print and save log.
 */
@interface LLLogHelper : NSObject

/**
 Singleton to control enable.
 
 @return Singleton
 */
+ (instancetype)shared;

/**
 Set enable to save log model.
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enable;

/**
 Return log levels string.
 */
+ (NSArray <NSString *>*)levelsDescription;

/**
 Print and save a log model with infos.

 @param file File name.
 @param function Function name.
 @param lineNo Line number.
 @param level Log level.
 @param onEvent Event,can filter by this.
 @param message Message.
 */
- (void)logInFile:(NSString *_Nullable)file function:(NSString *_Nullable)function lineNo:(NSInteger)lineNo level:(LLConfigLogLevel)level onEvent:(NSString *_Nullable)onEvent message:(NSString *_Nullable)message;

@end

NS_ASSUME_NONNULL_END
