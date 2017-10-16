/*
	This file is responsible for executing the ROP chain (post-installation on the sysctl entries).
*/

#include <stdlib.h>
#include <mach/mach.h>

#ifndef __RWX_H_
#define __RWX_H_


kern_return_t rwx_execute(uint64_t func_addr, unsigned long arg0, unsigned long arg1, unsigned long arg2);
kern_return_t rwx_read(uint64_t addr, void * value, size_t length);
kern_return_t rwx_write(uint64_t addr, void * value, size_t length);

#endif /* __RWX_H_ */
