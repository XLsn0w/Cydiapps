#include <stdio.h>
#include <mach/mach.h>

#include "remote_ports.h"
#include "remote_call.h"

// copy/move the right named by remote_port_name+disposition into this process, returning our name
mach_port_t
pull_remote_port(
                 mach_port_t task_port,
                 mach_port_name_t remote_port_name,
                 mach_port_right_t disposition)     // eg MACH_MSG_TYPE_COPY_SEND
{
  kern_return_t err;
  mach_port_t local_name = MACH_PORT_NULL;
  mach_msg_type_name_t local_rights = 0;
  err = mach_port_extract_right(task_port, remote_port_name, disposition, &local_name, &local_rights);
  if (err != KERN_SUCCESS) {
    printf("[INFO]: unable to extract right from remote task: %x %s\n", err, mach_error_string(err));
    return 0;
  }
  
  return local_name;
}

#define PUSH_PORT_MSGH_ID 0x74726f70

// pushing a local port to a remote process is more tricky:
// mach_port_insert_right requires you to specify the name of the new right;
// if that name doesn't exist in the destination space it will be allocated
// This makes things a bit fiddly as we'd have to come up with a name ourselves
// then check it succeeded etc
// Instead we can do it the proper way by sending the right in a mach message
// This will require a remote call though to receive the message in the context of the receiver
mach_port_name_t
push_local_port(mach_port_t remote_task_port,
                mach_port_t port_to_push,
                mach_port_right_t disposition)
{
  kern_return_t err;
  
  // allocate a receive right in the remote task:
  mach_port_name_t remote_receive_right_name = MACH_PORT_NULL;
  err = mach_port_allocate(remote_task_port, MACH_PORT_RIGHT_RECEIVE, &remote_receive_right_name);
  if (err != KERN_SUCCESS){
    printf("unable to allocate a receive right in the target %s %x", mach_error_string(err), err);
    return MACH_PORT_NULL;
  }
  
  // give ourselves a send right to that port:
  mach_port_t local_send_right_name = pull_remote_port(remote_task_port, remote_receive_right_name, MACH_MSG_TYPE_MAKE_SEND);
  
  // send the port - use the "reply port", we can actually send any right in there
  mach_msg_header_t msg = {0};

  msg.msgh_bits = MACH_MSGH_BITS_SET_PORTS(MACH_MSG_TYPE_COPY_SEND, disposition, 0);
  msg.msgh_size = sizeof(mach_msg_header_t);
  msg.msgh_remote_port = local_send_right_name;
  msg.msgh_local_port = port_to_push;
  msg.msgh_voucher_port = MACH_PORT_NULL;
  msg.msgh_id = PUSH_PORT_MSGH_ID;
  
  // send that:
  mach_msg_send(&msg);
  
  // receive it remotely:
  struct {
    mach_msg_header_t hdr;
    mach_msg_trailer_t trailer;
  } receive_msg;
  
  // we can't do this locally as mach_msg is only a mach_trap
  err = (kern_return_t) call_remote(remote_task_port, mach_msg, 7,
                                    REMOTE_OUT_BUFFER(&receive_msg, sizeof(receive_msg)),
                                    REMOTE_LITERAL(MACH_RCV_MSG | MACH_MSG_TIMEOUT_NONE),
                                    REMOTE_LITERAL(0),
                                    REMOTE_LITERAL(sizeof(receive_msg)),
                                    REMOTE_LITERAL(remote_receive_right_name),
                                    REMOTE_LITERAL(0),
                                    REMOTE_LITERAL(0));
  
  if (err != KERN_SUCCESS){
    printf("remote mach_msg failed: %s %x\n", mach_error_string(err), err);
    return MACH_PORT_NULL;
  }
  
  if (receive_msg.hdr.msgh_id != PUSH_PORT_MSGH_ID) {
    printf("received message doesn't have the expected msgh_id...\n");
    return MACH_PORT_NULL;
  }
  
  mach_port_name_t remote_name_for_local_port = receive_msg.hdr.msgh_remote_port;
  if (remote_name_for_local_port == MACH_PORT_NULL) {
    printf("mach_msg receive success but target didn't get a name for the port...\n");
    return MACH_PORT_NULL;
  }
  
  // clean up
  mach_port_deallocate(mach_task_self(), local_send_right_name);
  mach_port_destroy(remote_task_port, remote_receive_right_name);
  
  return remote_name_for_local_port;
}
