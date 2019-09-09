//
//  UIButton+LL_Utils.m
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

#import "UIButton+LL_Utils.h"
#import "UIImage+LL_Utils.h"

@implementation UIButton (LL_Utils)

- (void)LL_setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[UIImage LL_imageWithColor:backgroundColor] forState:state];
}

- (NSString *_Nullable)LL_typeDescription {
    switch (self.buttonType) {
        case UIButtonTypeCustom:
            return @"Custom";
        case UIButtonTypeSystem:
            return @"System";
        case UIButtonTypeDetailDisclosure:
            return @"Detail Disclosure";
        case UIButtonTypeInfoLight:
            return @"Info Light";
        case UIButtonTypeInfoDark:
            return @"Info Dark";
        case UIButtonTypeContactAdd:
            return @"Contact Add";
        default:
            return nil;
    }
}

- (NSString *)LL_stateDescription {
    switch (self.state) {
        case UIControlStateNormal:
            return @"Normal";
        case UIControlStateFocused:
            return @"Focused";
        case UIControlStateDisabled:
            return @"Disabled";
        case UIControlStateReserved:
            return @"Reserved";
        case UIControlStateSelected:
            return @"Selected";
        case UIControlStateApplication:
            return @"Application";
        case UIControlStateHighlighted:
            return @"Highlighted";
        default:
            return nil;
    }
}

// 设置颜色
+ (UIImage *)ll_imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
