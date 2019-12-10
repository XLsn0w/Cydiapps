/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/DataAccessExpress.framework/DataAccessExpress
 */


#import <DataAccessExpress/AccountRefreshProtocol.h>

@class NSString;

@interface DADConnectionForRefreshProtocol : NSObject <AccountRefreshProtocol> {
	NSString *_accountIdentifier;	// 4 = 0x4
}
+ (id)accountToRefreshForBasicAccount:(id)basicAccount;	// 0x6d49
- (id)defaultContainerIdentifierForDataclass:(id)dataclass;	// 0x6ebd
- (BOOL)refreshContainerListForDataclass:(id)dataclass isUserRequested:(BOOL)requested;	// 0x6e69
- (BOOL)refreshContainersForDataclass:(id)dataclass isUserRequested:(BOOL)requested;	// 0x6e15
- (BOOL)refreshContainerWithIdentifier:(id)identifier forDataclass:(id)dataclass isUserRequested:(BOOL)requested;	// 0x6d91
- (void)dealloc;	// 0x6cfd
- (id)_initWithBasicAccount:(id)basicAccount;	// 0x6c99
@end
