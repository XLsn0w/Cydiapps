/*
	Basic API for AppleAVE2UserClient
*/

#include <mach/mach.h>
#include <Foundation/Foundation.h>
#include "IOKitLib.h"


#ifndef __APPLE_AVE_UTILS_H_
#define __APPLE_AVE_UTILS_H_

#define IOKIT_ALL_SERVICES									("IOService")

#define APPLEAVE2_EXTERNAL_METHOD_ADD_CLIENT				(0)
#define APPLEAVE2_EXTERNAL_METHOD_REMOVE_CLIENT				(1)
#define APPLEAVE2_EXTERNAL_METHOD_SET_SESSION_SETTINGS		(3)
#define APPLEAVE2_EXTERNAL_METHOD_ENCODE_FRAME 				(6)
#define APPLEAVE2_EXTERNAL_METHOD_PREPARE_TO_ENCODE_FRAMES  (7)



/*
	v33 = *((_DWORD *)v13 + 0x654);
*/
#define ENCODE_FRAME_OFFSET_UI32_HEIGHT						(0xA10+8)
/*
	memmovea_74(v13 + 0x1C90, v20 + 0xD58, 0x2E18LL);
	v34 = *((_DWORD *)v13 + 0x730);
*/
#define ENCODE_FRAME_OFFSET_SLICE_PER_FRAME					(0xD58+0x30)
/*
 	 v55 = get_kernel_address_by_counter_multiple((__int64)kernel_frame_queue_1, counter);
 	 v58 = *(_DWORD *)(v55 + 0x10);
*/
#define ENCODE_FRAME_OFFSET_INFO_TYPE						(0x10)

#define ENCODE_FRAME_OFFSET_IOSURFACE_BUFFER_MGR			(0x11D8)

/*
	 v8 = *(unsigned int *)(a3 + 0xC);
  if ( (unsigned int)v8 >= 2 )
  {
    v9 = "AVE ERROR: IMG_V_EncodeAndSendFrame multiPassEndPassCounterEnc (%d) >= H264VIDEOENCODER_MULTI_PASS_PASSES\n";
*/
#define KERNEL_ADDRESS_MULTIPASS_END_PASS_COUNTER_ENC		(0xC)

/*
	memmovea_74(&frame_stuff->field_1C90, v20 + 0xD58, 0x2E18LL);
	frame_stuff->field_4A88
	Python>hex(0x4a88-0x1c90)
	0x2df8
	Python>hex(0xd58+0x2df8)
	0x3b50
*/
#define ENCODE_FRAME_OFFSET_KEEP_CACHE						(0x3B50)

#define IOKIT_ADD_CLIENT_INPUT_BUFFER_SIZE						(4)
#define IOKIT_ADD_CLIENT_OUTPUT_BUFFER_SIZE						(4)
#define IOKIT_REMOVE_CLIENT_INPUT_BUFFER_SIZE					(4)
#define IOKIT_REMOVE_CLIENT_OUTPUT_BUFFER_SIZE					(4)
#define IOKIT_ENCODE_FRAME_INPUT_BUFFER_SIZE					(0x28)
#define IOKIT_ENCODE_FRAME_OUTPUT_BUFFER_SIZE					(4)

kern_return_t apple_ave_utils_add_client(io_connect_t conn);
kern_return_t apple_ave_utils_remove_client(io_connect_t conn);
kern_return_t apple_ave_utils_get_connection(io_connect_t * conn_out);
void fuzz_encode_frames(io_connect_t conn, uint32_t bad_surface, uint32_t surface_id);
kern_return_t apple_ave_utils_prepare_to_encode_frames(io_connect_t conn, void * input_buffer,
 void * output_buffer);
kern_return_t apple_ave_utils_encode_frame(io_connect_t conn, void * input_buffer,
	void * output_buffer);
kern_return_t apple_ave_utils_set_session_settings(io_connect_t conn, void * input_buffer, void * output_buffer);

#endif /* __APPLE_AVE_UTILS_H_ */
