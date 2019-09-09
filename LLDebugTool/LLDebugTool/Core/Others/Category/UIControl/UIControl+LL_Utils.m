//
//  UIControl+LL_Utils.m
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

#import "UIControl+LL_Utils.h"

@implementation UIControl (LL_Utils)

- (NSString *_Nullable)LL_contentVerticalAlignmentDescription {
    switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentCenter:
            return @"Centered";
        case UIControlContentVerticalAlignmentTop:
            return @"Top";
        case UIControlContentVerticalAlignmentBottom:
            return @"Bottom";
        case UIControlContentVerticalAlignmentFill:
            return @"Fill";
        default:
            return nil;
    }
}

- (NSString *_Nullable)LL_contentHorizontalAlignmentDescription {
    switch (self.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentCenter:
            return @"Centered";
        case UIControlContentHorizontalAlignmentLeft:
            return @"Left";
        case UIControlContentHorizontalAlignmentRight:
            return @"Right";
        case UIControlContentHorizontalAlignmentFill:
            return @"Fill";
        case UIControlContentHorizontalAlignmentLeading:
            return @"Leading";
        case UIControlContentHorizontalAlignmentTrailing:
            return @"Trailing";
        default:
            return nil;
    }
}

@end
