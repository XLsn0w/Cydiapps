/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iTunesStoreUI.framework/iTunesStoreUI
 */

#import <iTunesStoreUI/XXUnknownSuperclass.h>

@class UIImageView, SUReflectionView;

@interface SUReflectionImageView : XXUnknownSuperclass {
	float _reflectionHeight;	// 48 = 0x30
	float _spacing;	// 52 = 0x34
	float _reflectionAlpha;	// 56 = 0x38
	BOOL _useImageSize;	// 60 = 0x3c
	unsigned _nonSquareImage : 1;	// 61 = 0x3d
	UIImageView *_imageView;	// 64 = 0x40
	SUReflectionView *_reflection;	// 68 = 0x44
}
@property(assign, nonatomic) BOOL nonSquareImage;	// G=0x25125; S=0x25555; 
@property(assign, nonatomic) float reflectionSpacing;	// G=0x2566d; S=0x2567d; @synthesize=_spacing
// declared property setter: - (void)setReflectionSpacing:(float)spacing;	// 0x2567d
// declared property getter: - (float)reflectionSpacing;	// 0x2566d
- (void)setUseImageSize:(BOOL)size;	// 0x2565d
- (void)setReflectionVisible:(BOOL)visible;	// 0x255d5
- (void)setReflectionAlphaWhenVisible:(float)visible;	// 0x25579
// declared property setter: - (void)setNonSquareImage:(BOOL)image;	// 0x25555
- (void)setImage:(id)image;	// 0x25139
// declared property getter: - (BOOL)nonSquareImage;	// 0x25125
- (void)dealloc;	// 0x250c5
- (id)initWithReflectionHeight:(float)reflectionHeight spacing:(float)spacing;	// 0x25051
- (id)init;	// 0x25039
@end
