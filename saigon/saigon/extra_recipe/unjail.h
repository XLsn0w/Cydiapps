//
//  unjail.h
//  extra_recipe
//
//  Created by xerub on 16/05/2017.
//  Copyright © 2017 xerub. All rights reserved.
//

#ifndef unjail_h
#define unjail_h

#include <dlfcn.h>
#include <copyfile.h>
#include <stdio.h>
#include <spawn.h>
#include <unistd.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <sys/utsname.h>
#include <Foundation/Foundation.h>

extern mach_port_t tfp0;
extern uint64_t kaslr_shift;
extern uint64_t kernel_base;

int go_extra_recipe(void);
kern_return_t go_kppless();

size_t kread(uint64_t where, void *p, size_t size);
uint64_t kread_uint64(uint64_t where);
uint32_t kread_uint32(uint64_t where);
size_t kwrite(uint64_t where, const void *p, size_t size);
size_t kwrite_uint64(uint64_t where, uint64_t value);
size_t kwrite_uint32(uint64_t where, uint32_t value);

void kx2(uint64_t fptr, uint64_t arg1, uint64_t arg2);
uint32_t kx5(uint64_t fptr, uint64_t arg1, uint64_t arg2, uint64_t arg3, uint64_t arg4, uint64_t arg5);

#endif /* unjail_h */
