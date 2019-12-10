/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/AccountSettingsUI.framework/AccountSettingsUI
 */

#import <AccountSettingsUI/AccountSettingsUIAccount.h>
#import <AccountSettingsUI/XXUnknownSuperclass.h>

// iOSOpenDev: wrapped with define check (since occurs in other dumped files)
#ifndef __XXUnknownSuperclass__
#define __XXUnknownSuperclass__ 1
@interface XXUnknownSuperclass : NSObject
@end
#endif

@interface XXUnknownSuperclass (Internal)
- (BOOL)_setTetheredDataSourceEnabled:(BOOL)enabled forDataclass:(id)dataclass;	// 0xff2d
- (BOOL)_deleteDataSourceForDataclass:(id)dataclass;	// 0xffad
- (void)_saveChangesToOnMyDeviceAccount;	// 0xfc31
@end

@interface XXUnknownSuperclass (AccountSettingsUI) <AccountSettingsUIAccount>
+ (id)displayedShortAccountTypeString;	// 0xfc11
+ (id)displayedAccountTypeString;	// 0xfc21
+ (void *)createSyncDataSourceForDataclass:(id)dataclass options:(id)options;	// 0xfdf5
- (BOOL)supportsPush;	// 0xfbdd
- (id)uniqueId;	// 0xfbe1
- (void)setEnabled:(BOOL)enabled forDataclass:(id)dataclass;	// 0xfce9
- (void)setTetheredEnabled:(BOOL)enabled forDataclass:(id)dataclass;	// 0xfbf1
- (void)deleteLocalDataSourceForDataclass:(id)dataclass;	// 0xfc01
- (BOOL)otherAccountEnabledForDataclass:(id)dataclass;	// 0xfd35
- (void)showLocalStoreIfAppropriateForDataclass:(id)dataclass;	// 0x10681
- (void)hideLocalStoreForDataclass:(id)dataclass;	// 0x106fd
@end

@interface XXUnknownSuperclass (AccountSettingsUI)
- (id)setOfKeysForAlteredValuesComparedTo:(id)to;	// 0x10791
@end
