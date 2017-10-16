#ifndef remote_ports_h
#define remote_ports_h

#include <mach/mach.h>

mach_port_t
pull_remote_port(mach_port_t task_port,
                 mach_port_name_t remote_port_name,
                 mach_port_right_t disposition);    // eg MACH_MSG_TYPE_COPY_SEND

mach_port_name_t
push_local_port(mach_port_t remote_task_port,
                mach_port_t port_to_push,
                mach_port_right_t disposition);

#endif /* remote_ports_h */
