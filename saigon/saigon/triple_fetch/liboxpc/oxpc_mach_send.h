#ifndef _oxpc_mach_send_h
#define _oxpc_mach_send_h

#include <mach/mach.h>

#include "oxpc_object.h"

oxpc_object_t
oxpc_mach_send_alloc(
  mach_port_t value);

extern struct oxpc_type_descriptor oxpc_mach_send_type_descriptor;

#endif
