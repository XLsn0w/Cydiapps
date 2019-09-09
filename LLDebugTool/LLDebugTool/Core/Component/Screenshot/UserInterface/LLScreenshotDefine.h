//
//  LLScreenshotDefine.h
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

#ifndef LLScreenshotDefine_h
#define LLScreenshotDefine_h

typedef NS_ENUM(NSUInteger, LLScreenshotAction) {
    LLScreenshotActionNone      = 0,
    LLScreenshotActionRect      = 1,
    LLScreenshotActionRound     = 2,
    LLScreenshotActionLine      = 3,
    LLScreenshotActionPen       = 4,
    LLScreenshotActionText      = 5,
    LLScreenshotActionBack      = 6,
    LLScreenshotActionCancel    = 7,
    LLScreenshotActionConfirm   = 8
};

typedef NS_ENUM(NSUInteger, LLScreenshotSelectorAction) {
    LLScreenshotSelectorActionSmall     = 0,
    LLScreenshotSelectorActionMedium    = 1,
    LLScreenshotSelectorActionBig       = 2,
    LLScreenshotSelectorActionRed       = 3,    // d81e06
    LLScreenshotSelectorActionBlue      = 4,    // 1296db
    LLScreenshotSelectorActionGreen     = 5,    // 1afa29
    LLScreenshotSelectorActionYellow    = 6,    // f4ea2a
    LLScreenshotSelectorActionGray      = 7,    // 2c2c2c
    LLScreenshotSelectorActionWhite     = 8,    // ffffff
};

#endif /* LLScreenshotDefine_h */
