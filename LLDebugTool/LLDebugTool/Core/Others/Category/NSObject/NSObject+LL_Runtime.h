//
//  NSObject+LL_Runtime.h
//
//  Copyright (c) 2018 LLBaseFoundation Software Foundation (https://github.com/HDB-Li/LLDebugTool)
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
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LL_Runtime)

/**
 Swizzle class method.

 @param oriSel Original selector.
 @param swiSel Swizzled selector.
 */
+ (void)LL_swizzleClassMethodWithOriginSel:(SEL)oriSel
                               swizzledSel:(SEL)swiSel;

/**
 Swizzle instance method.

 @param oriSel Original selector.
 @param swiSel Swizzled selector.
 */
+ (void)LL_swizzleInstanceMethodWithOriginSel:(SEL)oriSel
                                  swizzledSel:(SEL)swiSel;

/// Swizzle method.
/// @param method1 Method1
/// @param method2 Method2
+ (void)LL_swizzleMethod:(Method)method1 anotherMethod:(Method)method2;

/**
 Get all property names.

 @return Property name array.
 */
+ (NSArray *)LL_getPropertyNames;

/**
Get all property names.

@return Property name array.
*/
- (NSArray *)LL_getPropertyNames;

/**
 Add string property.

 @param string String value.
 @param key Key.
 */
- (void)LL_setStringProperty:(NSString *_Nullable)string key:(const char *)key;

/**
 Get string property.

 @param key Key.
 @return String value.
 */
- (NSString *_Nullable)LL_getStringProperty:(const char *)key;

/**
 Add CGFloat property.
 
 @param number CGFloat value.
 @param key Key.
 */
- (void)LL_setCGFloatProperty:(CGFloat)number key:(const char *)key;

/**
 Get CGFloat property.
 
 @param key Key.
 @return CGFloat value.
 */
- (CGFloat)LL_getCGFloatProperty:(const char *)key;

@end

NS_ASSUME_NONNULL_END
