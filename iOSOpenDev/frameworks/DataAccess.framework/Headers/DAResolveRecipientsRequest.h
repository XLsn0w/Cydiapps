/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/DataAccess.framework/DataAccess
 */

#import <DataAccess/XXUnknownSuperclass.h>

@class NSArray;

@interface DAResolveRecipientsRequest : XXUnknownSuperclass {
	NSArray *_emailAddresses;	// 4 = 0x4
}
@property(readonly, retain) NSArray *emailAddresses;	// G=0xe489; converted property
// converted property getter: - (id)emailAddresses;	// 0xe489
- (void)dealloc;	// 0xe43d
- (id)description;	// 0xe3d5
- (BOOL)isEqual:(id)equal;	// 0xe365
- (unsigned)hash;	// 0xe2b9
- (id)initWithEmailAddresses:(id)emailAddresses;	// 0xe265
@end