/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/StoreServices.framework/StoreServices
 */

#import <StoreServices/XXUnknownSuperclass.h>

@class NSString, NSDictionary, NSHTTPURLResponse, NSNumber;

@interface SSAuthenticationResponse : XXUnknownSuperclass {
@private
	NSDictionary *_responseDictionary;	// 4 = 0x4
	int _urlBagType;	// 8 = 0x8
	NSHTTPURLResponse *_urlResponse;	// 12 = 0xc
}
@property(readonly, assign) NSString *userMessage;	// G=0x40839; 
@property(readonly, assign) int responseType;	// G=0x40685; 
@property(readonly, assign) NSNumber *failureType;	// G=0x40465; 
@property(readonly, assign) NSString *token;	// G=0x40771; 
@property(readonly, assign) NSString *storeFrontIdentifier;	// G=0x40705; 
@property(readonly, assign) int enabledServiceTypes;	// G=0x4027d; 
@property(readonly, assign) int availableServiceTypes;	// G=0x400c9; 
@property(readonly, assign) NSString *creditsString;	// G=0x401ed; 
@property(readonly, assign) NSNumber *accountUniqueIdentifier;	// G=0x40075; 
@property(readonly, assign) int accountKind;	// G=0x3fed1; 
@property(readonly, assign) NSString *accountName;	// G=0x3ff89; 
@property(readonly, assign) NSHTTPURLResponse *URLResponse;	// G=0x40801; 
@property(readonly, assign) NSDictionary *responseDictionary;	// G=0x40989; @synthesize=_responseDictionary
@property(assign) int URLBagType;	// G=0x40999; S=0x409a9; @synthesize=_urlBagType
// declared property setter: - (void)setURLBagType:(int)type;	// 0x409a9
// declared property getter: - (int)URLBagType;	// 0x40999
// declared property getter: - (id)responseDictionary;	// 0x40989
- (id)_statusValue;	// 0x40905
- (int)_responseTypeForStatusValue:(int)statusValue;	// 0x408e5
- (int)_responseTypeForFailureType:(int)failureType;	// 0x408c9
// declared property getter: - (id)userMessage;	// 0x40839
// declared property getter: - (id)URLResponse;	// 0x40801
// declared property getter: - (id)token;	// 0x40771
// declared property getter: - (id)storeFrontIdentifier;	// 0x40705
// declared property getter: - (int)responseType;	// 0x40685
- (id)newAccount;	// 0x404e9
// declared property getter: - (id)failureType;	// 0x40465
// declared property getter: - (int)enabledServiceTypes;	// 0x4027d
// declared property getter: - (id)creditsString;	// 0x401ed
// declared property getter: - (int)availableServiceTypes;	// 0x400c9
// declared property getter: - (id)accountUniqueIdentifier;	// 0x40075
// declared property getter: - (id)accountName;	// 0x3ff89
// declared property getter: - (int)accountKind;	// 0x3fed1
- (void)dealloc;	// 0x3fe85
- (id)initWithURLResponse:(id)urlresponse dictionary:(id)dictionary;	// 0x3fe11
@end
