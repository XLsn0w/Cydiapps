/*
	API for basic communication with IOSurfaceRootUserClient
*/

#include <mach/mach.h>
#include <Foundation/Foundation.h>
#include "IOKitLib.h"

#ifndef IOSURFACE_UTILS_H_
#define IOSURFACE_UTILS_H_

#define IOSURFACE_IOKIT_SERVICE											("IOSurfaceRoot")

#define IOSURFACE_EXTERNAL_METHOD_CREATE								(0)
#define IOSURFACE_EXTERNAL_METHOD_RELEASE								(1)
#define IOSURFACE_EXTERNAL_METHOD_LOOKUP								(4)
#define IOSURFACE_EXTERNAL_METHOD_CREATE_SET_VALUE						(9)
#define IOSURFACE_EXTERNAL_METHOD_CREATE_COPY_VALUE						(10)
#define IOSURFACE_EXTERNAL_METHOD_SET_BULK_ATTACHMENT					(26)
#define IOSURFACE_EXTERNAL_METHOD_GET_BULK_ATTACHMENT					(27)


#define IOSURFACE_BULK_ATTACHMENT_SIZE									(0x58)
#define IOSURFACE_BULK_ATTACHMENT_FLAG									(0x48)

#define IOSURFACE_BULKATTACHMENT_FLAG_SET_ALL_BULKS						(0xFF)

#define IOSURFACE_DICTIONARY_SIZE										(0x3C8)
#define IOSURFACE_SURFACE_ID_OFFSET										(0x10)

#define IOSURFACE_KERNEL_OBJECT_SIZE									(0x338)

kern_return_t iosurface_utils_get_connection(io_connect_t * conn_out);
kern_return_t iosurface_utils_create_surface(io_connect_t connection, uint32_t * surface_id_out, void * output_buffer);
kern_return_t iosurface_utils_release_surface(io_connect_t connection, uint32_t surface_id_to_free);
kern_return_t iosurface_utils_set_bulk_attachment(io_connect_t conn, uint32_t surface_id, void * bulk_data);
kern_return_t iosurface_utils_get_bulk_attachment(io_connect_t conn, uint32_t surface_id, char * bulk_data_out);
kern_return_t iosurface_utils_get_surface_info(io_connect_t conn, uint32_t surface_id, void ** surface_buffer, size_t * buffer_size);

kern_return_t iosurface_utils_set_value(io_connect_t conn, uint32_t surface_id,
	const char * key, char * data);
/*
 * Function name: 	iosurface_utils_set_bulk_attachment_flag
 * Description:		Sets the flag for the input buffer. Used for set bulk attachment to define which fields should be set
 * Returns:			void.
 */

static inline void iosurface_utils_set_bulk_attachment_flag(void * input_buffer, uint16_t flags) {
	*(uint16_t*)((char*)input_buffer + IOSURFACE_BULK_ATTACHMENT_FLAG) = flags;
}



#endif /* IOSURFACE_UTILS_H_ */
