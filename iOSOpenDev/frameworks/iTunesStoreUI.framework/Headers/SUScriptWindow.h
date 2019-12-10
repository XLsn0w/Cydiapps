/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iTunesStoreUI.framework/iTunesStoreUI
 */

#import <iTunesStoreUI/iTunesStoreUI-Structs.h>
#import <iTunesStoreUI/SUScriptObject.h>

@class NSString, SUScriptViewController, SUScriptFunction, WebScriptObject, SUScriptWindowContext, NSNumber, SUScriptCanvasFunction;

@interface SUScriptWindow : SUScriptObject {
	SUScriptViewController *_backViewController;	// 36 = 0x24
	SUScriptWindowContext *_context;	// 40 = 0x28
	SUScriptViewController *_frontViewController;	// 44 = 0x2c
	id _height;	// 48 = 0x30
	SUScriptCanvasFunction *_maskFunction;	// 52 = 0x34
	id _shadowOpacity;	// 56 = 0x38
	id _shadowRadius;	// 60 = 0x3c
	SUScriptFunction *_shouldDismissFunction;	// 64 = 0x40
	id _width;	// 68 = 0x44
}
@property(readonly, assign) SUScriptViewController *windowParentViewController;	// G=0x578c1; 
@property(retain) NSNumber *width;	// G=0x57851; S=0x576dd; 
@property(readonly, assign) NSString *style;	// G=0x57845; 
@property(retain) WebScriptObject *shouldDismissFunction;	// G=0x577f1; S=0x5762d; 
@property(retain) NSNumber *shadowRadius;	// G=0x577a9; S=0x57571; 
@property(retain) NSNumber *shadowOpacity;	// G=0x57761; S=0x574a5; 
@property(retain) WebScriptObject *maskFunction;	// G=0x57139; S=0x57299; 
@property(retain) NSNumber *height;	// G=0x570c9; S=0x57215; 
@property(retain) SUScriptViewController *frontViewController;	// G=0x57059; S=0x57419; 
@property(retain) SUScriptViewController *backViewController;	// G=0x56fdd; S=0x57189; 
@property(readonly, assign) SUScriptWindowContext *context;	// G=0x56e81; @synthesize=_context
+ (void)initialize;	// 0x58e5d
+ (id)webScriptNameForSelector:(SEL)selector;	// 0x58da1
+ (id)webScriptNameForKey:(const char *)key;	// 0x58cfd
+ (void)_dismissWindowsAnimated:(BOOL)animated;	// 0x57aa5
+ (void)dismissWindowsWithOptions:(id)options;	// 0x56df5
- (id)scriptAttributeKeys;	// 0x58dfd
- (id)attributeKeys;	// 0x58ded
- (void)_registerForOverlayNotifications;	// 0x58c3d
- (id)_overlayViewController:(BOOL)controller;	// 0x58bf9
- (id)_newOverlayTransitionWithOptions:(id)options;	// 0x589f9
- (id)_copySafeTransitionOptionsFromOptions:(id)options;	// 0x589a5
- (id)_backgroundViewController:(BOOL)controller;	// 0x58915
- (void)_show:(id)show;	// 0x584dd
- (void)_setWidth:(float)width;	// 0x58419
- (void)_setShouldDismissFunction:(id)_set;	// 0x58379
- (void)_setShadowRadius:(float)radius;	// 0x582f9
- (void)_setShadowOpacity:(float)opacity;	// 0x58279
- (void)_setMaskFunction:(id)function;	// 0x58201
- (void)_setHeight:(float)height;	// 0x5813d
- (void)_setFrontViewController:(id)controller;	// 0x580b5
- (void)_setBackViewController:(id)controller;	// 0x5802d
- (void)_reloadVisibility;	// 0x57ff1
- (CGSize)_overlaySize;	// 0x57f35
- (float)_mainThreadShadowRadius;	// 0x57ed1
- (float)_mainThreadShadowOpacity;	// 0x57e6d
- (void)_flip:(id)flip;	// 0x57de9
- (void)_dismiss:(id)dismiss;	// 0x57d01
- (id)_copyWindowParentViewController;	// 0x57c1d
- (id)_copyShouldDismissFunction;	// 0x57ba5
- (id)_copyFrontViewController;	// 0x57b49
- (id)_copyBackViewController;	// 0x57aed
- (void)_overlayDidShowNotification:(id)_overlay;	// 0x57a19
- (void)_overlayDidFlipNotification:(id)_overlay;	// 0x579a1
- (void)_overlayDidDismissNotification:(id)_overlay;	// 0x57915
// declared property getter: - (id)windowParentViewController;	// 0x578c1
// declared property getter: - (id)width;	// 0x57851
// declared property getter: - (id)style;	// 0x57845
// declared property getter: - (id)shouldDismissFunction;	// 0x577f1
// declared property getter: - (id)shadowRadius;	// 0x577a9
// declared property getter: - (id)shadowOpacity;	// 0x57761
// declared property setter: - (void)setWidth:(id)width;	// 0x576dd
// declared property setter: - (void)setShouldDismissFunction:(id)dismissFunction;	// 0x5762d
// declared property setter: - (void)setShadowRadius:(id)radius;	// 0x57571
// declared property setter: - (void)setShadowOpacity:(id)opacity;	// 0x574a5
// declared property setter: - (void)setFrontViewController:(id)controller;	// 0x57419
// declared property setter: - (void)setMaskFunction:(id)function;	// 0x57299
// declared property setter: - (void)setHeight:(id)height;	// 0x57215
// declared property setter: - (void)setBackViewController:(id)controller;	// 0x57189
// declared property getter: - (id)maskFunction;	// 0x57139
// declared property getter: - (id)height;	// 0x570c9
// declared property getter: - (id)frontViewController;	// 0x57059
- (id)_className;	// 0x5704d
// declared property getter: - (id)backViewController;	// 0x56fdd
- (void)show:(id)show;	// 0x56f89
- (void)flip:(id)flip;	// 0x56f35
- (void)dismiss:(id)dismiss;	// 0x56ee1
// declared property getter: - (id)context;	// 0x56e81
- (void)dealloc;	// 0x56c55
- (id)initWithContext:(id)context;	// 0x56bed
- (id)init;	// 0x56b79
@end
