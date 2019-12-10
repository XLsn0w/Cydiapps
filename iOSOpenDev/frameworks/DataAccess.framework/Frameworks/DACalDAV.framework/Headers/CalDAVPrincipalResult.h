/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/DataAccess.framework/Frameworks/DACalDAV.framework/DACalDAV
 */

#import <DACalDAV/CalDAVPrincipalResult.h>
#import <DACalDAV/XXUnknownSuperclass.h>

@class NSString, NSArray, NSMutableArray;

@interface CalDAVPrincipalResult : XXUnknownSuperclass {
	NSString *_firstName;	// 4 = 0x4
	NSString *_lastName;	// 8 = 0x8
	NSString *_displayName;	// 12 = 0xc
	NSString *_type;	// 16 = 0x10
	NSString *_principal;	// 20 = 0x14
	NSMutableArray *_emails;	// 24 = 0x18
	NSMutableArray *_cuAddresses;	// 28 = 0x1c
}
@property(readonly, assign) NSString *preferredCUAddress;	// G=0x205ed; 
@property(retain) NSArray *cuAddresses;	// G=0x20a29; S=0x20a3d; @synthesize=_cuAddresses
@property(retain) NSArray *emailAddresses;	// G=0x209b9; S=0x209cd; @synthesize=_emails
@property(readonly, assign) NSString *emailAddress;	// G=0x20725; 
@property(retain) NSString *principalPath;	// G=0x209f1; S=0x20a05; @synthesize=_principal
@property(retain) NSString *resultType;	// G=0x20981; S=0x20995; @synthesize=_type
@property(retain) NSString *displayName;	// G=0x20949; S=0x2095d; @synthesize=_displayName
@property(retain) NSString *lastName;	// G=0x20911; S=0x20925; @synthesize=_lastName
@property(retain) NSString *firstName;	// G=0x208d9; S=0x208ed; @synthesize=_firstName
+ (id)resultFromResponse:(id)response;	// 0x2051d
// declared property setter: - (void)setCuAddresses:(id)addresses;	// 0x20a3d
// declared property getter: - (id)cuAddresses;	// 0x20a29
// declared property setter: - (void)setPrincipalPath:(id)path;	// 0x20a05
// declared property getter: - (id)principalPath;	// 0x209f1
// declared property setter: - (void)setEmailAddresses:(id)addresses;	// 0x209cd
// declared property getter: - (id)emailAddresses;	// 0x209b9
// declared property setter: - (void)setResultType:(id)type;	// 0x20995
// declared property getter: - (id)resultType;	// 0x20981
// declared property setter: - (void)setDisplayName:(id)name;	// 0x2095d
// declared property getter: - (id)displayName;	// 0x20949
// declared property setter: - (void)setLastName:(id)name;	// 0x20925
// declared property getter: - (id)lastName;	// 0x20911
// declared property setter: - (void)setFirstName:(id)name;	// 0x208ed
// declared property getter: - (id)firstName;	// 0x208d9
- (id)description;	// 0x2083d
// declared property getter: - (id)emailAddress;	// 0x20725
// declared property getter: - (id)preferredCUAddress;	// 0x205ed
- (void)addEmail:(id)email;	// 0x205a9
- (void)addCUAddress:(id)address;	// 0x20565
- (id)initWithResponse:(id)response;	// 0x200b9
- (void)dealloc;	// 0x1fff5
- (id)init;	// 0x1fef9
@end

@interface CalDAVPrincipalResult (DASearch)
- (id)convertToDAContactSearchResultElement;	// 0x110d
@end
