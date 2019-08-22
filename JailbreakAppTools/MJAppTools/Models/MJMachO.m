//
//  MJMachO.m
//  MJAppTools
//
//  Created by MJ Lee on 2018/1/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJMachO.h"
#import <mach-o/loader.h>
#import <mach-o/fat.h>
#import "NSFileHandle+Extension.h"

#define MJEndianConvert(big, value) \
((big) ? OSSwapInt32((value)) : (value))

@implementation MJMachO

+ (instancetype)machOWithFileHandle:(NSFileHandle *)handle
{
    return [[self alloc] initWithFileHandle:handle];
}

- (instancetype)initWithFileHandle:(NSFileHandle *)handle
{
    if (self = [super init]) {
        uint32_t magic = [handle mj_staticReadUint32];
        if (magic == FAT_CIGAM || magic == FAT_MAGIC) { // FAT
            [self setupFat:handle];
        } else if (magic == MH_MAGIC || magic == MH_CIGAM
                   || magic == MH_MAGIC_64 || magic == MH_CIGAM_64) {
            [self setupMachO:handle];
        } else {
            return nil;
        }
    }
    return self;
}

- (void)setupMachO:(NSFileHandle *)handle
{
    // magic
    uint32_t magic = [handle mj_staticReadUint32];
    
    // header
    struct mach_header header;
    int headerLength = sizeof(struct mach_header);
    BOOL bigEndian = (magic == MH_CIGAM);
    BOOL is64bit = NO;
    if (magic == MH_MAGIC_64 || magic == MH_CIGAM_64) {
        headerLength = sizeof(struct mach_header_64);
        bigEndian = (magic == MH_CIGAM_64);
        is64bit = YES;
    }
    
    // 读取头部数据
    [handle mj_readData:&header length:headerLength];
    uint32_t cputype = MJEndianConvert(bigEndian, header.cputype);
    uint32_t cpusubtype = MJEndianConvert(bigEndian, header.cpusubtype);
    if (cputype == CPU_TYPE_X86_64) {
        self.architecture = @"x86_64";
    } else if (cputype == CPU_TYPE_X86) {
        if (cpusubtype == CPU_SUBTYPE_I386_ALL) {
            self.architecture = @"i386";
        } else if (cpusubtype == CPU_SUBTYPE_X86_ALL) {
            self.architecture = @"x86";
        }
    } else if (cputype == CPU_TYPE_ARM64) {
        self.architecture = @"arm_64";
    } else if (cputype == CPU_TYPE_ARM) {
        if (cpusubtype == CPU_SUBTYPE_ARM_V6) {
            self.architecture = @"arm_v6";
        } else if (cpusubtype == CPU_SUBTYPE_ARM_V6) {
            self.architecture = @"arm_v6";
        } else if (cpusubtype == CPU_SUBTYPE_ARM_V7) {
            self.architecture = @"arm_v7";
        } else if (cpusubtype == CPU_SUBTYPE_ARM_V7S) {
            self.architecture = @"arm_v7s";
        }
    }
    
    // lc的数量
    uint32_t ncmds = MJEndianConvert(bigEndian, header.ncmds);
    // 遍历lc
    for (int i = 0; i < ncmds; i++) {
        struct load_command lc;
        [handle mj_staticReadData:&lc length:sizeof(struct load_command)];
        
        if (lc.cmd == LC_ENCRYPTION_INFO || lc.cmd == LC_ENCRYPTION_INFO_64) {
            struct encryption_info_command eic;
            [handle mj_readData:&eic length:sizeof(struct encryption_info_command)];
            self.encrypted = (eic.cryptid != 0);
            break;
        }
        
        [handle seekToFileOffset:handle.offsetInFile + lc.cmdsize];
    }
}

- (void)setupFat:(NSFileHandle *)handle
{
    self.fat = YES;
    
    // fat头
    struct fat_header header;
    [handle mj_readData:&header length:sizeof(struct fat_header)];
    BOOL bigEndian = (header.magic == FAT_CIGAM);
    
    // 架构数量
    uint32_t archCount = MJEndianConvert(bigEndian, header.nfat_arch);
    NSMutableArray *machOs = [NSMutableArray arrayWithCapacity:archCount];
    
    for (int i = 0; i < archCount; i++) {
        // 读取一个架构的元数据
        struct fat_arch arch;
        [handle mj_readData:&arch length:sizeof(struct fat_arch)];
        // 保留偏移
        unsigned long long archMetaOffset = handle.offsetInFile;
        
        // 偏移到架构具体数据的开始
        [handle seekToFileOffset:MJEndianConvert(bigEndian, arch.offset)];
        MJMachO *machO = [[[self class] alloc] init];
        [machO setupMachO:handle];
        if (machO.isEncrypted) {
            self.encrypted = YES;
        }
        [machOs addObject:machO];
        
        // 跳过这个架构的元数据
        [handle seekToFileOffset:archMetaOffset];
    }
    
    self.machOs = machOs;
}

@end
