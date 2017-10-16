#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "oxpc_utils.h"

#include "oxpc_object.h"
#include "oxpc_uuid.h"

// runtime structure
typedef struct __attribute__((packed)) _oxpc_uuid {
  uint32_t type;
  uint8_t value[16];
}* oxpc_uuid_t;

// runtime structure allocation
oxpc_object_t
oxpc_uuid_alloc(
  uint8_t* value)
{
  oxpc_uuid_t obj = NULL;
  obj = malloc(sizeof(*obj));
  if (!obj) {
    ERROR("unable to allocate memory for oxpc_uuid");
  }
  obj->type = OXPC_TYPE_UUID;
  memcpy(obj->value, value, 16);
  return (oxpc_object_t)obj;
}

// runtime structure free
void oxpc_uuid_free(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_UUID);
  free(obj);
}

// size of serialized structure
static size_t
oxpc_uuid_serialized_size(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_UUID);
  oxpc_uuid_t value = (oxpc_uuid_t)obj;
  return sizeof(*value);
}

// serialize runtime object to buffer
static void
oxpc_uuid_serialize_to_buffer(
  oxpc_object_t obj,
  void* buffer,
  oxpc_port_list_t ports)
{
  oxpc_check_type(obj, OXPC_TYPE_UUID);
  oxpc_uuid_t value = (oxpc_uuid_t)obj;
  memcpy(buffer, value, sizeof(*value));
}

struct oxpc_type_descriptor oxpc_uuid_type_descriptor = {
  .free = oxpc_uuid_free,
  .serialized_size = oxpc_uuid_serialized_size,
  .serialize_to_buffer = oxpc_uuid_serialize_to_buffer,
};

