#ifndef _oxpc_ool_data_h
#define _oxpc_ool_data_h

#include <mach/mach.h>
#include <stdint.h>

#include "oxpc_object.h"

oxpc_object_t
oxpc_ool_data_alloc(
  mach_port_t port,
  size_t size);

extern struct oxpc_type_descriptor oxpc_ool_data_type_descriptor;

#endif
