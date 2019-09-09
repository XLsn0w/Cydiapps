//
//  LLScreenshotImageView.h
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

#import <UIKit/UIKit.h>
#import "LLScreenshotBaseOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLScreenshotImageView : UIView

/**
 Image to show.
 */
@property (nonatomic, strong, nullable) UIImage *image;

/**
 Current operation.
 */
@property (nonatomic, strong, readonly, nullable) LLScreenshotBaseOperation *currentOperation;

/**
 Current action.
 */
@property (nonatomic, assign) LLScreenshotAction currentAction;

/**
 Current selector model.
 */
@property (nonatomic, strong, nullable) LLScreenshotSelectorModel *currentSelectorModel;

/**
 Specifies the initialization method.
 */
- (instancetype _Nonnull)initWithFrame:(CGRect)frame;

/**
 Remove last operation in operations.
 */
- (void)removeLastOperation;

@end

NS_ASSUME_NONNULL_END
