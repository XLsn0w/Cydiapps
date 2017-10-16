#ifndef _oxpc_object_h
#define _oxpc_object_h

#include <stdint.h>
#include <mach/mach.h>

#define OXPC_TYPE_UINT64     0x4000
#define OXPC_TYPE_DATA       0x8000
#define OXPC_TYPE_OOL_DATA   0x8001
#define OXPC_TYPE_STRING     0x9000
#define OXPC_TYPE_UUID       0xa000
#define OXPC_TYPE_MACH_SEND  0xd000
#define OXPC_TYPE_ARRAY      0xe000
#define OXPC_TYPE_DICTIONARY 0xf000

#define oxpc_arbitrary_size_limit 0x3456789

// oxpc base type
typedef struct __attribute__((packed)) _oxpc_object {
    uint32_t type;
}* oxpc_object_t;

typedef struct _oxpc_port_list {
  size_t count;
  mach_port_t* ports;
}* oxpc_port_list_t;

typedef void (*oxpc_free)(oxpc_object_t);
typedef size_t (*oxpc_serialized_size)(oxpc_object_t);
typedef void (*oxpc_serialize_to_buffer)(oxpc_object_t, void*, oxpc_port_list_t);

struct oxpc_type_descriptor {
  oxpc_free free;
  oxpc_serialized_size serialized_size;
  oxpc_serialize_to_buffer serialize_to_buffer;
};

void
oxpc_check_type(
  oxpc_object_t obj,
  int type);

/* user interface */
void
oxpc_object_free(
  oxpc_object_t obj);

size_t
oxpc_object_serialized_size(
  oxpc_object_t obj);

void
oxpc_object_serialize_to_buffer(
  oxpc_object_t obj,
  void* buffer,
  oxpc_port_list_t ports);

void*
oxpc_object_serialize(
  oxpc_object_t obj,
  size_t* size,
  oxpc_port_list_t* ports_out);

void*
oxpc_object_serialize_to_mach_message(
  oxpc_object_t obj,
  mach_port_t destination_port,
  mach_port_t reply_port,
  size_t* mach_message_size);

kern_return_t
oxpc_object_send_as_mach_message(
  oxpc_object_t obj,
  mach_port_t destination_port,
  mach_port_t reply_port);

void
oxpc_port_list_append(
  oxpc_port_list_t list,
  mach_port_t port);

#endif
