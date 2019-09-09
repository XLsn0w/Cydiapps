//
//  LLStorageManager.h
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
#import "LLStorageModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^LLStorageManagerBoolBlock)(BOOL result);
typedef void(^LLStorageManagerArrayBlock)(NSArray <LLStorageModel *>* _Nullable result);

/**
 Operation database.
 */
// TODO: Change from synchronous to asynchronous.
@interface LLStorageManager : NSObject

/**
 Singleton to operation database.
 Database file path is based on LLConfig's folderPath.

 @return Singleton
 */
+ (instancetype _Nonnull)shared;

/**
 Register a class in database and auto create a table.
 */
- (BOOL)registerClass:(Class _Nonnull)cls;

#pragma mark - SAVE
/**
 Save a model in database. Operation depend [model operationOnMainThread] on and callback in main thread.
 */
- (void)saveModel:(LLStorageModel *)model complete:(LLStorageManagerBoolBlock _Nullable)complete;

/**
 Save a model in database. [synchronous] decision synchronous or asynchronous, if YES, all operations will work in current thread, if NO, Operations will work in child thread and callback in main thread.
 */
- (void)saveModel:(LLStorageModel *)model complete:(LLStorageManagerBoolBlock _Nullable)complete synchronous:(BOOL)synchronous;

#pragma mark - UPDATE
/**
 Replace a model by identity in database. Operation depend [model operationOnMainThread] on and callback in main thread.
 */
- (void)updateModel:(LLStorageModel *)model complete:(LLStorageManagerBoolBlock _Nullable)complete;

/**
 Replace a model by identity in database. [synchronous] decision synchronous or asynchronous, if YES, all operations will work in current thread, if NO, Operations will work in child thread and callback in main thread.
 */
- (void)updateModel:(LLStorageModel *)model complete:(LLStorageManagerBoolBlock _Nullable)complete synchronous:(BOOL)synchronous;

#pragma mark - GET
/**
 Get models in database. If nothing, it will return an emtpy array. Operation in child thread and callback in main thread.
 */
- (void)getModels:(Class _Nonnull)cls complete:(LLStorageManagerArrayBlock _Nullable)complete;
- (void)getModels:(Class _Nonnull)cls launchDate:(NSString * _Nullable)launchDate complete:(LLStorageManagerArrayBlock _Nullable)complete;
- (void)getModels:(Class _Nonnull)cls launchDate:(NSString * _Nullable)launchDate storageIdentity:(NSString * _Nullable)storageIdentity complete:(LLStorageManagerArrayBlock _Nullable)complete;

/**
 Get models in database. [synchronous] decision synchronous or asynchronous, if YES, all operations will work in current thread, if NO, Operations will work in child thread and callback in main thread.
 */
- (void)getModels:(Class _Nonnull)cls launchDate:(NSString *_Nullable)launchDate storageIdentity:(NSString *_Nullable)storageIdentity complete:(LLStorageManagerArrayBlock _Nullable)complete synchronous:(BOOL)synchronous;

#pragma mark - DELETE
/**
 Remove models in database. Operation in child thread and callback in main thread.
 */
- (void)removeModels:(NSArray <LLStorageModel *>*_Nullable)models complete:(LLStorageManagerBoolBlock _Nullable)complete;

/**
 Remove models in database. [synchronous] decision synchronous or asynchronous, if YES, all operations will work in current thread, if NO, Operations will work in child thread and callback in main thread.
 */
- (void)removeModels:(NSArray <LLStorageModel *>*_Nullable)models complete:(LLStorageManagerBoolBlock _Nullable)complete synchronous:(BOOL)synchronous;

#pragma mark - Table

/**
 Clear table.
 */
- (void)clearTable:(Class _Nonnull)cls complete:(LLStorageManagerBoolBlock _Nullable)complete;
- (void)clearTable:(Class _Nonnull)cls complete:(LLStorageManagerBoolBlock _Nullable)complete synchronous:(BOOL)synchronous;

/**
 Clear database.
 */
- (void)clearDatabaseWithComplete:(LLStorageManagerBoolBlock _Nullable)complete;
- (void)clearDatabaseWithComplete:(LLStorageManagerBoolBlock _Nullable)complete synchronous:(BOOL)synchronous;

#pragma mark -
- (void)updateDatabaseWithVersion:(NSString *)version complete:(LLStorageManagerBoolBlock _Nullable )complete;

@end

NS_ASSUME_NONNULL_END
