/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iPodUI.framework/iPodUI
 */

#import <iPodUI/iPodUI-Structs.h>
#import <iPodUI/XXUnknownSuperclass.h>

@class UIView, MPMediaItem, UIButton, NSDictionary, MPWebDocumentView, UIImageView, UILabel, UIScrollView;
@protocol IUVideoSummaryViewDataSource;

@interface IUVideoSummaryView : XXUnknownSuperclass {
	id<IUVideoSummaryViewDataSource> _dataSource;	// 48 = 0x30
	UIView *_footerView;	// 52 = 0x34
	MPMediaItem *_mediaItem;	// 56 = 0x38
	UIScrollView *_scrollView;	// 60 = 0x3c
	BOOL _layoutReallyNeeded;	// 64 = 0x40
	BOOL _isTVShow;	// 65 = 0x41
	float _availableWidth;	// 68 = 0x44
	float _columnLeftMargin;	// 72 = 0x48
	float _columnHeight;	// 76 = 0x4c
	float _columnWidth;	// 80 = 0x50
	float _height;	// 84 = 0x54
	NSDictionary *_movieInfo;	// 88 = 0x58
}
@property(readonly, assign, nonatomic) UIView *lowerBackgroundView;	// G=0xb9fb1; 
@property(readonly, assign, nonatomic) UIButton *soundtrackBuyButton;	// G=0xb9f65; 
@property(readonly, assign, nonatomic) UIImageView *soundtrackAlbumArtImageView;	// G=0xb9f19; 
@property(readonly, assign, nonatomic) UILabel *soundtrackContentLabel;	// G=0xb9ef9; 
@property(readonly, assign, nonatomic) UILabel *soundtrackHeaderLabel;	// G=0xb9ed9; 
@property(readonly, assign, nonatomic) MPWebDocumentView *summaryContentTextView;	// G=0xb9eb9; 
@property(readonly, assign, nonatomic) UILabel *summaryHeaderLabel;	// G=0xb9e99; 
@property(readonly, assign, nonatomic) UILabel *screenwriterContentLabel;	// G=0xb9e79; 
@property(readonly, assign, nonatomic) UILabel *screenwriterHeaderLabel;	// G=0xb9e59; 
@property(readonly, assign, nonatomic) UILabel *producerContentLabel;	// G=0xb9e39; 
@property(readonly, assign, nonatomic) UILabel *producerHeaderLabel;	// G=0xb9e19; 
@property(readonly, assign, nonatomic) UILabel *directorContentLabel;	// G=0xb9df9; 
@property(readonly, assign, nonatomic) UILabel *directorHeaderLabel;	// G=0xb9dd9; 
@property(readonly, assign, nonatomic) UILabel *actorContentLabel;	// G=0xb9db9; 
@property(readonly, assign, nonatomic) UILabel *actorHeaderLabel;	// G=0xb9d99; 
@property(retain, nonatomic) NSDictionary *movieInfo;	// G=0xbafe5; S=0xbaff5; @synthesize=_movieInfo
@property(assign, nonatomic) id<IUVideoSummaryViewDataSource> dataSource;	// G=0xbafc5; S=0xbafd5; @synthesize=_dataSource
+ (float)contentWidthForBoundsWidth:(float)boundsWidth;	// 0xb86f5
// declared property setter: - (void)setMovieInfo:(id)info;	// 0xbaff5
// declared property getter: - (id)movieInfo;	// 0xbafe5
// declared property setter: - (void)setDataSource:(id)source;	// 0xbafd5
// declared property getter: - (id)dataSource;	// 0xbafc5
- (void)_setMediaItem:(id)item;	// 0xbaf3d
- (void)_setFooterView:(id)view;	// 0xbaebd
- (void)_layoutNoMetadataColumn2;	// 0xbab29
- (void)_layoutNoMetadataColumn1;	// 0xba865
- (id)contentLabelWithTag:(int)tag name:(id)name width:(float)width;	// 0xba569
- (id)headerLabelWithTag:(int)tag name:(id)name width:(float)width;	// 0xba26d
- (void)addToColumn:(id)column;	// 0xba1ad
- (void)layoutSizeColumn;	// 0xba02d
- (void)layoutSubviewsWithNoMetadata;	// 0xb9fed
// declared property getter: - (id)lowerBackgroundView;	// 0xb9fb1
// declared property getter: - (id)soundtrackBuyButton;	// 0xb9f65
// declared property getter: - (id)soundtrackAlbumArtImageView;	// 0xb9f19
// declared property getter: - (id)soundtrackContentLabel;	// 0xb9ef9
// declared property getter: - (id)soundtrackHeaderLabel;	// 0xb9ed9
// declared property getter: - (id)summaryContentTextView;	// 0xb9eb9
// declared property getter: - (id)summaryHeaderLabel;	// 0xb9e99
// declared property getter: - (id)screenwriterContentLabel;	// 0xb9e79
// declared property getter: - (id)screenwriterHeaderLabel;	// 0xb9e59
// declared property getter: - (id)producerContentLabel;	// 0xb9e39
// declared property getter: - (id)producerHeaderLabel;	// 0xb9e19
// declared property getter: - (id)directorContentLabel;	// 0xb9df9
// declared property getter: - (id)directorHeaderLabel;	// 0xb9dd9
// declared property getter: - (id)actorContentLabel;	// 0xb9db9
// declared property getter: - (id)actorHeaderLabel;	// 0xb9d99
- (id)_newlineSeperatedListOfNames:(id)names;	// 0xb9c69
- (void)_populateHeaderAndContentLabels:(id)labels key:(id)key singular:(id)singular plural:(id)plural header:(id)header content:(id)content;	// 0xb9b81
- (void)reloadData;	// 0xb9ab9
- (BOOL)haveEnoughMetadataForMetadataView;	// 0xb9969
- (void)layoutSubviewsWithMetadata;	// 0xb8e65
- (void)layoutSubviews;	// 0xb8885
- (void)setFrame:(CGRect)frame;	// 0xb87c9
- (void)setBounds:(CGRect)bounds;	// 0xb870d
- (void)dealloc;	// 0xb8661
- (id)initWithFrame:(CGRect)frame;	// 0xb852d
@end
