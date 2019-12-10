/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/CoreMediaStream.framework/CoreMediaStream
 */

#import <CoreMediaStream/MSSharingManager.h>
#import <CoreMediaStream/MSSharingProtocolDelegate.h>

#import <CoreMediaStream/XXUnknownSuperclass.h>

@class NSMutableArray, MSSharingProtocol, NSMutableDictionary, NSString, NSArray, MSMediaStreamDaemon, NSTimer;
@protocol MSSharingManagerDelegate;

@protocol MSSharingManager <NSObject>
@property(retain, nonatomic) NSArray *shares;
@property(readonly, assign) NSString *personID;
@property(assign, nonatomic) id<MSSharingManagerDelegate> delegate;
// declared property setter: - (void)setShares:(id)shares;
// declared property getter: - (id)shares;
// declared property getter: - (id)personID;
// declared property setter: - (void)setDelegate:(id)delegate;
// declared property getter: - (id)delegate;
- (void)removeShare:(id)share;
- (void)modifyShare:(id)share;
- (void)refreshCurrentShareState;
- (void)respondToInvitation:(id)invitation accept:(BOOL)accept;
- (void)sendInvitationsForShares:(id)shares;
@end

@interface MSSharingManager : XXUnknownSuperclass <MSSharingManager, MSSharingProtocolDelegate> {
@private
	NSString *_personID;	// 4 = 0x4
	NSString *_manifestPath;	// 8 = 0x8
	NSArray *_shares;	// 12 = 0xc
	NSMutableArray *_sharesWithLocalModifications;	// 16 = 0x10
	MSSharingProtocol *_protocol;	// 20 = 0x14
	int _state;	// 24 = 0x18
	BOOL _requestCurrentStateRequested;	// 28 = 0x1c
	NSMutableArray *_invitationQueue;	// 32 = 0x20
	NSMutableArray *_invitationResponseQueue;	// 36 = 0x24
	NSMutableDictionary *_manageShareByPersonID;	// 40 = 0x28
	NSMutableArray *_deleteQueue;	// 44 = 0x2c
	NSTimer *_manageShareDebounceTimer;	// 48 = 0x30
	id<MSSharingManagerDelegate> _delegate;	// 52 = 0x34
	MSMediaStreamDaemon *_daemon;	// 56 = 0x38
}
@property(retain, nonatomic) NSArray *shares;	// G=0x1a015; S=0x1a091; 
@property(readonly, assign) NSString *personID;	// G=0x1b069; @synthesize=_personID
@property(assign, nonatomic) id<MSSharingManagerDelegate> delegate;	// G=0x1b079; S=0x1b089; @synthesize=_delegate
@property(assign, nonatomic) MSMediaStreamDaemon *daemon;	// G=0x1b099; S=0x1b0a9; @synthesize=_daemon
+ (void)forgetPersonID:(id)anId;	// 0x19d3d
+ (void)abortAllActivities;	// 0x19c95
+ (id)_clearInstantiatedSharingManagersByPersonID;	// 0x19c6d
+ (id)existingSharingManagerForPersonID:(id)personID;	// 0x19c51
+ (id)sharingManagerForPersonID:(id)personID;	// 0x19b79
// declared property setter: - (void)setDaemon:(id)daemon;	// 0x1b0a9
// declared property getter: - (id)daemon;	// 0x1b099
// declared property setter: - (void)setDelegate:(id)delegate;	// 0x1b089
// declared property getter: - (id)delegate;	// 0x1b079
// declared property getter: - (id)personID;	// 0x1b069
- (void)sharingProtocol:(id)protocol didFailToSendInvitations:(id)sendInvitations;	// 0x1b029
- (void)sharingProtocol:(id)protocol didReceiveAuthenticationError:(id)error;	// 0x1af4d
- (void)sharingProtocol:(id)protocol didCompleteTransactionWithError:(id)error;	// 0x1ae71
- (void)sharingProtocol:(id)protocol didFindShareState:(id)state;	// 0x1adfd
- (void)abort;	// 0x1ac4d
- (void)_performNextQueuedAction;	// 0x1ab31
- (void)_requestCurrentShareState;	// 0x1aaf1
- (void)_sendNextManagedShare;	// 0x1a949
- (void)_sendNextInvitationResponse;	// 0x1a88d
- (void)_sendNextInvitation;	// 0x1a7f9
- (void)_sendNextDeletion;	// 0x1a665
- (id)_sharesWithLocalModifications;	// 0x1a61d
- (void)refreshCurrentShareState;	// 0x1a5fd
- (void)removeShare:(id)share;	// 0x1a5c1
- (void)modifyShare:(id)share;	// 0x1a3e9
- (void)_shareDebounceTimerDidFire:(id)_shareDebounceTimer;	// 0x1a32d
- (void)respondToInvitation:(id)invitation accept:(BOOL)accept;	// 0x1a2d1
- (void)sendInvitationsForShares:(id)shares;	// 0x1a295
// declared property setter: - (void)setShares:(id)shares;	// 0x1a091
// declared property getter: - (id)shares;	// 0x1a015
- (void)dealloc;	// 0x19eed
- (id)initWithPersonID:(id)personID baseURL:(id)url;	// 0x19d8d
@end
