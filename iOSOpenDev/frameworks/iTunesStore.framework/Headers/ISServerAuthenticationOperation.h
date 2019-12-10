/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iTunesStore.framework/iTunesStore
 */

#import <iTunesStore/ISOperation.h>

@class NSURL, NSNumber, SSAuthenticationContext, ISDialog;

@interface ISServerAuthenticationOperation : ISOperation {
	NSNumber *_authenticatedAccountDSID;	// 60 = 0x3c
	SSAuthenticationContext *_authenticationContext;	// 64 = 0x40
	ISDialog *_dialog;	// 68 = 0x44
	NSURL *_redirectURL;	// 72 = 0x48
}
@property(retain) NSURL *redirectURL;	// G=0x220d9; S=0x220ed; @synthesize=_redirectURL
@property(retain) NSNumber *authenticatedAccountDSID;	// G=0x22069; S=0x2207d; @synthesize=_authenticatedAccountDSID
@property(retain) ISDialog *dialog;	// G=0x220a1; S=0x220b5; @synthesize=_dialog
@property(retain) SSAuthenticationContext *authenticationContext;	// G=0x22031; S=0x22045; @synthesize=_authenticationContext
// declared property setter: - (void)setRedirectURL:(id)url;	// 0x220ed
// declared property getter: - (id)redirectURL;	// 0x220d9
// declared property setter: - (void)setDialog:(id)dialog;	// 0x220b5
// declared property getter: - (id)dialog;	// 0x220a1
// declared property setter: - (void)setAuthenticatedAccountDSID:(id)dsid;	// 0x2207d
// declared property getter: - (id)authenticatedAccountDSID;	// 0x22069
// declared property setter: - (void)setAuthenticationContext:(id)context;	// 0x22045
// declared property getter: - (id)authenticationContext;	// 0x22031
- (BOOL)_shouldAuthenticateForButton:(id)button;	// 0x21fb1
- (BOOL)_handleSelectedButton:(id)button;	// 0x21ec5
- (BOOL)_copySelectedButton:(id *)button returningError:(id *)error;	// 0x21dcd
- (id)_copyButtonForDialogSkip;	// 0x21d19
- (id)_copyAuthenticationContext;	// 0x21b99
- (BOOL)_copyAccountIdentifier:(id *)identifier returningError:(id *)error;	// 0x21af1
- (void)run;	// 0x21759
- (void)dealloc;	// 0x216ad
@end
