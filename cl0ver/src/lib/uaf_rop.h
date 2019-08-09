#ifndef UAF_ROP_H
#define UAF_ROP_H

#include "common.h"             // file_t
#include "io.h"                 // OSString

void uaf_parse(const OSString *fake);

addr_t* uaf_rop_stack(void);

void uaf_rop(void);

#endif
