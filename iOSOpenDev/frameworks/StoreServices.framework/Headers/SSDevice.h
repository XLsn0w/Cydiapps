/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/StoreServices.framework/StoreServices
 */

#import <StoreServices/SSRequestDelegate.h>
#import <StoreServices/StoreServices-Structs.h>
#import <StoreServices/XXUnknownSuperclass.h>

@class NSMutableArray, NSSet, NSString, SSRequest;

@interface SSDevice : XXUnknownSuperclass <SSRequestDelegate> {
@private
	dispatch_queue_s *_dispatchQueue;	// 4 = 0x4
	NSMutableArray *_loadStoreFrontHandlers;	// 8 = 0x8
	SSRequest *_loadStoreFrontRequest;	// 12 = 0xc
	NSString *_localStoreFrontIdentifier;	// 16 = 0x10
	BOOL _localStoreFrontIsTransient;	// 20 = 0x14
	id _mediaLibraryIdentifier;	// 24 = 0x18
	NSMutableArray *_simpleRequests;	// 28 = 0x1c
	id _softwareLibraryIdentifier;	// 32 = 0x20
	NSString *_synchedStoreFrontIdentifier;	// 36 = 0x24
}
@property(readonly, assign) NSString *synchedStoreFrontIdentifier;	// G=0x27031; 
@property(readonly, assign, getter=isStoreFrontIdentifierTransient) BOOL storeFrontIdentifierTransient;	// G=0x26a81; 
@property(copy) NSString *mediaLibraryIdentifier;	// G=0x25e09; S=0x26c21; 
@property(readonly, assign) NSSet *automaticDownloadKinds;	// G=0x2577d; 
@property(readonly, assign) NSString *storeFrontIdentifier;	// G=0x265d5; 
@property(copy) NSString *softwareLibraryIdentifier;	// G=0x2638d; S=0x26d7d; 
+ (void)setPromptWithIdentifier:(id)identifier needsDisplay:(BOOL)display;	// 0x269ed
+ (void)setLastPromptAttemptDate:(id)date forPromptWithIdentifier:(id)identifier;	// 0x269a9
+ (BOOL)setCachedAvailableItemKinds:(id)kinds;	// 0x26929
+ (BOOL)promptNeedsDisplay:(id)display;	// 0x26865
+ (id)copyCachedAvailableItemKinds;	// 0x267a9
+ (id)currentDevice;	// 0x25711
- (void)_updateAutomaticDownloadKinds:(id)kinds withValue:(id)value completionBlock:(id)block;	// 0x27e01
- (void)_trackSimpleRequest:(id)request;	// 0x27d9d
- (BOOL)_setStoreFrontIdentifier:(id)identifier isTransient:(BOOL)transient;	// 0x27c25
- (void)_setLocalStoreFrontIdentifier:(id)identifier isTransient:(BOOL)transient;	// 0x27b11
- (void)_reloadStoreFrontIdentifier;	// 0x279f9
- (void)_reloadAfterStoreFrontChange;	// 0x277c9
- (void)_postStoreFrontDidChangeNotification;	// 0x27749
- (void)_invalidateSoftwareCUID;	// 0x276ad
- (void)_finishRequestWithError:(id)error;	// 0x27429
- (void)_cleanupSimpleRequest:(id)request;	// 0x273d5
- (void)setStoreFrontIdentifierWithInfo:(id)info;	// 0x27361
- (void)resetStoreFrontForSignOut;	// 0x272f5
- (void)requestDidFinish:(id)request;	// 0x272e1
- (void)request:(id)request didFailWithError:(id)error;	// 0x272a5
- (void)unionAutomaticDownloadKinds:(id)kinds withCompletionBlock:(id)completionBlock;	// 0x27239
- (void)synchronizeAutomaticDownloadKinds;	// 0x27205
// declared property getter: - (id)synchedStoreFrontIdentifier;	// 0x27031
- (void)setStoreFrontIdentifier:(id)identifier isTransient:(BOOL)transient;	// 0x26ef1
// declared property setter: - (void)setSoftwareLibraryIdentifier:(id)identifier;	// 0x26d7d
// declared property setter: - (void)setMediaLibraryIdentifier:(id)identifier;	// 0x26c21
- (void)setAutomaticDownloadKinds:(id)kinds withCompletionBlock:(id)completionBlock;	// 0x26bd1
- (void)reloadStoreFrontIdentifier;	// 0x26bc1
- (void)minusAutomaticDownloadKinds:(id)kinds withCompletionBlock:(id)completionBlock;	// 0x26b55
// declared property getter: - (BOOL)isStoreFrontIdentifierTransient;	// 0x26a81
// declared property getter: - (id)storeFrontIdentifier;	// 0x265d5
// declared property getter: - (id)softwareLibraryIdentifier;	// 0x2638d
- (void)showPromptWithIdentifier:(id)identifier completionHandler:(id)handler;	// 0x260ad
- (void)setStoreFrontWithResponseHeaders:(id)responseHeaders;	// 0x26051
// declared property getter: - (id)mediaLibraryIdentifier;	// 0x25e09
- (void)loadStoreFrontWithCompletionHandler:(id)completionHandler;	// 0x25b19
- (void)getAvailableItemKindsWithBlock:(id)block;	// 0x25885
- (id)copyStoreFrontRequestHeaders;	// 0x25821
// declared property getter: - (id)automaticDownloadKinds;	// 0x2577d
- (void)dealloc;	// 0x25501
- (id)init;	// 0x253ad
@end
