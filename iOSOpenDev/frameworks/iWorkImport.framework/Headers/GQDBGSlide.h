/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iWorkImport.framework/iWorkImport
 */

#import <iWorkImport/GQDBGAbstractSlide.h>

@class GQDWPLayoutFrame, GQDBGMasterSlide;

__attribute__((visibility("hidden")))
@interface GQDBGSlide : GQDBGAbstractSlide {
@private
	GQDBGMasterSlide *mMaster;	// 40 = 0x28
	GQDWPLayoutFrame *mNoteFrame;	// 44 = 0x2c
}
- (id)init;	// 0x5125
- (void)dealloc;	// 0x50c5
- (id)master;	// 0x4fa5
- (id)noteFrame;	// 0x4fb5
@end
