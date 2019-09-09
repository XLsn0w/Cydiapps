//
//  LLBaseViewController.h
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

@interface LLBaseViewController : UIViewController

/// Left navigation item's custom view.
@property (nonatomic, strong, nullable) UIButton *leftNavigationButton;

/// Right navigation item's custom view.
@property (nonatomic, strong, nullable) UIButton *rightNavigationButton;

/**
 * Simple alert.
 */
- (void)showAlertControllerWithMessage:(NSString *_Nullable)message handler:(void (^_Nullable)(NSInteger action))handler;

/**
 * Left navigation item action.
 */
- (void)leftItemClick:(UIButton *)sender;

/**
 Right navigation item action.

 @param sender UIButton.
 */
- (void)rightItemClick:(UIButton *)sender;

/**
 Whether hit test at point with event.

 @param point Point
 @param event Event
 @return Result.
 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

/**
 Init navigation item.
 
 @param title Title if needed.
 @param imageName Image if needed.
 @param flag is left navigation item or right navigation item.
 */
- (void)initNavigationItemWithTitle:(NSString *_Nullable)title imageName:(NSString *_Nullable)imageName isLeft:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END
