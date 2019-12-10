/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iPodUI.framework/iPodUI
 */

#import <iPodUI/iPodUI-Structs.h>
#import <iPodUI/XXUnknownSuperclass.h>


@interface IUPropertyLayoutStorage : XXUnknownSuperclass {
@private
	unsigned _count;	// 4 = 0x4
	id *_values;	// 8 = 0x8
	id *_selectedValues;	// 12 = 0xc
	CGRect *_frames;	// 16 = 0x10
}
@property(readonly, assign) unsigned count;	// G=0xe801; converted property
- (CGRect)frameAtIndex:(unsigned)index;	// 0xe989
- (void)setFrame:(CGRect)frame atIndex:(unsigned)index;	// 0xe941
- (id)selectedValueAtIndex:(unsigned)index;	// 0xe915
- (id)valueAtIndex:(unsigned)index;	// 0xe8e9
- (void)setSelectedValue:(id)value atIndex:(unsigned)index;	// 0xe87d
- (void)setValue:(id)value atIndex:(unsigned)index;	// 0xe811
// converted property getter: - (unsigned)count;	// 0xe801
- (void)dealloc;	// 0xe73d
- (id)initWithCount:(unsigned)count;	// 0xe6b9
@end
