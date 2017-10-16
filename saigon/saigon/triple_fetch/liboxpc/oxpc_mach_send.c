#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mach/mach.h>

#include "oxpc_utils.h"

#include "oxpc_object.h"
#include "oxpc_uint64.h"

// runtime structure
typedef struct __attribute__((packed)) _oxpc_mach_send {
  uint32_t type;
  mach_port_t port;
}* oxpc_mach_send_t;

// runtime structure allocation
oxpc_object_t
oxpc_mach_send_alloc(
  mach_port_t port)
{
  oxpc_mach_send_t obj = NULL;
  obj = malloc(sizeof(*obj));
  if (!obj) {
    ERROR("unable to allocate memory for oxpc_uint64");
  }
  obj->type = OXPC_TYPE_MACH_SEND;
  obj->port = port;
  return (oxpc_object_t)obj;
}

// runtime structure free
void oxpc_mach_send_free(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_MACH_SEND);
  free(obj);
}

// size of serialized structure
static size_t
oxpc_mach_send_serialized_size(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_MACH_SEND);
  return sizeof(uint32_t);
}

// serialize runtime object to buffer
static void
oxpc_mach_send_serialize_to_buffer(
  oxpc_object_t obj,
  void* buffer,
  oxpc_port_list_t ports)
{
  oxpc_check_type(obj, OXPC_TYPE_MACH_SEND);
  oxpc_mach_send_t value = (oxpc_mach_send_t)obj;
  *(uint32_t*)(buffer) = OXPC_TYPE_MACH_SEND;
  oxpc_port_list_append(ports, value->port);
}

struct oxpc_type_descriptor oxpc_mach_send_type_descriptor = {
  .free = oxpc_mach_send_free,
  .serialized_size = oxpc_mach_send_serialized_size,
  .serialize_to_buffer = oxpc_mach_send_serialize_to_buffer,
};

