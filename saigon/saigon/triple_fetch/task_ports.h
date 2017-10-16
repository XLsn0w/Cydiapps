#ifndef task_ports_h
#define task_ports_h

#include <mach/mach.h>

mach_port_t
find_task_port_for_path(char* path);

mach_port_t
find_task_port_for_pid(pid_t pid);

void
refresh_task_ports_list(mach_port_t task_port);

void
drop_all_task_ports();

#endif
