/**
 * This header is generated by class-dump-z 0.2b.
 *
 * Source: /System/Library/PrivateFrameworks/iTunesStoreUI.framework/iTunesStoreUI
 */

#import <iTunesStoreUI/iTunesStoreUI-Structs.h>
#import <iTunesStoreUI/NSCopying.h>
#import <iTunesStoreUI/XXUnknownSuperclass.h>

@class NSString, SSURLRequestProperties;

@interface SUNavigationHistoryItem : XXUnknownSuperclass <NSCopying> {
	NSString *_title;	// 4 = 0x4
	SSURLRequestProperties *_urlRequestProperties;	// 8 = 0x8
}
@property(readonly, assign, nonatomic) SSURLRequestProperties *URLRequestProperties;	// G=0xa17b5; @synthesize=_urlRequestProperties
@property(readonly, assign, nonatomic) NSString *title;	// G=0xa17a5; @synthesize=_title
// declared property getter: - (id)URLRequestProperties;	// 0xa17b5
// declared property getter: - (id)title;	// 0xa17a5
- (id)newViewControllerInSection:(id)section;	// 0xa171d
- (id)copyWithZone:(NSZone *)zone;	// 0xa1689
- (void)dealloc;	// 0xa1629
- (id)initWithDictionary:(id)dictionary;	// 0xa14b5
- (id)init;	// 0xa14a1
@end
