#ifndef _oxpc_uint64_h
#define _oxpc_uint64_h

#include <stdint.h>

#include "oxpc_object.h"

oxpc_object_t
oxpc_uint64_alloc(
  uint64_t value);

extern struct oxpc_type_descriptor oxpc_uint64_type_descriptor;

#endif
