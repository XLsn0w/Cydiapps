/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/DataAccess.framework/Frameworks/DADaemonSupport.framework/DADaemonSupport
 */

#import <DADaemonSupport/XXUnknownSuperclass.h>
#import <DADaemonSupport/DASearchQueryConsumer.h>

@class DADClient, NSString, DASearchQuery, NSData;

@interface DADClientContactsSearchDelegate : XXUnknownSuperclass <DASearchQueryConsumer> {
	DADClient *_client;	// 8 = 0x8
	NSString *_accountID;	// 12 = 0xc
	DASearchQuery *_query;	// 16 = 0x10
	NSData *_queryResultData;	// 20 = 0x14
	BOOL _finished;	// 24 = 0x18
	BOOL _consumerCancelled;	// 25 = 0x19
	unsigned _delegateId;	// 28 = 0x1c
}
@property(readonly, assign) unsigned delegateId;	// G=0x106e9; @synthesize=_delegateId
// declared property getter: - (unsigned)delegateId;	// 0x106e9
- (void)userRequestsCancel;	// 0x106c5
- (void)finishWithStatus:(int)status;	// 0x1048d
- (void)disable;	// 0x10411
- (void)searchQuery:(id)query finishedWithError:(id)error;	// 0x103dd
- (void)searchQuery:(id)query returnedResults:(id)results;	// 0x10399
- (void)beginQuery;	// 0x102e5
- (void)dealloc;	// 0x1024d
- (id)initWithAccountID:(id)accountID queryDictionary:(id)dictionary client:(id)client;	// 0x1016d
@end
