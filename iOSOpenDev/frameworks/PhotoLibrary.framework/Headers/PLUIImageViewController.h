/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/PhotoLibrary.framework/PhotoLibrary
 */

#import <PhotoLibrary/PhotoLibrary-Structs.h>
#import <PhotoLibrary/PLPhotoTileViewControllerDelegate.h>
#import <PhotoLibrary/PLVideoViewDelegate.h>
#import <PhotoLibrary/XXUnknownSuperclass.h>
#import <PhotoLibrary/PLImageLoadingQueueDelegate.h>

@class PLCropOverlay, NSString, PLVideoRemaker, PLManagedAsset, UIImage, PLVideoView, PLPhotoTileViewController, PLImageCache, PLImageLoadingQueue, PLImageSource;

@interface PLUIImageViewController : XXUnknownSuperclass <PLVideoViewDelegate, PLImageLoadingQueueDelegate, PLPhotoTileViewControllerDelegate> {
	PLManagedAsset *_photo;	// 152 = 0x98
	CGImageRef _imageRef;	// 156 = 0x9c
	UIImage *_image;	// 160 = 0xa0
	CGRect _cropRect;	// 164 = 0xa4
	PLCropOverlay *_cropOverlay;	// 180 = 0xb4
	PLPhotoTileViewController *_imageTile;	// 184 = 0xb8
	PLVideoView *_videoView;	// 188 = 0xbc
	PLVideoRemaker *_remaker;	// 192 = 0xc0
	NSString *_videoPath;	// 196 = 0xc4
	PLImageCache *_imageCache;	// 200 = 0xc8
	PLImageLoadingQueue *_imageLoadingQueue;	// 204 = 0xcc
	PLImageSource *_imageSource;	// 208 = 0xd0
	int _previousStatusBarStyle;	// 212 = 0xd4
	int _newStatusBarStyle;	// 216 = 0xd8
	unsigned _allowEditing : 1;	// 220 = 0xdc
	unsigned _statusBarWasHidden : 1;	// 220 = 0xdc
	unsigned _isVideo : 1;	// 220 = 0xdc
	unsigned _isDisappearing : 1;	// 220 = 0xdc
	unsigned _remaking : 1;	// 220 = 0xdc
}
- (void)imageLoadingQueue:(id)queue didLoadImage:(id)image forAsset:(id)asset fromSource:(id)source;	// 0x52a85
- (BOOL)photoTileViewControllerAllowsEditing:(id)editing;	// 0x52a71
- (void)photoTileViewControllerDidEndGesture:(id)photoTileViewController;	// 0x52a6d
- (void)photoTileViewControllerWillBeginGesture:(id)photoTileViewController;	// 0x52a69
- (void)photoTileViewControllerSingleTap:(id)tap;	// 0x52a65
- (void)photoTileViewControllerRequestsFullSizeImage:(id)image;	// 0x52a61
- (void)photoTileViewControllerCancelImageRequests:(id)requests;	// 0x52a15
- (void)photoTileViewControllerRequestsFullScreenImage:(id)image;	// 0x528a5
- (int)imageFormat;	// 0x52889
- (void)photoTileViewController:(id)controller didDisappear:(BOOL)disappear;	// 0x52885
- (void)photoTileViewController:(id)controller didAppear:(BOOL)appear;	// 0x52881
- (void)photoTileViewController:(id)controller willAppear:(BOOL)appear;	// 0x5287d
- (BOOL)photoTileViewControllerIsDisplayingLandscape:(id)landscape;	// 0x52829
- (void)videoRemakerDidEndRemaking:(id)videoRemaker temporaryPath:(id)path;	// 0x52775
- (void)videoRemakerDidBeginRemaking:(id)videoRemaker;	// 0x52725
- (void)videoViewDidEndPlayback:(id)videoView didFinish:(BOOL)finish;	// 0x52705
- (void)videoViewDidPausePlayback:(id)videoView didFinish:(BOOL)finish;	// 0x526e5
- (void)videoViewDidBeginPlayback:(id)videoView;	// 0x526c5
- (void)videoViewIsReadyToBeginPlayback:(id)beginPlayback;	// 0x524bd
- (id)_trimMessage;	// 0x524ad
- (BOOL)videoViewCanBeginPlayback:(id)playback;	// 0x524a9
- (float)videoViewScrubberYOrigin:(id)origin forOrientation:(int)orientation;	// 0x52349
- (BOOL)videoViewCanCreateMetadata:(id)metadata;	// 0x5233d
- (void)cropOverlayPause:(id)pause;	// 0x5231d
- (void)cropOverlayPlay:(id)play;	// 0x522fd
- (void)cropOverlay:(id)overlay didFinishSaving:(id)saving;	// 0x52291
- (void)cropOverlayWasOKed:(id)ked;	// 0x51bd9
- (void)_enableCropOverlayIfNecessary;	// 0x51b7d
- (void)didChooseVideoAtPath:(id)path options:(id)options;	// 0x51b79
- (void)cropOverlayWasCancelled:(id)cancelled;	// 0x51b0d
- (void)_updateGestureSettings;	// 0x51a81
- (void)_editabilityChanged:(id)changed;	// 0x51a11
- (void)setAllowsEditing:(BOOL)editing;	// 0x519ad
- (void)_removedAsTopViewController;	// 0x5198d
- (void)viewDidDisappear:(BOOL)view;	// 0x51945
- (void)viewWillDisappear:(BOOL)view;	// 0x51835
- (int)_imagePickerStatusBarStyle;	// 0x51825
- (void)viewDidAppear:(BOOL)view;	// 0x517dd
- (void)viewWillAppear:(BOOL)view;	// 0x5165d
- (void)loadView;	// 0x50d01
- (Class)_viewClass;	// 0x50ce5
- (void)setupNavigationItem;	// 0x50b39
- (BOOL)clientIsWallpaper;	// 0x50b35
- (id)useButtonTitle;	// 0x50b1d
- (unsigned)_tileAutoresizingMask;	// 0x50b19
- (unsigned)_contentAutoresizingMask;	// 0x50b15
- (CGRect)_viewFrame;	// 0x50a79
- (CGRect)previewFrame;	// 0x50a59
- (int)cropOverlayMode;	// 0x509ed
- (void)dealloc;	// 0x50869
- (id)initWithVideoPath:(id)videoPath;	// 0x50801
- (id)initWithImageData:(id)imageData cropRect:(CGRect)rect;	// 0x50715
- (id)initWithUIImage:(id)uiimage cropRect:(CGRect)rect;	// 0x5068d
- (id)initWithImage:(CGImageRef)image cropRect:(CGRect)rect;	// 0x50611
- (id)initWithPhoto:(id)photo;	// 0x50595
- (BOOL)_displaysFullScreen;	// 0x50559
@end
