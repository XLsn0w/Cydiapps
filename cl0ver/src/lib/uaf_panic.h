#ifndef UAF_PANIC_H
#define UAF_PANIC_H

#include "common.h"             // addr_t

void uaf_with_vtab(addr_t addr);

void uaf_panic_leak_DATA_const_base(void);

void uaf_panic_leak_vtab(void);

#endif
