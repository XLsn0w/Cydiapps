#ifndef _oxpc_data_h
#define _oxpc_data_h

#include "oxpc_object.h"

// this doesn't take ownership of bytes
oxpc_object_t
oxpc_data_alloc(
  void* bytes,
  size_t byte_length);

extern struct oxpc_type_descriptor oxpc_data_type_descriptor;

#endif
