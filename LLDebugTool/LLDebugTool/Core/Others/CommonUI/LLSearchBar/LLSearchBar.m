//
//  LLSearchBar.m
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

#import "LLSearchBar.h"

@implementation LLSearchBarBackView

- (CGSize)intrinsicContentSize {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 12 * 2, 44);
}

@end

@implementation LLSearchBar

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *view in self.subviews) {
        for (UIView *subView in view.subviews) {
            if ([subView isKindOfClass:[UITextField class]]) {
                CGRect frame = subView.frame;
                if (frame.size.height != 28) {
                    CGRect newFrame = CGRectMake(frame.origin.x, (frame.origin.y * 2 + frame.size.height - 28 ) / 2.0, frame.size.width, 28);
                    subView.frame = newFrame;
                }
            }
        }
    }
}

@end
