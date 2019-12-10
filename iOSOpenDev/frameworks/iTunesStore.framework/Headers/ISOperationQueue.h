/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iTunesStore.framework/iTunesStore
 */

#import <iTunesStore/XXUnknownSuperclass.h>

@class NSOperationQueue;

@interface ISOperationQueue : XXUnknownSuperclass {
	NSOperationQueue *_queue;	// 4 = 0x4
}
@property(assign) int maxConcurrentOperationCount;	// G=0x77b1; S=0x77f1; converted property
+ (id)mainQueue;	// 0x75e9
+ (BOOL)isActive;	// 0x75a9
- (void)setSuspended:(BOOL)suspended;	// 0x7811
// converted property setter: - (void)setMaxConcurrentOperationCount:(int)count;	// 0x77f1
- (id)operations;	// 0x77d1
// converted property getter: - (int)maxConcurrentOperationCount;	// 0x77b1
- (void)cancelAllOperations;	// 0x7791
- (void)addOperations:(id)operations waitUntilFinished:(BOOL)finished;	// 0x76b1
- (void)addOperation:(id)operation;	// 0x7655
- (void)dealloc;	// 0x7541
- (id)init;	// 0x74c9
@end
