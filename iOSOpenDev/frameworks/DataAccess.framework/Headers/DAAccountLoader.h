/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/DataAccess.framework/DataAccess
 */

#import <DataAccess/ASDynamicAccountClassLoader.h>
#import <DataAccess/XXUnknownSuperclass.h>

@class NSMutableDictionary;

@interface DAAccountLoader : XXUnknownSuperclass <ASDynamicAccountClassLoader> {
	NSMutableDictionary *_accountTypeToAccountFrameworkSubpath;	// 4 = 0x4
	NSMutableDictionary *_accountTypeToAccountDaemonBundleSubpath;	// 8 = 0x8
	NSMutableDictionary *_accountTypeToClassNames;	// 12 = 0xc
}
+ (BOOL)loadBundleForAccountWithProperties:(id)properties;	// 0x78a1
+ (id)sharedInstance;	// 0x6b0d
- (BOOL)loadBundleForAccountWithProperties:(id)properties;	// 0x7859
- (Class)daemonAppropriateAccountClassForAccountType:(id)accountType;	// 0x7825
- (Class)agentClassForAccountType:(id)accountType;	// 0x7745
- (Class)daemonAccountClassForAccountType:(id)accountType;	// 0x7625
- (Class)clientAccountClassForAccountType:(id)accountType;	// 0x7525
- (Class)accountClassForAccountType:(id)accountType;	// 0x7445
- (void)loadDaemonBundleForAccountType:(id)accountType;	// 0x7409
- (void)loadFrameworkForAccountType:(id)accountType;	// 0x7349
- (BOOL)_loadFrameworkAtSubpath:(id)subpath;	// 0x72e1
- (id)init;	// 0x6e0d
- (void)_addAccountInfo:(id)info forFrameworkNamed:(id)frameworkNamed;	// 0x6c0d
@end
