#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

#include "remote_file.h"

#include "remote_call.h"
#include "remote_ports.h"

extern int fileport_makeport(int fd, mach_port_name_t* port);
extern int fileport_makefd(mach_port_name_t port);

// copy the remote file descriptor remote_fd to this task
// and return the local fd
int pull_remote_fd(mach_port_t remote_task_port, int remote_fd) {
  // this will only work for the following file types:
  // DTYPE_VNODE, DTYPE_SOCKET, DTYPE_PIPE, DTYPE_PSXSHM
  
  mach_port_t remote_fileport_name = MACH_PORT_NULL;
  int remote_err = (int) call_remote(remote_task_port, fileport_makeport, 2, REMOTE_LITERAL(remote_fd), REMOTE_OUT_BUFFER(&remote_fileport_name, sizeof(remote_fileport_name)));
  
  if (remote_err != 0) {
    printf("remote fileport_makeport failed: %x\n", remote_err);
    return -1;
  }
  
  // move that send right into this process:
  mach_port_t local_fileport = pull_remote_port(remote_task_port, remote_fileport_name, MACH_MSG_TYPE_MOVE_SEND);
  if (local_fileport == MACH_PORT_NULL) {
    printf("failed to pull fileport into this process\n");
    return -1;
  }
  
  // convert the fileport into a local fd
  int local_fd = fileport_makefd(local_fileport);
  if (local_fd < 0) {
    // is that how it would return an error?
    printf("fileport_makefd failed %x\n", local_fd);
    return -1;
  }
  
  return local_fd;
}

// copy the local fd to the remote process and return the remote fd number
int push_local_fd(mach_port_t remote_task_port, int local_fd) {
  kern_return_t err;
  mach_port_t local_fileport_name = MACH_PORT_NULL;
  err = fileport_makeport(local_fd, &local_fileport_name);
  if (err != KERN_SUCCESS) {
    printf("failed to make local fileport\n");
    return -1;
  }
  
  mach_port_name_t remote_fileport_name = push_local_port(remote_task_port, local_fileport_name, MACH_MSG_TYPE_MOVE_SEND);
  if (remote_fileport_name == MACH_PORT_NULL) {
    printf("failed to push local fileport to target process\n");
    return -1;
  }
  
  // convert that remote fileport back into the fd in the remote process:
  int remote_fd = (int) call_remote(remote_task_port, fileport_makefd, 1,
                                    REMOTE_LITERAL(remote_fileport_name));
  
  if (remote_fd < 0) {
    printf("failed to convert remote fileport %x into fd %d\n", remote_fileport_name, remote_fd);
    return -1;
  }
  
  // drop the uref on the remote send right
  err = mach_port_deallocate(remote_task_port, remote_fileport_name);
  if (err != KERN_SUCCESS) {
    printf("failed to drop uref on fileport in remote process\n");
    return -1;
  }
  
  return remote_fd;
}

// open a file the the context of the given task and move the file descriptor back to this task
int remote_open(mach_port_t remote_task_port, char* path, int oflags, mode_t mode) {
  
  int remote_fd = (int) call_remote(remote_task_port, open, 3, REMOTE_CSTRING(path), REMOTE_LITERAL(oflags), REMOTE_LITERAL(mode));
  
  if (remote_fd < 0) {
    printf("remote open failed: %d\n", remote_fd);
    return remote_fd;
  }
  
  int local_fd = pull_remote_fd(remote_task_port, remote_fd);
  
  // close the remote file:
  (void) call_remote(remote_task_port, close, 1, REMOTE_LITERAL(remote_fd));
  
  return local_fd;
}
