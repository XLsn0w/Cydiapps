//
//  LLConst.h
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
#import <Foundation/Foundation.h>

// Default suspension window width.
UIKIT_EXTERN CGFloat const kLLSuspensionWindowWidth;
// Min width of suspension window.
UIKIT_EXTERN CGFloat const kLLSuspensionWindowMinWidth;
// The distance between Suspension window and UIScreen.
UIKIT_EXTERN CGFloat const kLLSuspensionWindowHideWidth;
// Normal status alpha of suspension window.
UIKIT_EXTERN CGFloat const kLLSuspensionWindowNormalAlpha;
// Active status alpha of suspension window.
UIKIT_EXTERN CGFloat const kLLSuspensionWindowActiveAlpha;
// Default top of suspension window.
UIKIT_EXTERN CGFloat const kLLSuspensionWindowTop;

// Default magnifier window zoom level.
UIKIT_EXTERN NSInteger const kLLMagnifierWindowZoomLevel;
// Number of rows per magnifier window.
UIKIT_EXTERN NSInteger const kLLMagnifierWindowSize;

// General margin.
UIKIT_EXTERN CGFloat const kLLGeneralMargin;

// Default EntryView double click component.
FOUNDATION_EXTERN NSString * const kLLEntryViewDoubleClickComponent;
