#ifndef FIND_H
#define FIND_H

#include <stdint.h>             // int64_t

#include "common.h"             // file_t
#include "offsets.h"            // offsets_t

void find_all_offsets(file_t *kernel, int64_t delta, offsets_t *off);

#endif
