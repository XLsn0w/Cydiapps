//
//  NSFileHandle+Extension.m
//  MJOTool
//
//  Created by MJ Lee on 2018/1/24.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "NSFileHandle+Extension.h"

@implementation NSFileHandle (Extension)

- (uint32_t)mj_readUint32
{
    size_t length = sizeof(uint32_t);
    uint32_t value;
    [[self readDataOfLength:length] getBytes:&value length:length];
    return value;
}

- (uint32_t)mj_staticReadUint32
{
    unsigned long long offset = self.offsetInFile;
    uint32_t value = [self mj_readUint32];
    [self seekToFileOffset:offset];
    return value;
}

- (void)mj_readData:(void *)data length:(NSUInteger)length
{
    [[self readDataOfLength:length] getBytes:data length:length];
}

- (void)mj_staticReadData:(void *)data length:(NSUInteger)length
{
    unsigned long long offset = self.offsetInFile;
    [self mj_readData:data length:length];
    [self seekToFileOffset:offset];
}

- (void)mj_appendOffset:(unsigned long long)offset
{
    [self seekToFileOffset:self.offsetInFile + offset];
}

@end
