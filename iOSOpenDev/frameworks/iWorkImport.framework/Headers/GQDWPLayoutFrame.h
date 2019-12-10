/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iWorkImport.framework/iWorkImport
 */

#import <iWorkImport/XXUnknownSuperclass.h>
#import <iWorkImport/iWorkImport-Structs.h>
#import <iWorkImport/GQDWPLayoutFrame.h>

@class GQDWPLayoutStorage, GQDSStyle;

__attribute__((visibility("hidden")))
@interface GQDWPLayoutFrame : XXUnknownSuperclass {
@private
	char *mStyleRef;	// 4 = 0x4
	GQDSStyle *mStyle;	// 8 = 0x8
	GQDWPLayoutStorage *mStorage;	// 12 = 0xc
	unsigned mTextScale;	// 16 = 0x10
}
- (void)dealloc;	// 0x219d9
- (id)layoutStyle;	// 0x217a9
- (id)storage;	// 0x217b9
- (unsigned)textScale;	// 0x217c9
- (BOOL)isBlank;	// 0x218f1
@end

@interface GQDWPLayoutFrame (Private)
- (int)readAttributesFromReader:(xmlTextReader *)reader;	// 0x21a99
- (void)resolveStyleRef;	// 0x217d9
@end
