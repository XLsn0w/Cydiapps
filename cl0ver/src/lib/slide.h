#ifndef SLIDE_H
#define SLIDE_H

#include <stddef.h>             // size_t

#include "common.h"             // addr_t

addr_t get_kernel_anchor(void);

size_t get_kernel_slide(void);

#endif
