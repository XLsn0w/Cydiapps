/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/CalDAV.framework/CalDAV
 */

#import <CalDAV/XXUnknownSuperclass.h>

@class CoreDAVItemWithNoChildren;

@interface CalDAVCalendarServerAccessItem : XXUnknownSuperclass {
	CoreDAVItemWithNoChildren *_accessLevel;	// 24 = 0x18
}
@property(retain) CoreDAVItemWithNoChildren *accessLevel;	// G=0x10141; S=0x1011d; @synthesize=_accessLevel
- (id)init;	// 0xfcf1
- (id)initWithNameSpace:(id)nameSpace andName:(id)name;	// 0x100d1
- (id)initWithAccess:(int)access;	// 0xfd2d
- (void)dealloc;	// 0x10185
- (id)description;	// 0x10159
- (id)copyParseRules;	// 0xfe4d
// declared property getter: - (id)accessLevel;	// 0x10141
// declared property setter: - (void)setAccessLevel:(id)level;	// 0x1011d
@end
