#ifndef _oxpc_string_h
#define _oxpc_string_h

#include <stdint.h>

#include "oxpc_object.h"

// note that __xpc_string_deserialize will fail to deserialize an xpc string if it isn't
// NULL terminated
oxpc_object_t
oxpc_string_alloc(
  uint8_t* bytes,      // raw character bytes (including NULL if you want one)
  size_t byte_length); // length including NULL terminator

oxpc_object_t
oxpc_string_alloc_with_cstring(
  char* cstring);

extern struct oxpc_type_descriptor oxpc_string_type_descriptor;

#endif
