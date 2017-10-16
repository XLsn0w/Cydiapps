#ifndef remote_file_h
#define remote_file_h

#include <fcntl.h>
#include <mach/mach.h>

int pull_remote_fd(mach_port_t remote_task_port, int remote_fd);
int push_local_fd(mach_port_t remote_task_port, int local_fd);

// open a file the the context of the given task and move the file descriptor back to this task
int remote_open(mach_port_t remote_task_port, char* path, int oflags, mode_t mode);


#endif
