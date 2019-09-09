//
//  LLTool.h
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

/**
 Work as tool.
 */
@interface LLTool : NSObject

/**
 Identity to model. Deal with the same date, start at 1.
 */
+ (NSString *)absolutelyIdentity;

/**
 Create directory if not exist.
 */
+ (BOOL)createDirectoryAtPath:(NSString *)path;

/**
 Get rect from two point
 */
+ (CGRect)rectWithPoint:(CGPoint)point otherPoint:(CGPoint)otherPoint;

/**
 Frame fromat.
 */
+ (NSString *)stringFromFrame:(CGRect)frame;

/**
 Supported interface orientations in info.plist.
 */
+ (UIInterfaceOrientationMask)infoPlistSupportedInterfaceOrientationsMask;

/**
 Top level window.

 @return Top level window.
 */
+ (UIWindow *)topWindow;

/**
 Internal log.

 @param string log string.
 */
+ (void)log:(NSString *)string;

/// Get UIStatusBar_Modern.
+ (UIView *_Nullable)getUIStatusBarModern;

@end

NS_ASSUME_NONNULL_END
