/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/Message.framework/Message
 */

#import <Message/MailboxUid.h>

@class DAFolder;

@interface MFDAMailbox : MailboxUid {
	DAFolder *_DAFolder;	// 68 = 0x44
}
@property(retain) DAFolder *DAFolder;	// G=0x61359; S=0x61269; converted property
- (id)initWithName:(id)name attributes:(unsigned)attributes account:(id)account folder:(id)folder;	// 0x61431
- (id)description;	// 0x6139d
// converted property getter: - (id)DAFolder;	// 0x61359
// converted property setter: - (void)setDAFolder:(id)folder;	// 0x61269
- (id)folderID;	// 0x61211
- (id)URLStringWithAccount:(id)account;	// 0x61121
- (void)dealloc;	// 0x610d5
@end
