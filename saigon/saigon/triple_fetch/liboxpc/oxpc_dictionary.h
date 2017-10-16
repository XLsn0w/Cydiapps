#ifndef _oxpc_dictionary_h
#define _oxpc_dictionary_h

#include <stdint.h>

#include "oxpc_object.h"

oxpc_object_t
oxpc_dictionary_alloc();

void
oxpc_dictionary_append(
  oxpc_object_t obj,
  char* key,
  oxpc_object_t value);

extern struct oxpc_type_descriptor oxpc_dictionary_type_descriptor;

#endif
