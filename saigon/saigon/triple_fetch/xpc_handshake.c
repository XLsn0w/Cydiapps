#include <stdio.h>
#include <stdlib.h>

#include <mach/mach.h>
//#include <bootstrap.h>

kern_return_t
bootstrap_look_up(mach_port_t bp, const char* service_name, mach_port_t *sp);

#include "xpc_handshake.h"

struct xpc_w00t {
  mach_msg_header_t hdr;
  mach_msg_body_t body;
  mach_msg_port_descriptor_t client_port;
  mach_msg_port_descriptor_t reply_port;
};

static int
xpc_checkin(
  mach_port_t service_port,
  mach_port_t* client_port,
  mach_port_t* reply_port)
{
  // allocate the client and reply port:
  kern_return_t err;
  err = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, client_port);
  if (err != KERN_SUCCESS) {
    printf("port allocation failed: %s\n", mach_error_string(err));
    exit(EXIT_FAILURE);
  }
  // insert a send so we maintain the ability to send to this port
  err = mach_port_insert_right(mach_task_self(), *client_port, *client_port, MACH_MSG_TYPE_MAKE_SEND);
  if (err != KERN_SUCCESS) {
    printf("port right insertion failed: %s\n", mach_error_string(err));
    exit(EXIT_FAILURE);
  }

  err = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, reply_port);
  if (err != KERN_SUCCESS) {
    printf("port allocation failed: %s\n", mach_error_string(err));
    exit(EXIT_FAILURE);
  }

  struct xpc_w00t msg;
  memset(&msg.hdr, 0, sizeof(msg));
  msg.hdr.msgh_bits = MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, 0, 0, MACH_MSGH_BITS_COMPLEX);
  msg.hdr.msgh_size = sizeof(msg);
  msg.hdr.msgh_remote_port = service_port;
  msg.hdr.msgh_id   = 'w00t';
  
  msg.body.msgh_descriptor_count = 2;

  msg.client_port.name        = *client_port;
  msg.client_port.disposition = MACH_MSG_TYPE_MOVE_RECEIVE; // we still keep the send
  msg.client_port.type        = MACH_MSG_PORT_DESCRIPTOR;

  msg.reply_port.name        = *reply_port;
  msg.reply_port.disposition = MACH_MSG_TYPE_MAKE_SEND;
  msg.reply_port.type        = MACH_MSG_PORT_DESCRIPTOR;
  
  err = mach_msg(&msg.hdr,
                 MACH_SEND_MSG|MACH_MSG_OPTION_NONE,
                 msg.hdr.msgh_size,
                 0,
                 MACH_PORT_NULL,
                 MACH_MSG_TIMEOUT_NONE,
                 MACH_PORT_NULL);
  if (err != KERN_SUCCESS) {
    printf("w00t message send failed: %s\n", mach_error_string(err));
      exit(EXIT_FAILURE); // TODO: We shouldn't exit. Or should we?
  }

  return 1;
}

// lookup a launchd service:
static mach_port_t
lookup(
  char* name)
{
  mach_port_t service_port = MACH_PORT_NULL;
  kern_return_t err = bootstrap_look_up(bootstrap_port, name, &service_port);
  if(err != KERN_SUCCESS){
    printf("unable to look up %s\n", name);
    return MACH_PORT_NULL;
  }
  
  if (service_port == MACH_PORT_NULL) {
    printf("bad service port\n");
    return MACH_PORT_NULL;
  }
  return service_port;
}

void
xpc_connect(
  char* service_name,
  mach_port_t* xpc_client_port,
  mach_port_t* xpc_reply_port)
{
  mach_port_t service_port = lookup(service_name);
  xpc_checkin(service_port, xpc_client_port, xpc_reply_port);
  mach_port_destroy(mach_task_self(), service_port);
}

#if 0
int main() {
  mach_port_t service_port = lookup("com.apple.wifi.sharekit");

  mach_port_t xpc_client_port = MACH_PORT_NULL;
  mach_port_t xpc_reply_port  = MACH_PORT_NULL;

  xpc_checkin(service_port, &xpc_client_port, &xpc_reply_port);
  printf("checked in?\n");
  gets(NULL);
  return 0;
}
#endif

