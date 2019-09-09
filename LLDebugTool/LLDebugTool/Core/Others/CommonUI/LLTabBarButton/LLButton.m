//
//  LLButton.m
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

#import "LLButton.h"

@interface LLButton ()

@property (nonatomic, copy) NSAttributedString *attributedTitle;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIColor *selectedBackgroundColor;

@property (nonatomic, strong) UIColor *normalBackgroundColor;

@end

@implementation LLButton

#pragma mark - Public
+ (instancetype)buttonWithTitle:(NSString *)title image:(UIImage *)image font:(UIFont *)font tintColor:(UIColor *)tintColor selectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    LLButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.tintColor = tintColor;
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : tintColor}];
    button.attributedTitle = attributedTitle;
    button.image = image;
    button.selectedBackgroundColor = selectedBackgroundColor;
    [button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    return button;
}

#pragma mark - Primary


#pragma mark - Overrides
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    // The label height in tab bar.
    CGFloat titleHeight = 12;
    // The bottom margin in tab bar.
    CGFloat bottomMargin = 1;
    // Calculate label width.
    CGFloat titleWidth = ceil([self.attributedTitle boundingRectWithSize:contentRect.size options:0 context:nil].size.width);
    // Calculate left margin.
    CGFloat leftMargin = (contentRect.size.width - titleWidth) / 2.0;
    // Return new rect.
    return CGRectMake(leftMargin, contentRect.size.height - titleHeight - bottomMargin, titleWidth, titleHeight);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    // The icon size in tab bar.
    CGSize imageSize = CGSizeMake(25, 25);
    // The top margin in tab bar.
    CGFloat topMargin = 5.5;
    // Calculate left margin.
    CGFloat leftMargin = (contentRect.size.width - imageSize.width) / 2.0;
    // Return new rect.
    return CGRectMake(leftMargin, topMargin, imageSize.width, imageSize.height);
}

@end
