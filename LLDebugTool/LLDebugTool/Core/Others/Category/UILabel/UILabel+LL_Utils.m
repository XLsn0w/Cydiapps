//
//  UILabel+LL_Utils.m
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

#import "UILabel+LL_Utils.h"

@implementation UILabel (LL_Utils)

- (NSString *)LL_textAlignmentDescription {
    switch (self.textAlignment) {
        case NSTextAlignmentLeft:
            return @"Left";
        case NSTextAlignmentRight:
            return @"Right";
        case NSTextAlignmentCenter:
            return @"Center";
        case NSTextAlignmentJustified:
            return @"Justified";
        case NSTextAlignmentNatural:
            return @"Natural";
        default:
            return nil;
    }
}

- (NSString *)LL_baselineAdjustmentDescription {
    switch (self.baselineAdjustment) {
        case UIBaselineAdjustmentAlignBaselines:
            return @"Baselines";
        case UIBaselineAdjustmentAlignCenters:
            return @"Centers";
        case UIBaselineAdjustmentNone:
            return @"None";
        default:
            return nil;
    }
}

- (NSString *_Nullable)LL_lineBreakModeDescription {
    switch (self.lineBreakMode) {
        case NSLineBreakByWordWrapping:
            return @"Word Wrapping";
        case NSLineBreakByCharWrapping:
            return @"Char Wrapping";
        case NSLineBreakByClipping:
            return @"Clipping";
        case NSLineBreakByTruncatingHead:
            return @"Truncate Head";
        case NSLineBreakByTruncatingTail:
            return @"Truncate Tail";
        case NSLineBreakByTruncatingMiddle:
            return @"Truncate Middle";
        default:
            return nil;
    }
}

@end
