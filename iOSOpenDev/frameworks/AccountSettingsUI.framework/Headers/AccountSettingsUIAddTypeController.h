/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/AccountSettingsUI.framework/AccountSettingsUI
 */

#import <Foundation/NSThread.h>

@class NSArray;

@interface AccountSettingsUIAddTypeController : NSThread {
	NSArray *_plugins;	// 240 = 0xf0
	NSArray *_allowedDataclasses;	// 244 = 0xf4
	BOOL _dontShowSecondLevelOtherAccountTypes;	// 248 = 0xf8
	BOOL _forceMailSetup;	// 249 = 0xf9
	NSArray *_preEnabledDataclasses;	// 252 = 0xfc
	unsigned char originalWifiFlag;	// 256 = 0x100
	unsigned char originalCellFlag;	// 257 = 0x101
}
@property(retain) NSArray *preEnabledDataclasses;	// G=0x2e55; S=0x2e31; @synthesize=_preEnabledDataclasses
@property(retain) NSArray *plugins;	// G=0x2e91; S=0x2e6d; @synthesize=_plugins
@property(retain) NSArray *allowedDataclasses;	// G=0x2ecd; S=0x2ea9; @synthesize=_allowedDataclasses
- (id)init;	// 0x2dcd
- (void)handleURL:(id)url;	// 0x3a3d
- (void)dealloc;	// 0x39b9
- (id)specifiers;	// 0x3185
- (void)finishedAccountSetup;	// 0x313d
- (id)specifierForAccountType:(id)accountType;	// 0x3009
- (int)numAddControllersInStack;	// 0x2755
- (void)popOutOfAddControllers;	// 0x2ee5
- (void)dontShowSecondLevelOtherAccountTypes;	// 0x2759
- (void)forceMailSetup;	// 0x276d
// declared property getter: - (id)allowedDataclasses;	// 0x2ecd
// declared property setter: - (void)setAllowedDataclasses:(id)dataclasses;	// 0x2ea9
// declared property getter: - (id)plugins;	// 0x2e91
// declared property setter: - (void)setPlugins:(id)plugins;	// 0x2e6d
// declared property getter: - (id)preEnabledDataclasses;	// 0x2e55
// declared property setter: - (void)setPreEnabledDataclasses:(id)dataclasses;	// 0x2e31
@end

