/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/CertUI.framework/CertUI
 */

/* iOSOpenDev: commented-out (since file not found)
#import <Security/_kSecAttrProtocolPOP3.h>
*/

@class CertUITrustManager, NSString;

/* iOSOpenDev: replaced with next line (since file not found)
@interface CertUIConnectionDelegate : _kSecAttrProtocolPOP3 {
*/
@interface CertUIConnectionDelegate : NSObject {
	CertUITrustManager *_trustManager;	// 4 = 0x4
	id _forwardingDelegate;	// 8 = 0x8
	NSString *_connectionDisplayName;	// 12 = 0xc
	struct {
		unsigned canAuthenticateAgainstProtectionSpace : 1;
		unsigned didReceiveAuthenticationChallenge : 1;
	} _delegateRespondsTo;	// 16 = 0x10
}
@property(copy, nonatomic) NSString *connectionDisplayName;	// G=0x1795; S=0x17a5; @synthesize=_connectionDisplayName
@property(assign, nonatomic) id forwardingDelegate;	// G=0x1785; S=0xf99; @synthesize=_forwardingDelegate
+ (id)defaultServiceForProtocol:(id)protocol;	// 0x1079
// declared property setter: - (void)setConnectionDisplayName:(id)name;	// 0x17a5
// declared property getter: - (id)connectionDisplayName;	// 0x1795
// declared property getter: - (id)forwardingDelegate;	// 0x1785
- (void)connection:(id)connection didReceiveAuthenticationChallenge:(id)challenge;	// 0x13e5
- (void)_continueConnectionWithResponse:(int)response challenge:(id)challenge service:(id)service;	// 0x1225
- (BOOL)connection:(id)connection canAuthenticateAgainstProtectionSpace:(id)space;	// 0x11b5
- (id)forwardingTargetForSelector:(SEL)selector;	// 0x1069
- (BOOL)respondsToSelector:(SEL)selector;	// 0x101d
// declared property setter: - (void)setForwardingDelegate:(id)delegate;	// 0xf99
- (void)dealloc;	// 0xf4d
@end

