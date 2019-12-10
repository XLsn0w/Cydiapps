/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/Message.framework/Message
 */

#import <Message/MFDAMailAccountRequest.h>
#import <Message/XXUnknownSuperclass.h>

@class MFDAMessageStore, MimePart, Message;
@protocol MFRequestQueueResponseConsumer, DAMailAccountStreamConsumerFactory;

@interface _MFDAMessageStoreFetchRequest : XXUnknownSuperclass <MFDAMailAccountRequest> {
	id<DAMailAccountStreamConsumerFactory, MFRequestQueueResponseConsumer> consumer;	// 20 = 0x14
	MFDAMessageStore *store;	// 24 = 0x18
	Message *message;	// 28 = 0x1c
	MimePart *part;	// 32 = 0x20
	int format;	// 36 = 0x24
	BOOL partial;	// 40 = 0x28
}
- (unsigned long long)generationNumber;	// 0x66381
- (BOOL)shouldSend;	// 0x66435
- (id)deferredOperation;	// 0x62c75
- (unsigned)hash;	// 0x66529
- (BOOL)isEqual:(id)equal;	// 0x66561
@end
