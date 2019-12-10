/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/PhotoLibrary.framework/PhotoLibrary
 */

#import <PhotoLibrary/XXUnknownSuperclass.h>
#import <PhotoLibrary/PLDataArrayInputStreamProgressDelegate.h>

@class NSMutableArray, PLVideoRemaker, NSString, NSData, UIViewController;
@protocol PLPublishingAgentDelegate;

@interface PLPublishingAgent : XXUnknownSuperclass <PLDataArrayInputStreamProgressDelegate> {
	id _userInfo;	// 4 = 0x4
	id _delegate;	// 8 = 0x8
	NSString *_mediaPath;	// 12 = 0xc
	NSData *_mediaData;	// 16 = 0x10
	NSString *_mimeType;	// 20 = 0x14
	BOOL _deleteAfterPublishing;	// 24 = 0x18
	double _changeRate;	// 28 = 0x1c
	long long _currentValue;	// 36 = 0x24
	double _estimatedTimeRemaining;	// 44 = 0x2c
	long long _maxValue;	// 52 = 0x34
	long long _normalizedCurrentValue;	// 60 = 0x3c
	long long _normalizedMaxValue;	// 68 = 0x44
	float _percentComplete;	// 76 = 0x4c
	float _remakingPercentComplete;	// 80 = 0x50
	float _progressMultiplier;	// 84 = 0x54
	NSMutableArray *_snapshotTimes;	// 88 = 0x58
	NSMutableArray *_snapshotValues;	// 92 = 0x5c
	UIViewController *_parentNavigationController;	// 96 = 0x60
	BOOL _ownerIsCamera;	// 100 = 0x64
	BOOL _needsRemaking;	// 101 = 0x65
	double _startTime;	// 104 = 0x68
	double _endTime;	// 112 = 0x70
	long long _approximateHDUploadSize;	// 120 = 0x78
	long long _approximateSDUploadSize;	// 128 = 0x80
	BOOL _mediaIsHDVideo;	// 136 = 0x88
	BOOL _enableHDUpload;	// 137 = 0x89
	BOOL _needsTrimming;	// 138 = 0x8a
	BOOL _allowsHDOver3GUpload;	// 139 = 0x8b
	int _selectedOption;	// 140 = 0x8c
	PLVideoRemaker *_remaker;	// 144 = 0x90
	int _remakerMode;	// 148 = 0x94
	SEL _completionSelector;	// 152 = 0x98
	unsigned _remakingWasCancelled : 1;	// 156 = 0x9c
	unsigned _remaking : 1;	// 156 = 0x9c
	unsigned _publishing : 1;	// 156 = 0x9c
	BOOL _shouldCancelPublish;	// 157 = 0x9d
}
@property(assign, nonatomic) BOOL shouldCancelPublish;	// G=0x686ad; S=0x686bd; @synthesize=_shouldCancelPublish
@property(assign, nonatomic) BOOL allowsHDOver3GUpload;	// G=0x6868d; S=0x6869d; @synthesize=_allowsHDOver3GUpload
@property(assign, nonatomic) float progressMultiplier;	// G=0x6866d; S=0x6867d; @synthesize=_progressMultiplier
@property(assign, nonatomic) int selectedOption;	// G=0x6864d; S=0x6865d; @synthesize=_selectedOption
@property(assign, nonatomic) int remakerMode;	// G=0x6863d; S=0x67599; @synthesize=_remakerMode
@property(assign, nonatomic) BOOL needsTrimming;	// G=0x6861d; S=0x6862d; @synthesize=_needsTrimming
@property(assign, nonatomic) BOOL enableHDUpload;	// G=0x685fd; S=0x6860d; @synthesize=_enableHDUpload
@property(assign, nonatomic) BOOL mediaIsHDVideo;	// G=0x685dd; S=0x685ed; @synthesize=_mediaIsHDVideo
@property(assign, nonatomic) long long approximateSDUploadSize;	// G=0x685b1; S=0x685c9; @synthesize=_approximateSDUploadSize
@property(assign, nonatomic) long long approximateHDUploadSize;	// G=0x68585; S=0x6859d; @synthesize=_approximateHDUploadSize
@property(assign, nonatomic) BOOL ownerIsCamera;	// G=0x68565; S=0x68575; @synthesize=_ownerIsCamera
@property(assign, nonatomic) id<PLPublishingAgentDelegate> delegate;	// G=0x68545; S=0x68555; @synthesize=_delegate
@property(assign, getter=isPublishing) BOOL publishing;	// G=0x6755d; S=0x67571; converted property
@property(retain) id userInfo;	// G=0x67509; S=0x67519; converted property
@property(retain) NSData *mediaData;	// G=0x674b5; S=0x674c5; converted property
@property(assign) BOOL deleteMediaFileAfterPublishing;	// G=0x674a5; S=0x67495; converted property
@property(retain) NSString *mediaPath;	// G=0x67441; S=0x67451; converted property
@property(readonly, assign) double estimatedTimeRemaining;	// G=0x67ed9; converted property
@property(readonly, assign) float percentComplete;	// G=0x67ef1; converted property
@property(readonly, assign) float remakingPercentComplete;	// G=0x67f35; converted property
@property(readonly, retain) UIViewController *parentNavigationController;	// G=0x679fd; converted property
+ (id)publishingAgentForBundleNamed:(id)bundleNamed toPublishMedia:(id)publishMedia;	// 0x67215
// declared property setter: - (void)setShouldCancelPublish:(BOOL)cancelPublish;	// 0x686bd
// declared property getter: - (BOOL)shouldCancelPublish;	// 0x686ad
// declared property setter: - (void)setAllowsHDOver3GUpload:(BOOL)upload;	// 0x6869d
// declared property getter: - (BOOL)allowsHDOver3GUpload;	// 0x6868d
// declared property setter: - (void)setProgressMultiplier:(float)multiplier;	// 0x6867d
// declared property getter: - (float)progressMultiplier;	// 0x6866d
// declared property setter: - (void)setSelectedOption:(int)option;	// 0x6865d
// declared property getter: - (int)selectedOption;	// 0x6864d
// declared property getter: - (int)remakerMode;	// 0x6863d
// declared property setter: - (void)setNeedsTrimming:(BOOL)trimming;	// 0x6862d
// declared property getter: - (BOOL)needsTrimming;	// 0x6861d
// declared property setter: - (void)setEnableHDUpload:(BOOL)upload;	// 0x6860d
// declared property getter: - (BOOL)enableHDUpload;	// 0x685fd
// declared property setter: - (void)setMediaIsHDVideo:(BOOL)video;	// 0x685ed
// declared property getter: - (BOOL)mediaIsHDVideo;	// 0x685dd
// declared property setter: - (void)setApproximateSDUploadSize:(long long)size;	// 0x685c9
// declared property getter: - (long long)approximateSDUploadSize;	// 0x685b1
// declared property setter: - (void)setApproximateHDUploadSize:(long long)size;	// 0x6859d
// declared property getter: - (long long)approximateHDUploadSize;	// 0x68585
// declared property setter: - (void)setOwnerIsCamera:(BOOL)camera;	// 0x68575
// declared property getter: - (BOOL)ownerIsCamera;	// 0x68565
// declared property setter: - (void)setDelegate:(id)delegate;	// 0x68555
// declared property getter: - (id)delegate;	// 0x68545
- (int)_remakerModeForSelectedOption;	// 0x684e5
- (id)progressViewMessageDuringRemake;	// 0x684c5
- (void)videoRemaker:(id)remaker progressDidChange:(float)progress;	// 0x684b5
- (void)videoRemakerDidEndRemaking:(id)videoRemaker temporaryPath:(id)path;	// 0x683ad
- (void)_remakerDidFinish:(id)_remaker;	// 0x68275
- (void)videoRemakerDidBeginRemaking:(id)videoRemaker;	// 0x681a5
- (void)_transcodeVideo:(id)video;	// 0x68021
- (void)_cancelRemaking:(id)remaking;	// 0x67f8d
- (BOOL)isRemaking;	// 0x67f79
- (void)cancelRemaking;	// 0x67f65
// converted property getter: - (float)remakingPercentComplete;	// 0x67f35
// converted property getter: - (float)percentComplete;	// 0x67ef1
// converted property getter: - (double)estimatedTimeRemaining;	// 0x67ed9
- (void)_updateStatisticsFromSnapshots;	// 0x67d09
- (void)snapshot;	// 0x67b2d
- (void)setTotalBytesWritten:(int)written totalBytes:(int)bytes;	// 0x67b01
- (void)dataArrayInputStreamBytesWereRead:(id)read;	// 0x67aad
- (double)maximumVideoDuration;	// 0x67a99
- (id)tellAFriendBody;	// 0x67a95
- (id)tellAFriendSubject;	// 0x67a59
- (id)tellAFriendURL;	// 0x67a4d
- (BOOL)isVideoMedia;	// 0x67a25
- (id)mediaTitle;	// 0x67a19
- (id)mediaURL;	// 0x67a0d
// converted property getter: - (id)parentNavigationController;	// 0x679fd
- (void)dismiss;	// 0x679c1
- (void)presentModalSheetInViewController:(id)viewController;	// 0x678e1
- (id)serviceName;	// 0x678d5
- (void)publish;	// 0x678b5
- (void)_agentIsReadyToPublish:(id)publish;	// 0x67871
- (void)doneButtonClicked;	// 0x67779
- (void)cancelButtonClicked;	// 0x6772d
- (id)navigationController;	// 0x67729
- (void)resignPublishingSheetResponders;	// 0x67725
- (void)_setApproximateVideoUploadSizes;	// 0x675f9
- (void)setTrimStartTime:(double)time andEndTime:(double)time2;	// 0x675cd
// declared property setter: - (void)setRemakerMode:(int)mode;	// 0x67599
// converted property setter: - (void)setPublishing:(BOOL)publishing;	// 0x67571
// converted property getter: - (BOOL)isPublishing;	// 0x6755d
// converted property setter: - (void)setUserInfo:(id)info;	// 0x67519
// converted property getter: - (id)userInfo;	// 0x67509
// converted property setter: - (void)setMediaData:(id)data;	// 0x674c5
// converted property getter: - (id)mediaData;	// 0x674b5
// converted property getter: - (BOOL)deleteMediaFileAfterPublishing;	// 0x674a5
// converted property setter: - (void)setDeleteMediaFileAfterPublishing:(BOOL)publishing;	// 0x67495
// converted property setter: - (void)setMediaPath:(id)path;	// 0x67451
// converted property getter: - (id)mediaPath;	// 0x67441
- (void)_setUpPublishingParams;	// 0x67311
- (void)dealloc;	// 0x6715d
- (id)initWithMedia:(id)media;	// 0x67081
- (void)_stopNetworkObservation;	// 0x66fe9
- (void)_startNetworkObservation;	// 0x66f45
- (void)_networkReachabilityDidChange:(id)_networkReachability;	// 0x66e89
@end
