/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/PhotoLibrary.framework/PhotoLibrary
 */

#import <PhotoLibrary/PhotoLibrary-Structs.h>
#import <PhotoLibrary/XXUnknownSuperclass.h>

@class UIImageView, NSTimer;

@interface PLCameraZoomSlider : XXUnknownSuperclass {
	BOOL _isZoomingFromMin;	// 132 = 0x84
	BOOL _isZoomingFromMax;	// 133 = 0x85
	BOOL _autorotationEnabled;	// 134 = 0x86
	BOOL _watchingOrientationChanges;	// 135 = 0x87
	int _orientation;	// 136 = 0x88
	NSTimer *_visibilityTimer;	// 140 = 0x8c
	UIImageView *_minImageView;	// 144 = 0x90
	UIImageView *_maxImageView;	// 148 = 0x94
}
@property(assign, nonatomic) BOOL autorotationEnabled;	// G=0xb7b69; S=0xb7b79; 
@property(assign, nonatomic) BOOL isZoomingFromMax;	// G=0xb8205; S=0xb8215; @synthesize=_isZoomingFromMax
@property(assign, nonatomic) BOOL isZoomingFromMin;	// G=0xb81e5; S=0xb81f5; @synthesize=_isZoomingFromMin
// declared property setter: - (void)setIsZoomingFromMax:(BOOL)max;	// 0xb8215
// declared property getter: - (BOOL)isZoomingFromMax;	// 0xb8205
// declared property setter: - (void)setIsZoomingFromMin:(BOOL)min;	// 0xb81f5
// declared property getter: - (BOOL)isZoomingFromMin;	// 0xb81e5
- (void)hideZoomSlider:(id)slider;	// 0xb810d
- (void)_postHideZoomSliderAnimation;	// 0xb80d9
- (void)makeInvisible;	// 0xb80c5
- (void)makeVisible;	// 0xb804d
- (void)stopVisibilityTimer;	// 0xb7fed
- (void)startVisibilityTimer;	// 0xb7edd
- (BOOL)visibilityTimerIsValid;	// 0xb7eb9
- (void)_setDeviceOrientation:(int)orientation animated:(BOOL)animated;	// 0xb7d9d
- (void)setOrientation:(int)orientation;	// 0xb7d89
- (void)_deviceOrientationChanged:(id)changed;	// 0xb7d1d
- (void)stopWatchingDeviceOrientationChanges;	// 0xb7c91
- (void)startWatchingDeviceOrientationChanges;	// 0xb7bcd
// declared property setter: - (void)setAutorotationEnabled:(BOOL)enabled;	// 0xb7b79
// declared property getter: - (BOOL)autorotationEnabled;	// 0xb7b69
- (CGAffineTransform)_rotationTransformForDeviceOrientation:(int)deviceOrientation;	// 0xb7afd
- (void)endTrackingWithTouch:(id)touch withEvent:(id)event;	// 0xb7a99
- (BOOL)continueTrackingWithTouch:(id)touch withEvent:(id)event;	// 0xb7929
- (BOOL)beginTrackingWithTouch:(id)touch withEvent:(id)event;	// 0xb78a5
- (void)clearZoomingFromEndcap;	// 0xb7871
- (BOOL)isZoomingFromEndcap;	// 0xb782d
- (BOOL)pointInside:(CGPoint)inside withEvent:(id)event;	// 0xb77b1
- (int)locationOfTouch:(id)touch;	// 0xb7551
- (CGRect)trackRectForBounds:(CGRect)bounds;	// 0xb74e5
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value;	// 0xb7469
- (void)addEndCapImageViewsWithMinImage:(id)minImage maxImage:(id)image;	// 0xb7141
- (void)dealloc;	// 0xb7085
- (id)initWithFrame:(CGRect)frame;	// 0xb7011
@end
