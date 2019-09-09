//
//  LLScreenshotBaseOperation.m
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

#import "LLScreenshotBaseOperation.h"
#import "LLImageNameConfig.h"
#import "LLMacros.h"
#import "LLTool.h"
#import "LLFactory.h"

@interface LLScreenshotBaseOperation ()

@property (nonatomic, strong) LLScreenshotSelectorModel *selector;

@property (nonatomic, strong) UIBezierPath *path;

@property (nonatomic, strong) UIColor *redColor;

@property (nonatomic, strong) UIColor *blueColor;

@property (nonatomic, strong) UIColor *greenColor;

@property (nonatomic, strong) UIColor *yellowColor;

@property (nonatomic, strong) UIColor *grayColor;

@property (nonatomic, strong) UIColor *whiteColor;

@property (nonatomic, strong) UIFont *smallFont;

@property (nonatomic, strong) UIFont *mediumFont;

@property (nonatomic, strong) UIFont *bigFont;

@end

@implementation LLScreenshotBaseOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _selector = [[LLScreenshotSelectorModel alloc] initWithSize:LLScreenshotSelectorActionSmall color:LLScreenshotSelectorActionRed];
        _action = LLScreenshotActionRect;
        _path = [UIBezierPath bezierPath];
        _layer = [CAShapeLayer layer];
    }
    return self;
}

- (instancetype _Nonnull)initWithSelector:(LLScreenshotSelectorModel *)selector action:(LLScreenshotAction)action {
    if (self = [super init]) {
        _selector = selector;
        _action = action;
        _path = [UIBezierPath bezierPath];
        _layer = [CAShapeLayer layer];
    }
    return self;
}

- (void)drawImageView:(CGRect)rect {
    [LLTool log:[NSString stringWithFormat:@"%@ : Subclasses need to be rewritten.", NSStringFromClass(self.class)]];
}

- (LLScreenshotSelectorAction)size {
    return _selector.size;
}

- (LLScreenshotSelectorAction)color {
    return _selector.color;
}

- (UIColor *)redColor {
    if (!_redColor) {
        _redColor = [UIColor colorWithRed:0xd8/255.0 green:0x1e/255.0 blue:0x06/255.0 alpha:1];
    }
    return _redColor;
}

- (UIColor *)blueColor {
    if (!_blueColor) {
        _blueColor = [UIColor colorWithRed:0x12/255.0 green:0x96/255.0 blue:0xdb/255.0 alpha:1];
    }
    return _blueColor;
}

- (UIColor *)greenColor {
    if (!_greenColor) {
        _greenColor = [UIColor colorWithRed:0x1a/255.0 green:0xfa/255.0 blue:0x29/255.0 alpha:1];
    }
    return _greenColor;
}

- (UIColor *)yellowColor {
    if (!_yellowColor) {
        _yellowColor = [UIColor colorWithRed:0xf4/255.0 green:0xea/255.0 blue:0x2a/255.0 alpha:1];
    }
    return _yellowColor;
}

- (UIColor *)grayColor {
    if (!_grayColor) {
        _grayColor = [UIColor colorWithRed:0x2c/255.0 green:0x2c/255.0 blue:0x2c/255.0 alpha:1];
    }
    return _grayColor;
}

- (UIColor *)whiteColor {
    if (!_whiteColor) {
        _whiteColor = [UIColor whiteColor];
    }
    return _whiteColor;
}

- (UIFont *)smallFont {
    if (!_smallFont) {
        _smallFont = [UIFont systemFontOfSize:12];
    }
    return _smallFont;
}

- (UIFont *)mediumFont {
    if (!_mediumFont) {
        _mediumFont = [UIFont systemFontOfSize:14];
    }
    return _mediumFont;
}

- (UIFont *)bigFont {
    if (!_bigFont) {
        _bigFont = [UIFont systemFontOfSize:17];
    }
    return _bigFont;
}

#pragma mark - Primary
- (CGRect)rectWithPoint:(CGPoint)point {
    CGFloat size = [self sizeBySelector] / 2.0;
    return CGRectMake(point.x - size, point.y - size, size, size);
}

- (CGFloat)sizeBySelector {
    switch (self.size) {
        case LLScreenshotSelectorActionSmall:
            return 3;
        case LLScreenshotSelectorActionMedium:
            return 6;
        case LLScreenshotSelectorActionBig:
            return 9;
        default:
            break;
    }
    return 3;
}

- (UIColor *)colorBySelector {
    switch (self.color) {
        case LLScreenshotSelectorActionRed:
            return self.redColor;
        case LLScreenshotSelectorActionBlue:
            return self.blueColor;
        case LLScreenshotSelectorActionGreen:
            return self.greenColor;
        case LLScreenshotSelectorActionYellow:
            return self.yellowColor;
        case LLScreenshotSelectorActionGray:
            return self.grayColor;
        case LLScreenshotSelectorActionWhite:
            return self.whiteColor;
        default:
            break;
    }
    return self.whiteColor;
}

- (UIFont *)fontBySelector {
    switch (self.size) {
        case LLScreenshotSelectorActionSmall:
            return self.smallFont;
        case LLScreenshotSelectorActionMedium:
            return self.mediumFont;
        case LLScreenshotSelectorActionBig:
            return self.bigFont;
        default:
            break;
    }
    return self.smallFont;
}

@end

@implementation LLScreenshotTwoValueOperation

@end

@implementation LLScreenshotRectOperation

- (void)drawImageView:(CGRect)rect {
    CGRect rectPath = CGRectZero;
    if (self.startValue && self.endValue) {
        rectPath = [LLTool rectWithPoint:self.startValue.CGPointValue otherPoint:self.endValue.CGPointValue];
    }
    [self configPathWithRect:rectPath];
}

- (void)configPathWithRect:(CGRect)rect {
    self.path = [UIBezierPath bezierPathWithRect:rect];
    self.layer.lineWidth = [self sizeBySelector];
    self.layer.strokeColor = [self colorBySelector].CGColor;
    self.layer.fillColor = nil;
    self.layer.path = self.path.CGPath;
}

@end

@implementation LLScreenshotRoundOperation

- (void)drawImageView:(CGRect)rect {
    CGRect rectPath = CGRectZero;
    if (self.startValue && self.endValue) {
        rectPath = [LLTool rectWithPoint:self.startValue.CGPointValue otherPoint:self.endValue.CGPointValue];
    }
    [self configPathWithRect:rectPath];
}

- (void)configPathWithRect:(CGRect)rect {
    self.path = [UIBezierPath bezierPathWithOvalInRect:rect];
    self.layer.lineWidth = [self sizeBySelector];
    self.layer.strokeColor = [self colorBySelector].CGColor;
    self.layer.fillColor = nil;
    self.layer.path = self.path.CGPath;
}

@end

@implementation LLScreenshotLineOperation

- (void)drawImageView:(CGRect)rect {
    if (self.startValue && self.endValue) {
        self.path = [UIBezierPath bezierPath];
        [self.path moveToPoint:self.startValue.CGPointValue];
        [self.path addLineToPoint:self.endValue.CGPointValue];
        self.layer.lineWidth = [self sizeBySelector];
        self.layer.strokeColor = [self colorBySelector].CGColor;
        self.layer.fillColor = nil;
        self.layer.path = self.path.CGPath;
    }
}

@end

@interface LLScreenshotPenOperation ()

// CGPoint
@property (nonatomic, strong) NSMutableArray <NSValue *>*values;

@end

@implementation LLScreenshotPenOperation

- (instancetype)initWithSelector:(LLScreenshotSelectorModel *)selector action:(LLScreenshotAction)action {
    if (self = [super initWithSelector:selector action:action]) {
        self.values = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addValue:(NSValue *)value {
    [self.values addObject:value];
    if (self.values.count == 1) {
        [self.path moveToPoint:value.CGPointValue];
    } else {
        [self.path addLineToPoint:value.CGPointValue];
    }
}

- (void)drawImageView:(CGRect)rect {
    self.layer.lineWidth = [self sizeBySelector];
    self.layer.strokeColor = [self colorBySelector].CGColor;
    self.layer.fillColor = nil;
    self.layer.path = self.path.CGPath;
}

@end

@implementation LLScreenshotTextOperation

- (instancetype)initWithSelector:(LLScreenshotSelectorModel *)selector action:(LLScreenshotAction)action {
    if (self = [super initWithSelector:selector action:action]) {
        _textView = [LLFactory getTextView:nil frame:CGRectZero delegate:self];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.showsHorizontalScrollIndicator = NO;
        _textView.showsVerticalScrollIndicator = NO;
    }
    return self;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.textColor = [self colorBySelector];
    textView.font = [self fontBySelector];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        [textView removeFromSuperview];
    } else {
        textView.editable = NO;
        textView.selectable = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)];
    textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, size.height);
}

@end
