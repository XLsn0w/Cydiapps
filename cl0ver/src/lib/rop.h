#ifndef ROP_H
#define ROP_H

#include <mach/mach_types.h>    // task_t

#include "common.h"             // addr_t

addr_t get_stack_pivot(void);

void rop_get_kernel_task(addr_t **chain, task_t *task);

#endif
