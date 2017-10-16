//
//  offsets.m
//  extra_recipe
//
//  Created by xerub on 28/05/2017.
//  Copyright © 2017 xerub. All rights reserved.
//

#include <sys/utsname.h>
#include <UIKit/UIKit.h>

#include "extra_offsets.h"

unsigned offsetof_p_pid = 0x10;               // proc_t::p_pid
unsigned offsetof_task = 0x18;                // proc_t::task
unsigned offsetof_p_ucred = 0x100;            // proc_t::p_ucred
unsigned offsetof_p_comm = 0x26c;             // proc_t::p_comm
unsigned offsetof_p_csflags = 0x2a8;          // proc_t::p_csflags
unsigned offsetof_itk_self = 0xD8;            // task_t::itk_self (convert_task_to_port)
unsigned offsetof_itk_sself = 0xE8;           // task_t::itk_sself (task_get_special_port)
unsigned offsetof_itk_bootstrap = 0x2b8;      // task_t::itk_bootstrap (task_get_special_port)
unsigned offsetof_ip_mscount = 0x9C;          // ipc_port_t::ip_mscount (ipc_port_make_send)
unsigned offsetof_ip_srights = 0xA0;          // ipc_port_t::ip_srights (ipc_port_make_send)
unsigned offsetof_special = 2 * sizeof(long); // host::special

const char *mp = NULL;

uint64_t AGXCommandQueue_vtable = 0;
uint64_t OSData_getMetaClass = 0;
uint64_t OSSerializer_serialize = 0;
uint64_t k_uuid_copy = 0;

uint64_t allproc = 0;
uint64_t realhost = 0;
uint64_t call5 = 0;

int nports = 40000;

static NSMutableArray *consttable = nil;
static NSMutableArray *collide = nil;

static int
constload(void)
{
    struct utsname uts;
    uname(&uts);
    if (strstr(uts.version, "Marijuan")) {
        return -2;
    }

    NSString *strv = [NSString stringWithUTF8String:uts.version];
    NSArray *dp =[[NSArray alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"def" ofType:@"plist"]];
    int m = 0;
    collide = [NSMutableArray new];

    for (NSDictionary *dict in dp) {
        if ([dict[@"vers"] isEqualToString:strv]) {
            [collide setObject:[NSMutableArray new] atIndexedSubscript:m];
            int i = 0;
            for (NSString *str in dict[@"val"]) {
                [collide[m] setObject:[NSNumber numberWithUnsignedLongLong:strtoull([str UTF8String], 0, 0)] atIndexedSubscript:i];
                i++;
            }
            m++;
        }
    }
    if (m) {
        return 0;
    }
    return -1;
}

static char
affine_const_by_surfacevt(uint64_t surfacevt_slid)
{
    for (NSArray *arr in collide) {
        if ((surfacevt_slid & 0xfffff) == ([[arr objectAtIndex:1] unsignedLongLongValue] & 0xfffff)) {
            NSLog(@"affined");
            consttable = arr;
            return 0;
        }
    }
    return -1;
}

uint64_t
constget(int idx)
{
    return [[consttable objectAtIndex:idx] unsignedLongLongValue];
}

static int
offload(const char *hw, NSString *ios)
{
    NSArray *dp = [[NSArray alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"dex" ofType:@"plist"]];
    for (NSDictionary *dict in dp) {
        NSArray *hw_array = dict[@"hw"];
        for (NSString *h in hw_array) {
            if (!strcmp([h UTF8String], hw)) {
                NSArray *ios_array = dict[@"ios"];
                for (NSString *i in ios_array) {
                    if ([ios compare:i] == NSOrderedSame) {
                        NSArray *a = dict[@"offsets"];
                        AGXCommandQueue_vtable = strtoull([[a objectAtIndex:0] UTF8String], NULL, 0);
                        OSData_getMetaClass = strtoull([[a objectAtIndex:1] UTF8String], NULL, 0);
                        OSSerializer_serialize = strtoull([[a objectAtIndex:2] UTF8String], NULL, 0);
                        k_uuid_copy = strtoull([[a objectAtIndex:3] UTF8String], NULL, 0);
                        allproc = strtoull([[a objectAtIndex:4] UTF8String], NULL, 0);
                        realhost = strtoull([[a objectAtIndex:5] UTF8String], NULL, 0);
                        call5 = strtoull([[a objectAtIndex:6] UTF8String], NULL, 0);
                        NSNumber *np = dict[@"nports"];
                        if (np) {
                            nports = [np intValue];
                        }
                        return 0;
                    }
                }
            }
        }
    }
    return -1;
}

// TODO: needs to be replaced with the main offsets.m
int
init_extra_offsets(void)
{
    struct utsname uts;

    if (uname(&uts)) {
        return ERR_INTERNAL;
    }

    NSString *version = [[UIDevice currentDevice] systemVersion];
    if ([version compare:@"10.0" options:NSNumericSearch] == NSOrderedAscending ||
        [version compare:@"10.2" options:NSNumericSearch] == NSOrderedDescending) {
        return ERR_UNSUPPORTED;
    }

    if (!strncmp(uts.machine, "iPhone9,", sizeof("iPhone9"))) {
        // iPhone 7 (plus)
        if (constload() || affine_const_by_surfacevt(0xfffffff006e521e0)) {
            return ERR_INTERNAL;
        }
        if ([version compare:@"10.1" options:NSNumericSearch] == NSOrderedAscending) {
            // 10.0[.x]
            mp = "@executable_path/mach-portal.dylib";
        } else {
            // 10.1[.x]
            mp = "@executable_path/mach_portal.dylib";
        }
    }

    if (offload(uts.machine, version) || !AGXCommandQueue_vtable) {
        return ERR_UNSUPPORTED_YET;
    }

    return 0;
}
