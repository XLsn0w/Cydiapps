/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/SportsWorkout.framework/SportsWorkout
 */

#import <SportsWorkout/SWAccessory.h>


@interface SWRemote : SWAccessory {
	BOOL _isListeningToRemote;	// 24 = 0x18
}
@property(readonly, assign, nonatomic) BOOL isListeningToRemote;	// G=0x323f1; @synthesize=_isListeningToRemote
// declared property getter: - (BOOL)isListeningToRemote;	// 0x323f1
- (void)stopListeningToRemoteCommands;	// 0x323dd
- (void)beginListeningToRemoteCommands;	// 0x323c9
@end