//
//  LLThemeManager.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const kThemeManagerUpdatePrimaryColorNotificaionName;
FOUNDATION_EXTERN NSString *const kThemeManagerUpdateBackgroundColorNotificaionName;

@interface LLThemeManager : NSObject

/**
 Primary color, use on text and border.
 */
@property (nonatomic, copy) UIColor *primaryColor;

/**
 Background color, use on background.
 */
@property (nonatomic, copy) UIColor *backgroundColor;

/**
 Container color, use on containerView, should different with backgroundColor.
 */
@property (nonatomic, copy, readonly) UIColor *containerColor;

/**
 Window's statusBarStyle when show.
 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/**
 System tint color.
 */
@property (nonatomic, strong, readonly) UIColor *systemTintColor;

/**
 Singleton

 @return singleton.
 */
+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
