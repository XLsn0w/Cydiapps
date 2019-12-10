/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iPodUI.framework/iPodUI
 */

#import <iPodUI/iPodUI-Structs.h>
#import <iPodUI/IUFoldingTransitionFace.h>

@class UIView;

@interface IUBookTransitionAlbumArtFace : IUFoldingTransitionFace {
	UIView *_gradientView;	// 8 = 0x8
	float _reflectionHeight;	// 12 = 0xc
}
@property(assign, nonatomic) float reflectionHeight;	// G=0xad7a9; S=0xad275; @synthesize=_reflectionHeight
// declared property getter: - (float)reflectionHeight;	// 0xad7a9
- (void)_reloadGradientView;	// 0xad4b5
- (CGImageRef)_newGradientMaskWithSize:(CGSize)size;	// 0xad3f1
- (void)addAnimationsForTransition:(id)transition;	// 0xad2b1
// declared property setter: - (void)setReflectionHeight:(float)height;	// 0xad275
- (void)dealloc;	// 0xad229
- (id)initWithImage:(id)image;	// 0xad1cd
@end
