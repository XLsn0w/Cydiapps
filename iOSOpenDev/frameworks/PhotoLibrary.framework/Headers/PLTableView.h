/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/PhotoLibrary.framework/PhotoLibrary
 */

#import <PhotoLibrary/XXUnknownSuperclass.h>
#import <PhotoLibrary/PhotoLibrary-Structs.h>

@class CAFilter;

@interface PLTableView : XXUnknownSuperclass {
	CAFilter *_blurFilter;	// 720 = 0x2d0
	unsigned _shouldBlur : 1;	// 724 = 0x2d4
@private
	id scrollingEndedCompletion;	// 728 = 0x2d8
}
@property(copy, nonatomic) id scrollingEndedCompletion;	// G=0xbed8d; S=0xbed9d; @synthesize
@property(assign, nonatomic, getter=isBlurFilterEnabled) BOOL blurFilterEnabled;	// G=0xbed35; S=0xbeced; 
@property(readonly, assign, nonatomic, getter=isScrolling) BOOL scrolling;	// G=0xbed49; 
// declared property setter: - (void)setScrollingEndedCompletion:(id)completion;	// 0xbed9d
// declared property getter: - (id)scrollingEndedCompletion;	// 0xbed8d
- (void)_removeBlurFilter;	// 0x8ec1
- (void)_setBlurFilterEnabled:(BOOL)enabled;	// 0x7705
- (void)animationDidStop:(id)animation finished:(BOOL)finished;	// 0x8e65
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;	// 0x763d
// declared property getter: - (BOOL)isScrolling;	// 0xbed49
// declared property getter: - (BOOL)isBlurFilterEnabled;	// 0xbed35
// declared property setter: - (void)setBlurFilterEnabled:(BOOL)enabled;	// 0xbeced
- (void)dealloc;	// 0xbec8d
- (id)initWithFrame:(CGRect)frame style:(int)style;	// 0x7435
@end
