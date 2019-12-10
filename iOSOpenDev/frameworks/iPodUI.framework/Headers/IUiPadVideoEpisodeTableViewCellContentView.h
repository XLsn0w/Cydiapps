/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iPodUI.framework/iPodUI
 */

#import <iPodUI/iPodUI-Structs.h>
#import <iPodUI/IUiPadVideoPartTableViewCellContentView.h>

@class MPButton, UIImageView, NSString, UIView, NSArray;

@interface IUiPadVideoEpisodeTableViewCellContentView : IUiPadVideoPartTableViewCellContentView {
	NSString *_expirationText;	// 52 = 0x34
	CGSize _expirationTextSize;	// 56 = 0x38
	BOOL _expiresSoon;	// 64 = 0x40
	NSString *_title;	// 68 = 0x44
	NSString *_summary;	// 72 = 0x48
	NSArray *_supertitles;	// 76 = 0x4c
	MPButton *_moreButton;	// 80 = 0x50
	id _moreButtonTarget;	// 84 = 0x54
	SEL _moreButtonAction;	// 88 = 0x58
	BOOL _expanded;	// 92 = 0x5c
	int _unplayedState;	// 96 = 0x60
	UIImageView *_unplayedIndicator;	// 100 = 0x64
	UIView *_disabledView;	// 104 = 0x68
}
@property(retain, nonatomic) NSString *expirationText;	// G=0x377d9; S=0x36da9; @synthesize=_expirationText
@property(assign, nonatomic) BOOL expiresSoon;	// G=0x377b9; S=0x377c9; @synthesize=_expiresSoon
@property(assign, nonatomic) int unplayedState;	// G=0x378a1; S=0x36ee1; @synthesize=_unplayedState
@property(retain, nonatomic) NSArray *supertitles;	// G=0x37839; S=0x37849; @synthesize=_supertitles
@property(retain, nonatomic) NSString *summary;	// G=0x37829; S=0x36269; @synthesize=_summary
@property(retain, nonatomic) NSString *title;	// G=0x3786d; S=0x3787d; @synthesize=_title
@property(assign, nonatomic) id moreButtonTarget;	// G=0x37809; S=0x37819; @synthesize=_moreButtonTarget
@property(assign, nonatomic) SEL moreButtonAction;	// G=0x377e9; S=0x377f9; @synthesize=_moreButtonAction
@property(assign, nonatomic) BOOL expanded;	// G=0x377a9; S=0x36239; @synthesize=_expanded
// declared property getter: - (int)unplayedState;	// 0x378a1
// declared property setter: - (void)setTitle:(id)title;	// 0x3787d
// declared property getter: - (id)title;	// 0x3786d
// declared property setter: - (void)setSupertitles:(id)supertitles;	// 0x37849
// declared property getter: - (id)supertitles;	// 0x37839
// declared property getter: - (id)summary;	// 0x37829
// declared property setter: - (void)setMoreButtonTarget:(id)target;	// 0x37819
// declared property getter: - (id)moreButtonTarget;	// 0x37809
// declared property setter: - (void)setMoreButtonAction:(SEL)action;	// 0x377f9
// declared property getter: - (SEL)moreButtonAction;	// 0x377e9
// declared property getter: - (id)expirationText;	// 0x377d9
// declared property setter: - (void)setExpiresSoon:(BOOL)soon;	// 0x377c9
// declared property getter: - (BOOL)expiresSoon;	// 0x377b9
// declared property getter: - (BOOL)expanded;	// 0x377a9
- (CFAttributedStringRef)_newSummaryAttributedString:(id)string withLineBreakMode:(unsigned char)lineBreakMode;	// 0x376d5
- (void)_moreButtonSelected:(id)selected;	// 0x3768d
- (void)_drawText;	// 0x36f59
// declared property setter: - (void)setUnplayedState:(int)state;	// 0x36ee1
- (void)setHighlightedOrSelected:(BOOL)selected;	// 0x36e51
// declared property setter: - (void)setExpirationText:(id)text;	// 0x36da9
- (CGSize)sizeThatFits:(CGSize)fits expanded:(BOOL)expanded;	// 0x36cbd
- (CGSize)sizeThatFits:(CGSize)fits;	// 0x36c71
- (void)layoutSubviews;	// 0x368b1
- (id)initWithFrame:(CGRect)frame;	// 0x364a9
- (void)drawRect:(CGRect)rect;	// 0x363c1
- (void)dealloc;	// 0x362dd
// declared property setter: - (void)setSummary:(id)summary;	// 0x36269
// declared property setter: - (void)setExpanded:(BOOL)expanded;	// 0x36239
@end
