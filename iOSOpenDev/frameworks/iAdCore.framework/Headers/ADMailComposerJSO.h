/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iAdCore.framework/iAdCore
 */

#import <iAdCore/MFMailComposeViewControllerDelegate.h>
#import <iAdCore/ADJavaScriptObject.h>
#import <iAdCore/iAdCore-Structs.h>

@class NSArray, WebScriptObject, NSString;
@protocol ADJSODelegate;

@interface ADMailComposerJSO : ADJavaScriptObject <MFMailComposeViewControllerDelegate> {
@private
	id<ADJSODelegate> _delegate;	// 4 = 0x4
	WebScriptObject *_listener;	// 8 = 0x8
	NSArray *_messageRecipients;	// 12 = 0xc
	NSString *_subject;	// 16 = 0x10
	NSString *_messageBody;	// 20 = 0x14
	NSArray *_attachmentDownloads;	// 24 = 0x18
	unsigned _attachmentDownloadCount;	// 28 = 0x1c
	BOOL _isHTML;	// 32 = 0x20
}
@property(assign) BOOL isHTML;	// G=0x3c451; S=0x3c461; @synthesize=_isHTML
@property(assign) unsigned attachmentDownloadCount;	// G=0x3c431; S=0x3c441; @synthesize=_attachmentDownloadCount
@property(retain, nonatomic) NSArray *attachmentDownloads;	// G=0x3c421; S=0x3b055; @synthesize=_attachmentDownloads
@property(retain, nonatomic) NSString *messageBody;	// G=0x3c3ed; S=0x3c3fd; @synthesize=_messageBody
@property(retain, nonatomic) NSString *subject;	// G=0x3c3dd; S=0x3aea9; @synthesize=_subject
@property(retain, nonatomic) NSArray *messageRecipients;	// G=0x3c3a9; S=0x3c3b9; @synthesize=_messageRecipients
@property(retain, nonatomic) WebScriptObject *listener;	// G=0x3c399; S=0x3abad; @synthesize=_listener
@property(assign, nonatomic) id<ADJSODelegate> delegate;	// G=0x3c379; S=0x3c389; @synthesize=_delegate
@property(retain) id toRecipients;	// G=0x3abf1; S=0x3ac01; converted property
+ (void)initializeInContext:(OpaqueJSContext *)context;	// 0x3c221
+ (id)scriptSelectors;	// 0x3aa99
+ (id)scriptingKeys;	// 0x3aa2d
// declared property setter: - (void)setIsHTML:(BOOL)html;	// 0x3c461
// declared property getter: - (BOOL)isHTML;	// 0x3c451
// declared property setter: - (void)setAttachmentDownloadCount:(unsigned)count;	// 0x3c441
// declared property getter: - (unsigned)attachmentDownloadCount;	// 0x3c431
// declared property getter: - (id)attachmentDownloads;	// 0x3c421
// declared property setter: - (void)setMessageBody:(id)body;	// 0x3c3fd
// declared property getter: - (id)messageBody;	// 0x3c3ed
// declared property getter: - (id)subject;	// 0x3c3dd
// declared property setter: - (void)setMessageRecipients:(id)recipients;	// 0x3c3b9
// declared property getter: - (id)messageRecipients;	// 0x3c3a9
// declared property getter: - (id)listener;	// 0x3c399
// declared property setter: - (void)setDelegate:(id)delegate;	// 0x3c389
// declared property getter: - (id)delegate;	// 0x3c379
- (void)mailComposeController:(id)controller didFinishWithResult:(int)result error:(id)error;	// 0x3c04d
- (void)send;	// 0x3bae5
- (void)reset;	// 0x3ba1d
- (void)setAttachments:(id)attachments;	// 0x3b21d
// declared property setter: - (void)setAttachmentDownloads:(id)downloads;	// 0x3b055
- (void)setMessageBody:(id)body isHTML:(BOOL)html;	// 0x3af71
// declared property setter: - (void)setSubject:(id)subject;	// 0x3aea9
// converted property setter: - (void)setToRecipients:(id)recipients;	// 0x3ac01
// converted property getter: - (id)toRecipients;	// 0x3abf1
// declared property setter: - (void)setListener:(id)listener;	// 0x3abad
- (id)init;	// 0x3ab0d
- (void)dealloc;	// 0x3a97d
@end
