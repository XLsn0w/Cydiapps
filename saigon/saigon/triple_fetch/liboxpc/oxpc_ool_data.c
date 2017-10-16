#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mach/mach.h>

#include "oxpc_utils.h"

#include "oxpc_object.h"
#include "oxpc_ool_data.h"

// runtime structure
typedef struct _oxpc_ool_data {
  uint32_t type;
  mach_port_t port;
  size_t size;
}* oxpc_ool_data_t;


// size needs to be > 0x4000 for libxpc to recognize it as an ool_data object
// runtime structure allocation
oxpc_object_t
oxpc_ool_data_alloc(
  mach_port_t port,
  size_t size)
{
  oxpc_ool_data_t data = NULL;
  data = malloc(sizeof(*data));
  if (!data) {
    ERROR("unable to allocate memory for oxpc_ool_data");
  }
  data->type = OXPC_TYPE_OOL_DATA;
  data->port = port;
  data->size = size;
  return (oxpc_object_t)data;
}

// runtime structure free
void oxpc_ool_data_free(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_OOL_DATA);
  free(obj);
}

typedef struct __attribute__((packed)) _oxpc_ool_data_serialized {
  uint32_t type;
  uint32_t size;
}* oxpc_ool_data_serialized_t;

// size of serialized structure
static size_t
oxpc_ool_data_serialized_size(
  oxpc_object_t obj)
{
  oxpc_check_type(obj, OXPC_TYPE_OOL_DATA);
  return sizeof(struct _oxpc_ool_data_serialized);
}

// serialize runtime object to buffer
static void
oxpc_ool_data_serialize_to_buffer(
  oxpc_object_t obj,
  void* buffer,
  oxpc_port_list_t ports)
{
  oxpc_check_type(obj, OXPC_TYPE_OOL_DATA);
  oxpc_ool_data_t data = (oxpc_ool_data_t)obj;
  oxpc_ool_data_serialized_t serialized_data = (oxpc_ool_data_serialized_t)buffer;
  serialized_data->type = OXPC_TYPE_DATA; // OOL_DATA isn't a real type
  serialized_data->size = (uint32_t)data->size;
  oxpc_port_list_append(ports, data->port);
}

struct oxpc_type_descriptor oxpc_ool_data_type_descriptor = {
  .free = oxpc_ool_data_free,
  .serialized_size = oxpc_ool_data_serialized_size,
  .serialize_to_buffer = oxpc_ool_data_serialize_to_buffer,
};
