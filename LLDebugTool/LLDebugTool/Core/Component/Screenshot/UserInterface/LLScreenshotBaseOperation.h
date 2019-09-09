//
//  LLScreenshotBaseOperation.h
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
#import "LLScreenshotSelectorModel.h"
#import "LLScreenshotDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLScreenshotBaseOperation : NSObject

@property (nonatomic, assign, readonly) LLScreenshotAction action;

@property (nonatomic, assign, readonly) LLScreenshotSelectorAction size;

@property (nonatomic, assign, readonly) LLScreenshotSelectorAction color;

@property (nonatomic, strong, readonly) CAShapeLayer *layer;

/**
 Specifies the initialization method.
 */
- (instancetype _Nonnull)initWithSelector:(LLScreenshotSelectorModel *)selector action:(LLScreenshotAction)action;

/**
 Subclasses need to be rewritten.
 */
- (void)drawImageView:(CGRect)rect;

@end

@interface LLScreenshotTwoValueOperation : LLScreenshotBaseOperation

// CGPoint

/**
 CGPoint value. Mark start point.
 */
@property (nonatomic, strong, nullable) NSValue *startValue;

/**
 CGPoint value. Mark end point.
 */
@property (nonatomic, strong, nullable) NSValue *endValue;

@end

@interface LLScreenshotRectOperation : LLScreenshotTwoValueOperation

@end

@interface LLScreenshotRoundOperation : LLScreenshotTwoValueOperation

@end

@interface LLScreenshotLineOperation : LLScreenshotTwoValueOperation

@end

@interface LLScreenshotPenOperation : LLScreenshotBaseOperation

/**
 CGPoint value. add operation point.
 */
- (void)addValue:(NSValue *)value;

@end

@interface LLScreenshotTextOperation : LLScreenshotBaseOperation <UITextViewDelegate>

/**
 Use to input text.
 */
@property (nonatomic, strong, readonly) UITextView *textView;

@end

NS_ASSUME_NONNULL_END
