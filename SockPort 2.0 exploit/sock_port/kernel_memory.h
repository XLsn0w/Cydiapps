//
//  kernel_memory.h
//  sock_port
//
//  Created by Jake James on 7/18/19.
//  Copyright © 2019 Jake James. All rights reserved.
//

#ifndef kernel_memory_h
#define kernel_memory_h

#include <stdio.h>
#include <mach/mach.h>
#include "offsets.h"

kern_return_t mach_vm_allocate(vm_map_t target, mach_vm_address_t *address, mach_vm_size_t size, int flags);
kern_return_t mach_vm_read_overwrite(vm_map_t target_task, mach_vm_address_t address, mach_vm_size_t size, mach_vm_address_t data, mach_vm_size_t *outsize);
kern_return_t mach_vm_write(vm_map_t target_task, mach_vm_address_t address, vm_offset_t data, mach_msg_type_number_t dataCnt);
kern_return_t mach_vm_deallocate(vm_map_t target, mach_vm_address_t address, mach_vm_size_t size);;
kern_return_t mach_vm_read(vm_map_t target_task, mach_vm_address_t address, mach_vm_size_t size, vm_offset_t *data, mach_msg_type_number_t *dataCnt);

void init_kernel_memory(mach_port_t tfp0);

size_t kread(uint64_t where, void *p, size_t size);
uint32_t rk32(uint64_t where);
uint64_t rk64(uint64_t where);

size_t kwrite(uint64_t where, const void *p, size_t size);
void wk32(uint64_t where, uint32_t what);
void wk64(uint64_t where, uint64_t what);

void kfree(mach_vm_address_t address, vm_size_t size);
uint64_t kalloc(vm_size_t size);

uint64_t find_port(mach_port_name_t port, uint64_t task_self);

#endif /* kernel_memory_h */
