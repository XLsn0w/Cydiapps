/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iTunesStoreUI.framework/iTunesStoreUI
 */

#import <iTunesStoreUI/XXUnknownSuperclass.h>


@interface SUCheckLocationsEnabledOperation : XXUnknownSuperclass {
	BOOL _locationsEnabled;	// 60 = 0x3c
	int _updateDistance;	// 64 = 0x40
}
@property(assign) int updateDistance;	// G=0x3e40d; S=0x3e41d; @synthesize=_updateDistance
@property(assign) BOOL locationsEnabled;	// G=0x3e3ed; S=0x3e3fd; @synthesize=_locationsEnabled
// declared property setter: - (void)setUpdateDistance:(int)distance;	// 0x3e41d
// declared property getter: - (int)updateDistance;	// 0x3e40d
// declared property setter: - (void)setLocationsEnabled:(BOOL)enabled;	// 0x3e3fd
// declared property getter: - (BOOL)locationsEnabled;	// 0x3e3ed
- (void)run;	// 0x3e071
@end
