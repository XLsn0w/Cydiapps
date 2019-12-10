/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/ScreenReaderCore.framework/ScreenReaderCore
 */

#import <ScreenReaderCore/ScreenReaderCore-Structs.h>
#import <ScreenReaderCore/XXUnknownSuperclass.h>

@class SCRCTargetSelectorTimer, SCRCGestureFactory;

@interface SCRCGestureFactory : XXUnknownSuperclass {
	float _stallDistance;	// 4 = 0x4
	float _maxDimension;	// 8 = 0x8
	float _thumbRegion;	// 12 = 0xc
	int _orientation;	// 16 = 0x10
	int _directions[7];	// 20 = 0x14
	CGPoint _axisFlipper;	// 48 = 0x30
	float _scaledTrackingDistance;	// 56 = 0x38
	BOOL _setTrackingTimer;	// 60 = 0x3c
	float _flickVelocityThreshold;	// 64 = 0x40
	double _tapVelocityThreshold;	// 68 = 0x44
	double _echoWaitTime;	// 76 = 0x4c
	CGRect _mainFrame;	// 84 = 0x54
	CGRect _gutterFrame;	// 100 = 0x64
	double _lastTime;	// 116 = 0x74
	double _lastDownTime;	// 124 = 0x7c
	double _lastGutterDownTime;	// 132 = 0x84
	float _lastDegrees;	// 140 = 0x8c
	float _startDegrees;	// 144 = 0x90
	float _startDistance;	// 148 = 0x94
	BOOL _startedInGutter;	// 152 = 0x98
	double _requireDelayBeforeTracking;	// 156 = 0x9c
	BOOL _requireUp;	// 164 = 0xa4
	BOOL _thumbRejectionEnabled;	// 165 = 0xa5
	float _thumbRejectionDistance;	// 168 = 0xa8
	int _state;	// 172 = 0xac
	int _previousState;	// 176 = 0xb0
	int _direction;	// 180 = 0xb4
	float _directionalSlope;	// 184 = 0xb8
	SCRCFingerState _finger[2];	// 188 = 0xbc
	unsigned _absoluteFingerCount;	// 2036 = 0x7f4
	unsigned short _fingerCount;	// 2040 = 0x7f8
	unsigned short _lastFingerCount;	// 2042 = 0x7fa
	float _distance;	// 2044 = 0x7fc
	unsigned _tapCount;	// 2048 = 0x800
	CGRect _tapFrame;	// 2052 = 0x804
	CGRect _tapMultiFrame;	// 2068 = 0x814
	struct {
		id track;
		id tap;
		id gutterUp;
		id splitTap;
	} _delegate;	// 2084 = 0x824
	SCRCTargetSelectorTimer *_trackingTimer;	// 2100 = 0x834
	struct {
		BOOL down;
		BOOL dead;
		BOOL gutter;
		unsigned current;
		unsigned digits;
		unsigned count;
		CGRect frame;
		CGPoint location[5];
		CGPoint locationPerTap[5];
		unsigned digitsPerTap;
		double thisTime;
		double lastTime;
	} _tap;	// 2104 = 0x838
	SCRCTargetSelectorTimer *_tapTimer;	// 2236 = 0x8bc
	SCRCTargetSelectorTimer *_gutterUpTimer;	// 2240 = 0x8c0
	struct {
		SCRCGestureFactory *factory;
		BOOL isSplitting;
		BOOL isTapping;
		BOOL fastTrack;
		BOOL tapDead;
		BOOL timedOut;
		BOOL active;
		unsigned fingerIdentifier;
		double fingerDownTime;
		CGPoint startTapLocation;
		CGPoint lastTapLocation;
		CGPoint primaryFingerLocation;
		float tapDistance;
		int state;
	} _split;	// 2244 = 0x8c4
}
@property(assign, nonatomic) BOOL thumbRejectionEnabled;	// G=0x8911; S=0x8921; @synthesize=_thumbRejectionEnabled
@property(assign) float flickSpeed;	// G=0x8645; S=0x85ed; converted property
@property(assign) float tapSpeed;	// G=0x86e1; S=0x8675; converted property
@property(assign) int orientation;	// G=0x8719; S=0x8955; converted property
@property(readonly, assign) CGRect mainFrame;	// G=0x8729; converted property
@property(readonly, assign) int direction;	// G=0x9939; converted property
@property(readonly, assign) float directionalSlope;	// G=0x874d; converted property
@property(readonly, assign) unsigned absoluteFingerCount;	// G=0x8789; converted property
@property(readonly, assign) float distance;	// G=0x99cd; converted property
@property(readonly, assign) unsigned tapCount;	// G=0x87a9; converted property
@property(readonly, assign) CGRect tapFrame;	// G=0x87c9; converted property
- (id)initWithSize:(CGSize)size delegate:(id)delegate;	// 0x8931
- (id)initWithSize:(CGSize)size delegate:(id)delegate threadKey:(id)key;	// 0x9a2d
// converted property setter: - (void)setFlickSpeed:(float)speed;	// 0x85ed
// converted property getter: - (float)flickSpeed;	// 0x8645
// converted property setter: - (void)setTapSpeed:(float)speed;	// 0x8675
// converted property getter: - (float)tapSpeed;	// 0x86e1
// converted property setter: - (void)setOrientation:(int)orientation;	// 0x8955
// converted property getter: - (int)orientation;	// 0x8719
- (void)dealloc;	// 0x11121
// converted property getter: - (CGRect)mainFrame;	// 0x8729
- (CGRect)_currentTapRect;	// 0x1102d
- (void)_updateMultiTapFrame;	// 0x10f59
- (void)_updateTapState;	// 0x10dfd
- (void)_handleTap;	// 0x10bf5
- (void)_enterTrackingMode:(id)mode;	// 0x8ae1
- (void)_handleGutterUp;	// 0x8b55
- (void)_processUpAndPost:(BOOL)post;	// 0x8b69
- (void)_updateStartWithPoint:(CGPoint)point time:(double)time;	// 0x10afd
- (BOOL)_handleSplitTap;	// 0x10a51
- (BOOL)_handleSplitEvent:(id)event;	// 0x103e5
- (void)handleGestureEvent:(id)event;	// 0xfea9
- (void)_down:(id)down;	// 0xf905
- (void)_drag:(id)drag;	// 0xa2b5
- (void)_up;	// 0x8c19
- (void)reset;	// 0x98d9
// converted property getter: - (float)directionalSlope;	// 0x874d
- (int)gestureState;	// 0x875d
// converted property getter: - (int)direction;	// 0x9939
- (float)vector;	// 0xa20d
- (float)velocity;	// 0x9985
// converted property getter: - (float)distance;	// 0x99cd
// converted property getter: - (unsigned)absoluteFingerCount;	// 0x8789
- (unsigned)fingerCount;	// 0x8799
// converted property getter: - (unsigned)tapCount;	// 0x87a9
- (BOOL)tapIsDown;	// 0x87b9
- (CGPoint)rawLocation;	// 0xa1a5
- (CGPoint)startLocation;	// 0x9fc5
- (CGPoint)endLocation;	// 0x9de5
// converted property getter: - (CGRect)tapFrame;	// 0x87c9
- (CGRect)multiTapFrame;	// 0x8829
- (CGPoint)tapPoint;	// 0x9da5
- (CGPoint)tapPointWeightedToSides;	// 0x8889
- (double)tapInterval;	// 0x88f1
- (id)gestureStateString;	// 0x9a15
// declared property getter: - (BOOL)thumbRejectionEnabled;	// 0x8911
// declared property setter: - (void)setThumbRejectionEnabled:(BOOL)enabled;	// 0x8921
@end
