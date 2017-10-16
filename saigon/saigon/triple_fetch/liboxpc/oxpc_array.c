#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "oxpc_utils.h"

#include "oxpc_object.h"
#include "oxpc_array.h"

// runtime structure
typedef struct _oxpc_array {
  uint32_t type;
  uint32_t count;
  size_t serialized_size;
  oxpc_object_t* objects;
}* oxpc_array_t;

// runtime structure allocation
oxpc_object_t
oxpc_array_alloc()
{
  oxpc_array_t obj = NULL;
  obj = malloc(sizeof(*obj));
  if (!obj) {
    ERROR("unable to allocate memory for oxpc_array");
  }
  obj->type = OXPC_TYPE_ARRAY;
  obj->count = 0;
  obj->serialized_size = 0;
  obj->objects = NULL;
  return (oxpc_object_t)obj;
}

/*
 * oxpc_array_append takes ownership of val
 * callers of this function must no longer use val
 *
 * the array is only mutable until it's serialized
 * after serialization it may not be modified
 */
void
oxpc_array_append(
  oxpc_object_t obj,
  oxpc_object_t val)
{
  oxpc_check_type(obj, OXPC_TYPE_ARRAY);
  oxpc_array_t arr = (oxpc_array_t)obj;

  if (arr->count > oxpc_arbitrary_size_limit) {
    ERROR("oxpc array grew too large");
  }

  arr->count++;
  size_t new_size = arr->count * sizeof(oxpc_object_t*);
  arr->objects = realloc(arr->objects, new_size);
  if (!arr->objects) {
    ERROR("oxpc array reallocation failed\n");
  }

  arr->objects[arr->count-1] = val;
}

// runtime structure free
static void
oxpc_array_free(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_ARRAY);
  oxpc_array_t arr = (oxpc_array_t)obj;

  // the array owns all the objects in it, so recursivly free them:
  for (uint32_t i = 0; i < arr->count; i++) {
    oxpc_object_free(arr->objects[i]);
  }

  free(arr->objects);
  free(arr);
}

typedef struct __attribute__((packed)) _oxpc_array_serialized {
  uint32_t type;
  uint32_t byte_count; // byte count excluding first 8 bytes (type & byte_count)
  uint32_t count;
  uint8_t bytes[0];
}* oxpc_array_serialized_t;

// size of serialized structure
static size_t
oxpc_array_serialized_size(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_ARRAY);
  oxpc_array_t arr = (oxpc_array_t)obj;

  if (arr->serialized_size != 0) {
    return arr->serialized_size;
  }

  size_t total = 0;
  for (uint32_t i = 0; i < arr->count; i++) {
    size_t element_size = oxpc_object_serialized_size(arr->objects[i]);
    if (element_size > oxpc_arbitrary_size_limit) {
      ERROR("array element too large for serialization");
    }
    if (total > oxpc_arbitrary_size_limit) {
      ERROR("array too large for serialization");
    }
    total += element_size;
  }
  arr->serialized_size = sizeof(struct _oxpc_array_serialized) + total;
  return arr->serialized_size;
}

// serialize runtime object to buffer
static void
oxpc_array_serialize_to_buffer(
  oxpc_object_t obj,
  void* buffer,
  oxpc_port_list_t ports)
{
  oxpc_check_type(obj, OXPC_TYPE_ARRAY);
  oxpc_array_t arr = (oxpc_array_t)obj;

  oxpc_array_serialized_t serialized_arr = (oxpc_array_serialized_t)buffer;
  serialized_arr->type = arr->type;
  // byte count is the total count *after* the byte_count element until the start of the next
  // element
  serialized_arr->byte_count = *((uint32_t*)oxpc_array_serialized_size(obj) - 8);
  serialized_arr->count = arr->count;

  uint8_t* elements_buffer = serialized_arr->bytes;

  for (uint32_t i = 0; i < arr->count; i++) {
    size_t element_size = oxpc_object_serialized_size(arr->objects[i]);
    oxpc_object_serialize_to_buffer(arr->objects[i], elements_buffer, ports);
    elements_buffer += element_size;
  }
}

struct oxpc_type_descriptor oxpc_array_type_descriptor = {
  .free = oxpc_array_free,
  .serialized_size = oxpc_array_serialized_size,
  .serialize_to_buffer = oxpc_array_serialize_to_buffer,
};

