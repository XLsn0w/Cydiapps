/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/MediaControlReceiver.framework/MediaControlReceiver
 */

#import <MediaControlReceiver/MediaControlReceiver-Structs.h>
#import <MediaControlReceiver/XXUnknownSuperclass.h>

@class AirPlayLocalSlideshow;
@protocol MediaControlServerDelegate;

@interface MediaControlServer : XXUnknownSuperclass {
	MediaControlServerImp *_server;	// 4 = 0x4
	dispatch_queue_s *_dispatchQueue;	// 8 = 0x8
	id<MediaControlServerDelegate> _delegate;	// 12 = 0xc
	AirPlayLocalSlideshow *_slideshow;	// 16 = 0x10
	double _lastActivity;	// 20 = 0x14
}
@property(assign, nonatomic) id<MediaControlServerDelegate> delegate;	// G=0xfd1d; S=0xfd2d; @synthesize=_delegate
@property(assign, nonatomic) unsigned supportedFeatures;	// G=0xfcc9; S=0x105b1; 
- (id)init;	// 0x106ad
- (void)dealloc;	// 0x103d9
- (void)invalidate;	// 0x10639
- (void)setDispatchQueue:(dispatch_queue_s *)queue;	// 0x105f9
- (long)setPassword:(id)password;	// 0x105c5
// declared property getter: - (unsigned)supportedFeatures;	// 0xfcc9
// declared property setter: - (void)setSupportedFeatures:(unsigned)features;	// 0x105b1
- (long)start;	// 0x10569
- (void)postEvent:(id)event;	// 0x10539
- (void)slideshowRequestAssetWithInfo:(id)info sessionUUID:(const char *)uuid completion:(id)completion;	// 0x10435
// declared property getter: - (id)delegate;	// 0xfd1d
// declared property setter: - (void)setDelegate:(id)delegate;	// 0xfd2d
@end
