//
//  NSFileHandle+Extension.h
//  MJOTool
//
//  Created by MJ Lee on 2018/1/24.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileHandle (Extension)

- (uint32_t)mj_readUint32;
- (uint32_t)mj_staticReadUint32;

- (void)mj_readData:(void *)data length:(NSUInteger)length;
- (void)mj_staticReadData:(void *)data length:(NSUInteger)length;

- (void)mj_appendOffset:(unsigned long long)offset;

@end
