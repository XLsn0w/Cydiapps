/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/CalDAV.framework/CalDAV
 */

#import <CalDAV/XXUnknownSuperclass.h>

@class CoreDAVItemWithNoChildren, CalDAVCalendarServerUpdateItem, CalDAVCalendarServerCancelItem, CalDAVCalendarServerReplyItem;

@interface CalDAVCalendarServerActionItem : XXUnknownSuperclass {
	CoreDAVItemWithNoChildren *_create;	// 24 = 0x18
	CalDAVCalendarServerUpdateItem *_update;	// 28 = 0x1c
	CalDAVCalendarServerCancelItem *_cancel;	// 32 = 0x20
	CalDAVCalendarServerReplyItem *_reply;	// 36 = 0x24
}
@property(retain) CoreDAVItemWithNoChildren *create;	// G=0xc695; S=0xc671; @synthesize=_create
@property(retain) CalDAVCalendarServerUpdateItem *update;	// G=0xc6d1; S=0xc6ad; @synthesize=_update
@property(retain) CalDAVCalendarServerReplyItem *reply;	// G=0xc70d; S=0xc6e9; @synthesize=_reply
@property(retain) CalDAVCalendarServerCancelItem *cancel;	// G=0xc749; S=0xc725; @synthesize=_cancel
- (id)init;	// 0xc28d
- (id)initWithNameSpace:(id)nameSpace andName:(id)name;	// 0xc5e9
- (void)dealloc;	// 0xc78d
- (id)description;	// 0xc761
- (id)copyParseRules;	// 0xc2c9
// declared property getter: - (id)cancel;	// 0xc749
// declared property setter: - (void)setCancel:(id)cancel;	// 0xc725
// declared property getter: - (id)reply;	// 0xc70d
// declared property setter: - (void)setReply:(id)reply;	// 0xc6e9
// declared property getter: - (id)update;	// 0xc6d1
// declared property setter: - (void)setUpdate:(id)update;	// 0xc6ad
// declared property getter: - (id)create;	// 0xc695
// declared property setter: - (void)setCreate:(id)create;	// 0xc671
@end
