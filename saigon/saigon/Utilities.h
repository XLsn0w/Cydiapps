//
//  Utilities.h
//  saïgon
//
//  Created by Abraham Masri on 8/18/17.
//

#ifndef Utilities_h
#define Utilities_h

#include <stdint.h>
#include <stdlib.h>
#include "task_ports.h"
#include "offsets.h"

int ami_jailbroken();

void set_privileged_port(mach_port_t _privileged_port, task_t launchd_task);
mach_port_t get_privileged_port();
mach_port_t get_launchd_task();

void set_self_port_name(mach_port_name_t pt_name);
mach_port_name_t get_self_port_name();

void kernel_panic();
char * utils_get_base64_payload(void * buffer, size_t length);

int offsets_init();

#endif /* Utilities_h */
