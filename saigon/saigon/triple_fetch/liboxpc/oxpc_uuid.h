#ifndef _oxpc_uuid_h
#define _oxpc_uuid_h

#include <stdint.h>

#include "oxpc_object.h"

oxpc_object_t
oxpc_uuid_alloc(
  uint8_t* value);

extern struct oxpc_type_descriptor oxpc_uuid_type_descriptor;

#endif
