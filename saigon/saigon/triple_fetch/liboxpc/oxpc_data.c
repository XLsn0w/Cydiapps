#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "oxpc_utils.h"

#include "oxpc_object.h"
#include "oxpc_data.h"

// runtime and serialized structure is the same
typedef struct __attribute__((packed)) _oxpc_data {
  uint32_t type;
  uint32_t byte_length; // this value is not rounded to 4 bytes but the structure is
  uint8_t bytes[0];
}* oxpc_data_t;

// runtime structure allocation
oxpc_object_t
oxpc_data_alloc(
  void* bytes,
  size_t byte_length)
{
  if (byte_length > oxpc_arbitrary_size_limit) {
    return NULL;
  }
  
  oxpc_data_t data = NULL;
  size_t rounded_up_data_length = round_up_32(byte_length, 4);
  size_t allocation_size = sizeof(*data) + rounded_up_data_length;
  
  data = malloc(allocation_size);
  if (!data) {
    ERROR("unable to allocate memory for oxpc_string");
  }
  memset(data, 0, allocation_size);
  data->type = OXPC_TYPE_DATA;
  data->byte_length = (uint32_t)byte_length;
  memcpy(data->bytes, bytes, byte_length);

  return (oxpc_object_t)data;
}

// runtime structure free
static void
oxpc_data_free(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_DATA);
  oxpc_data_t data = (oxpc_data_t)obj;
  free(data);
}

// size of serialized structure
static size_t
oxpc_data_serialized_size(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_DATA);
  oxpc_data_t data = (oxpc_data_t)obj;
  return sizeof(*data) + round_up_32(data->byte_length, 4);
}

// serialize runtime object to buffer
static void
oxpc_data_serialize_to_buffer(
  oxpc_object_t obj,
  void* buffer,
  oxpc_port_list_t ports)
{
  oxpc_check_type(obj, OXPC_TYPE_DATA);
  oxpc_data_t data = (oxpc_data_t)obj;
  memcpy(buffer, data, oxpc_data_serialized_size(obj));
}

struct oxpc_type_descriptor oxpc_data_type_descriptor = {
  .free = oxpc_data_free,
  .serialized_size = oxpc_data_serialized_size,
  .serialize_to_buffer = oxpc_data_serialize_to_buffer,
};

