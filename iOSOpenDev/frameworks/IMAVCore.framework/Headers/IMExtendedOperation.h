/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/IMAVCore.framework/IMAVCore
 */

#import <IMAVCore/XXUnknownSuperclass.h>

@class NSString, NSThread, NSMutableSet;

__attribute__((visibility("hidden")))
@interface IMExtendedOperation : XXUnknownSuperclass {
	NSThread *_operationThread;	// 12 = 0xc
	NSString *_operationName;	// 16 = 0x10
	unsigned _operationState;	// 20 = 0x14
	double _operationTimeout;	// 24 = 0x18
	NSMutableSet *_childOperations;	// 32 = 0x20
}
@property(readonly, assign, nonatomic) unsigned state;	// G=0x1cd3d; 
@property(assign, nonatomic) double timeout;	// G=0x1cc0d; S=0x1cbf9; 
@property(retain, nonatomic) NSString *name;	// G=0x1cbe9; S=0x1cba5; 
+ (id)runLoopModes;	// 0x1c6d1
- (BOOL)isFinished;	// 0x1cd71
- (BOOL)isExecuting;	// 0x1cd51
- (BOOL)isConcurrent;	// 0x1cd4d
// declared property getter: - (unsigned)state;	// 0x1cd3d
- (void)cancel;	// 0x1cd29
- (void)fail;	// 0x1cd15
- (void)_timeout;	// 0x1cd01
- (void)_stopWithState:(unsigned)state;	// 0x1cc25
// declared property getter: - (double)timeout;	// 0x1cc0d
// declared property setter: - (void)setTimeout:(double)timeout;	// 0x1cbf9
// declared property getter: - (id)name;	// 0x1cbe9
// declared property setter: - (void)setName:(id)name;	// 0x1cba5
- (void)didFinish;	// 0x1cba1
- (void)createChildOperations;	// 0x1cb9d
- (void)addChildOperation:(id)operation;	// 0x1c9d5
- (void)observeValueForKeyPath:(id)keyPath ofObject:(id)object change:(id)change context:(void *)context;	// 0x1c8e9
- (void)_threadedMain;	// 0x1c715
- (void)start;	// 0x1c585
- (void)_startThread;	// 0x1c429
- (unsigned)_minChildOperationState;	// 0x1c351
- (unsigned)_maxChildOperationState;	// 0x1c275
- (void)_setState:(unsigned)state;	// 0x1bf85
- (void)dealloc;	// 0x1be6d
@end
