/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/OfficeImport.framework/OfficeImport
 */

#import <OfficeImport/OfficeImport-Structs.h>
#import <OfficeImport/XXUnknownSuperclass.h>


__attribute__((visibility("hidden")))
@interface ESDObjectFactory : XXUnknownSuperclass {
}
+ (EshObject *)createObjectWithType:(unsigned short)type;	// 0x7dfad
+ (EshObject *)createObjectWithType:(unsigned short)type version:(unsigned short)version;	// 0xe61a9
+ (void)initialize;	// 0xac5ed
+ (void)replaceHostEshFactoryWith:(EshObjectFactory *)with;	// 0xd72c9
+ (void)restoreHostEshFactory;	// 0xe73ed
+ (void)setEshFactory:(EshObjectFactory *)factory;	// 0xac63d
@end
