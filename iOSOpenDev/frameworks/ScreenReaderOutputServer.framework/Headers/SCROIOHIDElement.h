/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/ScreenReaderOutputServer.framework/ScreenReaderOutputServer
 */

#import <ScreenReaderOutputServer/SCROIOElement.h>
#import <ScreenReaderOutputServer/SCROIOHIDElementProtocol.h>
#import <ScreenReaderOutputServer/ScreenReaderOutputServer-Structs.h>

// iOSOpenDev: wrapped with define check (since occurs in other dumped files)
#ifndef __SCROIOHIDElement__
#define __SCROIOHIDElement__ 1
@interface SCROIOHIDElement : SCROIOElement <SCROIOHIDElementProtocol> {
	IOHIDDeviceRef _hidDevice;	// 12 = 0xc
}
@property(readonly, assign) IOHIDDeviceRef hidDevice;	// G=0x19295; converted property
- (id)initWithIOObject:(unsigned)ioobject;	// 0x192a9
- (void)dealloc;	// 0x19399
- (id)copyWithZone:(NSZone *)zone;	// 0x1934d
// converted property getter: - (IOHIDDeviceRef)hidDevice;	// 0x19295
- (int)transport;	// 0x192a5
@end
#endif
