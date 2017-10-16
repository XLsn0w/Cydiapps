#ifndef sploit_h
#define sploit_h

#include <stdint.h>

mach_port_t do_exploit();
uint64_t find_blr_x19_gadget();
#endif
