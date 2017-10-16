#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <mach/mach.h>

#include "oxpc_utils.h"

#include "oxpc_object.h"

#include "oxpc_string.h"
#include "oxpc_uint64.h"
#include "oxpc_array.h"
#include "oxpc_dictionary.h"
#include "oxpc_ool_data.h"
#include "oxpc_uuid.h"
#include "oxpc_mach_send.h"
#include "oxpc_data.h"

static struct oxpc_type_descriptor*
oxpc_get_type_descriptor(
  oxpc_object_t obj)
{
  switch(obj->type) {
    case OXPC_TYPE_STRING:
      return &oxpc_string_type_descriptor;
    case OXPC_TYPE_UINT64:
      return &oxpc_uint64_type_descriptor;
    case OXPC_TYPE_ARRAY:
      return &oxpc_array_type_descriptor;
    case OXPC_TYPE_DICTIONARY:
      return &oxpc_dictionary_type_descriptor;
    case OXPC_TYPE_OOL_DATA:
      return &oxpc_ool_data_type_descriptor;
    case OXPC_TYPE_UUID:
      return &oxpc_uuid_type_descriptor;
    case OXPC_TYPE_MACH_SEND:
      return &oxpc_mach_send_type_descriptor;
    case OXPC_TYPE_DATA:
      return &oxpc_data_type_descriptor;
    default:
      printf("bad type: %x\n", obj->type);
      ERROR("unrecognized oxpc type");
  }
  return NULL;
}

void
oxpc_object_free(
  oxpc_object_t obj)
{
  oxpc_get_type_descriptor(obj)->free(obj);
}

size_t
oxpc_object_serialized_size(
  oxpc_object_t obj)
{
  return oxpc_get_type_descriptor(obj)->serialized_size(obj);
}

void
oxpc_object_serialize_to_buffer(
  oxpc_object_t obj,
  void* buffer,
  oxpc_port_list_t ports)
{
  oxpc_get_type_descriptor(obj)->serialize_to_buffer(obj, buffer, ports);
}

static oxpc_port_list_t
oxpc_port_list_alloc()
{
  oxpc_port_list_t list = NULL;
  list = malloc(sizeof(*list));
  if (!list) {
    ERROR("not enough memory to allocate oxpc_ports_list");
  }
  list->count = 0;
  list->ports = NULL;
  return list;
}

void
oxpc_port_list_free(oxpc_port_list_t list)
{
  free(list->ports);
  free(list);
}

/* append a mach port name to the list of mach ports contained in the message */
void
oxpc_port_list_append(
  oxpc_port_list_t list,
  mach_port_t port)
{
  if (list->count > oxpc_arbitrary_size_limit) {
    ERROR("oxpc_ports_list too large");
  }
  list->count++;
  size_t new_size = list->count * sizeof(mach_port_t);
  list->ports = realloc(list->ports, new_size);
  if (!list->ports) {
    ERROR("not enough memory to grow oxpc_ports_list");
  }
  list->ports[list->count-1] = port;
}

// allocate a buffer to hold the serialized object and serialize into it
void*
oxpc_object_serialize(
  oxpc_object_t obj,
  size_t* size,
  oxpc_port_list_t* ports_out)
{
  size_t total_size = oxpc_object_serialized_size(obj);
  if (total_size > oxpc_arbitrary_size_limit) {
    ERROR("oxpc object too large to be serialized");
  }
  void* buffer = malloc(total_size);
  if (!buffer) {
    ERROR("unable to allocate memory for serialized oxpc object");
  }
  memset(buffer, 0, total_size);

  oxpc_port_list_t ports = oxpc_port_list_alloc();

  oxpc_object_serialize_to_buffer(obj, buffer, ports);
  *size = total_size;
  *ports_out = ports;
  return buffer;
}

// serialize an oxpc object to a mach message which can be sent
// to an xpc service
// assumes COPY_SEND disposition for ports if they are non-zero
// doesn't send a voucher port
void*
oxpc_object_serialize_to_mach_message(
  oxpc_object_t obj,
  mach_port_t destination_port,
  mach_port_t reply_port,
  size_t* mach_message_size)
{
  size_t serialized_payload_size = 0;
  oxpc_port_list_t port_list = NULL;
  void* serialized_payload = oxpc_object_serialize(obj, &serialized_payload_size, &port_list);

  int is_complex_message = port_list->count > 0;

  int xpc_header_size = 8; // XPC! + u32 version number

  size_t total_size = sizeof(mach_msg_header_t) + xpc_header_size + serialized_payload_size;

  if (is_complex_message) {
    total_size += sizeof(mach_msg_body_t) + (port_list->count * sizeof(mach_msg_port_descriptor_t));
  }

  uint8_t* message = malloc(total_size);
  if (!message) {
    ERROR("not enough memory to allocate mach message");
  }

  memset(message, 0, total_size);

  mach_msg_header_t* hdr = (mach_msg_header_t*)message;
  
  mach_msg_type_name_t destination_disposition = 0;
  if (destination_port != MACH_PORT_NULL) {
    destination_disposition = MACH_MSG_TYPE_COPY_SEND;
  }
  
  mach_msg_type_name_t reply_disposition = 0;
  if (reply_port != MACH_PORT_NULL) {
    reply_disposition = MACH_MSG_TYPE_COPY_SEND;
  }

  hdr->msgh_bits = MACH_MSGH_BITS_SET(destination_disposition,
                                      reply_disposition,
                                      0,
                                      is_complex_message ? MACH_MSGH_BITS_COMPLEX : 0);

  hdr->msgh_size         = total_size;
  hdr->msgh_remote_port  = destination_port;
  hdr->msgh_local_port   = reply_port;
  hdr->msgh_voucher_port = MACH_PORT_NULL;
  hdr->msgh_id           = 0x10000000;

  void* message_body = (void*)(hdr+1);

  if (is_complex_message) {
    mach_msg_body_t* body = (mach_msg_body_t*)message_body;
    body->msgh_descriptor_count = port_list->count;
    mach_msg_port_descriptor_t* desc = (mach_msg_port_descriptor_t*)(body+1);

    for (size_t i = 0; i < port_list->count; i++) {
      desc->name = port_list->ports[i];
      desc->disposition = MACH_MSG_TYPE_COPY_SEND;
      desc->type = MACH_MSG_PORT_DESCRIPTOR;
      desc++;
    }
    message_body = (void*)(desc);
  }

  // append the XPC header magic
  uint32_t* xpc_magic = (uint32_t*)message_body;
  *xpc_magic = 'XPC!';
  uint32_t* xpc_version = xpc_magic + 1;
  *xpc_version = 5;

  void* xpc_message_body_payload = (void*)(xpc_version+1);

  memcpy(xpc_message_body_payload, serialized_payload, serialized_payload_size);

  *mach_message_size = total_size;
  oxpc_port_list_free(port_list);

  return message;
}

kern_return_t
oxpc_object_send_as_mach_message(
  oxpc_object_t obj,
  mach_port_t destination_port,
  mach_port_t reply_port)
{
  size_t msg_size = 0;
  mach_msg_header_t* msg = oxpc_object_serialize_to_mach_message(obj, destination_port, reply_port, &msg_size);

  if (!msg) {
    ERROR("unable to serialize oxpc object to mach message");
  }

  kern_return_t err;
  err = mach_msg(msg,
                 MACH_SEND_MSG|MACH_MSG_OPTION_NONE,
                 (mach_msg_size_t)msg_size,
                 0,
                 MACH_PORT_NULL,
                 MACH_MSG_TIMEOUT_NONE,
                 MACH_PORT_NULL);

  return err;
}

/* check the type of the runtime object and ERROR on mismatch */
void
oxpc_check_type(
  oxpc_object_t obj,
  int type)
{
  if (obj->type != type) {
    ERROR("bad oxpc type\n");
  }
}



