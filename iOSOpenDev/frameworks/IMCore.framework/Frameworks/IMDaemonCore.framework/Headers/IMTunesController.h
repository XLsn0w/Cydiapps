/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/IMCore.framework/Frameworks/IMDaemonCore.framework/IMDaemonCore
 */

#import <IMDaemonCore/XXUnknownSuperclass.h>

@class NSMutableArray, NSDate, NSMutableDictionary, NSString, NSDictionary;

@interface IMTunesController : XXUnknownSuperclass {
	NSDate *_lastChange;	// 4 = 0x4
	NSDictionary *_lastInfo;	// 8 = 0x8
	NSMutableDictionary *_playerInfo;	// 12 = 0xc
	NSMutableArray *_listeners;	// 16 = 0x10
	NSString *_messageFormat;	// 20 = 0x14
}
@property(readonly, assign, nonatomic) NSString *messageFormat;	// G=0x193d; 
@property(readonly, assign, nonatomic) NSDictionary *playerInfo;	// G=0x15185; @synthesize=_playerInfo
@property(readonly, assign, nonatomic) BOOL isEnabled;	// G=0x14945; 
+ (id)sharedTunesController;	// 0x18ad
// declared property getter: - (id)playerInfo;	// 0x15185
// declared property getter: - (id)messageFormat;	// 0x193d
- (void)removeListener:(id)listener;	// 0x15181
- (void)addListener:(id)listener;	// 0x3011
- (void)_playerChangedNotification:(id)notification;	// 0x14ffd
- (void)_playerChanged:(id)changed;	// 0x14ad5
- (void)_updateMessage;	// 0x14951
// declared property getter: - (BOOL)isEnabled;	// 0x14945
- (void)dealloc;	// 0x148a9
- (id)init;	// 0x1911
- (BOOL)retainWeakReference;	// 0x148a5
- (BOOL)allowsWeakReference;	// 0x148a1
@end
