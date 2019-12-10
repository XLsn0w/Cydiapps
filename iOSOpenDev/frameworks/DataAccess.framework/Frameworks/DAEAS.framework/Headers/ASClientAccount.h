/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/DataAccess.framework/Frameworks/DAEAS.framework/DAEAS
 */

#import <DAEAS/ASAccount.h>

@class NSMutableSet;

@interface ASClientAccount : ASAccount {
	NSMutableSet *_daemonMonitoredFolders;	// 96 = 0x60
	NSMutableSet *_foldersToRetryForMonitoring;	// 100 = 0x64
	NSMutableSet *_folderIDsOnRemoteHold;	// 104 = 0x68
}
- (void)_reportFolderItemSyncSuccess:(BOOL)success forFolderWithID:(id)anId;	// 0x26ed1
- (id)mailboxes;	// 0x26dc9
- (int)performMailboxRequest:(id)request mailbox:(id)mailbox previousTag:(id)tag consumer:(id)consumer;	// 0x26d51
- (int)performMailboxRequests:(id)requests mailbox:(id)mailbox previousTag:(id)tag consumer:(id)consumer;	// 0x2685d
- (id)_copySetFlagsActionForRequest:(id)request;	// 0x267b5
- (void)performFolderChange:(id)change;	// 0x26751
- (int)performResolveRecipientsRequest:(id)request consumer:(id)consumer;	// 0x26681
- (void)resolveRecipientsTask:(id)task completedWithStatus:(int)status error:(id)error queriedEmailAddressToRecpient:(id)recpient;	// 0x26631
- (int)performFetchMessageSearchResultRequests:(id)requests consumer:(id)consumer;	// 0x2631d
- (int)performFetchAttachmentRequest:(id)request consumer:(id)consumer;	// 0x26141
- (int)performMoveRequests:(id)requests consumer:(id)consumer;	// 0x25e41
- (void)sendMailTask:(id)task completedWithStatus:(int)status error:(id)error;	// 0x25dd9
- (void)_sync:(id)sync withConsumer:(id)consumer;	// 0x25d39
- (void)suspendMonitoringFoldersWithIDs:(id)ids;	// 0x25ca9
- (BOOL)setFolderIdsThatExternalClientsCareAboutAdded:(id)added deleted:(id)deleted foldersTag:(id)tag;	// 0x25c25
- (void)upgradeWithProtocolVersion:(id)protocolVersion;	// 0x25b35
- (void)applyNewAccountProperties:(id)properties forceSave:(BOOL)save;	// 0x25a39
- (BOOL)reattemptInvitationLinkageForMetaData:(id)metaData inFolderWithId:(id)anId;	// 0x2597d
- (void)stopMonitoringAllFolders;	// 0x25929
- (void)stopMonitoringFoldersForUpdates:(id)updates;	// 0x258c1
- (void)monitorFoldersForUpdates:(id)updates;	// 0x257ad
- (void)_retryMonitoring;	// 0x256cd
- (void)_removeFoldersFromDaemonMonitoring:(id)daemonMonitoring;	// 0x25625
- (void)_addFoldersToDaemonMonitoring:(id)daemonMonitoring;	// 0x255c1
- (void)_logStatus:(id)status;	// 0x25565
- (void)_daemonDied;	// 0x25471
- (void)_foldersUpdated:(id)updated;	// 0x2526d
- (void)resumeMonitoringFoldersWithIDs:(id)ids;	// 0x25181
- (void)_foldersThatExternalClientsCareAboutChanged;	// 0x250e1
- (void)_folderHierarchyChanged;	// 0x25041
- (void)clearFolderHierarchyCache;	// 0x25019
- (void)dealloc;	// 0x24f59
- (id)initWithProperties:(id)properties;	// 0x24ed9
- (id)_newPolicyManager;	// 0x24ea1
@end
