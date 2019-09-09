//
//  UIView+LL_Utils.h
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

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LL_Utils)

@property (nonatomic, assign) CGFloat LL_horizontalPadding;

@property (nonatomic, assign) CGFloat LL_verticalPadding;

@property (nonatomic, assign) CGFloat LL_x;

@property (nonatomic, assign) CGFloat LL_y;

@property (nonatomic, assign) CGFloat LL_centerX;

@property (nonatomic, assign) CGFloat LL_centerY;

@property (nonatomic, assign) CGFloat LL_width;

@property (nonatomic, assign) CGFloat LL_height;

@property (nonatomic, assign) CGSize LL_size;

@property (nonatomic, assign) CGFloat LL_top;

@property (nonatomic, assign) CGFloat LL_bottom;

@property (nonatomic, assign) CGFloat LL_left;

@property (nonatomic, assign) CGFloat LL_right;

@property (nonatomic, copy, readonly, nullable) NSString *LL_contentModeDescription;

- (void)LL_setCornerRadius:(CGFloat)cornerRadius;

- (void)LL_setBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

- (void)LL_removeAllSubviews;

- (void)LL_removeAllSubviewsIgnoreIn:(NSArray <UIView *>*_Nullable)views;

- (UIView *_Nullable)LL_bottomView;

- (void)LL_AddClickListener:(id)target action:(SEL)action;

- (UIImage *)LL_convertViewToImage;

@end

NS_ASSUME_NONNULL_END
