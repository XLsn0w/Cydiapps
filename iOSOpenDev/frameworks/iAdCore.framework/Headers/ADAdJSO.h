/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iAdCore.framework/iAdCore
 */

#import <iAdCore/ADJavaScriptObject.h>
#import <iAdCore/iAdCore-Structs.h>

@class ADContactsJSO, ADMailComposerJSO, WebScriptObject, NSDictionary, ADSMSComposerJSO, ADStoreJSO, ADWebScriptDictionary, ADAdData, ADTwitterJSO, AdSheetJSSetWallpaperRequest, ADBooksJSO, ADCalendarJSO, ADCameraJSO;
@protocol ADJSODelegate;

@interface ADAdJSO : ADJavaScriptObject {
@private
	id<ADJSODelegate> _delegate;	// 4 = 0x4
	BOOL _privilegedClient;	// 8 = 0x8
	dispatch_queue_s *_dispatchQueue;	// 12 = 0xc
	BOOL _adManagesPurchaseFlow;	// 16 = 0x10
	ADStoreJSO *_store;	// 20 = 0x14
	ADCalendarJSO *_calendar;	// 24 = 0x18
	ADCameraJSO *_camera;	// 28 = 0x1c
	ADBooksJSO *_books;	// 32 = 0x20
	ADSMSComposerJSO *_smsComposer;	// 36 = 0x24
	ADMailComposerJSO *_mailComposer;	// 40 = 0x28
	ADContactsJSO *_contacts;	// 44 = 0x2c
	ADTwitterJSO *_twitterComposer;	// 48 = 0x30
	WebScriptObject *_listener;	// 52 = 0x34
	WebScriptObject *_shakeEventsListener;	// 56 = 0x38
	WebScriptObject *_deviceOrientationListener;	// 60 = 0x3c
	WebScriptObject *_networkTypeListener;	// 64 = 0x40
	WebScriptObject *_writeImageListener;	// 68 = 0x44
	WebScriptObject *_deviceVolumeListener;	// 72 = 0x48
	unsigned _currentSupportedInterfaceOrientations;	// 76 = 0x4c
	ADWebScriptDictionary *_bannerParametersDictionary;	// 80 = 0x50
	AdSheetJSSetWallpaperRequest *_wallpaperRequest;	// 84 = 0x54
	int _currentNetworkType;	// 88 = 0x58
	BOOL _isCoalescingShakeEvents;	// 92 = 0x5c
	NSDictionary *_ringtoneData;	// 96 = 0x60
	ADAdData *_adResponse;	// 100 = 0x64
}
@property(assign, nonatomic) dispatch_queue_s *dispatchQueue;	// G=0x34235; S=0x34245; @synthesize=_dispatchQueue
@property(retain, nonatomic) NSDictionary *ringtoneData;	// G=0x343a1; S=0x343b1; @synthesize=_ringtoneData
@property(assign, nonatomic) BOOL isCoalescingShakeEvents;	// G=0x34381; S=0x34391; @synthesize=_isCoalescingShakeEvents
@property(readonly, assign) int currentNetworkType;	// G=0x34371; @synthesize=_currentNetworkType
@property(retain, nonatomic) AdSheetJSSetWallpaperRequest *wallpaperRequest;	// G=0x3433d; S=0x3434d; @synthesize=_wallpaperRequest
@property(retain, nonatomic) ADWebScriptDictionary *bannerParametersDictionary;	// G=0x34309; S=0x34319; @synthesize=_bannerParametersDictionary
@property(assign, nonatomic) unsigned currentSupportedInterfaceOrientations;	// G=0x342f9; S=0x31661; @synthesize=_currentSupportedInterfaceOrientations
@property(retain, nonatomic) WebScriptObject *deviceVolumeListener;	// G=0x342e9; S=0x31a21; @synthesize=_deviceVolumeListener
@property(retain, nonatomic) WebScriptObject *writeImageListener;	// G=0x342b5; S=0x342c5; @synthesize=_writeImageListener
@property(retain, nonatomic) WebScriptObject *networkTypeListener;	// G=0x342a5; S=0x31b31; @synthesize=_networkTypeListener
@property(retain, nonatomic) WebScriptObject *deviceOrientationListener;	// G=0x34295; S=0x31759; @synthesize=_deviceOrientationListener
@property(retain, nonatomic) WebScriptObject *shakeEventsListener;	// G=0x34285; S=0x31495; @synthesize=_shakeEventsListener
@property(retain, nonatomic) WebScriptObject *listener;	// G=0x34275; S=0x312f1; @synthesize=_listener
@property(readonly, assign, nonatomic) ADTwitterJSO *twitterComposer;	// G=0x30799; @synthesize=_twitterComposer
@property(readonly, assign, nonatomic) ADContactsJSO *contacts;	// G=0x306b1; @synthesize=_contacts
@property(readonly, assign, nonatomic) ADMailComposerJSO *mailComposer;	// G=0x30725; @synthesize=_mailComposer
@property(readonly, assign, nonatomic) ADSMSComposerJSO *smsComposer;	// G=0x3063d; @synthesize=_smsComposer
@property(readonly, assign, nonatomic) ADBooksJSO *books;	// G=0x305c9; @synthesize=_books
@property(readonly, assign, nonatomic) ADCameraJSO *camera;	// G=0x30555; @synthesize=_camera
@property(readonly, assign, nonatomic) ADCalendarJSO *calendar;	// G=0x304c1; @synthesize=_calendar
@property(readonly, assign, nonatomic) ADStoreJSO *store;	// G=0x303e9; @synthesize=_store
@property(retain, nonatomic) ADAdData *adResponse;	// G=0x343d5; S=0x343e5; @synthesize=_adResponse
@property(assign) BOOL adManagesPurchaseFlow;	// G=0x34255; S=0x34265; @synthesize=_adManagesPurchaseFlow
@property(assign, nonatomic, getter=isPrivilegedClient) BOOL privilegedClient;	// G=0x34215; S=0x34225; @synthesize=_privilegedClient
@property(assign, nonatomic) id<ADJSODelegate> delegate;	// G=0x341f5; S=0x34205; @synthesize=_delegate
+ (void)initializeInContext:(OpaqueJSContext *)context;	// 0x30db5
+ (id)scriptSelectors;	// 0x30c35
+ (id)scriptingKeys;	// 0x30af9
// declared property setter: - (void)setAdResponse:(id)response;	// 0x343e5
// declared property getter: - (id)adResponse;	// 0x343d5
// declared property setter: - (void)setRingtoneData:(id)data;	// 0x343b1
// declared property getter: - (id)ringtoneData;	// 0x343a1
// declared property setter: - (void)setIsCoalescingShakeEvents:(BOOL)events;	// 0x34391
// declared property getter: - (BOOL)isCoalescingShakeEvents;	// 0x34381
// declared property getter: - (int)currentNetworkType;	// 0x34371
// declared property setter: - (void)setWallpaperRequest:(id)request;	// 0x3434d
// declared property getter: - (id)wallpaperRequest;	// 0x3433d
// declared property setter: - (void)setBannerParametersDictionary:(id)dictionary;	// 0x34319
// declared property getter: - (id)bannerParametersDictionary;	// 0x34309
// declared property getter: - (unsigned)currentSupportedInterfaceOrientations;	// 0x342f9
// declared property getter: - (id)deviceVolumeListener;	// 0x342e9
// declared property setter: - (void)setWriteImageListener:(id)listener;	// 0x342c5
// declared property getter: - (id)writeImageListener;	// 0x342b5
// declared property getter: - (id)networkTypeListener;	// 0x342a5
// declared property getter: - (id)deviceOrientationListener;	// 0x34295
// declared property getter: - (id)shakeEventsListener;	// 0x34285
// declared property getter: - (id)listener;	// 0x34275
// declared property setter: - (void)setAdManagesPurchaseFlow:(BOOL)flow;	// 0x34265
// declared property getter: - (BOOL)adManagesPurchaseFlow;	// 0x34255
// declared property setter: - (void)setDispatchQueue:(dispatch_queue_s *)queue;	// 0x34245
// declared property getter: - (dispatch_queue_s *)dispatchQueue;	// 0x34235
// declared property setter: - (void)setPrivilegedClient:(BOOL)client;	// 0x34225
// declared property getter: - (BOOL)isPrivilegedClient;	// 0x34215
// declared property setter: - (void)setDelegate:(id)delegate;	// 0x34205
// declared property getter: - (id)delegate;	// 0x341f5
- (id)description;	// 0x341e9
- (void)addRingtone:(id)ringtone;	// 0x33761
- (void)writeDisplayedContentToSavedPhotos:(id)savedPhotos;	// 0x332ed
- (void)image:(id)image didFinishSavingWithError:(id)error contextInfo:(void *)info;	// 0x330ad
- (void)writeImageToSavedPhotosAlbum:(id)savedPhotosAlbum listener:(id)listener;	// 0x32931
- (void)alertView:(id)view clickedButtonAtIndex:(int)index;	// 0x32615
- (void)wallpaperImageViewControllerDidCancel:(id)wallpaperImageViewController;	// 0x324a9
- (void)wallpaperImageViewControllerDidFinishSaving:(id)wallpaperImageViewController;	// 0x323cd
- (void)setImageAsWallpaper:(id)wallpaper withTitle:(id)title listener:(id)listener;	// 0x31cbd
- (void)networkTypeChanged:(id)changed;	// 0x31b75
// declared property setter: - (void)setNetworkTypeListener:(id)listener;	// 0x31b31
- (int)networkType;	// 0x31a65
// declared property setter: - (void)setDeviceVolumeListener:(id)listener;	// 0x31a21
- (void)registerForVolumeChanges:(id)volumeChanges;	// 0x3193d
- (void)volumeChanged:(id)changed;	// 0x31821
- (id)currentDeviceVolume;	// 0x317bd
// declared property setter: - (void)setDeviceOrientationListener:(id)listener;	// 0x31759
// declared property setter: - (void)setCurrentSupportedInterfaceOrientations:(unsigned)orientations;	// 0x31661
- (void)orientationChanged:(id)changed;	// 0x315bd
- (void)forwardShakeEventToAd:(id)ad;	// 0x314d9
// declared property setter: - (void)setShakeEventsListener:(id)listener;	// 0x31495
- (void)clientApplicationDidBecomeActive;	// 0x31491
- (void)clientApplicationDidResignActive;	// 0x3148d
- (void)adDidResume;	// 0x31455
- (void)adWillPause;	// 0x3141d
- (void)adWillDismiss;	// 0x31335
// declared property setter: - (void)setListener:(id)listener;	// 0x312f1
- (void)reportClickEvent:(id)event;	// 0x31235
- (void)dismissAd;	// 0x31199
- (void)contentSignalsReady;	// 0x30d95
- (void)fireTestProbe:(id)probe withOptions:(id)options;	// 0x30d35
- (id)bannerRectOnScreen;	// 0x30a95
- (id)bannerTapLocation;	// 0x30a35
- (id)bannerParameters;	// 0x308e1
- (BOOL)isBusy;	// 0x3080d
// declared property getter: - (id)twitterComposer;	// 0x30799
// declared property getter: - (id)mailComposer;	// 0x30725
// declared property getter: - (id)contacts;	// 0x306b1
// declared property getter: - (id)smsComposer;	// 0x3063d
// declared property getter: - (id)books;	// 0x305c9
// declared property getter: - (id)camera;	// 0x30555
// declared property getter: - (id)calendar;	// 0x304c1
// declared property getter: - (id)store;	// 0x303e9
- (id)init;	// 0x30229
- (void)dealloc;	// 0x2ff51
@end
