/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/PhotoLibrary.framework/PhotoLibrary
 */

#import <PhotoLibrary/PhotoLibrary-Structs.h>
#import <PhotoLibrary/UITextFieldDelegate.h>
#import <PhotoLibrary/XXUnknownSuperclass.h>

@class UIButton, UIImage, UIImageView, UIView, PLImageView, PLAlbumTextField, UILabel;
@protocol PLStackableImage;

@interface PLStackItemViewCell : XXUnknownSuperclass <UITextFieldDelegate> {
	UIView<PLStackableImage> *_sourceView;	// 48 = 0x30
	UIImageView *_badgeView;	// 52 = 0x34
	UIImage *_badgeImage;	// 56 = 0x38
	UIButton *_closeButton;	// 60 = 0x3c
	UILabel *_titleLabel;	// 64 = 0x40
	PLAlbumTextField *_editField;	// 68 = 0x44
	float _stackedAngle;	// 72 = 0x48
	CGSize _lastItemSize;	// 76 = 0x4c
	BOOL _didHaveSourceView;	// 84 = 0x54
	BOOL _ignoreEndEditing;	// 85 = 0x55
	unsigned _showBadge : 1;	// 86 = 0x56
	unsigned _titleIsEditable : 1;	// 86 = 0x56
	id _closeAction;	// 88 = 0x58
	id _renameAction;	// 92 = 0x5c
@private
	BOOL _enabled;	// 96 = 0x60
	float _previousEnabledAlpha;	// 100 = 0x64
}
@property(copy, nonatomic) id closeAction;	// G=0x84109; S=0x84119; @synthesize=_closeAction
@property(copy, nonatomic) id renameAction;	// G=0x8413d; S=0x8414d; @synthesize=_renameAction
@property(assign, nonatomic, getter=isShadowEnabled) BOOL shadowEnabled;	// G=0x84011; S=0x83ff1; 
@property(assign, nonatomic) BOOL enabled;	// G=0x84171; S=0x84035; @synthesize=_enabled
@property(assign, nonatomic) unsigned imageIndex;	// G=0x831e9; S=0x831d5; 
@property(retain, nonatomic) UIImage *badgeImage;	// G=0x8349d; S=0x833f9; 
@property(assign, nonatomic, getter=isBadgeShown) BOOL showBadge;	// G=0x833e5; S=0x832ed; 
@property(assign, nonatomic) float stackedAngle;	// G=0x840c9; S=0x840d9; @synthesize=_stackedAngle
@property(readonly, assign, nonatomic) CGPoint closeBoxPosition;	// G=0x83919; 
@property(assign, nonatomic, getter=isCloseBoxShown) BOOL showCloseBox;	// G=0x83901; S=0x834ad; 
@property(assign, nonatomic) BOOL ignoreEndEditing;	// G=0x84181; S=0x84191; @synthesize=_ignoreEndEditing
@property(readonly, assign, nonatomic) BOOL isLabelEditing;	// G=0x83d9d; 
@property(assign, nonatomic, getter=isLabelEditable) BOOL labelIsEditable;	// G=0x83d89; S=0x83a6d; 
@property(retain, nonatomic) UILabel *title;	// G=0x840f9; S=0x839d5; @synthesize=_titleLabel
@property(readonly, assign, nonatomic) UIView *badgeView;	// G=0x840e9; @synthesize=_badgeView
@property(readonly, assign, nonatomic) PLImageView *imageView;	// G=0x832cd; 
@property(retain, nonatomic) UIView<PLStackableImage> *sourceView;	// G=0x840b9; S=0x83055; @synthesize=_sourceView
+ (CGSize)badgeOffset;	// 0x82b61
+ (void)initialize;	// 0x82aed
// declared property setter: - (void)setIgnoreEndEditing:(BOOL)editing;	// 0x84191
// declared property getter: - (BOOL)ignoreEndEditing;	// 0x84181
// declared property getter: - (BOOL)enabled;	// 0x84171
// declared property setter: - (void)setRenameAction:(id)action;	// 0x8414d
// declared property getter: - (id)renameAction;	// 0x8413d
// declared property setter: - (void)setCloseAction:(id)action;	// 0x84119
// declared property getter: - (id)closeAction;	// 0x84109
// declared property getter: - (id)title;	// 0x840f9
// declared property getter: - (id)badgeView;	// 0x840e9
// declared property setter: - (void)setStackedAngle:(float)angle;	// 0x840d9
// declared property getter: - (float)stackedAngle;	// 0x840c9
// declared property getter: - (id)sourceView;	// 0x840b9
// declared property setter: - (void)setEnabled:(BOOL)enabled;	// 0x84035
// declared property getter: - (BOOL)isShadowEnabled;	// 0x84011
// declared property setter: - (void)setShadowEnabled:(BOOL)enabled;	// 0x83ff1
- (BOOL)textFieldShouldReturn:(id)textField;	// 0x83fd5
- (NSRange)textField:(id)field willChangeSelectionFromCharacterRange:(NSRange)characterRange toCharacterRange:(NSRange)characterRange3;	// 0x83fb1
- (BOOL)textFieldShouldClear:(id)textField;	// 0x83f95
- (BOOL)textField:(id)field shouldChangeCharactersInRange:(NSRange)range replacementString:(id)string;	// 0x83f41
- (void)textFieldDidEndEditing:(id)textField;	// 0x83e1d
- (void)textFieldDidBeginEditing:(id)textField;	// 0x83dd1
// declared property getter: - (BOOL)isLabelEditing;	// 0x83d9d
// declared property getter: - (BOOL)isLabelEditable;	// 0x83d89
// declared property setter: - (void)setLabelIsEditable:(BOOL)editable;	// 0x83a6d
// declared property setter: - (void)setTitle:(id)title;	// 0x839d5
- (BOOL)becomeFirstResponder;	// 0x839b1
- (BOOL)canBecomeFirstResponder;	// 0x8399d
- (void)_handleCloseBoxTap;	// 0x8397d
// declared property getter: - (CGPoint)closeBoxPosition;	// 0x83919
// declared property getter: - (BOOL)isCloseBoxShown;	// 0x83901
- (void)setShowCloseBox:(BOOL)box animated:(BOOL)animated;	// 0x834c1
// declared property setter: - (void)setShowCloseBox:(BOOL)box;	// 0x834ad
// declared property getter: - (id)badgeImage;	// 0x8349d
// declared property setter: - (void)setBadgeImage:(id)image;	// 0x833f9
// declared property getter: - (BOOL)isBadgeShown;	// 0x833e5
// declared property setter: - (void)setShowBadge:(BOOL)badge;	// 0x832ed
// declared property getter: - (id)imageView;	// 0x832cd
- (void)resetToInitialSizeAndAngle;	// 0x8327d
- (void)setSize:(CGSize)size angle:(float)angle;	// 0x83201
// declared property getter: - (unsigned)imageIndex;	// 0x831e9
// declared property setter: - (void)setImageIndex:(unsigned)index;	// 0x831d5
// declared property setter: - (void)setSourceView:(id)view;	// 0x83055
- (void)_positionBadgeView;	// 0x82e45
- (id)hitTest:(CGPoint)test withEvent:(id)event;	// 0x82de9
- (BOOL)pointIsInsideTitle:(CGPoint)title;	// 0x82d2d
- (void)dealloc;	// 0x82c65
- (id)initWithFrame:(CGRect)frame;	// 0x82b6d
@end
