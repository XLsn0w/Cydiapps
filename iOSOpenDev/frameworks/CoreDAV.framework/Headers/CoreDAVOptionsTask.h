/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/CoreDAV.framework/CoreDAV
 */

#import <CoreDAV/CoreDAVTask.h>

@protocol CoreDAVOptionsTaskDelegate;

@interface CoreDAVOptionsTask : CoreDAVTask {
}
@property(assign, nonatomic) id<CoreDAVOptionsTaskDelegate> delegate;	// @dynamic
- (void)finishCoreDAVTaskWithError:(id)error;	// 0x14771
- (id)requestBody;	// 0x1476d
- (id)httpMethod;	// 0x14761
@end
