//
//  LLSandboxModel.h
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

#import "LLBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Sandbox model. Save and show sandbox infos.
 */
@interface LLSandboxModel : LLBaseModel

/**
 File path.
 */
@property (copy, nonatomic, readonly) NSString *filePath;

/**
 File name.
 */
@property (copy, nonatomic, readonly) NSString *name;

/**
 NSFileAttributeType.
 */
@property (copy, nonatomic, readonly, nullable) NSString *fileType;

/**
 Is Directory or not.
 */
@property (assign, nonatomic, readonly) BOOL isDirectory;

/**
 File size, byte.
 */
@property (assign, nonatomic, readonly) unsigned long long fileSize;

/**
 File size contain sub files, byte.
 */
@property (assign, nonatomic) unsigned long long totalFileSize;

/**
 File or folder create date.
 */
@property (strong, nonatomic, readonly, nullable) NSDate *createDate;

/**
 File or folder modifi date.
 */
@property (strong, nonatomic, readonly, nullable) NSDate *modifiDate;

/**
 File or folder is hidden or not.
 */
@property (assign, nonatomic, readonly) BOOL isHidden;

/**
 Is NSHomeDirectory() or not.
 */
@property (assign, nonatomic, readonly) BOOL isHomeDirectory;

/**
 Icon name.
 */
@property (copy, nonatomic, readonly) NSString *iconName;

/**
 Can preview or not.
 */
@property (assign, nonatomic, readonly) BOOL canPreview;

/**
 Submodels in the path.
 */
@property (strong, nonatomic) NSMutableArray <LLSandboxModel *> *subModels;

/**
 Initialization of the model.
 */
- (instancetype _Nonnull)initWithAttributes:(NSDictionary <NSString *,id>*)attributes filePath:(NSString *)filePath;

/**
 Convet file size to NSString.
 */
- (NSString *)fileSizeString;

/**
 Convent total file size to NSString.
 */
- (NSString *)totalFileSizeString;

@end

NS_ASSUME_NONNULL_END
