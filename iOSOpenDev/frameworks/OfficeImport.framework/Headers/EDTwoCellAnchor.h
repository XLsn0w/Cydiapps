/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/OfficeImport.framework/OfficeImport
 */

#import <OfficeImport/EDAnchor.h>
#import <OfficeImport/OfficeImport-Structs.h>


__attribute__((visibility("hidden")))
@interface EDTwoCellAnchor : EDAnchor {
@private
	EDCellAnchorMarker mFrom;	// 4 = 0x4
	EDCellAnchorMarker mTo;	// 20 = 0x14
	BOOL mIsRelative;	// 36 = 0x24
	int mEditAs;	// 40 = 0x28
}
@property(assign) EDCellAnchorMarker from;	// G=0x1067f1; S=0x101b8d; converted property
@property(assign) EDCellAnchorMarker to;	// G=0x106aa1; S=0x101bb1; converted property
@property(assign, getter=isRelative) BOOL relative;	// G=0x1067e1; S=0x101b6d; converted property
@property(assign) int editAs;	// G=0x25090d; S=0x101b7d; converted property
- (id)init;	// 0x101add
// converted property getter: - (EDCellAnchorMarker)from;	// 0x1067f1
// converted property setter: - (void)setFrom:(EDCellAnchorMarker)from;	// 0x101b8d
// converted property getter: - (EDCellAnchorMarker)to;	// 0x106aa1
// converted property setter: - (void)setTo:(EDCellAnchorMarker)to;	// 0x101bb1
// converted property getter: - (BOOL)isRelative;	// 0x1067e1
// converted property setter: - (void)setRelative:(BOOL)relative;	// 0x101b6d
// converted property getter: - (int)editAs;	// 0x25090d
// converted property setter: - (void)setEditAs:(int)as;	// 0x101b7d
- (id).cxx_construct;	// 0x101aad
@end
