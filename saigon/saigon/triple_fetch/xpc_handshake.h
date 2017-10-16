#ifndef _xpc_handshake_h
#define _xpc_handshake_h

#include <mach/mach.h>

void
xpc_connect(
  char* service_name,
  mach_port_t* xpc_client_port,
  mach_port_t* xpc_reply_port);

#endif
