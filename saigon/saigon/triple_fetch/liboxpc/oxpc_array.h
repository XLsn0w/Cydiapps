#ifndef _oxpc_array_h
#define _oxpc_array_h

#include <stdint.h>

#include "oxpc_object.h"

oxpc_object_t
oxpc_array_alloc();

void
oxpc_array_append(
  oxpc_object_t obj,
  oxpc_object_t val);

extern struct oxpc_type_descriptor oxpc_array_type_descriptor;

#endif
