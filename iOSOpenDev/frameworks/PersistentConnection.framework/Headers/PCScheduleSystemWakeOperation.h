/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/PersistentConnection.framework/PersistentConnection
 */



@class NSString, NSDate;

__attribute__((visibility("hidden")))
@interface PCScheduleSystemWakeOperation : NSObject {
@private
	BOOL _scheduleOrCancel;	// 12 = 0xc
	NSDate *_wakeDate;	// 16 = 0x10
	NSString *_serviceIdentifier;	// 20 = 0x14
	void *_unqiueIdentifier;	// 24 = 0x18
}
- (id)initForScheduledWake:(BOOL)scheduledWake wakeDate:(id)date serviceIdentifier:(id)identifier uniqueIdentifier:(void *)identifier4;	// 0xde19
- (void)main;	// 0xda81
- (void)dealloc;	// 0xda21
@end
