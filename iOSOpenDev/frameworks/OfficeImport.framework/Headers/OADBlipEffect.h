/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/OfficeImport.framework/OfficeImport
 */

#import <OfficeImport/OfficeImport-Structs.h>
#import <OfficeImport/NSCopying.h>
#import <OfficeImport/XXUnknownSuperclass.h>


__attribute__((visibility("hidden")))
@interface OADBlipEffect : XXUnknownSuperclass <NSCopying> {
@private
	int mType;	// 4 = 0x4
}
- (id)initWithType:(int)type;	// 0xc6eb5
- (id)copyWithZone:(NSZone *)zone;	// 0x29d731
- (int)type;	// 0x29d735
- (void)setStyleColor:(id)color;	// 0x29d745
- (unsigned)hash;	// 0x29d749
- (BOOL)isEqual:(id)equal;	// 0x29d829
@end