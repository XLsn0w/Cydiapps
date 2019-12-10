/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/ChatKit.framework/ChatKit
 */

#import <ChatKit/ChatKit-Structs.h>


@protocol CKEntryField
@property(assign, nonatomic) int outgoingBubbleColor;
@property(assign) id entryFieldDelegate;	// converted property
@property(retain) id messageComposition;	// converted property
@property(retain) id messageParts;	// converted property
@property(assign) int cursorPosition;	// converted property
@property(retain) id subject;	// converted property
// converted property setter: - (void)setEntryFieldDelegate:(id)delegate;
// converted property getter: - (id)entryFieldDelegate;
- (void)clearMessage;
- (BOOL)hasContent;
- (id)attachments;
// converted property setter: - (void)setMessageComposition:(id)composition;
// converted property getter: - (id)messageComposition;
- (id)messageCompositionIfTextOnly;
// converted property setter: - (void)setMessageParts:(id)parts;
// converted property getter: - (id)messageParts;
- (void)insertMessagePart:(id)part;
- (CGPoint)contentOffset;
- (UIEdgeInsets)contentInset;
- (void)moveCursorToEnd;
// converted property setter: - (void)setCursorPosition:(int)position;
- (void)reflowContent;
- (void)reflowContentWithAnimation:(BOOL)animation;
// converted property getter: - (int)cursorPosition;
- (int)lastCursorPosition;
- (void)saveCursorPosition;
- (void)restoreCursorPosition;
- (void)makeActive;
- (BOOL)isActive;
- (void)disableEditing;
- (void)setIgnoreAnimations:(BOOL)animations;
// converted property getter: - (id)subject;
// converted property setter: - (void)setSubject:(id)subject;
- (void)setContentHidden:(BOOL)hidden subjectHidden:(BOOL)hidden2;
- (void)loadSubviews;
- (void)updateFontSize;
- (id)activeView;
- (void)setDefaultText:(id)text;
// declared property getter: - (int)outgoingBubbleColor;
// declared property setter: - (void)setOutgoingBubbleColor:(int)color;
@end
