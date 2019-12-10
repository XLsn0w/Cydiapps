/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/DataAccess.framework/DataAccess
 */

#import <DataAccess/NSCoding.h>
#import <DataAccess/XXUnknownSuperclass.h>


@interface DAMailMessage : XXUnknownSuperclass <NSCoding> {
}
- (void)encodeWithCoder:(id)coder;	// 0xec6d
- (id)initWithCoder:(id)coder;	// 0xec2d
- (id)rfc822Data;	// 0xea55
- (int)smimeType;	// 0xe8d5
- (BOOL)verbIsSet;	// 0xe8d1
- (BOOL)flaggedIsSet;	// 0xe8cd
- (BOOL)readIsSet;	// 0xe8c9
- (int)lastVerb;	// 0xe8c5
- (id)folderID;	// 0xe8c1
- (id)longID;	// 0xe8bd
- (id)remoteID;	// 0xe8b9
- (id)conversationIndex;	// 0xe8b5
- (id)conversationId;	// 0xe8b1
- (id)threadTopic;	// 0xe8ad
- (id)meetingRequestMetaData;	// 0xe8a9
- (id)meetingRequestUUID;	// 0xe8a5
- (id)attachments;	// 0xe8a1
- (id)messageClass;	// 0xe89d
- (int)bodyTruncated;	// 0xe899
- (int)bodySize;	// 0xe895
- (id)body;	// 0xe891
- (BOOL)flagged;	// 0xe88d
- (BOOL)read;	// 0xe889
- (int)importance;	// 0xe885
- (id)displayTo;	// 0xe881
- (id)subject;	// 0xe87d
- (id)date;	// 0xe879
- (id)replyTo;	// 0xe875
- (id)from;	// 0xe871
- (id)cc;	// 0xe86d
- (id)to;	// 0xe869
@end
