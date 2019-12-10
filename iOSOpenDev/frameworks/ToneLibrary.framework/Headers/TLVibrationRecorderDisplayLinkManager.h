/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/ToneLibrary.framework/ToneLibrary
 */

#import <ToneLibrary/XXUnknownSuperclass.h>

@class CADisplayLink, NSMutableSet;

@interface TLVibrationRecorderDisplayLinkManager : XXUnknownSuperclass {
	CADisplayLink *_displayLink;	// 4 = 0x4
	NSMutableSet *_activeTargetActions;	// 8 = 0x8
	NSMutableSet *_addedTargetActions;	// 12 = 0xc
	NSMutableSet *_removedTargetActions;	// 16 = 0x10
	BOOL _isHandlingDisplayRefresh;	// 20 = 0x14
	BOOL _shouldInvalidate;	// 21 = 0x15
	BOOL _shouldInvalidateAutomatically;	// 22 = 0x16
@private
	BOOL shouldInvalidateAutomatically;	// 23 = 0x17
}
@property(retain, nonatomic, setter=_setDisplayLink:) CADisplayLink *_displayLink;	// G=0x1aa21; S=0x1aad9; 
@property(assign, nonatomic) BOOL shouldInvalidateAutomatically;	// G=0x1b151; S=0x1ada5; @synthesize
@property(readonly, assign, nonatomic) int frameInterval;	// G=0x1aa01; 
@property(readonly, assign, nonatomic) double timestamp;	// G=0x1a9e1; 
@property(readonly, assign, nonatomic) double duration;	// G=0x1a9c1; 
@property(readonly, assign, nonatomic, getter=isPaused) BOOL paused;	// G=0x1a99d; 
+ (void)releaseCurrentDisplayLinkManager;	// 0x1a7f5
+ (id)currentDisplayLinkManager;	// 0x1a745
// declared property getter: - (BOOL)shouldInvalidateAutomatically;	// 0x1b151
- (void)_displayDidRefresh:(id)_display;	// 0x1ae0d
- (void)invalidate;	// 0x1adf9
// declared property setter: - (void)setShouldInvalidateAutomatically:(BOOL)invalidateAutomatically;	// 0x1ada5
- (void)removeTarget:(id)target selector:(SEL)selector;	// 0x1ac79
- (void)addTarget:(id)target selector:(SEL)selector frameInterval:(int)interval;	// 0x1ab75
- (void)addTarget:(id)target selector:(SEL)selector;	// 0x1ab51
// declared property setter: - (void)_setDisplayLink:(id)link;	// 0x1aad9
// declared property getter: - (id)_displayLink;	// 0x1aa21
// declared property getter: - (int)frameInterval;	// 0x1aa01
// declared property getter: - (double)timestamp;	// 0x1a9e1
// declared property getter: - (double)duration;	// 0x1a9c1
// declared property getter: - (BOOL)isPaused;	// 0x1a99d
- (void)dealloc;	// 0x1a915
- (id)init;	// 0x1a855
@end
