/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/DataAccess.framework/Frameworks/DAEAS.framework/DAEAS
 */

#import <DAEAS/ASItem.h>

@class NSArray, NSNumber;

@interface ASItemOperationsResponse : ASItem {
	NSNumber *_status;	// 40 = 0x28
	NSArray *_fetchResponses;	// 44 = 0x2c
}
@property(retain) NSNumber *status;	// G=0x18209; S=0x181c5; converted property
@property(retain) NSArray *fetchResponses;	// G=0x17dd1; S=0x17de1; converted property
+ (BOOL)notifyOfUnknownTokens;	// 0x17d7d
+ (BOOL)frontingBasicTypes;	// 0x17d29
+ (BOOL)parsingWithSubItems;	// 0x17cd5
+ (BOOL)parsingLeafNode;	// 0x17c81
+ (BOOL)acceptsTopLevelLeaves;	// 0x17c2d
- (void)dealloc;	// 0x18241
// converted property getter: - (id)status;	// 0x18209
// converted property setter: - (void)setStatus:(id)status;	// 0x181c5
- (id)description;	// 0x18159
- (void)parseASParseContext:(id)context root:(id)root parent:(id)parent callbackDict:(id)dict streamCallbackDict:(id)dict5 account:(id)account;	// 0x18045
- (id)asParseRules;	// 0x17e25
// converted property setter: - (void)setFetchResponses:(id)responses;	// 0x17de1
// converted property getter: - (id)fetchResponses;	// 0x17dd1
@end
