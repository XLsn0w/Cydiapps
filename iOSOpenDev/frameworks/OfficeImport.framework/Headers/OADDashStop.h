/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/OfficeImport.framework/OfficeImport
 */

#import <OfficeImport/OfficeImport-Structs.h>
#import <OfficeImport/NSCopying.h>
#import <OfficeImport/XXUnknownSuperclass.h>


__attribute__((visibility("hidden")))
@interface OADDashStop : XXUnknownSuperclass <NSCopying> {
@private
	float mDash;	// 4 = 0x4
	float mSpace;	// 8 = 0x8
}
- (id)initWithDash:(float)dash space:(float)space;	// 0x14afd9
- (id)copyWithZone:(NSZone *)zone;	// 0x2a652d
- (float)dash;	// 0x14b099
- (float)space;	// 0x14b0e5
- (unsigned)hash;	// 0x2a635d
- (BOOL)isEqual:(id)equal;	// 0x2a658d
@end
