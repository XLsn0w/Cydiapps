//
//  LLFilterTextFieldModel.h
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

NS_ASSUME_NONNULL_BEGIN

@interface LLFilterTextFieldModel : NSObject

// Normal
@property (copy, nonatomic, nullable) NSString *title;

@property (copy, nonatomic, nullable) NSString *currentFilter;

@property (assign, nonatomic) CGFloat titleWidth;

@property (assign, nonatomic) BOOL autoAdjustWidthToTitle;

// File Part
@property (copy, nonatomic, nullable) NSArray *filters;

// Date Part
@property (assign, nonatomic) BOOL useDatePicker;

@property (strong, nonatomic, nullable) NSDate *fromDate;

@property (strong, nonatomic, nullable) NSDate *endDate;

@end

NS_ASSUME_NONNULL_END
