#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "oxpc_utils.h"

#include "oxpc_object.h"
#include "oxpc_uint64.h"

// runtime structure
typedef struct __attribute__((packed)) _oxpc_uint64 {
  uint32_t type;
  uint64_t value;
}* oxpc_uint64_t;

// runtime structure allocation
oxpc_object_t
oxpc_uint64_alloc(
  uint64_t value)
{
  oxpc_uint64_t obj = NULL;
  obj = malloc(sizeof(*obj));
  if (!obj) {
    ERROR("unable to allocate memory for oxpc_uint64");
  }
  obj->type = OXPC_TYPE_UINT64;
  obj->value = value;
  return (oxpc_object_t)obj;
}

// runtime structure free
void oxpc_uint64_free(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_UINT64);
  free(obj);
}

// size of serialized structure
static size_t
oxpc_uint64_serialized_size(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_UINT64);
  oxpc_uint64_t value = (oxpc_uint64_t)obj;
  return sizeof(*value);
}

// serialize runtime object to buffer
static void
oxpc_uint64_serialize_to_buffer(
  oxpc_object_t obj,
  void* buffer,
  oxpc_port_list_t ports)
{
  oxpc_check_type(obj, OXPC_TYPE_UINT64);
  oxpc_uint64_t value = (oxpc_uint64_t)obj;
  memcpy(buffer, value, sizeof(*value));
}

struct oxpc_type_descriptor oxpc_uint64_type_descriptor = {
  .free = oxpc_uint64_free,
  .serialized_size = oxpc_uint64_serialized_size,
  .serialize_to_buffer = oxpc_uint64_serialize_to_buffer,
};

