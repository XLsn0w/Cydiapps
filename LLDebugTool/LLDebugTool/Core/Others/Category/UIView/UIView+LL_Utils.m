//
//  UIView+LL_Utils.m
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

#import "UIView+LL_Utils.h"
#import "NSObject+LL_Runtime.h"

static const char kLLHorizontalPaddingKey;
static const char kLLVerticalPaddingKey;

@implementation UIView (LL_Utils)

+ (void)load {
    [self LL_swizzleInstanceMethodWithOriginSel:@selector(sizeToFit) swizzledSel:@selector(LL_sizeToFit)];
}

- (void)LL_sizeToFit {
    [self LL_sizeToFit];
    CGRect frame = self.frame;
    frame.size = CGSizeMake(frame.size.width + 2 * self.LL_horizontalPadding, frame.size.height + 2 * self.LL_verticalPadding);
    self.frame = frame;
}

- (void)setLL_horizontalPadding:(CGFloat)LL_horizontalPadding {
    [self LL_setCGFloatProperty:LL_horizontalPadding key:&kLLHorizontalPaddingKey];
}

- (CGFloat)LL_horizontalPadding {
    return [self LL_getCGFloatProperty:&kLLHorizontalPaddingKey];
}

- (void)setLL_verticalPadding:(CGFloat)LL_verticalPadding {
    [self LL_setCGFloatProperty:LL_verticalPadding key:&kLLVerticalPaddingKey];
}

- (CGFloat)LL_verticalPadding {
    return [self LL_getCGFloatProperty:&kLLVerticalPaddingKey];
}

- (void)setLL_x:(CGFloat)LL_x {
    CGRect frame = self.frame;
    frame.origin.x = LL_x;
    self.frame = frame;
}

- (CGFloat)LL_x {
    return self.frame.origin.x;
}

- (void)setLL_y:(CGFloat)LL_y {
    CGRect frame = self.frame;
    frame.origin.y = LL_y;
    self.frame = frame;
}

- (CGFloat)LL_y {
    return self.frame.origin.y;
}

- (void)setLL_centerX:(CGFloat)LL_centerX {
    CGPoint center = self.center;
    center.x = LL_centerX;
    self.center = center;
}

- (CGFloat)LL_centerX {
    return self.center.x;
}

- (void)setLL_centerY:(CGFloat)LL_centerY {
    CGPoint center = self.center;
    center.y = LL_centerY;
    self.center = center;
}

- (CGFloat)LL_centerY {
    return self.center.y;
}

- (void)setLL_width:(CGFloat)LL_width {
    CGRect frame = self.frame;
    frame.size.width = LL_width;
    self.frame = frame;
}

- (CGFloat)LL_width {
    return self.frame.size.width;
}

- (void)setLL_height:(CGFloat)LL_height {
    CGRect frame = self.frame;
    frame.size.height = LL_height;
    self.frame = frame;
}

- (CGFloat)LL_height {
    return self.frame.size.height;
}

- (void)setLL_size:(CGSize)LL_size {
    CGRect frame = self.frame;
    frame.size = LL_size;
    self.frame = frame;
}

- (CGSize)LL_size {
    return self.frame.size;
}

- (void)setLL_top:(CGFloat)LL_top {
    CGRect frame = self.frame;
    frame.origin.y = LL_top;
    self.frame = frame;
}

- (CGFloat)LL_top {
    return self.frame.origin.y;
}

- (void)setLL_bottom:(CGFloat)LL_bottom {
    CGRect frame = self.frame;
    frame.origin.y = LL_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)LL_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setLL_left:(CGFloat)LL_left {
    CGRect frame = self.frame;
    frame.origin.x = LL_left;
    self.frame = frame;
}

- (CGFloat)LL_left {
    return self.frame.origin.x;
}

- (void)setLL_right:(CGFloat)LL_right {
    CGRect frame = self.frame;
    frame.origin.x = LL_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)LL_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (NSString *)LL_contentModeDescription {
    switch (self.contentMode) {
        case UIViewContentModeScaleToFill:
            return @"ScaleToFill";
        case UIViewContentModeScaleAspectFit:
            return @"ScaleAspectFit";
        case UIViewContentModeScaleAspectFill:
            return @"ScaleAspectFill";
        case UIViewContentModeRedraw:
            return @"Redraw";
        case UIViewContentModeCenter:
            return @"Center";
        case UIViewContentModeTop:
            return @"Top";
        case UIViewContentModeBottom:
            return @"Bottom";
        case UIViewContentModeLeft:
            return @"Left";
        case UIViewContentModeRight:
            return @"Right";
        case UIViewContentModeTopLeft:
            return @"TopLeft";
        case UIViewContentModeTopRight:
            return @"TopRight";
        case UIViewContentModeBottomLeft:
            return @"BottomLeft";
        case UIViewContentModeBottomRight:
            return @"BottomRight";
        default:
            return nil;
    }
}

- (void)LL_setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)LL_setBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
}

- (void)LL_removeAllSubviews {
    [self LL_removeAllSubviewsIgnoreIn:nil];
}

- (void)LL_removeAllSubviewsIgnoreIn:(NSArray <UIView *>*_Nullable)views {
    for (UIView *subview in self.subviews) {
        if (![views containsObject:subview]) {
            [subview removeFromSuperview];
        }
    }
}

- (UIView *_Nullable)LL_bottomView {
    UIView *view = nil;
    for (UIView *subview in self.subviews) {
        if (subview.LL_bottom > view.LL_bottom) {
            view = subview;
        }
    }
    return view;
}

- (void)LL_AddClickListener:(id)target action:(SEL)action {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
}

- (UIImage *)LL_convertViewToImage {
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
