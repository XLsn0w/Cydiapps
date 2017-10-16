#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "oxpc_utils.h"

#include "oxpc_object.h"
#include "oxpc_string.h"

// runtime and serialized structure is the same
typedef struct __attribute__((packed)) _oxpc_string {
  uint32_t type;
  uint32_t byte_length; // includes NULL byte (if provided) but this value is *not* rounded up to 4 bytes
  uint8_t bytes[0];
}* oxpc_string_t;

// runtime structure allocation
oxpc_object_t
oxpc_string_alloc(
  uint8_t* bytes,        // raw character bytes
  size_t byte_length) // byte length including NULL termination
{
  if (byte_length > oxpc_arbitrary_size_limit) {
    return NULL;
  }
  
  oxpc_string_t str = NULL;
  size_t rounded_up_string_length = round_up_32((uint32_t)byte_length, 4);
  size_t allocation_size = sizeof(*str) + rounded_up_string_length;
  
  str = malloc(allocation_size);
  if (!str) {
    ERROR("unable to allocate memory for oxpc_string");
  }
  memset(str, 0, allocation_size);
  str->type = OXPC_TYPE_STRING;
  str->byte_length = (uint32_t)byte_length;
  memcpy(str->bytes, bytes, byte_length);

  return (oxpc_object_t)str;
}

oxpc_object_t
oxpc_string_alloc_with_cstring(
  char* cstring)
{
  return oxpc_string_alloc((uint8_t*)cstring, strlen(cstring)+1);
}

// runtime structure free
static void
oxpc_string_free(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_STRING);
  oxpc_string_t str = (oxpc_string_t)obj;
  free(str);
}

// size of serialized structure
static size_t
oxpc_string_serialized_size(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_STRING);
  oxpc_string_t str = (oxpc_string_t)obj;
  return sizeof(*str) + round_up_32(str->byte_length, 4);
}

// serialize runtime object to buffer
static void
oxpc_string_serialize_to_buffer(
  oxpc_object_t obj,
  void* buffer,
  oxpc_port_list_t ports)
{
  oxpc_check_type(obj, OXPC_TYPE_STRING);
  oxpc_string_t str = (oxpc_string_t)obj;
  memcpy(buffer, str, oxpc_string_serialized_size(obj));
}

struct oxpc_type_descriptor oxpc_string_type_descriptor = {
  .free = oxpc_string_free,
  .serialized_size = oxpc_string_serialized_size,
  .serialize_to_buffer = oxpc_string_serialize_to_buffer,
};

