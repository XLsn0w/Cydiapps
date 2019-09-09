//
//  LLScreenshotImageView.m
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

#import "LLScreenshotImageView.h"
#import "LLScreenshotBaseOperation.h"
#import "LLFactory.h"
#import "LLConst.h"

@interface LLScreenshotImageView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong, nullable) LLScreenshotBaseOperation *currentOperation;

@property (nonatomic, strong) NSMutableArray <LLScreenshotBaseOperation *>*operations;

@end

@implementation LLScreenshotImageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)removeLastOperation {
    LLScreenshotBaseOperation *operation = self.operations.lastObject;
    switch (operation.action) {
        case LLScreenshotActionRect:
        case LLScreenshotActionRound:
        case LLScreenshotActionLine:
        case LLScreenshotActionPen:{
            LLScreenshotTwoValueOperation *oper = (LLScreenshotTwoValueOperation *)operation;
            [oper.layer removeFromSuperlayer];
            [self.operations removeObject:oper];
        }
            break;
        case LLScreenshotActionText:{
            LLScreenshotTextOperation *oper = (LLScreenshotTextOperation *)operation;
            [oper.textView removeFromSuperview];
            [self.operations removeObject:oper];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.currentOperation isKindOfClass:[LLScreenshotTextOperation class]]) {
        LLScreenshotTextOperation *operation = (LLScreenshotTextOperation *)self.currentOperation;
        [operation.textView resignFirstResponder];
        if (self.currentAction == LLScreenshotActionText) {
            self.currentOperation = nil;
            return;
        }
    }
    
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    if (!CGRectContainsPoint(self.bounds, point)) {
        return;
    }
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    switch (self.currentAction) {
        case LLScreenshotActionRect:{
            LLScreenshotRectOperation *operation = [[LLScreenshotRectOperation alloc] initWithSelector:self.currentSelectorModel action:self.currentAction];
            self.currentOperation = operation;
            [self.operations addObject:operation];
            [self.layer addSublayer:operation.layer];
            operation.startValue = pointValue;
            [self setNeedsDisplay];
        }
            break;
        case LLScreenshotActionRound:{
            LLScreenshotRoundOperation *operation = [[LLScreenshotRoundOperation alloc] initWithSelector:self.currentSelectorModel action:self.currentAction];
            self.currentOperation = operation;
            [self.operations addObject:operation];
            [self.layer addSublayer:operation.layer];
            operation.startValue = pointValue;
            [self setNeedsDisplay];
        }
            break;
        case LLScreenshotActionLine:{
            LLScreenshotLineOperation *operation = [[LLScreenshotLineOperation alloc] initWithSelector:self.currentSelectorModel action:self.currentAction];
            self.currentOperation = operation;
            [self.operations addObject:operation];
            [self.layer addSublayer:operation.layer];
            operation.startValue = pointValue;
            [self setNeedsDisplay];
        }
            break;
        case LLScreenshotActionPen:{
            LLScreenshotPenOperation *operation = [[LLScreenshotPenOperation alloc] initWithSelector:self.currentSelectorModel action:self.currentAction];
            self.currentOperation = operation;
            [self.operations addObject:operation];
            [self.layer addSublayer:operation.layer];
            [operation addValue:pointValue];
            [self setNeedsDisplay];
        }
            break;
        case LLScreenshotActionText:{
            if (self.frame.size.height - 30 < point.y) {
                return;
            }
            LLScreenshotTextOperation *operation = [[LLScreenshotTextOperation alloc] initWithSelector:self.currentSelectorModel action:self.currentAction];
            self.currentOperation = operation;
            [self.operations addObject:operation];
            [self addSubview:operation.textView];
            operation.textView.frame = CGRectMake(point.x, point.y, self.frame.size.width - point.x - kLLGeneralMargin, 30);
            [operation.textView becomeFirstResponder];
        }
            break;
        default:
            break;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    if (!CGRectContainsPoint(self.bounds, point)) {
        return;
    }
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    switch (self.currentAction) {
        case LLScreenshotActionRect:{
            LLScreenshotRectOperation *operation = (LLScreenshotRectOperation *)self.currentOperation;
            operation.endValue = pointValue;
            [self setNeedsDisplay];
        }
            break;
        case LLScreenshotActionRound:{
            LLScreenshotRoundOperation *operation = (LLScreenshotRoundOperation *)self.currentOperation;
            operation.endValue = pointValue;
            [self setNeedsDisplay];
        }
            break;
        case LLScreenshotActionLine:{
            LLScreenshotLineOperation *operation = (LLScreenshotLineOperation *)self.currentOperation;
            operation.endValue = pointValue;
            [self setNeedsDisplay];
        }
            break;
        case LLScreenshotActionPen:{
            LLScreenshotPenOperation *operation = (LLScreenshotPenOperation *)self.currentOperation;
            [operation addValue:pointValue];
            [self setNeedsDisplay];
        }
            break;
        default:
            break;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // Call end if cancelled.
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    if (!CGRectContainsPoint(self.bounds, point)) {
        return;
    }
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    switch (self.currentAction) {
        case LLScreenshotActionRect:{
            LLScreenshotRectOperation *operation = (LLScreenshotRectOperation *)self.currentOperation;
            operation.endValue = pointValue;
            [self setNeedsDisplay];
        }
            break;
        case LLScreenshotActionRound:{
            LLScreenshotRoundOperation *operation = (LLScreenshotRoundOperation *)self.currentOperation;
            operation.endValue = pointValue;
            [self setNeedsDisplay];
        }
            break;
        case LLScreenshotActionLine:{
            LLScreenshotLineOperation *operation = (LLScreenshotLineOperation *)self.currentOperation;
            operation.endValue = pointValue;
            [self setNeedsDisplay];
        }
            break;
        case LLScreenshotActionPen:{
            LLScreenshotPenOperation *operation = (LLScreenshotPenOperation *)self.currentOperation;
            [operation addValue:pointValue];
            [self setNeedsDisplay];
        }
            break;
        default:
            break;
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self.currentOperation drawImageView:rect];
}

#pragma mark - Primary
- (void)initial {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = NO;
    self.operations = [[NSMutableArray alloc] init];
    
    self.imageView = [LLFactory getImageView:self frame:self.bounds];
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 2;
    self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageView.layer.shadowOffset = CGSizeZero;
    self.imageView.layer.shadowOpacity = 0.5;
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        self.imageView.image = image;
    }
}

- (void)setCurrentAction:(LLScreenshotAction)currentAction {
    if (_currentAction != currentAction) {
        _currentAction = currentAction;
        if (currentAction > LLScreenshotActionNone && currentAction < LLScreenshotActionBack) {
            self.userInteractionEnabled = YES;
        } else {
            self.userInteractionEnabled = NO;
        }
    }
}

@end
