//
//  MJMachO.h
//  MJAppTools
//
//  Created by MJ Lee on 2018/1/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJMachO : NSObject

/** 架构名称 */
@property (copy, nonatomic) NSString *architecture;
/** 是否被加密 */
@property (assign, nonatomic, getter=isEncrypted) BOOL encrypted;
@property (assign, nonatomic, getter=isFat) BOOL fat;
@property (strong, nonatomic) NSArray *machOs;

+ (instancetype)machOWithFileHandle:(NSFileHandle *)handle;
- (instancetype)initWithFileHandle:(NSFileHandle *)handle;

@end
