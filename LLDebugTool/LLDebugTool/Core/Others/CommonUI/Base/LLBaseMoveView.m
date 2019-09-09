//
//  LLBaseMoveView.m
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

#import "LLBaseMoveView.h"
#import "LLMacros.h"
#import "UIView+LL_Utils.h"

@interface LLBaseMoveView ()

@property (nonatomic, assign) BOOL moved;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation LLBaseMoveView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _moveable = YES;
        // Pan, to moveable.
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGR:)];
        
        [self addGestureRecognizer:self.panGestureRecognizer];
    }
    return self;
}

- (void)panGR:(UIPanGestureRecognizer *)sender {
    
    if (!self.isMoved) {
        self.moved = YES;
    }
    
    CGPoint offsetPoint = [sender translationInView:sender.view];
    
    [self viewWillUpdateOffset:sender offset:offsetPoint];
    
    [sender setTranslation:CGPointZero inView:sender.view];
    
    [self changeFrameWithPoint:offsetPoint];
    
    [self viewDidUpdateOffset:sender offset:offsetPoint];
}

- (void)changeFrameWithPoint:(CGPoint)point {
    
    CGPoint center = self.center;
    center.x += point.x;
    center.y += point.y;
    
    if (self.isOverflow) {
        center.x = MIN(center.x, self.superview.LL_width);
        center.x = MAX(center.x, 0);
        
        center.y = MIN(center.y, self.superview.LL_height);
        center.y = MAX(center.y, 0);
    } else {
        
        if (center.x < self.LL_width / 2.0) {
            center.x = self.LL_width / 2.0;
        } else if (center.x > self.superview.LL_width - self.LL_width / 2.0) {
            center.x = self.superview.LL_width - self.LL_width / 2.0;
        }
        
        if (center.y < self.LL_height / 2.0) {
            center.y = self.LL_height / 2.0;
        } else if (center.y > self.superview.LL_height - self.LL_height / 2.0) {
            center.y = self.superview.LL_height - self.LL_height / 2.0;
        }
    }

    self.center = center;
}

- (void)viewWillUpdateOffset:(UIPanGestureRecognizer *)sender offset:(CGPoint)offsetPoint {
    
}

- (void)viewDidUpdateOffset:(UIPanGestureRecognizer *)sender offset:(CGPoint)offsetPoint {
    
}

#pragma mark - Primary
- (void)setMoveable:(BOOL)moveable {
    if (_moveable != moveable) {
        _moveable = moveable;
        self.panGestureRecognizer.enabled = moveable;
    }
}

@end
